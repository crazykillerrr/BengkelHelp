import 'package:bengkelhelp/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RevenueReportScreen extends StatelessWidget {
  const RevenueReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Pendapatan'),
        backgroundColor: AppColors.primary,
      ),
      body: const Center(
        child: Text('Revenue Report - Coming Soon'),
      ),
    );
  }
}