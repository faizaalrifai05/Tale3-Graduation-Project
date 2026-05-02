import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/saved_account.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _wasBlocked = false;
  final List<SavedAccount> _savedAccounts = [];
  StreamSubscription? _userSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get wasBlocked => _wasBlocked;
  String get userName => _currentUser?.name ?? '';
  String get userPhone => _currentUser?.phone ?? '';
  String get userEmail => _currentUser?.email ?? '';
  UserRole? get userRole => _currentUser?.role;
  List<SavedAccount> get savedAccounts => List.unmodifiable(_savedAccounts);

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  /// Clears the blocked flag after the UI has shown the blocked dialog.
  void clearBlockedFlag() {
    _wasBlocked = false;
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _userSubscription?.cancel();
      _userSubscription = null;
    } else {
      await _fetchUserData(firebaseUser.uid);

      // Save to saved accounts list if not already there
      if (_currentUser != null) {
        final exists = _savedAccounts.any((a) => a.uid == _currentUser!.uid);
        if (!exists) {
          _savedAccounts.add(SavedAccount(
            uid: _currentUser!.uid,
            name: _currentUser!.name,
            email: _currentUser!.email,
            photoUrl: _currentUser!.photoUrl ?? '',
            role: _roleToString(_currentUser!.role),
          ));
        }
      }

      // 🔴 Listen to user document in real-time
      // Handles: block while in app, verification approval, profile changes
      _userSubscription?.cancel();
      _userSubscription = _db
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((doc) async {
        if (!doc.exists) return;
        final data = doc.data()!;
        final blocked = data['isBlocked'] as bool? ?? false;

        if (blocked) {
          // User got blocked while inside the app — sign out immediately
          _wasBlocked = true;
          await _auth.signOut();
          _currentUser = null;
          notifyListeners();
          return;
        }

        // Update local user data with latest Firestore data in real-time
        _currentUser = UserModel(
          uid: doc.id,
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
          isBlocked: false,
        );
        notifyListeners();
      });
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
          isBlocked: data['isBlocked'] as bool? ?? false,
        );

        // Block check on initial fetch
        if (_currentUser!.isBlocked) {
          _wasBlocked = true;
          await _auth.signOut();
          _currentUser = null;
        }
      }
    } catch (_) {}
  }

  /// Sign in with email and password.
  /// Returns null on success, error message on failure.
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
        // Check if blocked
        final blocked = doc.data()!['isBlocked'] as bool? ?? false;
        if (blocked) {
          await _auth.signOut();
          return 'Your account has been blocked. Please contact support.';
        }

        // Check role matches
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

      // Set current user immediately so navigation isn't blocked
      _currentUser = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        role: role,
      );
      notifyListeners();

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
          'isBlocked': false,
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

  /// Sign in with Google.
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
        // Check if blocked
        final blocked = doc.data()!['isBlocked'] as bool? ?? false;
        if (blocked) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          return 'Your account has been blocked. Please contact support.';
        }

        // Check role matches
        final storedRole = _roleFromString(doc.data()!['role'] as String?);
        if (storedRole != role) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          final roleName = _roleToString(storedRole);
          return 'This Google account is already registered as a $roleName.';
        }
      } else {
        // New Google user — create Firestore record
        await _db.collection('users').doc(uid).set({
          'name': userCred.user!.displayName ?? '',
          'email': userCred.user!.email ?? '',
          'role': _roleToString(role),
          'phone': '',
          'photoUrl': userCred.user!.photoURL ?? '',
          'verificationStatus': 'unsubmitted',
          'idFrontUrl': '',
          'idBackUrl': '',
          'isBlocked': false,
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

  /// Sets verificationStatus to pending in Firestore without uploading images.
  /// Firebase Storage is not required — driver appears in admin verification
  /// queue immediately after submitting.
  /// Returns null on success, error message on failure.
  Future<String?> submitIdVerification({
    required dynamic frontImage,
    required dynamic backImage,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not logged in.';
    try {
      await _db.collection('users').doc(uid).update({
        'verificationStatus': 'pending',
        'idFrontUrl': '',
        'idBackUrl': '',
      });

      _currentUser = _currentUser?.copyWith(
        verificationStatus: VerificationStatus.pending,
      );
      notifyListeners();
      return null;
    } catch (_) {
      return 'Failed to submit verification. Please try again.';
    }
  }

  /// Signs out the current user and cancels the real-time listener.
  Future<void> signOut() async {
    _userSubscription?.cancel();
    _userSubscription = null;
    await _googleSignIn.signOut();
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Removes a saved account from the local list.
  void removeSavedAccount(String uid) {
    _savedAccounts.removeWhere((a) => a.uid == uid);
    notifyListeners();
  }

  /// Updates the user's name and phone locally and in Firestore.
  Future<void> updateProfile({
    required String name,
    required String phone,
  }) async {
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

  /// Changes the user's password. Requires current password to reauthenticate.
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
      if (password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
      final uid = user.uid;
      _userSubscription?.cancel();
      _userSubscription = null;
      await _db.collection('users').doc(uid).delete();
      await user.delete();
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

  /// Alias for signOut — kept for backwards compatibility.
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