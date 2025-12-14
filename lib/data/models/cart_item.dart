import 'product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, ProductModel product) {
    return CartItem(
      product: product,
      quantity: map['quantity'] ?? 1,
    );
  }
}
