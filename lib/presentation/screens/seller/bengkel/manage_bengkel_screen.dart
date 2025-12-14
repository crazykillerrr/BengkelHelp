import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../../data/models/bengkel_model.dart';

class ManageBengkelScreen extends StatefulWidget {
  const ManageBengkelScreen({Key? key}) : super(key: key);

  @override
  State<ManageBengkelScreen> createState() => _ManageBengkelScreenState();
}

class _ManageBengkelScreenState extends State<ManageBengkelScreen> {
  @override
  void initState() {
    super.initState();
    _loadBengkel();
  }

  Future<void> _loadBengkel() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bengkelProvider = Provider.of<BengkelProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      await bengkelProvider.fetchBengkelByOwner(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Bengkel'),
        backgroundColor: AppColors.primary,
      ),
      body: Consumer<BengkelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bengkel = provider.selectedBengkel;
          
          if (bengkel == null) {
            return _buildNoBengkelState();
          }

          return _buildBengkelInfo(bengkel);
        },
      ),
    );
  }

  Widget _buildNoBengkelState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_mall_directory_outlined,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Bengkel',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Daftarkan bengkel Anda untuk mulai menerima pesanan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.registerBengkel);
              },
              icon: const Icon(Icons.add),
              label: const Text('Daftarkan Bengkel'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBengkelInfo(BengkelModel bengkel) {
    Color statusColor;
    String statusText;
    
    switch (bengkel.status) {
      case BengkelStatus.pending:
        statusColor = AppColors.warning;
        statusText = 'Menunggu Verifikasi';
        break;
      case BengkelStatus.verified:
        statusColor = AppColors.success;
        statusText = 'Terverifikasi';
        break;
      case BengkelStatus.rejected:
        statusColor = AppColors.error;
        statusText = 'Ditolak';
        break;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Bengkel Image
          if (bengkel.photoUrl != null)
            Image.network(
              bengkel.photoUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
            )
          else
            _buildPlaceholderImage(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        bengkel.status == BengkelStatus.verified
                            ? Icons.verified
                            : Icons.pending,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Bengkel Name
                Text(
                  bengkel.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Cards
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Alamat',
                  value: bengkel.address,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Telepon',
                  value: bengkel.phone,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.access_time,
                  title: 'Jam Operasional',
                  value: '${bengkel.openTime} - ${bengkel.closeTime}',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.star,
                  title: 'Rating',
                  value: '${bengkel.rating} (${bengkel.totalReviews} ulasan)',
                ),
                
                const SizedBox(height: 24),
                
                // Description
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(bengkel.description),
                
                const SizedBox(height: 24),
                
                // Services
                const Text(
                  'Layanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: bengkel.services.map((service) {
                    return Chip(
                      label: Text(service),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 32),
                
                // Edit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to edit bengkel
                      Navigator.pushNamed(
                        context,
                        '/edit-bengkel',
                        arguments: bengkel.id,
                      );
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Informasi'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.store,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}