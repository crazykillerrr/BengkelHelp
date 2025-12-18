import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_item.dart';
import '../../../widgets/common/custom_button.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    Future<void> _confirmCheckout() async {
      if (cartProvider.cartItems.isEmpty) return;

      final userId = authProvider.currentUser!.id;

      // ================= GROUP CART BY SELLER =================
      final Map<String, List> groupedBySeller = {};

      for (var item in cartProvider.cartItems) {
        groupedBySeller.putIfAbsent(
          item.product.sellerId,
          () => [],
        );
        groupedBySeller[item.product.sellerId]!.add(item);
      }

      // ================= CREATE ORDER PER SELLER =================
      for (final entry in groupedBySeller.entries) {
        final sellerId = entry.key;
        final sellerItems = entry.value;

        final orderItems = sellerItems.map((item) {
          return OrderItem(
            productId: item.product.id,
            productName: item.product.name,
            photoUrl: item.product.photoUrl,
            price: item.product.price,
            quantity: item.quantity,
          );
        }).toList();

        final subtotal = sellerItems.fold<double>(
          0,
          (sum, item) => sum + item.totalPrice,
        );

        final order = OrderModel(
          id: '',
          userId: userId,
          sellerId: sellerId, // 🔥 PENTING
          bengkelId: sellerItems.first.product.bengkelId,
          type: 'product',
          items: orderItems,
          subtotal: subtotal,
          deliveryFee: 0,
          totalAmount: subtotal,
          status: OrderStatus.pending,
          paymentMethod: 'COD',
          deliveryAddress: 'Alamat user',
          createdAt: DateTime.now(),
        );

        await orderProvider.createOrder(order);
      }

      if (!context.mounted) return;

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // ================= CART PREVIEW =================
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (_, i) {
                final item = cartProvider.cartItems[i];
                return ListTile(
                  leading: Image.network(
                    item.product.photoUrl,
                    width: 50,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image),
                  ),
                  title: Text(item.product.name),
                  subtitle: Text(
                    '${item.quantity} x ${currency.format(item.product.price)}',
                  ),
                  trailing: Text(
                    currency.format(item.totalPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),

          // ================= TOTAL & CONFIRM =================
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total'),
                    Text(
                      currency.format(cartProvider.totalPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Konfirmasi Pesanan',
                  onPressed: _confirmCheckout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
