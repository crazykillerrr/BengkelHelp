import 'package:bengkelhelp/core/constants/app_colors.dart';
import 'package:flutter/material.dart';


class ActivityReportScreen extends StatelessWidget {
  const ActivityReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Aktivitas'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Activity Report - Coming Soon'),
      ),
    );
  }
}