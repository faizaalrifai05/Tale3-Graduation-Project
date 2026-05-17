enum UserRole { driver, passenger, admin }

enum VerificationStatus { unsubmitted, pending, verified, rejected }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String? photoUrl;
  // Driver vehicle fields
  final String carMake;
  final String carModel;
  final String carYear;
  final String carColor;
  final String plateNumber;
  // Driver ID verification
  final VerificationStatus verificationStatus;
  final String idFrontUrl;
  final String idBackUrl;
  final bool isBlocked;
  // Driver rating
  final double averageRating;
  final int ratingCount;
  // Gender
  final String gender;
  // Account creation date
  final DateTime? createdAt;
  // Credit card (driver only — for platform revenue collection)
  final String creditCardNumber;
  final String creditCardHolder;
  final String creditCardExpiry;
  final String creditCardCvc;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.photoUrl,
    this.carMake = '',
    this.carModel = '',
    this.carYear = '',
    this.carColor = '',
    this.plateNumber = '',
    this.verificationStatus = VerificationStatus.unsubmitted,
    this.idFrontUrl = '',
    this.idBackUrl = '',
    this.isBlocked = false,
    this.averageRating = 0.0,
    this.ratingCount = 0,
    this.gender = '',
    this.createdAt,
    this.creditCardNumber = '',
    this.creditCardHolder = '',
    this.creditCardExpiry = '',
    this.creditCardCvc = '',
  });

  bool get isVerified => verificationStatus == VerificationStatus.verified;

  /// How many full years since account was created.
  /// Returns 0 if createdAt is null (brand new account).
  int get yearsOnPlatform {
    if (createdAt == null) return 0;
    final now = DateTime.now();
    int years = now.year - createdAt!.year;
    if (now.month < createdAt!.month ||
        (now.month == createdAt!.month && now.day < createdAt!.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? photoUrl,
    String? carMake,
    String? carModel,
    String? carYear,
    String? carColor,
    String? plateNumber,
    VerificationStatus? verificationStatus,
    String? idFrontUrl,
    String? idBackUrl,
    bool? isBlocked,
    double? averageRating,
    int? ratingCount,
    String? gender,
    DateTime? createdAt,
    String? creditCardNumber,
    String? creditCardHolder,
    String? creditCardExpiry,
    String? creditCardCvc,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      carMake: carMake ?? this.carMake,
      carModel: carModel ?? this.carModel,
      carYear: carYear ?? this.carYear,
      carColor: carColor ?? this.carColor,
      plateNumber: plateNumber ?? this.plateNumber,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idFrontUrl: idFrontUrl ?? this.idFrontUrl,
      idBackUrl: idBackUrl ?? this.idBackUrl,
      isBlocked: isBlocked ?? this.isBlocked,
      averageRating: averageRating ?? this.averageRating,
      ratingCount: ratingCount ?? this.ratingCount,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      creditCardNumber: creditCardNumber ?? this.creditCardNumber,
      creditCardHolder: creditCardHolder ?? this.creditCardHolder,
      creditCardExpiry: creditCardExpiry ?? this.creditCardExpiry,
      creditCardCvc: creditCardCvc ?? this.creditCardCvc,
    );
  }
}