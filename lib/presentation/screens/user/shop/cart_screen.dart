import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_item.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _updateQuantity(String productId, int quantity) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.updateQuantity(productId, quantity);
  }

  void _removeFromCart(String productId) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.removeFromCart(productId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Produk dihapus dari keranjang'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkout() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keranjang kosong'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Create order items from cart
    final orderItems = cartProvider.cartItems.map((item) {
      return OrderItem(
        productId: item.product.id,
        productName: item.product.name,
        photoUrl: item.product.photoUrl, // simpan foto produk
        price: item.product.price,
        quantity: item.quantity,
      );
    }).toList();


    final order = OrderModel(
      id: '',
      userId: authProvider.currentUser!.id,
      sellerId: '', // Will be set by the seller who fulfills the order
      bengkelId: '', // Not applicable for product orders
      type: 'product',
      items: orderItems,
      totalAmount: cartProvider.totalPrice,
      status: OrderStatus.pending, 
      paymentMethod: AppConstants.paymentBengkelPay,
      createdAt: DateTime.now(),
    );

    final success = await orderProvider.createOrder(order);

    if (!mounted) return;

    if (success) {
      cartProvider.clearCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal membuat pesanan'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Keranjang'),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          if (cartProvider.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppTheme.textHint,
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  Text(
                    'Keranjang kosong',
                    style: AppTheme.h3.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    'Tambahkan produk ke keranjang untuk melanjutkan',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textHint,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingXL),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingXL,
                        vertical: AppTheme.spacingM,
                      ),
                    ),
                    child: const Text('Belanja Sekarang'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        boxShadow: AppTheme.shadowLight,
                      ),
                      child: Row(
                        children: [
                          // Product Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundColor,
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                            child: item.product.photoUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusM),
                                    child: Image.network(
                                      item.product.photoUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2,
                                    size: 32,
                                    color: AppTheme.textHint,
                                  ),
                          ),

                          const SizedBox(width: AppTheme.spacingM),

                          // Product Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppTheme.spacingXS),
                                Text(
                                  currencyFormat.format(item.product.price),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: AppTheme.spacingM),

                          // Quantity Controls
                          Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: item.quantity > 1
                                        ? () => _updateQuantity(
                                            item.product.id, item.quantity - 1)
                                        : null,
                                    icon: const Icon(Icons.remove),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.grey[200],
                                      disabledBackgroundColor: Colors.grey[100],
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  Text(
                                    item.quantity.toString(),
                                    style: AppTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: AppTheme.spacingS),
                                  IconButton(
                                    onPressed: item.quantity <
                                            item.product.stock
                                        ? () => _updateQuantity(
                                            item.product.id, item.quantity + 1)
                                        : null,
                                    icon: const Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppTheme.primaryColor,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor: Colors.grey[100],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () =>
                                    _removeFromCart(item.product.id),
                                icon: const Icon(Icons.delete,
                                    color: AppTheme.errorColor),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Checkout Section
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusXL),
                    topRight: Radius.circular(AppTheme.radiusXL),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTheme.h3,
                        ),
                        Text(
                          currencyFormat.format(cartProvider.totalPrice),
                          style: AppTheme.h3.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingL),
                    CustomButton(
                      text: 'Checkout (${cartProvider.itemCount} item)',
                      onPressed: _checkout,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
