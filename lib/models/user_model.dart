enum UserRole { driver, passenger }

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
  });

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
    );
  }
}
