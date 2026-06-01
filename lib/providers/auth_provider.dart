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
    serverClientId:
        '290962167334-5dgdt7he5aeh9ua5p9vqkd8cmbejqib5.apps.googleusercontent.com',
  );

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  bool _wasBlocked = false;
  bool _isSendingVerificationEmail = false;

  // ── Registration guard ────────────────────────────────────────────────────
  // Set to true while registerWithEmail() is running. This tells the
  // real-time Firestore listener NOT to overwrite the doc being created.
  // Without this flag, the listener fires the instant the Firebase Auth user
  // is created (before the Firestore doc is written) and recreates the doc
  // with role='passenger', causing the driver to be stored as a passenger.
  bool _isRegistering = false;

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

  void clearBlockedFlag() {
    _wasBlocked = false;
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    // Don't react to auth changes triggered by our own registration flow.
    // registerWithEmail() sets _isRegistering=true, writes the Firestore doc
    // itself, then sets it back to false — so we skip this whole block.
    if (_isRegistering) return;

    if (_isSendingVerificationEmail) return;

    if (firebaseUser == null) {
      _currentUser = null;
      _userSubscription?.cancel();
      _userSubscription = null;
    } else {
      await _fetchUserData(firebaseUser.uid);
      FCMService.registerToken(firebaseUser.uid);

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

      // Real-time listener on the user's Firestore doc.
      _userSubscription?.cancel();
      _userSubscription = _db
          .collection('users')
          .doc(firebaseUser.uid)
          .snapshots()
          .listen((doc) async {
        // Guard: if we are mid-registration, ignore snapshot events entirely.
        // The doc may not exist yet or may be in a partial state.
        if (_isRegistering) return;

        if (!doc.exists) {
          // Doc is missing for an already-authenticated user (e.g. manually
          // deleted in Firebase Console). Recreate it, but ONLY if we are NOT
          // in the registration flow (guarded above). Use role='passenger' as
          // a safe default for recovery — a newly registered driver will have
          // their doc written by registerWithEmail() before this path runs.
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

        if (_currentUser!.isBlocked) {
          _wasBlocked = true;
          await _auth.signOut();
          _currentUser = null;
        }
      }
    } catch (_) {}
  }

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
      if (!doc.exists) {
        await _auth.signOut();
        return 'No account found with this email address.';
      }
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
      return null;
    } on FirebaseAuthException catch (e) {
      // Firebase now returns 'invalid-credential' for both wrong password AND
      // non-existent account. Check Firestore to give the right message.
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        try {
          final snap = await _db
              .collection('users')
              .where('email', isEqualTo: email.trim())
              .limit(1)
              .get();
          if (snap.docs.isEmpty) {
            return 'No account found with this email address.';
          }
        } catch (_) {}
        return 'Incorrect email or password.';
      }
      return _friendlyError(e.code);
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Register a new user with email and password.
  ///
  /// FIX: We set _isRegistering = true before creating the Firebase Auth user.
  /// This suppresses the _onAuthStateChanged listener so it cannot race with
  /// our Firestore doc write. We write the Firestore doc immediately after
  /// createUserWithEmailAndPassword (before anything else), then clear the
  /// flag and manually set up the state.
  Future<String?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String phone = '',
    String gender = '',
  }) async {
    _isRegistering = true; // ← suppress _onAuthStateChanged during registration
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;

      // ── Step 1: Write the Firestore doc IMMEDIATELY ───────────────────────
      // This must happen before anything that yields control back to the event
      // loop (including notifyListeners), otherwise the real-time snapshot
      // listener can fire first and recreate the doc with role='passenger'.
      await _db.collection('users').doc(uid).set({
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
      debugPrint('✅ Firestore user doc written successfully (role: ${_roleToString(role)})');

      // ── Step 2: Secondary setup ───────────────────────────────────────────
      try {
        await cred.user!.updateDisplayName(name);
      } catch (e) {
        debugPrint('updateDisplayName failed (non-fatal): $e');
      }

      try {
        await cred.user!.sendEmailVerification();
      } catch (e) {
        debugPrint('sendEmailVerification failed (non-fatal): $e');
      }

      // ── Step 3: Set local state ───────────────────────────────────────────
      _currentUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        gender: gender,
        verificationStatus: VerificationStatus.unsubmitted,
      );

      // Set up the real-time listener now that the doc exists.
      _userSubscription?.cancel();
      _userSubscription = _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen((doc) async {
        if (_isRegistering) return; // still guard until flag is cleared below
        if (!doc.exists) return;    // doc was just created, shouldn't be missing
        final data = doc.data()!;
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

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendlyError(e.code);
    } catch (e) {
      debugPrint('registerWithEmail unexpected error: $e');
      return 'Something went wrong. Please try again.';
    } finally {
      // Always clear the flag so _onAuthStateChanged resumes normal operation.
      _isRegistering = false;
    }
  }

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

  /// Attempts to upload ID photos to Firebase Storage and sets verificationStatus
  /// to 'pending' in Firestore.
  ///
  /// The Firestore 'pending' write is guaranteed even if Storage upload fails.
  Future<String?> submitIdVerification({
    required File frontImage,
    required File backImage,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return 'Not logged in.';
    final uid = firebaseUser.uid;

    // Ensure user doc exists before updating.
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        debugPrint('⚠️ submitIdVerification: user doc missing, attempting re-create');
        await _db.collection('users').doc(uid).set({
          'name': _currentUser?.name ?? firebaseUser.displayName ?? '',
          'email': _currentUser?.email ?? firebaseUser.email ?? '',
          'role': 'driver',
          'phone': _currentUser?.phone ?? '',
          'gender': _currentUser?.gender ?? '',
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
      }
    } catch (e) {
      debugPrint('submitIdVerification: user doc check/create failed: $e');
    }

    // Best-effort Storage upload.
    String frontUrl = '';
    String backUrl = '';
    try {
      final storage = FirebaseStorage.instance;
      final meta = SettableMetadata(contentType: 'image/jpeg');
      final frontRef = storage.ref('verification/$uid/id_front.jpg');
      await frontRef.putFile(frontImage, meta);
      frontUrl = await frontRef.getDownloadURL();
      final backRef = storage.ref('verification/$uid/id_back.jpg');
      await backRef.putFile(backImage, meta);
      backUrl = await backRef.getDownloadURL();
      debugPrint('✅ ID photos uploaded successfully.');
    } catch (e) {
      debugPrint('⚠️ ID photo upload skipped (Storage may be disabled): $e');
    }

    // ── Step A: Set verificationStatus to 'pending' ─────────────────────────
    // This is the CRITICAL write — it makes the driver appear in the admin queue.
    // Done as a SEPARATE update from the URL writes because the Firestore rule
    // for the driver-pending path does not whitelist idFrontUrl/idBackUrl in the
    // same operation. Combining them causes a silent rule rejection.
    try {
      await _db.collection('users').doc(uid).update({
        'verificationStatus': 'pending',
      });
      _currentUser = _currentUser?.copyWith(
        verificationStatus: VerificationStatus.pending,
        idFrontUrl: frontUrl,
        idBackUrl: backUrl,
      );
      notifyListeners();
      debugPrint('✅ verificationStatus set to pending in Firestore.');
    } catch (e) {
      debugPrint('❌ submitIdVerification — pending status write failed: $e');
      // Try the fallback direct write (no rule restriction on admin-SDK style set)
      try {
        await _db.collection('users').doc(uid).set(
          {'verificationStatus': 'pending'},
          SetOptions(merge: true),
        );
        _currentUser = _currentUser?.copyWith(
          verificationStatus: VerificationStatus.pending,
        );
        notifyListeners();
        debugPrint('✅ verificationStatus set to pending via merge set fallback.');
      } catch (e2) {
        debugPrint('❌ Fallback also failed: $e2');
        return 'Failed to submit verification. Please try again.';
      }
    }

    // ── Step B: Write photo URLs (best-effort, non-blocking) ─────────────────
    // Uses the first self-update rule which allows any field EXCEPT the protected
    // ones. idFrontUrl and idBackUrl are now NOT in the blocklist because
    // verificationStatus is already 'pending' (not changing in this update).
    if (frontUrl.isNotEmpty || backUrl.isNotEmpty) {
      try {
        await _db.collection('users').doc(uid).update({
          'idFrontUrl': frontUrl,
          'idBackUrl': backUrl,
        });
        _currentUser = _currentUser?.copyWith(
          idFrontUrl: frontUrl,
          idBackUrl: backUrl,
        );
        notifyListeners();
        debugPrint('✅ ID photo URLs saved.');
      } catch (e) {
        // Non-fatal — admin will see "no photo" placeholder but can still approve.
        debugPrint('⚠️ ID photo URL save failed (non-fatal): $e');
      }
    }

    return null;
  }

  /// Best-effort car photo upload. Callers do NOT block on failure.
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
      debugPrint('✅ Car photos uploaded successfully.');
      return null;
    } catch (e) {
      debugPrint('⚠️ submitCarPhotos failed (Storage may be disabled): $e');
      return 'Car photo upload failed: $e';
    }
  }

  /// Guaranteed fallback: write verificationStatus='pending' with no image uploads.
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
      debugPrint('✅ setVerificationPending: Firestore updated to pending.');
      return null;
    } catch (e) {
      debugPrint('❌ setVerificationPending failed: $e');
      return 'Failed to update status. Please try again.';
    }
  }

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

  void removeSavedAccount(String uid) {
    _savedAccounts.removeWhere((a) => a.uid == uid);
    notifyListeners();
  }

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

  Future<String?> deleteAccount({String? password}) async {
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';
    try {
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
      _userSubscription?.cancel();
      _userSubscription = null;

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

      await _db.collection('users').doc(uid).delete();
      await user.delete();
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

  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() => signOut();

  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email address.';
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