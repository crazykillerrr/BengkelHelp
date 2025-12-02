import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up')),
      body: const Center(child: Text('Top up placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
