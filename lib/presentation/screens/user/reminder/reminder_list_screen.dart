import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengingat Servis')),
      body: const Center(child: Text('Reminder list placeholder', style: AppTheme.bodyMedium)),
    );
  }
}
