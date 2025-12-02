import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class BengkelDetailScreen extends StatelessWidget {
  final String bengkelId;
  const BengkelDetailScreen({super.key, required this.bengkelId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Bengkel')),
      body: Center(child: Text('Detail for bengkel $bengkelId', style: AppTheme.bodyMedium)),
    );
  }
}
