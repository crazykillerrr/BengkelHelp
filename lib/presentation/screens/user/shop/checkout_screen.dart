import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_item.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final authProvider = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    Future<void> _confirmCheckout() async {
      if (cartProvider.cartItems.isEmpty) return;

      final userId = authProvider.currentUser!.id;

      final Map<String, List> groupedBySeller = {};

      for (var item in cartProvider.cartItems) {
        groupedBySeller.putIfAbsent(item.product.sellerId, () => []);
        groupedBySeller[item.product.sellerId]!.add(item);
      }

      for (final entry in groupedBySeller.entries) {
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
          sellerId: entry.key,
          bengkelId: sellerItems.first.product.bengkelId,
          type: 'product',
          items: orderItems,
          subtotal: subtotal,
          deliveryFee: 50000,
          totalAmount: subtotal + 50000,
          status: OrderStatus.pending,
          paymentMethod: 'COD',
          deliveryAddress: 'Alamat user',
          createdAt: DateTime.now(),
        );

        await orderProvider.createOrder(order);
      }

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dibuat')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    }

    final totalBarang = cartProvider.totalPrice;
    const ongkir = 50000;
    final totalBayar = totalBarang + ongkir;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Ringkasan Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= ALAMAT =================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined),
                    SizedBox(width: 8),
                    Text(
                      'Oliver Aiku  +6289******22',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Rkc Hanura Padang Cermin, Jalan Katamso Transad 2 '
                  'Hanura, Pesawaran, Lampung, Indonesia',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= PRODUK =================
          ...cartProvider.cartItems.map(
            (item) => _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Image.network(
                        item.product.photoUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${item.quantity} x ${currency.format(item.product.price)}',
                        ),
                      ),
                      Text(
                        currency.format(item.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ================= PENGIRIMAN =================
          _card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pengiriman'),
                Text(currency.format(ongkir)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= CATATAN =================
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Catatan Tambahan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Ketik disini',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= RINGKASAN =================
          _card(
            child: Column(
              children: [
                _row('Harga Barang', currency.format(totalBarang)),
                _row('Pengiriman', currency.format(ongkir)),
                const Divider(),
                _row(
                  'Total',
                  currency.format(totalBayar),
                  isBold: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),

      // ================= BUTTON =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2BB8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _confirmCheckout,
              child: const Text(
                'Buat Pesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= WIDGET HELPER =================

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _row(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
