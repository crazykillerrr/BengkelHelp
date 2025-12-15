import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/bengkel_model.dart';

class BengkelVerificationScreen extends StatefulWidget {
  const BengkelVerificationScreen({super.key});

  @override
  State<BengkelVerificationScreen> createState() =>
      _BengkelVerificationScreenState();
}

class _BengkelVerificationScreenState extends State<BengkelVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Bengkel'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Verified'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBengkelList(status: 'pending'),
          _buildBengkelList(status: 'verified'),
          _buildBengkelList(status: 'rejected'),
        ],
      ),
    );
  }

  // ================= LIST =================
  Widget _buildBengkelList({required String status}) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bengkel')
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bengkels = snapshot.data!.docs
            .map((doc) =>
                BengkelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (bengkels.isEmpty) {
          return const Center(child: Text('Tidak ada bengkel'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bengkels.length,
          itemBuilder: (context, index) {
            return _buildBengkelCard(bengkels[index]);
          },
        );
      },
    );
  }

  // ================= CARD =================
  Widget _buildBengkelCard(BengkelModel bengkel) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showDetail(bengkel),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: bengkel.photoUrl != null
                    ? Image.network(
                        bengkel.photoUrl!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bengkel.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bengkel.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rating: ${bengkel.rating} (${bengkel.totalReviews})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (bengkel.status == 'pending')
                const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[200],
      child: const Icon(Icons.store, color: Colors.grey),
    );
  }

  // ================= DETAIL =================
  void _showDetail(BengkelModel bengkel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bengkel.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text('Alamat: ${bengkel.address}'),
            Text('Telepon: ${bengkel.phone}'),
            Text('Jam: ${bengkel.openTime} - ${bengkel.closeTime}'),
            const SizedBox(height: 20),

            if (bengkel.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(bengkel.id, 'rejected'),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(bengkel.id, 'verified'),
                      child: const Text('Setujui'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ================= UPDATE =================
  Future<void> _updateStatus(String id, String status) async {
    Navigator.pop(context);
    await _firestore.collection('bengkel').doc(id).update({
      'status': status,
      'isActive': status != 'rejected',
      'updatedAt': Timestamp.now(),
    });
  }
}
