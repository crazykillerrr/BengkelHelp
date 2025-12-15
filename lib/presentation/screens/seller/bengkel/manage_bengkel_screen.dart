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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store, size: 100, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Bengkel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Daftarkan bengkel Anda untuk mulai menerima pesanan',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.registerBengkel);
            },
            child: const Text('Daftarkan Bengkel'),
          )
        ],
      ),
    );
  }

  // ================= DETAIL =================
  Widget _buildBengkelDetail(BengkelModel bengkel) {
    final statusInfo = _getStatusInfo(bengkel.status);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bengkel.photoUrl != null)
            Image.network(
              bengkel.photoUrl!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          else
            _placeholderImage(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusBadge(statusInfo),
                const SizedBox(height: 16),

                Text(
                  bengkel.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),
                _infoRow(Icons.location_on, bengkel.address),
                _infoRow(Icons.phone, bengkel.phone),
                _infoRow(
                  Icons.access_time,
                  '${bengkel.openTime} - ${bengkel.closeTime}',
                ),

                const SizedBox(height: 24),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(bengkel.description),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  Widget _infoRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.store, size: 80, color: Colors.grey),
      ),
    );
  }
}
