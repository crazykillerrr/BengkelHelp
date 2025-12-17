import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/product_model.dart';

class ProductVerificationScreen extends StatefulWidget {
  const ProductVerificationScreen({super.key});

  @override
  State<ProductVerificationScreen> createState() =>
      _ProductVerificationScreenState();
}

class _ProductVerificationScreenState extends State<ProductVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Produk'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Verified'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProductList(status: 'pending'),
          _ProductList(status: 'verified'),
          _ProductList(status: 'rejected'),
        ],
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final String status;
  const _ProductList({required this.status});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('products')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada produk'));
        }

        final products = snapshot.data!.docs.map((doc) {
          return ProductModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          );
        }).toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (_, i) => _ProductCard(product: products[i]),
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: product.photoUrl.isNotEmpty
                    ? Image.network(
                        product.photoUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(product.category,
                        style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (product.status == 'pending')
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Kategori: ${product.category}'),
              Text('Kondisi: ${product.condition}'),
              if (product.brand != null) Text('Merek: ${product.brand}'),
              const SizedBox(height: 12),
              Text(product.description),
              const SizedBox(height: 24),

              if (product.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _updateStatus(context, 'rejected'),
                        child: const Text('Tolak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            _updateStatus(context, 'verified'),
                        child: const Text('Setujui'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(BuildContext context, String status) async {
    Navigator.pop(context);
    await FirebaseFirestore.instance
        .collection('products')
        .doc(product.id)
        .update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Produk $status')),
    );
  }

  static Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
