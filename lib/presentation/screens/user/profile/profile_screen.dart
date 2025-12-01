import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../navigation/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        title: const Text('Profil'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXL),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppTheme.radiusXL),
                  bottomRight: Radius.circular(AppTheme.radiusXL),
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: user?.photoUrl != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoUrl!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: AppTheme.primaryColor,
                          ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    user?.name ?? 'User',
                    style: AppTheme.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    user?.email ?? '',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Menu Items
            _MenuSection(
              title: 'Akun',
              items: [
                _MenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  onTap: () {
                    // TODO: Navigate to edit profile
                  },
                ),
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat',
                  onTap: () {
                    // TODO: Navigate to address
                  },
                ),
                _MenuItem(
                  icon: Icons.payment,
                  title: 'BengkelPay',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.wallet);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            _MenuSection(
              title: 'Aktivitas',
              items: [
                _MenuItem(
                  icon: Icons.receipt_long,
                  title: 'Riwayat Pesanan',
                  onTap: () {
                    // TODO: Navigate to order history
                  },
                ),
                _MenuItem(
                  icon: Icons.schedule,
                  title: 'Pengingat Servis',
                  onTap: () {
                    // TODO: Navigate to reminders
                  },
                ),
                _MenuItem(
                  icon: Icons.favorite_outline,
                  title: 'Favorit',
                  onTap: () {
                    // TODO: Navigate to favorites
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingM),
            
            _MenuSection(
              title: 'Lainnya',
              items: [
                _MenuItem(
                  icon: Icons.help_outline,
                  title: 'Bantuan',
                  onTap: () {
                    // TODO: Navigate to help
                  },
                ),
                _MenuItem(
                  icon: Icons.info_outline,
                  title: 'Tentang Aplikasi',
                  onTap: () {
                    // TODO: Show about dialog
                  },
                ),
                _MenuItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  textColor: AppTheme.errorColor,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konfirmasi'),
                        content: const Text('Apakah Anda yakin ingin keluar?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true) {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.signIn,
                          (route) => false,
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  
  const _MenuSection({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            boxShadow: AppTheme.shadowLight,
          ),
          child: Column(
            children: items.map((item) {
              final isLast = item == items.last;
              return Column(
                children: [
                  item,
                  if (!isLast)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
                      child: Divider(height: 1),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? textColor;
  final VoidCallback onTap;
  
  const _MenuItem({
    required this.icon,
    required this.title,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.textPrimary),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          color: textColor ?? AppTheme.textPrimary,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap,
    );
  }
}
