class OrderItem {
  final String productId;
  final String productName;
  final String? photoUrl; // FOTO PRODUK SIMPAN DI ORDER
  final double price;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    this.photoUrl,
    required this.price,
    required this.quantity,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      photoUrl: map['photoUrl']?.toString(),
      price: _toDouble(map['price']),
      quantity: _toInt(map['quantity']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'photoUrl': photoUrl,
      'price': price,
      'quantity': quantity,
    };
  }

  // Normalisasi data agar aman
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
