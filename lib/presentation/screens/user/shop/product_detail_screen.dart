import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/product_provider.dart';
import '../../../../data/providers/cart_provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/common/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _addToCart() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(widget.product, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('$_quantity ${widget.product.name} ditambahkan ke keranjang'),
        action: SnackBarAction(
          label: 'Lihat Keranjang',
          onPressed: () {
            // TODO: Navigate to cart
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // Product Images
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.product.photoUrl.isNotEmpty
                  ? PageView.builder(
                      itemCount: widget.product.photoUrl.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          widget.product.photoUrl[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(
                        Icons.inventory_2,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),
          ),

          // Product Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXL),
                  topRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: AppTheme.h2.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        currencyFormat.format(widget.product.price),
                        style: AppTheme.h2.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingM),

                  // Rating and Stock
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppTheme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        '4.5 (120 ulasan)',
                        style: AppTheme.bodyMedium,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: AppTheme.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: widget.product.stock > 0
                              ? AppTheme.successColor
                                  .withAlpha((0.1 * 255).round())
                              : AppTheme.errorColor
                                  .withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          widget.product.stock > 0
                              ? 'Stok: ${widget.product.stock}'
                              : 'Stok Habis',
                          style: AppTheme.bodySmall.copyWith(
                            color: widget.product.stock > 0
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Description
                  Text(
                    'Deskripsi',
                    style: AppTheme.h3,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    widget.product.description,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacingL),

                  // Quantity Selector
                  Text(
                    'Jumlah',
                    style: AppTheme.h3,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          disabledBackgroundColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      Text(
                        _quantity.toString(),
                        style: AppTheme.h3,
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      IconButton(
                        onPressed: _quantity < widget.product.stock
                            ? () => setState(() => _quantity++)
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

                  const SizedBox(height: AppTheme.spacingXL),

                  // Add to Cart Button
                  ElevatedButton(
                    onPressed: widget.product.stock > 0 ? _addToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      ),
                    ),
                    child: const Text('Tambah ke Keranjang'),
                  ),

                  const SizedBox(height: AppTheme.spacingL),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
