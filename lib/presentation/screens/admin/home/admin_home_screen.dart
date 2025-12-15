import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../data/providers/auth_provider.dart';
import '../management/user_management_screen.dart';
import '../management/bengkel_management_screen.dart';
import '../verification/product_verification_screen.dart';
import '../verification/bengkel_verification_screen.dart';
import '../report/revenue_report_screen.dart';
import '../report/activity_report_screen.dart';
import 'admin_dasboard_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const UserManagementScreen(),
    const BengkelManagementScreen(),
    const ProductVerificationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Bengkel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified),
            label: 'Verifikasi',
          ),
        ],
      ),
    );
  }
}


