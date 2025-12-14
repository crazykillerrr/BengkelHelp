import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/providers/product_provider.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  String? _selectedCategory;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).loadProducts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Belanja Suku Cadang'),
        elevation: 0,
        actions: [
          Consumer<ProductProvider>(
            builder: (context, productProvider, _) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // TODO: Navigate to cart
                    },
                  ),
                  if (productProvider.cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          productProvider.cartItemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              itemCount: AppConstants.productCategories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryChip(
                    label: 'Semua',
                    isSelected: _selectedCategory == null,
                    onTap: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                      Provider.of<ProductProvider>(context, listen: false)
                          .loadProducts();
                    },
                  );
                }
                
                final category = AppConstants.productCategories[index - 1];
                return _CategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                    Provider.of<ProductProvider>(context, listen: false)
                        .loadProducts(category: category);
                  },
                );
              },
            ),
          ),
          
          // Products Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Text(
                          'Tidak ada produk',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: AppTheme.spacingM,
                    mainAxisSpacing: AppTheme.spacingM,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return GestureDetector(
                      onTap: () {
                        // TODO: Navigate to product detail
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          boxShadow: AppTheme.shadowLight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(AppTheme.radiusM),
                                topRight: Radius.circular(AppTheme.radiusM),
                              ),
                              child: product.photoUrl.isNotEmpty
                                  ? Image.network(
                                      product.photoUrl,
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 120,
                                      width: double.infinity,
                                      color: AppTheme.backgroundColor,
                                      child: const Icon(
                                        Icons.inventory_2,
                                        size: 40,
                                        color: AppTheme.textHint,
                                      ),
                                    ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(AppTheme.spacingS),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Text(
                                      currencyFormat.format(product.price),
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingXS),
                                    Text(
                                      'Stok: ${product.stock}',
                                      style: AppTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppTheme.spacingS),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.textHint,
            ),
          ),
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}