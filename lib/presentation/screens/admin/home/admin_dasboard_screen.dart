import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/providers/auth_provider.dart';
import '../verification/bengkel_verification_screen.dart';
import '../verification/product_verification_screen.dart';
import '../management/user_management_screen.dart';
import '../report/revenue_report_screen.dart';
import '../report/activity_report_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final users = await FirebaseFirestore.instance.collection('users').get();
      final bengkel =
      await FirebaseFirestore.instance.collection('bengkel').get();
      final products =
      await FirebaseFirestore.instance.collection('products').get();
      final orders =
      await FirebaseFirestore.instance.collection('orders').get();
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('status', isEqualTo: 'success')
          .get();

      double revenue = 0;
      for (var doc in transactions.docs) {
        revenue += (doc.data()['amount'] ?? 0).toDouble();
      }

      setState(() {
        _stats = {
          'totalUsers': users.docs.length,
          'totalBengkel': bengkel.docs.length,
          'totalProducts': products.docs.length,
          'totalOrders': orders.docs.length,
          'pendingBengkel':
          bengkel.docs.where((e) => e['status'] == 'pending').length,
          'pendingProducts':
          products.docs.where((e) => e['status'] == 'pending').length,
          'revenue': revenue,
        };
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin Dashboard',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'BengkelHelp Control Panel',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),

          // ================= LOGOUT AMAN =================
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text(
                    'Apakah Anda yakin ingin keluar dari akun admin?\n\n'
                        'Semua data akan tetap tersimpan.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final auth =
                Provider.of<AuthProvider>(context, listen: false);

                await auth.signOut();

                if (!mounted) return;

                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                      (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeCard(),
              const SizedBox(height: 24),

              if ((_stats['pendingBengkel'] ?? 0) > 0 ||
                  (_stats['pendingProducts'] ?? 0) > 0)
                _alertSection(),

              const SizedBox(height: 24),

              const Text('Statistik',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _statGrid(),

              const SizedBox(height: 24),
              const Text('Aksi Cepat',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _quickActions(),

              const SizedBox(height: 24),
              const Text('Laporan',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _reportSection(),
            ],
          ),
        ),
      ),
    );
  }

  /* ================= UI ================= */

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(Icons.admin_panel_settings,
                size: 30, color: AppColors.primary),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Datang',
                  style: TextStyle(color: Colors.white70)),
              SizedBox(height: 4),
              Text('Administrator BengkelHelp',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _alertSection() {
    return Column(
      children: [
        if ((_stats['pendingBengkel'] ?? 0) > 0)
          _alertCard(
            icon: Icons.store,
            title: 'Bengkel Menunggu Verifikasi',
            count: _stats['pendingBengkel'],
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const BengkelVerificationScreen()),
            ),
          ),
        const SizedBox(height: 12),
        if ((_stats['pendingProducts'] ?? 0) > 0)
          _alertCard(
            icon: Icons.inventory,
            title: 'Produk Menunggu Verifikasi',
            count: _stats['pendingProducts'],
            color: Colors.blue,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ProductVerificationScreen()),
            ),
          ),
      ],
    );
  }

  Widget _alertCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('$count item',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _statGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _statCard(Icons.people, 'Users', _stats['totalUsers'], Colors.blue),
        _statCard(Icons.store, 'Bengkel', _stats['totalBengkel'], Colors.purple),
        _statCard(Icons.inventory, 'Produk', _stats['totalProducts'], Colors.orange),
        _statCard(Icons.shopping_bag, 'Orders', _stats['totalOrders'], Colors.green),
      ],
    );
  }

  Widget _statCard(
      IconData icon, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 80, color: color.withOpacity(0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const Spacer(),
              Text('$value',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _actionCard(Icons.verified_user, 'Verifikasi Bengkel',
            AppColors.primary, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const BengkelVerificationScreen()),
              );
            }),
        _actionCard(Icons.check_circle, 'Verifikasi Produk',
            AppColors.secondary, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProductVerificationScreen()),
              );
            }),
        _actionCard(Icons.people_alt, 'Kelola Users', Colors.blue, () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const UserManagementScreen()),
          );
        }),
        _actionCard(Icons.store_mall_directory, 'Kelola Bengkel',
            Colors.purple, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProductVerificationScreen()),
              );
            }),
      ],
    );
  }

  Widget _actionCard(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 10),
            Text(label,
                style:
                TextStyle(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _reportSection() {
    return Column(
      children: [
        _reportCard(
          Icons.trending_up,
          'Laporan Pendapatan',
          CurrencyFormatter.format(_stats['revenue'] ?? 0),
          Colors.green,
              () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const RevenueReportScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _reportCard(
          Icons.analytics,
          'Laporan Aktivitas',
          'Aktivitas pengguna aplikasi',
          Colors.blue,
              () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ActivityReportScreen()),
          ),
        ),
      ],
    );
  }

  Widget _reportCard(IconData icon, String title, String subtitle,
      Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                      const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
