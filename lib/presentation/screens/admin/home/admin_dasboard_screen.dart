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
  const AdminDashboardScreen({Key? key}) : super(key: key);

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
      // Load statistics from Firestore
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      
      final bengkelSnapshot = await FirebaseFirestore.instance
          .collection('bengkel')
          .get();
      
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();
      
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('status', isEqualTo: 'success')
          .get();

      // Calculate statistics
      final totalUsers = usersSnapshot.docs.length;
      final totalBengkel = bengkelSnapshot.docs.length;
      final totalProducts = productsSnapshot.docs.length;
      final totalOrders = ordersSnapshot.docs.length;
      
      // Pending verifications
      final pendingBengkel = bengkelSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      final pendingProducts = productsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'pending')
          .length;
      
      // Revenue
      double totalRevenue = 0;
      for (var doc in transactionsSnapshot.docs) {
        totalRevenue += (doc.data()['amount'] ?? 0).toDouble();
      }

      setState(() {
        _stats = {
          'totalUsers': totalUsers,
          'totalBengkel': totalBengkel,
          'totalProducts': totalProducts,
          'totalOrders': totalOrders,
          'pendingBengkel': pendingBengkel,
          'pendingProducts': pendingProducts,
          'totalRevenue': totalRevenue,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading dashboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();
              if (!mounted) return;
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelection);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    
                    // Alerts Section
                    if ((_stats['pendingBengkel'] ?? 0) > 0 ||
                        (_stats['pendingProducts'] ?? 0) > 0)
                      _buildAlertsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Statistics Section
                    const Text(
                      'Statistik Aplikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticsGrid(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    const Text(
                      'Aksi Cepat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Reports Section
                    const Text(
                      'Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildReportsSection(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang, Admin!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'BengkelHelp Control Panel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      children: [
        if ((_stats['pendingBengkel'] ?? 0) > 0)
          _buildAlertCard(
            icon: Icons.store,
            title: 'Bengkel Menunggu Verifikasi',
            count: _stats['pendingBengkel'],
            color: AppColors.warning,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BengkelVerificationScreen(),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        if ((_stats['pendingProducts'] ?? 0) > 0)
          _buildAlertCard(
            icon: Icons.inventory,
            title: 'Produk Menunggu Verifikasi',
            count: _stats['pendingProducts'],
            color: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProductVerificationScreen(),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String title,
    required int count,
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
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    '$count item',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.people,
          label: 'Total Users',
          value: '${_stats['totalUsers'] ?? 0}',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.store,
          label: 'Total Bengkel',
          value: '${_stats['totalBengkel'] ?? 0}',
          color: Colors.purple,
        ),
        _buildStatCard(
          icon: Icons.inventory,
          label: 'Total Produk',
          value: '${_stats['totalProducts'] ?? 0}',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.shopping_bag,
          label: 'Total Orders',
          value: '${_stats['totalOrders'] ?? 0}',
          color: Colors.green,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildActionCard(
          icon: Icons.verified_user,
          label: 'Verifikasi Bengkel',
          color: AppColors.primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BengkelVerificationScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.check_circle,
          label: 'Verifikasi Produk',
          color: AppColors.secondary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductVerificationScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.people_alt,
          label: 'Kelola Users',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const UserManagementScreen(),
              ),
            );
          },
        ),
        _buildActionCard(
          icon: Icons.store_mall_directory,
          label: 'Kelola Bengkel',
          color: Colors.purple,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductVerificationScreen(),
              ),
            );
          },
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

  Widget _buildReportsSection() {
    return Column(
      children: [
        _buildReportCard(
          icon: Icons.trending_up,
          title: 'Laporan Pendapatan',
          subtitle: CurrencyFormatter.format(_stats['totalRevenue'] ?? 0),
          color: Colors.green,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RevenueReportScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildReportCard(
          icon: Icons.analytics,
          title: 'Laporan Aktivitas',
          subtitle: 'Lihat aktivitas pengguna',
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ActivityReportScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}