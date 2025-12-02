import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class RegisterBengkelScreen extends StatelessWidget {
  const RegisterBengkelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftarkan Bengkel')),
      body: const Center(
          child:
              Text('Register bengkel placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
