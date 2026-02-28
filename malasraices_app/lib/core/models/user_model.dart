import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImageUrl,
  });

  final String id;
  final String email;
  final String role;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImageUrl;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'role': role,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'profileImageUrl': profileImageUrl,
      };

  String get fullName => '$firstName $lastName';

  bool get isOwner => role == 'OWNER';
  bool get isTenant => role == 'TENANT';

  @override
  List<Object?> get props => [id, email, role, firstName, lastName];
}
