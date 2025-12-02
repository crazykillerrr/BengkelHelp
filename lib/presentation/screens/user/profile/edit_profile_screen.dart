import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: const Center(child: Text('Edit profile placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
