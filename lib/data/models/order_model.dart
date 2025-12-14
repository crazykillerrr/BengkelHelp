import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item.dart';

enum OrderStatus { pending, confirmed, onProgress, completed, cancelled }

class OrderModel {
  final String id;
  final String userId;
  final String sellerId;
  final String? bengkelId;
  final String type;
  final List<OrderItem> items;

  final double totalAmount;
  final double? subtotal;
  final double? deliveryFee;

  final OrderStatus status;
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
    this.subtotal,
    this.deliveryFee,
    required this.status,
    required this.paymentMethod,
    this.deliveryAddress,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.createdAt,
    this.completedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      sellerId: data['sellerId'] ?? '',
      bengkelId: data['bengkelId'],
      type: data['type'] ?? 'product',
      items: (data['items'] as List? ?? [])
          .map((i) => OrderItem.fromMap(i))
          .toList(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      status: _stringToStatus(data['status']),
      paymentMethod: data['paymentMethod'] ?? '',
      deliveryAddress: data['deliveryAddress'],
      deliveryLatitude: (data['deliveryLatitude'] != null)
          ? data['deliveryLatitude'].toDouble()
          : null,
      deliveryLongitude: (data['deliveryLongitude'] != null)
          ? data['deliveryLongitude'].toDouble()
          : null,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  static OrderStatus _stringToStatus(String? value) {
    switch (value?.toLowerCase()) {
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'onprogress':
      case 'processing':
      case 'inprogress':
        return OrderStatus.onProgress;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'sellerId': sellerId,
      'bengkelId': bengkelId,
      'type': type,
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'status': status.toString().split('.').last,
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
