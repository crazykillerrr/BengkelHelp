import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
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
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildWalletCard(),
              const SizedBox(height: 24),
              _buildStatusPesanan(orderProvider),
              const SizedBox(height: 24),
              _buildMenuCepat(),
              const SizedBox(height: 24),
              _buildMisiBengkel(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "BENGKELHELP",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.notifications_none, color: Colors.white),
              SizedBox(width: 12),
              Icon(Icons.headset_mic_outlined, color: Colors.white),
            ],
          )
        ],
      ),
    );
  }

  // ================= WALLET =================
  Widget _buildWalletCard() {
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
    return Container(width: 1, height: 40, color: Colors.grey[300]);
  }

  // ================= STATUS PESANAN =================
  Widget _buildStatusPesanan(OrderProvider orderProvider) {
    int pending =
        orderProvider.orders.where((o) => o.status == OrderStatus.pending).length;

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
        style: TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
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
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  // ================= MENU CEPAT =================
  Widget _buildMenuCepat() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _menuItem(Icons.inventory_2, "Produk"),
          _menuItem(Icons.account_balance_wallet, "Penghasilan"),
          _menuItem(Icons.bar_chart, "Statistik"),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(label),
      ],
    );
  }

  // ================= MISI =================
  Widget _buildMisiBengkel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Misi Bengkel",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Selengkapnya ›", style: TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          _misiItem("Upload 10 Produkmu dalam Sehari", 0, 10),
          const SizedBox(height: 12),
          _misiItem("Kirim 10 Montir Pertamamu", 2, 10),
        ],
      ),
    );
  }

  Widget _misiItem(String title, int current, int max) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: current / max,
                  backgroundColor: Colors.white,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text("$current/$max"),
            ],
          ),
        ],
      ),
    );
  }
}
