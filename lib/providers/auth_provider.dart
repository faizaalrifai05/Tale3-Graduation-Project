import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/saved_account.dart';
import '../Services/FCM_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _prefsKey = 'saved_accounts';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  final bool _isLoading = false;
  bool _isInitialized = false;

  /// Accounts that have previously signed in on this device.
  List<SavedAccount> _savedAccounts = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get userName => _currentUser?.name ?? '';
  String get userPhone => _currentUser?.phone ?? '';
  String get userEmail => _currentUser?.email ?? '';
  UserRole? get userRole => _currentUser?.role;
  List<SavedAccount> get savedAccounts => List.unmodifiable(_savedAccounts);

  AuthProvider() {
    _loadSavedAccounts();
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ── Saved accounts (SharedPreferences) ──────────────────────────────────

  Future<void> _loadSavedAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefsKey) ?? [];
      _savedAccounts = raw
          .map(SavedAccount.tryDecode)
          .whereType<SavedAccount>()
          .toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persistAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _prefsKey,
        _savedAccounts.map((a) => jsonEncode(a.toJson())).toList(),
      );
    } catch (_) {}
  }

  /// Saves (or updates) the current user in the local account list.
  Future<void> _upsertSavedAccount(UserModel user) async {
    _savedAccounts.removeWhere((a) => a.uid == user.uid);
    _savedAccounts.insert(
      0,
      SavedAccount(
        uid: user.uid,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl ?? '',
        role: user.role == UserRole.driver ? 'driver' : 'passenger',
      ),
    );
    // Keep at most 5 accounts
    if (_savedAccounts.length > 5) _savedAccounts = _savedAccounts.sublist(0, 5);
    notifyListeners();
    await _persistAccounts();
  }

  /// Removes a specific account from the saved list (e.g. user removes it).
  Future<void> removeSavedAccount(String uid) async {
    _savedAccounts.removeWhere((a) => a.uid == uid);
    notifyListeners();
    await _persistAccounts();
  }

  // ────────────────────────────────────────────────────────────────────────

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _fetchUserData(firebaseUser.uid);
      FCMService.registerToken(firebaseUser.uid);
      // Save this account to the local history
      if (_currentUser != null) await _upsertSavedAccount(_currentUser!);
    }
    _isInitialized = true;
    notifyListeners();
  }

  VerificationStatus _verificationStatusFromString(String? value) {
    switch (value) {
      case 'pending':
        return VerificationStatus.pending;
      case 'verified':
        return VerificationStatus.verified;
      case 'rejected':
        return VerificationStatus.rejected;
      default:
        return VerificationStatus.unsubmitted;
    }
  }

  UserRole _roleFromString(String? value) {
    switch (value) {
      case 'driver':
        return UserRole.driver;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.passenger;
    }
  }

  String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.driver:
        return 'driver';
      case UserRole.admin:
        return 'admin';
      case UserRole.passenger:
        return 'passenger';
    }
  }

  Future<void> _fetchUserData(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = UserModel(
          uid: uid,
          name: data['name'] ?? '',
          email: data['email'] ?? '',
          role: _roleFromString(data['role'] as String?),
          phone: data['phone'] ?? '',
          photoUrl: data['photoUrl'],
          carMake: data['carMake'] ?? '',
          carModel: data['carModel'] ?? '',
          carYear: data['carYear'] ?? '',
          carColor: data['carColor'] ?? '',
          plateNumber: data['plateNumber'] ?? '',
          verificationStatus: _verificationStatusFromString(
              data['verificationStatus'] as String?),
          idFrontUrl: data['idFrontUrl'] ?? '',
          idBackUrl: data['idBackUrl'] ?? '',
        );
      }
    } catch (_) {}
  }

  /// Sign in with email and password. Returns null on success, error message on failure.
  /// [expectedRole] is checked against the stored role to prevent cross-role login.
  Future<String?> signInWithEmail(
    String email,
    String password,
    UserRole expectedRole,
  ) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        final storedRole = _roleFromString(doc.data()!['role'] as String?);
        if (storedRole != expectedRole) {
          await _auth.signOut();
          final roleName = _roleToString(storedRole);
          return 'This account is registered as a $roleName. Please use the correct login screen.';
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Register a new user with email and password.
  /// Returns null on success, error message on failure.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String phone = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      // Set current user immediately so navigation isn't blocked by Firestore
      _currentUser = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
      );
      notifyListeners();

      // Write to Firestore in the background — don't await it
     try {
       await _db.collection('users').doc(cred.user!.uid).set({
       'name': name,
       'email': email,
       'role': _roleToString(role),
       'phone': phone,
       'photoUrl': '',
       'verificationStatus': 'unsubmitted',
       'idFrontUrl': '',
       'idBackUrl': '',
       'createdAt': FieldValue.serverTimestamp(),
        });
       debugPrint('✅ Firestore write SUCCESS');
       } catch (e) {
         debugPrint('❌ Firestore write FAILED: $e');
         }

     return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Sign in with Google. [role] sets the role for first-time users.
  /// Returns null on success, error message on failure.
  Future<String?> signInWithGoogle(UserRole role) async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Sign-in cancelled.';

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);
      final uid = userCred.user!.uid;

      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        // Existing user — check role matches
        final storedRole = _roleFromString(doc.data()!['role'] as String?);
        if (storedRole != role) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          final roleName = _roleToString(storedRole);
          return 'This Google account is already registered as a $roleName.';
        }
      } else {
        // New user — create Firestore record
        await _db.collection('users').doc(uid).set({
          'name': userCred.user!.displayName ?? '',
          'email': userCred.user!.email ?? '',
          'role': _roleToString(role),
          'phone': '',
          'photoUrl': userCred.user!.photoURL ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (_) {
      return 'Google Sign-In failed. Please try again.';
    }
  }

  /// Uploads front and back ID images to Firebase Storage and sets
  /// [verificationStatus] to [VerificationStatus.pending] in Firestore.
  /// Returns null on success, or an error message on failure.
  Future<String?> submitIdVerification({
    required File frontImage,
    required File backImage,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not logged in.';
    try {
      final storage = FirebaseStorage.instance;
      final frontRef = storage.ref('id_images/$uid/front.jpg');
      final backRef = storage.ref('id_images/$uid/back.jpg');

      await frontRef.putFile(frontImage);
      await backRef.putFile(backImage);

      final frontUrl = await frontRef.getDownloadURL();
      final backUrl = await backRef.getDownloadURL();

      await _db.collection('users').doc(uid).update({
        'verificationStatus': 'pending',
        'idFrontUrl': frontUrl,
        'idBackUrl': backUrl,
      });

      _currentUser = _currentUser?.copyWith(
        verificationStatus: VerificationStatus.pending,
        idFrontUrl: frontUrl,
        idBackUrl: backUrl,
      );
      notifyListeners();
      return null;
    } catch (_) {
      return 'Failed to upload ID. Please try again.';
    }
  }

  Future<void> signOut() async {
    if (_currentUser != null) {
      await FCMService.unregisterToken(_currentUser!.uid); // remove token on logout
    }
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Updates the user's name and phone locally and in Firestore.
  Future<void> updateProfile({required String name, required String phone}) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(name: name, phone: phone);
    notifyListeners();
    _db.collection('users').doc(_currentUser!.uid).update({
      'name': name,
      'phone': phone,
    }).catchError((_) {});
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// Saves vehicle details to Firestore and updates local state.
  Future<void> saveVehicleDetails({
    required String make,
    required String model,
    required String year,
    required String color,
    required String plateNumber,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      carMake: make,
      carModel: model,
      carYear: year,
      carColor: color,
      plateNumber: plateNumber,
    );
    notifyListeners();
    _db.collection('users').doc(_currentUser!.uid).update({
      'carMake': make,
      'carModel': model,
      'carYear': year,
      'carColor': color,
      'plateNumber': plateNumber,
    }).catchError((_) {});
  }

  /// Changes the user's password. Requires their current password to reauthenticate.
  /// Returns null on success, error message on failure.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return 'Not logged in.';
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Current password is incorrect.';
      }
      return _friendlyError(e.code);
    }
  }

  /// Permanently deletes the account from Firebase Auth and Firestore.
  /// Returns null on success, error message on failure.
  Future<String?> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';
    try {
      // Reauthenticate for email/password users
      final isEmailUser = user.providerData.any((p) => p.providerId == 'password');
      if (isEmailUser) {
        if (password == null || password.isEmpty) {
          return 'Password is required to delete your account.';
        }
        if (user.email != null) {
          final credential = EmailAuthProvider.credential(
            email: user.email!,
            password: password,
          );
          await user.reauthenticateWithCredential(credential);
        }
      }

      final uid = user.uid;
      final docRef = _db.collection('users').doc(uid);
      final docSnapshot = await docRef.get();
      final docData = docSnapshot.data();

      // Temporarily delete the firestore document
      await docRef.delete();

      try {
        await user.delete();
      } catch (e) {
        // If auth deletion fails, restore the firestore document!
        if (docData != null) {
          await docRef.set(docData);
        }
        rethrow;
      }

      _currentUser = null;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please log out and log back in before deleting your account.';
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect password.';
      }
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Alias for [signOut] — kept for backwards compatibility.
  Future<void> logout() => signOut();

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 8 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
