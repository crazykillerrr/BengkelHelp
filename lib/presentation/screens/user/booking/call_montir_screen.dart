import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class CallMontirScreen extends StatelessWidget {
  const CallMontirScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panggil Montir')),
      body: const Center(child: Text('Call montir placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
