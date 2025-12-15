import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/bengkel_model.dart';

class BengkelManagementScreen extends StatefulWidget {
  const BengkelManagementScreen({super.key});

  @override
  State<BengkelManagementScreen> createState() =>
      _BengkelManagementScreenState();
}

class _BengkelManagementScreenState extends State<BengkelManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedStatus = 'all';
  String _searchQuery = '';

  final List<String> _statusFilters = [
    'all',
    'verified',
    'pending',
    'rejected',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Bengkel'),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          _buildSearchBar(),
          Expanded(child: _buildBengkelList()),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _buildFilterBar() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = _selectedStatus == status;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.toUpperCase()),
              selected: isSelected,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              onSelected: (_) {
                setState(() => _selectedStatus = status);
              },
            ),
          );
        },
      ),
    );
  }

  // ================= SEARCH =================
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari bengkel...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  // ================= LIST =================
  Widget _buildBengkelList() {
    Query query = _firestore.collection('bengkel');

    if (_selectedStatus != 'all') {
      query = query.where('status', isEqualTo: _selectedStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final bengkels = docs
            .map((doc) =>
                BengkelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where((b) =>
                b.name.toLowerCase().contains(_searchQuery) ||
                b.address.toLowerCase().contains(_searchQuery))
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
    Color statusColor = Colors.grey;
    if (bengkel.status == BengkelStatus.verified) {
      statusColor = Colors.green;
    } else if (bengkel.status == BengkelStatus.pending) {
      statusColor = Colors.orange;
    } else if (bengkel.status == BengkelStatus.rejected) {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: const Icon(Icons.store, color: AppColors.primary),
        ),
        title: Text(
          bengkel.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(bengkel.address),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'view') {
              _showDetail(bengkel);
            } else if (value == 'verify') {
              _updateStatus(bengkel.id, 'verified');
            } else if (value == 'deactivate') {
              _updateStatus(bengkel.id, 'rejected');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'view', child: Text('Detail')),
            if (bengkel.status == BengkelStatus.pending)
              const PopupMenuItem(value: 'verify', child: Text('Verifikasi')),
            const PopupMenuItem(
              value: 'deactivate',
              child: Text('Nonaktifkan'),
            ),
          ],
        ),
        leadingAndTrailingTextStyle:
            TextStyle(color: statusColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ================= DETAIL =================
  void _showDetail(BengkelModel bengkel) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(bengkel.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alamat: ${bengkel.address}'),
            Text('Telepon: ${bengkel.phone}'),
            Text('Status: ${bengkel.status.name}'),
            Text('Rating: ${bengkel.rating}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ================= UPDATE STATUS =================
  Future<void> _updateStatus(String bengkelId, String status) async {
    await _firestore.collection('bengkel').doc(bengkelId).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status bengkel diperbarui: $status')),
      );
    }
  }
}
