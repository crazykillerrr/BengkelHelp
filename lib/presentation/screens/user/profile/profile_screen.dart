import 'package:bengkelhelp/presentation/navigation/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRouter.userHome);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRouter.searchScreen);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRouter.reminderList);
        break;
      case 3:
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= HEADER BIRU =================
          Container(
            height: 260,
            decoration: const BoxDecoration(
              color: Color(0xFF1A237E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),

          // ================= CONTENT =================
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // ================= AVATAR =================
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: Image.network(
                            user?.photoUrl ??
                                "https://i.imgur.com/BoN9kdC.png",
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 5,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.edit, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // ================= PROFILE CARD =================
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                      vertical: 25, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: AppTheme.shadowLight,
                  ),
                  child: Column(
                    children: [
                      // Username
                      Text(
                        user?.name ?? "User",
                        style: AppTheme.h2
                            .copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 5),

                      // Badge Role
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "User",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Wallet Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _walletItem("BengkelPay", "Rp1.000.000"),
                          _walletItem("Koin", "5000"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ================= PESANAN SAYA =================
                _orderSection(),

                const SizedBox(height: 25),

                // ================= MENU LIST =================
                _menuItem("Alamat Saya", Icons.language),
                _menuItem("Buka Bengkel", Icons.build),
                _menuItem("Riwayat Pesanan", Icons.receipt_long),
                _menuItem("Ganti PIN Bengkelpay", Icons.visibility_off),

                const SizedBox(height: 10),

                _menuItem("Customer Service", Icons.headset_mic),
                _menuItem("Tentang Aplikasi", Icons.info_outline),
                _menuItem("Keluar", Icons.logout, isLogout: true),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),

      // ================= NAVBAR SEPERTI HOME =================
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1E3A8A),
            selectedItemColor: const Color(0xFFFFA500),
            unselectedItemColor: Colors.white.withOpacity(0.6),
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.notifications_active_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
          ),
        ),
      ),
    );
  }

  // ========== SMALL WIDGETS ==========

  Widget _walletItem(String title, String amount) {
    return Column(
      children: [
        Text(
          title,
          style: AppTheme.bodyMedium
              .copyWith(color: Colors.orange, fontSize: 15),
        ),
        const SizedBox(height: 5),
        Text(amount,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _orderSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.shadowLight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pesanan Saya",
              style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _orderItem(Icons.inventory_2, "Dikemas", "2"),
              _orderItem(Icons.local_shipping, "Dikirim", "4"),
              _orderItem(Icons.star_border, "Penilaian", "3"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderItem(IconData icon, String label, String count) {
    return Column(
      children: [
        Stack(
          children: [
            Icon(icon, size: 45),
            Positioned(
              right: -4,
              top: -4,
              child: CircleAvatar(
                backgroundColor: Colors.blue,
                radius: 10,
                child: Text(
                  count,
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  Widget _menuItem(String title, IconData icon, {bool isLogout = false}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
          title: Text(title,
              style: TextStyle(
                  color: isLogout ? Colors.red : Colors.black,
                  fontSize: 16)),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
