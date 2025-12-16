import 'package:flutter/material.dart';

class ProfileBengkelScreen extends StatelessWidget {
  const ProfileBengkelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= BODY =================
      body: Stack(
        children: [
          // ===== HEADER BIRU =====
          Container(
            height: 220,
            width: double.infinity,
            color: const Color(0xFF1E2E8F),
          ),

          // ===== CONTENT =====
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 140),

                // ===== PROFILE CARD =====
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.fromLTRB(16, 70, 16, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
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

                            const SizedBox(height: 12),

                            // ===== SALDO + ROLE =====
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                // BengkelPay
                                Column(
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
                                    SizedBox(height: 4),
                                    Text('Rp1.000.000'),
                                  ],
                                ),

                                // Role
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E5BB8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Bengkel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Koin
                                Column(
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
                                    SizedBox(height: 4),
                                    Text('5000'),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ===== AVATAR =====
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
                                  child: const Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
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

                // ===== MENU CARD 1 =====
                _MenuCard(
                  children: const [
                    _MenuItem(Icons.receipt_long, 'Riwayat Pesanan'),
                    _Divider(),
                    _MenuItem(Icons.lock_outline, 'PIN Saya'),
                    _Divider(),
                    _MenuItem(Icons.language, 'Alamat Saya'),
                    _Divider(),
                    _MenuItem(Icons.build, 'Riwayat Jasa'),
                  ],
                ),

                const SizedBox(height: 16),

                // ===== MENU CARD 2 =====
                _MenuCard(
                  children: const [
                    _MenuItem(Icons.headset_mic, 'Customer Service'),
                    _Divider(),
                    _MenuItem(Icons.info_outline, 'Tentang Aplikasi'),
                    _Divider(),
                    _MenuItem(Icons.logout, 'Keluar'),
                  ],
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E2E8F),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}

// ================= WIDGET BANTUAN =================

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

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  const _MenuItem(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1);
  }
}
