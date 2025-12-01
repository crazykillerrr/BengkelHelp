import 'package:flutter/material.dart';
import '../../../../core/themes/app_theme.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusXL),
                  bottomRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, Admin!',
                    style: AppTheme.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    'Kelola sistem BengkelHelp',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: AppTheme.spacingM,
                mainAxisSpacing: AppTheme.spacingM,
              ),
              delegate: SliverChildListDelegate([
                _AdminMenuCard(
                  icon: Icons.verified_user,
                  title: 'Verifikasi',
                  subtitle: 'Produk & Bengkel',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // TODO: Navigate to verification
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.manage_accounts,
                  title: 'Kelola',
                  subtitle: 'Pengguna',
                  color: AppTheme.accentColor,
                  onTap: () {
                    // TODO: Navigate to user management
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.assessment,
                  title: 'Laporan',
                  subtitle: 'Aktivitas & Transaksi',
                  color: AppTheme.successColor,
                  onTap: () {
                    // TODO: Navigate to reports
                  },
                ),
                _AdminMenuCard(
                  icon: Icons.settings,
                  title: 'Pengaturan',
                  subtitle: 'Sistem',
                  color: AppTheme.textSecondary,
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  
  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.shadowLight,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              subtitle,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}