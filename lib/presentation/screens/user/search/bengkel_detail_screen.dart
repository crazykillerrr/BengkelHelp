import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/bengkel_model.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../widgets/bengkel/bengkel_detail_header.dart';
import '../../../widgets/bengkel/bengkel_review_item.dart';
import '../../../widgets/common/loading_indicator.dart';
import '../../../widgets/common/empty_state.dart';

class BengkelDetailScreen extends StatefulWidget {
  final String bengkelId;

  const BengkelDetailScreen({
    Key? key,
    required this.bengkelId,
  }) : super(key: key);

  @override
  State<BengkelDetailScreen> createState() => _BengkelDetailScreenState();
}

class _BengkelDetailScreenState extends State<BengkelDetailScreen> {
  BengkelModel? _bengkel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBengkelDetail();
  }

  Future<void> _loadBengkelDetail() async {
    final bengkelProvider =
        Provider.of<BengkelProvider>(context, listen: false);
    try {
      final bengkel = await bengkelProvider.getBengkelById(widget.bengkelId);
      setState(() {
        _bengkel = bengkel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bengkel: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Bengkel'),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        body: const LoadingIndicator(),
      );
    }

    if (_bengkel == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Bengkel'),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        body: const EmptyState(
          title: 'Bengkel Tidak Ditemukan',
          subtitle: 'Bengkel yang Anda cari tidak tersedia.',
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header with Bengkel Info
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            flexibleSpace: FlexibleSpaceBar(
              background: _bengkel!.photoUrl != null
                  ? Image.network(
                      _bengkel!.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.business,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.business,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),
            title: Text(_bengkel!.name),
          ),

          // Bengkel Detail Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BengkelDetailHeader(bengkel: _bengkel!),
            ),
          ),

          // Services Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bengkel!.services.map((service) {
                      return Chip(
                        label: Text(service),
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Operating Hours Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _bengkel!.operatingHours.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reviews Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all reviews
                        },
                        child: const Text(
                          'Lihat Semua',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // TODO: Load and display reviews
                  const Text('Belum ada ulasan'),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),

      // Floating Action Button for Booking
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to booking screen
        },
        backgroundColor: const Color(0xFFFFA500),
        icon: const Icon(Icons.calendar_today),
        label: const Text('Pesan Sekarang'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
