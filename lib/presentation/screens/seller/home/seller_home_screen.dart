import 'package:flutter/material.dart';

import '../dashboard/seller_dashboard_screen.dart';
import '../product/product_management_screen.dart';
import '../profile/profileseller_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({Key? key}) : super(key: key);

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SellerDashboardScreen(),   // HOME
    ProductManagementScreen(), // TAMBAH PRODUK
    SellerProfileScreen(),    // PROFILE BENGKEL
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Color(0xFF1E3A8A),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ================= HOME =================
            _NavIcon(
              icon: Icons.home_rounded,
              active: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),

            // ================= ADD PRODUCT =================
            GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),

            // ================= PROFILE =================
            _NavIcon(
              icon: Icons.person_rounded,
              active: _selectedIndex == 2,
              onTap: () => setState(() => _selectedIndex = 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= NAV ICON =================
class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 30,
        color: active ? Colors.white : Colors.white70,
      ),
    );
  }
}
