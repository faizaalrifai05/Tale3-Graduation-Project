import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../models/saved_account.dart';
import '../Services/FCM_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Required on Android (google_sign_in v6+) to get an idToken back,
    // which Firebase Auth needs. Use the web client ID from google-services.json.
    serverClientId:
        '290962167334-5dgdt7he5aeh9ua5p9vqkd8cmbejqib5.apps.googleusercontent.com',
  );

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _wasBlocked = false;
  bool _isSendingVerificationEmail = false;
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
    if (_isSendingVerificationEmail) return;
    if (firebaseUser == null) {
      _currentUser = null;
      _userSubscription?.cancel();
      _userSubscription = null;
    } else {
      await _fetchUserData(firebaseUser.uid);
      FCMService.registerToken(firebaseUser.uid);

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

      // Listen to user document in real-time
      _userSubscription?.cancel();
      _userSubscription = _db
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((doc) async {
        if (!doc.exists) {
          // User document missing — recreate it from Firebase Auth info so the
          // app doesn't end up in a broken state (e.g. after manual deletion).
          try {
            await _db.collection('users').doc(firebaseUser.uid).set({
              'name': firebaseUser.displayName ?? '',
              'email': firebaseUser.email ?? '',
              'role': 'passenger',
              'phone': '',
              'gender': '',
              'photoUrl': firebaseUser.photoURL ?? '',
              'verificationStatus': 'unsubmitted',
              'idFrontUrl': '',
              'idBackUrl': '',
              'carFrontUrl': '',
              'carBackUrl': '',
              'isBlocked': false,
              'averageRating': 0.0,
              'ratingCount': 0,
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('auth_provider: failed to recreate user doc: $e');
          }
          return;
        }
        final data = doc.data()!;
        final blocked = data['isBlocked'] as bool? ?? false;

        if (blocked) {
          _wasBlocked = true;
          await _auth.signOut();
          _currentUser = null;
          notifyListeners();
          return;
        }

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
          carFrontUrl: data['carFrontUrl'] ?? '',
          carBackUrl: data['carBackUrl'] ?? '',
          isBlocked: false,
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          gender: data['gender'] as String? ?? '',
          creditCardNumber: data['creditCardNumber'] as String? ?? '',
          creditCardHolder: data['creditCardHolder'] as String? ?? '',
          creditCardExpiry: data['creditCardExpiry'] as String? ?? '',
          creditCardCvc: data['creditCardCvc'] as String? ?? '',
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
          averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
          ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
          createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
          gender: data['gender'] as String? ?? '',
          creditCardNumber: data['creditCardNumber'] as String? ?? '',
          creditCardHolder: data['creditCardHolder'] as String? ?? '',
          creditCardExpiry: data['creditCardExpiry'] as String? ?? '',
          creditCardCvc: data['creditCardCvc'] as String? ?? '',
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

      if (!cred.user!.emailVerified) {
        await _auth.signOut();
        return 'email_not_verified';
      }

      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (doc.exists) {
        final blocked = doc.data()!['isBlocked'] as bool? ?? false;
        if (blocked) {
          await _auth.signOut();
          return 'Your account has been blocked. Please contact support.';
        }

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
    String gender = '',
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);

      try {
        await cred.user!.sendEmailVerification();
      } catch (_) {}

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
          'gender': gender,
          'photoUrl': '',
          'verificationStatus': 'unsubmitted',
          'idFrontUrl': '',
          'idBackUrl': '',
          'carFrontUrl': '',
          'carBackUrl': '',
          'isBlocked': false,
          'averageRating': 0.0,
          'ratingCount': 0,
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
      await _googleSignIn.signOut();
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
        final blocked = doc.data()!['isBlocked'] as bool? ?? false;
        if (blocked) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          return 'Your account has been blocked. Please contact support.';
        }

        final storedRole = _roleFromString(doc.data()!['role'] as String?);
        if (storedRole != role) {
          await _auth.signOut();
          await _googleSignIn.signOut();
          final roleName = _roleToString(storedRole);
          return 'This Google account is already registered as a $roleName.';
        }
      } else {
        await _db.collection('users').doc(uid).set({
          'name': userCred.user!.displayName ?? '',
          'email': userCred.user!.email ?? '',
          'role': _roleToString(role),
          'phone': '',
          'gender': '',
          'photoUrl': userCred.user!.photoURL ?? '',
          'verificationStatus': 'unsubmitted',
          'idFrontUrl': '',
          'idBackUrl': '',
          'carFrontUrl': '',
          'carBackUrl': '',
          'isBlocked': false,
          'averageRating': 0.0,
          'ratingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('10:') || msg.contains('12500') || msg.contains('DEVELOPER_ERROR')) {
        return 'Google Sign-In is not configured for this device. Please contact support.';
      }
      debugPrint('Google Sign-In error: $e');
      return 'Google Sign-In failed. Please try again.';
    }
  }

  /// Sets verificationStatus to pending in Firestore without uploading images.
  Future<String?> submitIdVerification({
    required File frontImage,
    required File backImage,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Not logged in.';
    final uid = firebaseUser.uid;
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        await _db.collection('users').doc(uid).set({
          'name': _currentUser?.name ?? firebaseUser.displayName ?? '',
          'email': _currentUser?.email ?? firebaseUser.email ?? '',
          'role': 'driver',
          'phone': _currentUser?.phone ?? '',
          'photoUrl': '',
          'verificationStatus': 'unsubmitted',
          'idFrontUrl': '',
          'idBackUrl': '',
          'isBlocked': false,
          'averageRating': 0.0,
          'ratingCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

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
    } catch (e) {
      debugPrint('submitIdVerification error: $e');
      return 'Failed to submit verification. Please try again.';
    }
  }

  /// Uploads car photos to Firebase Storage and saves download URLs to Firestore.
  Future<String?> submitCarPhotos({
    required File frontImage,
    required File backImage,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Not logged in.';
    final uid = firebaseUser.uid;
    try {
      final storage = FirebaseStorage.instance;
      final meta = SettableMetadata(contentType: 'image/jpeg');

      final frontRef = storage.ref('verification/$uid/car_front.jpg');
      await frontRef.putFile(frontImage, meta);
      final frontUrl = await frontRef.getDownloadURL();

      final backRef = storage.ref('verification/$uid/car_back.jpg');
      await backRef.putFile(backImage, meta);
      final backUrl = await backRef.getDownloadURL();

      await _db.collection('users').doc(uid).update({
        'carFrontUrl': frontUrl,
        'carBackUrl': backUrl,
      });
      _currentUser = _currentUser?.copyWith(
        carFrontUrl: frontUrl,
        carBackUrl: backUrl,
      );
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('submitCarPhotos error: $e');
      return 'Upload failed: $e';
    }
  }

  /// Sets verificationStatus to pending without requiring image files.
  /// Used for the registration resume flow when image files are no longer in memory.
  Future<String?> setVerificationPending() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Not logged in.';
    try {
      await _db.collection('users').doc(firebaseUser.uid).update({
        'verificationStatus': 'pending',
      });
      _currentUser = _currentUser?.copyWith(
        verificationStatus: VerificationStatus.pending,
      );
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('setVerificationPending error: $e');
      return 'Failed to update status. Please try again.';
    }
  }

  /// Signs out the current user and cancels the real-time listener.
  Future<void> signOut() async {
    final uid = _currentUser?.uid;
    _userSubscription?.cancel();
    _userSubscription = null;
    if (uid != null) await FCMService.unregisterToken(uid);
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

  /// Saves credit card details to Firestore (driver only).
  Future<void> saveCreditCard({
    required String cardNumber,
    required String cardHolder,
    required String expiry,
    String cvc = '',
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      creditCardNumber: cardNumber,
      creditCardHolder: cardHolder,
      creditCardExpiry: expiry,
      creditCardCvc: cvc,
    );
    notifyListeners();
    _db.collection('users').doc(_currentUser!.uid).update({
      'creditCardNumber': cardNumber,
      'creditCardHolder': cardHolder,
      'creditCardExpiry': expiry,
      'creditCardCvc': cvc,
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
      // Re-authenticate — required by Firebase before sensitive operations.
      final isGoogleUser = user.providerData
          .any((p) => p.providerId == 'google.com');

      if (isGoogleUser) {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return 'Google sign-in cancelled.';
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await user.reauthenticateWithCredential(credential);
      } else if (password != null && password.isNotEmpty && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      final uid = user.uid;

      // Stop listening to the user document before we delete it.
      _userSubscription?.cancel();
      _userSubscription = null;

      // Delete savedPlaces subcollection first (Firestore doesn't cascade).
      final placesSnap = await _db
          .collection('users')
          .doc(uid)
          .collection('savedPlaces')
          .get();
      if (placesSnap.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in placesSnap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }

      // Delete the user Firestore document.
      await _db.collection('users').doc(uid).delete();

      // Delete the Firebase Auth account — frees the email for re-registration.
      await user.delete();

      // Clean up Google session if applicable.
      await _googleSignIn.signOut();

      _currentUser = null;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'Please enter your password to confirm account deletion.';
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect password. Please try again.';
      }
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Returns true if the email is already registered, false if not.
  Future<bool?> checkEmailInUse(String email) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: '\x00__invalid_check__',
      );
      await _auth.signOut();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-password':
          return true;
        case 'user-not-found':
          return false;
        case 'invalid-credential':
          return null;
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Sends or resends the email verification link.
  Future<String?> sendVerificationEmail({String? email, String? password}) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.sendEmailVerification();
        return null;
      }

      if (email == null || password == null) {
        return 'Could not send verification email. Please try again later.';
      }

      _isSendingVerificationEmail = true;
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        await cred.user!.sendEmailVerification();
      } finally {
        await _auth.signOut();
        _isSendingVerificationEmail = false;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      _isSendingVerificationEmail = false;
      if (e.code == 'too-many-requests') {
        return 'Too many attempts. Please wait a few minutes before trying again.';
      }
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Incorrect password. Could not resend verification email.';
      }
      return 'Could not send verification email. Please try again later.';
    } catch (_) {
      _isSendingVerificationEmail = false;
      return 'Could not send verification email. Please try again later.';
    }
  }

  /// Reloads the Firebase Auth user and returns whether the email is verified.
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
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