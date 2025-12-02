import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String sellerId;
  final String? bengkelId;
  final String type; // 'product' or 'service'
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String paymentMethod;
  final String? deliveryAddress;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final DateTime createdAt;
  final DateTime? completedAt;
  
  OrderModel({
    required this.id,
    required this.userId,
    required this.sellerId,
    this.bengkelId,
    required this.type,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.paymentMethod,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.createdAt,
    this.completedAt,
  });
  
  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      bengkelId: map['bengkelId'],
      type: map['type'] ?? 'product',
      items: (map['items'] as List).map((i) => OrderItem.fromMap(i)).toList(),
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      paymentMethod: map['paymentMethod'] ?? 'bengkelpay',
      deliveryAddress: map['deliveryAddress'],
      deliveryLatitude: map['deliveryLatitude']?.toDouble(),
      deliveryLongitude: map['deliveryLongitude']?.toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sellerId': sellerId,
      'bengkelId': bengkelId,
      'type': type,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLatitude,
      'deliveryLongitude': deliveryLongitude,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null 
          ? Timestamp.fromDate(completedAt!) 
          : null,
    };
  }
}
