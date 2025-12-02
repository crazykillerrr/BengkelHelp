import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/providers/auth_provider.dart';
import '../../navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _isNavigating = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _controller.forward();
    _navigateToNextScreen();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _navigateToNextScreen() async {
    try {
      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 2));
      
      if (!mounted || _isNavigating) return;
      _isNavigating = true;
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Add timeout for auth check
      String route = await Future.any([
        _determineRoute(authProvider),
        Future.delayed(
          const Duration(seconds: 5),
          () => AppRouter.signIn, // Default to sign in if timeout
        ),
      ]);
      
      if (mounted && _isNavigating) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    } catch (e) {
      print('Error in splash navigation: $e');
      if (mounted && _isNavigating) {
        Navigator.of(context).pushReplacementNamed(AppRouter.signIn);
      }
    }
  }
  
  Future<String> _determineRoute(AuthProvider authProvider) async {
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      final role = authProvider.currentUser?.role;
      if (role == AppConstants.roleUser) {
        return AppRouter.userHome;
      } else if (role == AppConstants.roleSeller) {
        return AppRouter.sellerHome;
      } else if (role == AppConstants.roleAdmin) {
        return AppRouter.adminHome;
      }
    }
    return AppRouter.signIn;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingXL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  boxShadow: AppTheme.shadowMedium,
                ),
                child: const Icon(
                  Icons.build_circle,
                  size: 80,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL),
              const Text(
                'BengkelHelp',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                'Solusi Bengkel & Montir Terdekat',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: AppTheme.spacingXL * 2),
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}