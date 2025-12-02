import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: const Center(child: Text('Cart placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
