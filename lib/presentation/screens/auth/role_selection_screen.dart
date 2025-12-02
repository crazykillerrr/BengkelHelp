import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Peran')),
      body: const Center(
        child: Text('Role selection placeholder', style: AppTheme.bodyMedium),
      ),
    );
  }
}
