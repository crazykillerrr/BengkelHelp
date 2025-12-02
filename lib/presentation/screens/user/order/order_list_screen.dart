import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pesanan')),
      body: const Center(child: Text('Order list placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
