import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/order_provider.dart';
import '../../../../data/models/order_model.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({Key? key}) : super(key: key);

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final order = Provider.of<OrderProvider>(context, listen: false);
    if (auth.currentUser != null) {
      await order.fetchSellerOrders(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              _buildWalletCard(),
              const SizedBox(height: 20),
              _buildStatusPesanan(orderProvider),
              const SizedBox(height: 28),
              _buildMenuCepat(),
              const SizedBox(height: 28),
              _buildMisiBengkel(),
              const SizedBox(height: 28),
              _buildKelolaBengkel(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2E8F),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "BENGKELHELP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: Colors.white),
              SizedBox(width: 14),
              Icon(Icons.chat_bubble_outline, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // ================= WALLET =================
  Widget _buildWalletCard() {
    return Transform.translate(
      offset: const Offset(0, -18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              _bengkelPayItem("Rp1.000.000"),
              _divider(),
              _topUpItem(),
              _divider(),
              _coinItem("5000"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bengkelPayItem(String value) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Bengkel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA500),
                  ),
                ),
                TextSpan(
                  text: 'Pay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2E8F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _topUpItem() {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Top',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA500),
                  ),
                ),
                TextSpan(
                  text: 'Up',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2E8F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const CircleAvatar(
            radius: 16,
            backgroundColor: Color(0xFF1E2E8F),
            child: Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _coinItem(String value) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Ko',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFA500),
                  ),
                ),
                TextSpan(
                  text: 'in',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2E8F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 44, color: Colors.grey[300]);
  }

  // ================= STATUS PESANAN =================
  Widget _buildStatusPesanan(OrderProvider orderProvider) {
    int pending = orderProvider.orders
        .where((o) => o.status == OrderStatus.pending)
        .length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Status Pesanan",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.incomingOrders);
                },
                child: const Text(
                  "Riwayat Pesanan ›",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statusItem(pending.toString(), "Perlu Dikemas"),
              _statusItem("0", "Dikirim"),
              _statusItem("0", "Pengembalian"),
              _statusItem("0", "Selesai"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String count, String label) {
    return Container(
      width: 78,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(count,
              style:
              const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // ================= MENU CEPAT =================
  Widget _buildMenuCepat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _MenuCepatItem(Icons.inventory_2, "Produk"),
          _MenuCepatItem(Icons.account_balance_wallet, "Penghasilan"),
          _MenuCepatItem(Icons.bar_chart, "Statistik"),
        ],
      ),
    );
  }

  // ================= MISI =================
  Widget _buildMisiBengkel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Misi Bengkel",
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Selengkapnya ›",
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            _misiItem("Upload 10 Produkmu dalam Sehari", 0, 10, "Mulai"),
            const SizedBox(height: 12),
            _misiItem("Kirim 10 Montir Pertamamu", 2, 10, "Selesai"),
          ],
        ),
      ),
    );
  }

  Widget _misiItem(String title, int current, int total, String buttonText) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDED),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: current / total,
                  color: const Color(0xFF1E2E8F),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text("$current/$total",
                  style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 10),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2E8F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= KELOLA BENGKEL =================
  Widget _buildKelolaBengkel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Kelola Bengkel",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _KelolaItem(
                  icon: Icons.store,
                  label: "Profil",
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.manageBengkel);
                  },
                ),
                const _KelolaItem(icon: Icons.access_time, label: "Operasional"),
                const _KelolaItem(icon: Icons.people, label: "Montir"),
                const _KelolaItem(icon: Icons.inventory_2, label: "Produk"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ================= MENU CEPAT ITEM =================
class _MenuCepatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuCepatItem(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2E8F),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

// ================= KELOLA ITEM =================
class _KelolaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _KelolaItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EBFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1E2E8F),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
