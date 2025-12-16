import 'package:bengkelhelp/core/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/wallet_provider.dart';
import '../../../navigation/app_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================
              Container(
                height: 180,
                width: double.infinity,
                color: const Color(0xFF1E3A8A),
              ),

              // ================= CONTENT =================
              Transform.translate(
                offset: const Offset(0, -100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // ================= PROFILE CARD =================
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ---------- AVATAR ----------
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 52,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: user?.photoUrl != null
                                      ? NetworkImage(user!.photoUrl!)
                                      : null,
                                  child: user?.photoUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 52,
                                          color: Colors.black54,
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // ---------- NAME ----------
                            Text(
                              user?.name ?? 'rizky',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ---------- SALDO + ROLE ----------
                            Row(
                              children: [
                                // BengkelPay (LEFT)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'BengkelPay',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Rp1.000.000',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // USER (CENTER)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3A8A),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'User',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Koin (RIGHT)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: const [
                                      Text(
                                        'Koin',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        '5000',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= PESANAN =================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pesanan Saya',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: const [
                                _OrderItem(
                                  icon: Icons.inventory_2_outlined,
                                  label: 'Dikemas',
                                  count: 2,
                                ),
                                _OrderItem(
                                  icon: Icons.local_shipping_outlined,
                                  label: 'Dikirim',
                                  count: 4,
                                ),
                                _OrderItem(
                                  icon: Icons.star_border,
                                  label: 'Penilaian',
                                  count: 3,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ================= MENU =================
                      _MenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profil',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Alamat Saya',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'BengkelPay',
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.walletScreen);
                        },
                      ),
                      _MenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Riwayat Transaksi',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.favorite_outline,
                        title: 'Bengkel Favorit',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Bantuan',
                        onTap: () {},
                      ),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'Tentang Aplikasi',
                        onTap: () {},
                      ),

                      const SizedBox(height: 20),

                      // ================= LOGOUT =================
                      _MenuItem(
                        icon: Icons.logout,
                        title: 'Keluar',
                        textColor: Colors.red,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Konfirmasi'),
                              content: const Text(
                                  'Apakah Anda yakin ingin keluar?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Keluar'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            final walletProvider =
                                Provider.of<WalletProvider>(context,
                                    listen: false);
                            walletProvider.clearData();

                            await authProvider.signOut();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushNamedAndRemoveUntil(
                                AppRoutes.login,
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= WIDGET =================

class _OrderItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;

  const _OrderItem({
    required this.icon,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Icon(icon, size: 28),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.blue,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: textColor ?? const Color(0xFF1E3A8A),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textColor ?? Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}
