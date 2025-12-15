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
        onChanged: (value) =>
            setState(() => _searchQuery = value.toLowerCase()),
      ),
    );
  }

  // ================= LIST =================
  Widget _buildBengkelList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('bengkel')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final bengkels = snapshot.data!.docs
            .map((doc) =>
                BengkelModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .where(_filterByStatus)
            .where(_filterBySearch)
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

  // ================= FILTER LOGIC =================
  bool _filterByStatus(BengkelModel b) {
    if (_selectedStatus == 'all') return true;
    return b.status == _selectedStatus;
  }

  bool _filterBySearch(BengkelModel b) {
    return b.name.toLowerCase().contains(_searchQuery) ||
        b.address.toLowerCase().contains(_searchQuery);
  }

  // ================= CARD =================
  Widget _buildBengkelCard(BengkelModel bengkel) {
    Color statusColor;
    String statusText;

    switch (bengkel.status) {
      case 'verified':
        statusColor = Colors.green;
        statusText = 'Verified';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'Pending';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.15),
          child: const Icon(Icons.store, color: AppColors.primary),
        ),
        title: Text(
          bengkel.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${bengkel.address}\n$statusText'),
        trailing: PopupMenuButton(
          onSelected: (value) {
            if (value == 'view') {
              _showDetail(bengkel);
            } else if (value == 'verify') {
              _updateStatus(bengkel.id, 'verified');
            } else if (value == 'reject') {
              _updateStatus(bengkel.id, 'rejected');
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'view', child: Text('Detail')),
            if (bengkel.status == 'pending')
              const PopupMenuItem(value: 'verify', child: Text('Verifikasi')),
            if (bengkel.status != 'rejected')
              const PopupMenuItem(value: 'reject', child: Text('Tolak')),
          ],
        ),
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
            Text('Status: ${bengkel.status}'),
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
  Future<void> _updateStatus(String id, String status) async {
    await _firestore.collection('bengkel').doc(id).update({
      'status': status,
      'updatedAt': Timestamp.now(),
    });
  }
}
