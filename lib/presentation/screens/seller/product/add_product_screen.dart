import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Produk')),
      body: const Center(child: Text('Add product placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
