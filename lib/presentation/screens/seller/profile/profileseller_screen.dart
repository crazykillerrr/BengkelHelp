import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Stack(
        children: [
          // ================= HEADER =================
          Container(
            height: 230,
            width: double.infinity,
            color: const Color(0xFF1E2E8F),
          ),

          // ================= CONTENT =================
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 150),

                // ================= PROFILE CARD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
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
                            // ===== NAME =====
                            const Text(
                              'Aikuu Bengkel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ===== SALDO / ROLE / KOIN =====
                            Row(
                              children: const [
                                Expanded(
                                  child: _InfoItem(
                                    title: 'BengkelPay',
                                    value: 'Rp1.000.000',
                                    alignStart: true,
                                  ),
                                ),

                                _RoleBadge(),

                                Expanded(
                                  child: _InfoItem(
                                    title: 'Koin',
                                    value: '5000',
                                    alignStart: false,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ================= AVATAR =================
                      Positioned(
                        top: -55,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Stack(
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 46,
                                  backgroundImage: NetworkImage(
                                    'https://i.imgur.com/BoN9kdC.png',
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ================= MENU CARD 1 =================
                _MenuCard(
                  children: [
                    _MenuItem(Icons.receipt_long, 'Riwayat Pesanan', onTap: () {}),
                    const _Divider(),
                    _MenuItem(Icons.lock_outline, 'PIN Saya', onTap: () {}),
                    const _Divider(),
                    _MenuItem(Icons.language, 'Alamat Saya', onTap: () {}),
                    const _Divider(),
                    _MenuItem(Icons.build, 'Riwayat Jasa', onTap: () {}),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= MENU CARD 2 =================
                _MenuCard(
                  children: [
                    _MenuItem(Icons.headset_mic, 'Customer Service', onTap: () {}),
                    const _Divider(),
                    _MenuItem(Icons.info_outline, 'Tentang Aplikasi', onTap: () {}),
                    const _Divider(),
                    _MenuItem(
                      Icons.logout,
                      'Keluar',
                      textColor: Colors.red,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= ROLE BADGE =================
class _RoleBadge extends StatelessWidget {
  const _RoleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2E8F),
        borderRadius: BorderRadius.circular(30),
      ),
      child: const Text(
        'Bengkel',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ================= INFO ITEM =================
class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final bool alignStart;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.alignStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E2E8F), // ✅ NAVY (SAMAN DENGAN USER)
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ================= MENU CARD =================
class _MenuCard extends StatelessWidget {
  final List<Widget> children;
  const _MenuCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: children),
      ),
    );
  }
}

// ================= MENU ITEM =================
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _MenuItem(
    this.icon,
    this.title, {
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// ================= DIVIDER =================
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
