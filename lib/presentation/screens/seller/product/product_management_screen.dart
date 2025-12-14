import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/product_provider.dart';
import '../../../../data/models/product_model.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({Key? key}) : super(key: key);

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await productProvider.fetchProductsBySeller(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        backgroundColor: AppColors.primary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<ProductModel> products = provider.products;

          if (_searchQuery.isNotEmpty) {
            products = products.where((product) {
              final q = _searchQuery.toLowerCase();
              return product.name.toLowerCase().contains(q) ||
                  product.category.toLowerCase().contains(q);
            }).toList();
          }

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'Belum ada produk'
                        : 'Produk tidak ditemukan',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadProducts,
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductCard(products[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addProduct),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    // Default values
    Color statusColor = Colors.grey;
    String statusText = "Status tidak diketahui";

    // Convert string status
    if (product.status == "pending") {
      statusColor = AppColors.warning;
      statusText = "Menunggu Verifikasi";
    } else if (product.status == "verified") {
      statusColor = AppColors.success;
      statusText = "Terverifikasi";
    } else if (product.status == "rejected") {
      statusColor = AppColors.error;
      statusText = "Ditolak";
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.editProduct, // pastikan route ini kamu buat
            arguments: product.id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.photoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      product.category,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            CurrencyFormatter.format(product.price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: (product.stock > 0
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: product.stock > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editProduct,
                      arguments: product.id,
                    );
                  } else if (value == 'delete') {
                    _showDeleteDialog(product);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text("Edit"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text("Hapus", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.image, size: 40, color: Colors.grey),
    );
  }

  void _showDeleteDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Produk"),
        content: Text("Yakin ingin menghapus ${product.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final provider =
                  Provider.of<ProductProvider>(context, listen: false);
              final success = await provider.deleteProduct(product.id);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Produk berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadProducts();
              }
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }
}
