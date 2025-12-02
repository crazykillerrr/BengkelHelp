import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Produk')),
      body: const Center(child: Text('Product list placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
