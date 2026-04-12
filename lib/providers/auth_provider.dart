import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String get userName => _currentUser?.name ?? '';
  String get userPhone => _currentUser?.phone ?? '';
  String get userEmail => _currentUser?.email ?? '';
  UserRole? get userRole => _currentUser?.role;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
    } else {
      await _fetchUserData(firebaseUser.uid);
    }
    _isInitialized = true;
    notifyListeners();
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
          role: data['role'] == 'driver' ? UserRole.driver : UserRole.passenger,
          phone: data['phone'] ?? '',
          photoUrl: data['photoUrl'],
          carMake: data['carMake'] ?? '',
          carModel: data['carModel'] ?? '',
          carYear: data['carYear'] ?? '',
          carColor: data['carColor'] ?? '',
          plateNumber: data['plateNumber'] ?? '',
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
        final storedRole =
            doc.data()!['role'] == 'driver' ? UserRole.driver : UserRole.passenger;
        if (storedRole != expectedRole) {
          await _auth.signOut();
          final roleName = storedRole == UserRole.driver ? 'driver' : 'passenger';
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
      _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': role == UserRole.driver ? 'driver' : 'passenger',
        'phone': phone,
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      }).catchError((_) {});

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
        final storedRole =
            doc.data()!['role'] == 'driver' ? UserRole.driver : UserRole.passenger;
        if (storedRole != role) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          final roleName = storedRole == UserRole.driver ? 'driver' : 'passenger';
          return 'This Google account is already registered as a $roleName.';
        }
      } else {
        // New user — create Firestore record
        await _db.collection('users').doc(uid).set({
          'name': userCred.user!.displayName ?? '',
          'email': userCred.user!.email ?? '',
          'role': role == UserRole.driver ? 'driver' : 'passenger',
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

  Future<void> signOut() async {
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
      if (password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
      final uid = user.uid;
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
