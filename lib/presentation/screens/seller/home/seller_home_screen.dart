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
          color: Color(0xFF1E3A8A),
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

// ================= DASHBOARD SCREEN =================
class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(),
              const SizedBox(height: 12),
              _walletSection(),
              const SizedBox(height: 16),
              _statusPesananSection(),
              const SizedBox(height: 16),
              _menuSection(),
              const SizedBox(height: 16),
              _misiBengkelSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      color: Color(0xFF1E3A8A),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "BENGKELHELP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          Row(
              children: const [
              Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
              SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
          ],
        ),
        ],
      ),
    );
  }

  Widget _walletSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Expanded(child: _walletItem("Bengkel", "Pay", "Rp1.000.000")),
            Container(width: 1, height: 50, color: const Color(0xFFE0E0E0)),
            Expanded(child: _walletTopUp()),
            Container(width: 1, height: 50, color: const Color(0xFFE0E0E0)),
            Expanded(child: _walletItem("Ko", "in", "5000")),
          ],
        ),
      ),
    );
  }

  Widget _walletItem(String part1, String part2, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: part1,
                style: const TextStyle(
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: part2,
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _walletTopUp() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "Top",
                style: TextStyle(
                  color: Color(0xFFFF9800),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: "Up",
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF1E3A8A),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 16, color: Colors.white),
        ),
      ],
    );
  }

  Widget _statusPesananSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Status Pesanan",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: const [
                    Text(
                      "Riwayat Pesanan",
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, color: Color(0xFF9E9E9E), size: 16),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _statusItem("0", "Perlu Dikemas")),
                Expanded(child: _statusItem("0", "Dikirim")),
                Expanded(child: _statusItem("0", "Pengembalian")),
                Expanded(child: _statusItem("0", "Selesai")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF9E9E9E),
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _menuSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: _menuItem(Icons.inventory_2_rounded, "Produk", Color(0xFF1E3A8A))),
          const SizedBox(width: 12),
          Expanded(child: _menuItem(Icons.monetization_on_rounded, "Penghasilan", Color(0xFF1E3A8A))),
          const SizedBox(width: 12),
          Expanded(child: _menuItem(Icons.show_chart_rounded, "Statistik", Color(0xFF1E3A8A))),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _misiBengkelSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  "Misi Bengkel",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Selengkapnya >",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _misiItem(
              "Upload 10 Produkmu dalam Sehari",
              0,
              10,
              "Mulai",
            ),
            const SizedBox(height: 12),
            _misiItem(
              "Kirim 10 Montir Pertamamu",
              2,
              10,
              "Selesai",
            ),
          ],
        ),
      ),
    );
  }

  Widget _misiItem(String title, int current, int total, String buttonText) {
    double progress = current / total;
    bool isCompleted = buttonText == "Selesai";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$current/$total",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted ? Color(0xFF1E3A8A) : Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}