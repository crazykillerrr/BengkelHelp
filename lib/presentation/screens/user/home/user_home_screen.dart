import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/themes/app_theme.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/providers/bengkel_provider.dart';
import '../../../navigation/app_router.dart';
import '../../../widgets/bengkel/bengkel_card.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BengkelProvider>(context, listen: false).loadNearbyBengkels();
    });
  }
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    switch (index) {
      case 0:
        // Home - already here
        break;
      case 1:
        Navigator.of(context).pushNamed(AppRouter.search);
        break;
      case 2:
        Navigator.of(context).pushNamed(AppRouter.shop);
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
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<BengkelProvider>(context, listen: false)
                .loadNearbyBengkels();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppTheme.radiusXL),
                      bottomRight: Radius.circular(AppTheme.radiusXL),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, ${user?.name ?? "User"}!',
                                style: AppTheme.h3.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Text(
                                'Butuh bantuan bengkel hari ini?',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withAlpha((0.9 * 255).round()),
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.wallet);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                                decoration: BoxDecoration(
                                color: Colors.white.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      
                      // Search Bar
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.search);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingM,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                            boxShadow: AppTheme.shadowLight,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: AppTheme.spacingM),
                              Text(
                                'Cari bengkel atau layanan...',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textHint,
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
              
              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Layanan Cepat',
                        style: AppTheme.h3,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.build,
                              label: 'Panggil Montir',
                              color: AppTheme.primaryColor,
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRouter.booking);
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.shopping_cart,
                              label: 'Beli Suku Cadang',
                              color: AppTheme.accentColor,
                              onTap: () {
                                Navigator.of(context).pushNamed(AppRouter.shop);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.schedule,
                              label: 'Pengingat Servis',
                              color: AppTheme.successColor,
                              onTap: () {
                                // TODO: Navigate to reminder screen
                              },
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingM),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.history,
                              label: 'Riwayat',
                              color: AppTheme.secondaryColor,
                              onTap: () {
                                // TODO: Navigate to history screen
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Nearby Bengkels
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bengkel Terdekat',
                        style: AppTheme.h3,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRouter.search);
                        },
                        child: Text(
                          'Lihat Semua',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Bengkel List
              Consumer<BengkelProvider>(
                builder: (context, bengkelProvider, _) {
                  if (bengkelProvider.isLoading) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  if (bengkelProvider.nearbyBengkels.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_off,
                              size: 64,
                              color: AppTheme.textHint,
                            ),
                            const SizedBox(height: AppTheme.spacingM),
                            Text(
                              'Tidak ada bengkel terdekat',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return SliverPadding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final bengkel = bengkelProvider.nearbyBengkels[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                            child: BengkelCard(
                              bengkel: bengkel,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  AppRouter.booking,
                                  arguments: {'bengkelId': bengkel.id},
                                );
                              },
                            ),
                          );
                        },
                        childCount: bengkelProvider.nearbyBengkels.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Cari',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Belanja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.shadowLight,
        ),
                child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: color.withAlpha((0.1 * 255).round()),
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}