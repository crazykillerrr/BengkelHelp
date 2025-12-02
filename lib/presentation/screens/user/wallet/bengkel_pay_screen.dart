import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class BengkelPayScreen extends StatelessWidget {
  const BengkelPayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BengkelPay')),
      body: const Center(child: Text('BengkelPay placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
