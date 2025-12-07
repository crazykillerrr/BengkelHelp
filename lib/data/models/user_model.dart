import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? photoUrl;
  final String? address;
  final double? latitude;
  final double? longitude;
  final double walletBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.address,
    this.latitude,
    this.longitude,
    this.walletBalance = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });
  
  /// SAFE PARSING FROM FIRESTORE
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    print('📄 Parsing UserModel from Firestore...');
    print('   Raw data: $map');
    
    try {
      // Safe timestamp parsing
      DateTime createdAt = _parseTimestamp(map['createdAt'], 'createdAt');
      DateTime updatedAt = _parseTimestamp(map['updatedAt'], 'updatedAt');
      
      final model = UserModel(
        id: id,
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        phone: map['phone']?.toString() ?? '',
        role: map['role']?.toString() ?? 'user',
        photoUrl: map['photoUrl']?.toString(),
        address: map['address']?.toString(),
        latitude: _parseDouble(map['latitude']),
        longitude: _parseDouble(map['longitude']),
        walletBalance: _parseDouble(map['walletBalance']) ?? 0.0,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isActive: map['isActive'] == true,
      );
      
      print('✅ UserModel parsed successfully');
      print('   ID: ${model.id}');
      print('   Email: ${model.email}');
      print('   Name: ${model.name}');
      print('   Role: ${model.role}');
      
      return model;
    } catch (e, stackTrace) {
      print('❌ Error parsing UserModel: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Helper: Parse Timestamp safely
  static DateTime _parseTimestamp(dynamic value, String fieldName) {
    if (value == null) {
      print('⚠️  $fieldName is null, using current time');
      return DateTime.now();
    }
    
    if (value is Timestamp) {
      return value.toDate();
    }
    
    if (value is DateTime) {
      return value;
    }
    
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        print('⚠️  Failed to parse $fieldName as DateTime string, using current time');
        return DateTime.now();
      }
    }
    
    print('⚠️  Unknown type for $fieldName: ${value.runtimeType}, using current time');
    return DateTime.now();
  }
  
  /// Helper: Parse double safely
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
  
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'walletBalance': walletBalance,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }
  
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? role,
    String? photoUrl,
    String? address,
    double? latitude,
    double? longitude,
    double? walletBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}