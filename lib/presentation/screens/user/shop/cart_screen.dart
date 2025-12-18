import 'package:bengkelhelp/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../widgets/common/custom_button.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
            return _emptyCart(context);
          }

          return Column(
            children: [
              // ================= CART ITEMS =================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.cartItems[index];
                    return _cartItem(
                      context,
                      item,
                      currencyFormat,
                      cartProvider,
                    );
                  },
                ),
              ),

              // ================= CHECKOUT =================
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
                        Text('Total', style: AppTheme.h3),
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
                      text:
                          'Checkout (${cartProvider.itemCount} item)',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.checkout,
                        );
                      },
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

  // ================= CART ITEM =================

  Widget _cartItem(
    BuildContext context,
    dynamic item,
    NumberFormat currencyFormat,
    CartProvider cartProvider,
  ) {
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
          // IMAGE
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
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
                : const Icon(Icons.inventory_2),
          ),

          const SizedBox(width: AppTheme.spacingM),

          // INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
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

          // QTY
          Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: item.quantity > 1
                        ? () => cartProvider.updateQuantity(
                            item.product.id,
                            item.quantity - 1,
                          )
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text(item.quantity.toString()),
                  IconButton(
                    onPressed:
                        item.quantity < item.product.stock
                            ? () => cartProvider.updateQuantity(
                                  item.product.id,
                                  item.quantity + 1,
                                )
                            : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              IconButton(
                onPressed: () =>
                    cartProvider.removeFromCart(item.product.id),
                icon: const Icon(Icons.delete,
                    color: AppTheme.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= EMPTY CART =================

  Widget _emptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 80, color: AppTheme.textHint),
          const SizedBox(height: 16),
          Text('Keranjang kosong',
              style: AppTheme.h3
                  .copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('Tambahkan produk untuk checkout',
              style: AppTheme.bodyMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Belanja Sekarang'),
          )
        ],
      ),
    );
  }
}
