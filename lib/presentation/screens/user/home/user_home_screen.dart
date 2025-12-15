import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../../data/providers/wallet_provider.dart';
import '../../../navigation/app_router.dart';
import '../../../widgets/bengkel/bengkel_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
     Provider.of<BengkelProvider>(context, listen: false).loadVerifiedBengkels();
      if (authProvider.currentUser != null) {
        Provider.of<WalletProvider>(context, listen: false)
            .loadBalance(authProvider.currentUser!.id);
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.of(context).pushNamed(AppRouter.searchScreen);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRouter.reminderList);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRouter.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<BengkelProvider>(context, listen: false)
              .loadVerifiedBengkels();
          },
          child: CustomScrollView(
            slivers: [
              // Top Header with BENGKELHELP
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'BENGKELHELP',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.walletScreen);
                                },
                                icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Colors.white,
                                    size: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // <CHANGE> Redesigned Info Cards with dividers
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // BengkelPay Card
                            Expanded(
                              child: Consumer<WalletProvider>(
                                builder: (context, walletProvider, _) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Bengkel',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFFFA500),
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'Pay',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currencyFormat.format(walletProvider.balance),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            
                            // Divider
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            
                            // TopUp Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pushNamed(AppRouter.walletScreen);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Top',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFFA500),
                                            ),
                                          ),
                                          TextSpan(
                                            text: 'Up',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFA500),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Divider
                            Container(
                              height: 50,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            
                            // Coin Card
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Ko',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFFA500),
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'in',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    '5000',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Bengkel Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Top Bengkel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.searchScreen);
                            },
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Horizontal Bengkel Cards
                      Consumer<BengkelProvider>(
                        builder: (context, bengkelProvider, _) {
                          if (bengkelProvider.isLoading) {
                            return const SizedBox(
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          if (bengkelProvider.verifiedBengkels.isEmpty) {
                            return const SizedBox(
                              height: 180,
                              child: Center(
                                child: Text('Tidak ada bengkel tersedia'),
                              ),
                            );
                          }

                          return SizedBox(
                            height: 220,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: bengkelProvider.verifiedBengkels.take(5).length,
                              itemBuilder: (context, index) {
                                final bengkel = bengkelProvider.verifiedBengkels[index];
                                return _BengkelHorizontalCard(
                                  bengkel: bengkel,
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      AppRouter.booking,
                                      arguments: {'bengkelId': bengkel.id},
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Bengkel di Sekitar Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bengkel di Sekitar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRouter.searchScreen);
                        },
                        child: const Text(
                          'Lihat Selengkapnya',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Map Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Map placeholder
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        // Location info overlay
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Color(0xFF00BCD4),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Lampung',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00BCD4),
                                        ),
                                      ),
                                      Text(
                                        'Terminal Rajabasa, Lampung University',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E3A8A),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: const Color(0xFF1E3A8A),
            selectedItemColor: const Color(0xFFFFA500),
            unselectedItemColor: Colors.white.withOpacity(0.6),
            showUnselectedLabels: false,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_active_outlined),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BengkelHorizontalCard extends StatelessWidget {
  final dynamic bengkel;
  final VoidCallback onTap;

  const _BengkelHorizontalCard({
    required this.bengkel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: bengkel.photoUrl != null
                  ? Image.network(
                      bengkel.photoUrl!,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bengkel.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      bengkel.address,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 110,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Icon(
        Icons.build_circle,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}