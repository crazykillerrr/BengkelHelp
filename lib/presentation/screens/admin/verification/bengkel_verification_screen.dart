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
          _buildBengkelList(BengkelStatus.pending),
          _buildBengkelList(BengkelStatus.verified),
          _buildBengkelList(BengkelStatus.rejected),
        ],
      ),
    );
  }

  Widget _buildBengkelList(BengkelStatus status) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bengkel')
          .where('status', isEqualTo: status.name)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Tidak ada bengkel'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final bengkel = BengkelModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            );
            return _buildBengkelCard(bengkel);
          },
        );
      },
    );
  }

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
              if (bengkel.status == BengkelStatus.pending)
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

            if (bengkel.status == BengkelStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(bengkel, 'rejected'),
                      child: const Text('Tolak'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(bengkel, 'active'),
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

  Future<void> _updateStatus(BengkelModel bengkel, String status) async {
    Navigator.pop(context);

    await _firestore.collection('bengkel').doc(bengkel.id).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status bengkel diperbarui: $status')),
    );
  }
}
