

import 'package:crm_app_dv/core/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String email,
    required String name,
    required String lastName,
    required String dni,
    required String role,
  }) : super(
          id: id,
          email: email,
          name: name,
          lastName: lastName,
          dni: dni,
          role: role,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      email: json['email'],
      name: json['name'],
      lastName: json['lastName'],
      dni: json['dni'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'lastName': lastName,
      'dni': dni,
      'role': role,
    };
  }
}
