import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../dashboard/seller_dashboard_screen.dart';
import '../product/product_management_screen.dart';
import '../bengkel/manage_bengkel_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({Key? key}) : super(key: key);

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    SellerDashboardScreen(),   // Home
    ProductManagementScreen(),
    ManageBengkelScreen(),     // Profile
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // HOME
            _NavIcon(
              icon: Icons.home_rounded,
              active: _selectedIndex == 0,
              onTap: () => setState(() => _selectedIndex = 0),
            ),

            // PLUS (KOTAK ROUNDED)
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

            // PROFILE
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

// ================= ICON =================
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

  Widget _walletSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _walletItem("BengkelPay", "Rp1.000.000"),
            _divider(),
            _walletTopUp(),
            _divider(),
            _walletItem("Koin", "5000"),
          ],
        ),
      ),
    );
  }

  Widget _walletItem(String title, String value) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _walletTopUp() {
    return Column(
      children: const [
        Text("TopUp",
            style:
                TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        CircleAvatar(
          radius: 14,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.add, size: 16, color: Colors.white),
        )
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }