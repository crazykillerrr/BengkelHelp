import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime? birthDate;
  final String photoUrl;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.birthDate,
    required this.photoUrl,
    required this.role,
  });

  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: 'User',
      email: '',
      phone: '',
      birthDate: null,
      photoUrl: 'https://i.imgur.com/BoN9kdC.png',
      role: 'User',
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? photoUrl,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}

class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel.empty();
  bool _isLoggedIn = false;

  UserModel get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  // Login sederhana (mock)
  void login(UserModel data) {
    _user = data;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Update profil user
  void updateUser({
    String? name,
    String? email,
    String? phone,
    DateTime? birthDate,
    String? photoUrl,
  }) {
    _user = _user.copyWith(
      name: name,
      email: email,
      phone: phone,
      birthDate: birthDate,
      photoUrl: photoUrl,
    );
    notifyListeners();
  }

  // Logout
  void logout() {
    _user = UserModel.empty();
    _isLoggedIn = false;
    notifyListeners();
  }
}
