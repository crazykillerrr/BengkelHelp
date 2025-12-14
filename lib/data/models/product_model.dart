import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String sellerId;
  final String bengkelId;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String photoUrl;     // ← DIGANTI, BUKAN imageUrls
  final String? brand;
  final String condition;     // Baru / Bekas
  final String status;        // pending, active, rejected
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.bengkelId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    required this.photoUrl,
    this.brand,
    required this.condition,
    required this.status,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      bengkelId: map['bengkelId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      stock: map['stock'] ?? 0,
      photoUrl: map['photoUrl'] ?? '',
      brand: map['brand'],
      condition: map['condition'] ?? 'Baru',
      status: map['status'] ?? 'pending',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'bengkelId': bengkelId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'stock': stock,
      'photoUrl': photoUrl,
      'brand': brand,
      'condition': condition,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
