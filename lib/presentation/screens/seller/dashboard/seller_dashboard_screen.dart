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
  int _selectedIndex = 0; // Tambahkan supaya quick action tidak error

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await orderProvider.fetchSellerOrders(authProvider.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Bengkel'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(authProvider),
                const SizedBox(height: 24),

                const Text(
                  'Statistik Hari Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildStatisticsCards(orderProvider),

                const SizedBox(height: 24),

                const Text(
                  'Aksi Cepat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildQuickActions(),

                const SizedBox(height: 24),

                const Text(
                  'Pesanan Terbaru',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildRecentOrders(orderProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // WELCOME SECTION
  // =====================================================================

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final userName = authProvider.currentUser?.name?? "Seller";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Text(
              userName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // STATISTICS SECTION
  // =====================================================================

  Widget _buildStatisticsCards(OrderProvider orderProvider) {
    final pendingOrders =
        orderProvider.orders.where((o) => o.status == OrderStatus.pending).length;

    final completedToday = orderProvider.orders.where((order) {
      return order.status == OrderStatus.completed &&
          order.completedAt != null &&
          order.completedAt!.day == DateTime.now().day &&
          order.completedAt!.month == DateTime.now().month &&
          order.completedAt!.year == DateTime.now().year;
    }).length;

    final totalRevenue = orderProvider.orders.where((order) {
      return order.status == OrderStatus.completed &&
          order.completedAt != null &&
          order.completedAt!.day == DateTime.now().day &&
          order.completedAt!.month == DateTime.now().month &&
          order.completedAt!.year == DateTime.now().year;
    }).fold(0.0, (sum, order) => sum + order.totalAmount);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.pending_actions,
            label: 'Pesanan Baru',
            value: pendingOrders.toString(),
            color: AppColors.warning,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.check_circle,
            label: 'Selesai',
            value: completedToday.toString(),
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.attach_money,
            label: 'Pendapatan',
            value: CurrencyFormatter.formatCompact(totalRevenue),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // QUICK ACTIONS
  // =====================================================================

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          icon: Icons.add_box,
          label: 'Tambah Produk',
          color: AppColors.primary,
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.addProduct),
        ),
        _buildActionCard(
          icon: Icons.inventory,
          label: 'Kelola Produk',
          color: AppColors.secondary,
          onTap: () => setState(() => _selectedIndex = 1),
        ),
        _buildActionCard(
          icon: Icons.shopping_bag,
          label: 'Pesanan Masuk',
          color: Colors.green,
          onTap: () => setState(() => _selectedIndex = 2),
        ),
        _buildActionCard(
          icon: Icons.store,
          label: 'Info Bengkel',
          color: Colors.purple,
          onTap: () => setState(() => _selectedIndex = 3),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // RECENT ORDERS
  // =====================================================================

  Widget _buildRecentOrders(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (orderProvider.orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum ada pesanan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            )
          ],
        ),
      );
    }

    final recent = orderProvider.orders.take(5).toList();

    return ListView.builder(
      shrinkWrap: true,
      itemCount: recent.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) => _buildOrderCard(recent[i]),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    late Color statusColor;
    late String statusText;

    switch (order.status) {
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusText = "Menunggu Konfirmasi";
        break;
      case OrderStatus.confirmed:
        statusColor = AppColors.info;
        statusText = "Dikonfirmasi";
        break;
      case OrderStatus.onProgress:
        statusColor = AppColors.secondary;
        statusText = "Sedang Diproses";
        break;
      case OrderStatus.completed:
        statusColor = AppColors.success;
        statusText = "Selesai";
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusText = "Dibatalkan";
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, "/order-detail", arguments: order.id);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ORDER HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Order #${order.id.substring(0, 8)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                "${order.items.length} item",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),

              // PRICE + ACTION BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    CurrencyFormatter.format(order.totalAmount),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (order.status == OrderStatus.pending)
                    TextButton(
                      onPressed: () => _showOrderActionDialog(order),
                      child: const Text("Tindak Lanjuti"),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderActionDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Tindakan Pesanan"),
        content: const Text("Pilih tindakan untuk pesanan ini."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<OrderProvider>(context, listen: false)
                  .updateOrderStatus(order.id, OrderStatus.cancelled);
            },
            child: const Text("Tolak"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<OrderProvider>(context, listen: false)
                  .updateOrderStatus(order.id, OrderStatus.confirmed);
            },
            child: const Text("Terima"),
          ),
        ],
      ),
    );
  }
}
