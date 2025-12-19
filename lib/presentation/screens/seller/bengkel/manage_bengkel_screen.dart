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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final bengkelProvider =
    Provider.of<BengkelProvider>(context, listen: false);

    if (auth.currentUser != null) {
      await bengkelProvider.fetchBengkelByOwner(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          'Kelola Bengkel',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<BengkelProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bengkel = provider.selectedBengkel;

          if (bengkel == null) {
            return _buildNoBengkel();
          }

          return _buildBengkelDetail(bengkel);
        },
      ),
    );
  }

  // ================= NO BENGKEL =================
  Widget _buildNoBengkel() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.store,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Bengkel',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daftarkan bengkel Anda untuk mulai menerima pesanan dari pelanggan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.registerBengkel);
                },
                child: const Text(
                  'Daftarkan Bengkel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ================= DETAIL BENGKEL =================
  Widget _buildBengkelDetail(BengkelModel bengkel) {
    final statusInfo = _getStatusInfo(bengkel.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= IMAGE HEADER =================
          Stack(
            children: [
              bengkel.photoUrl != null
                  ? Image.network(
                bengkel.photoUrl!,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : _placeholderImage(),
              Positioned(
                top: 16,
                right: 16,
                child: _statusBadge(statusInfo),
              ),
            ],
          ),

          // ================= CONTENT =================
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bengkel.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                _infoCard(
                  icon: Icons.location_on,
                  label: 'Alamat',
                  value: bengkel.address,
                ),
                _infoCard(
                  icon: Icons.phone,
                  label: 'No. Telepon',
                  value: bengkel.phone,
                ),
                _infoCard(
                  icon: Icons.access_time,
                  label: 'Jam Operasional',
                  value: '${bengkel.openTime} - ${bengkel.closeTime}',
                ),

                const SizedBox(height: 24),
                const Text(
                  'Deskripsi Bengkel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    bengkel.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS =================
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'verified':
        return {
          'text': 'Terverifikasi',
          'color': Colors.green,
          'icon': Icons.verified,
        };
      case 'rejected':
        return {
          'text': 'Ditolak',
          'color': Colors.red,
          'icon': Icons.cancel,
        };
      default:
        return {
          'text': 'Menunggu Verifikasi',
          'color': Colors.orange,
          'icon': Icons.hourglass_top,
        };
    }
  }

  Widget _statusBadge(Map<String, dynamic> status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: status['color'].withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status['icon'], size: 16, color: status['color']),
          const SizedBox(width: 6),
          Text(
            status['text'],
            style: TextStyle(
              color: status['color'],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ================= INFO CARD =================
  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 220,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.store, size: 80, color: Colors.grey),
      ),
    );
  }
}
