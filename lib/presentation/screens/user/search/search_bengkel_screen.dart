import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class SearchBengkelScreen extends StatelessWidget {
  const SearchBengkelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cari Bengkel')),
      body: const Center(child: Text('Search bengkel placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
