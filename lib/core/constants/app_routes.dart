import 'package:flutter/material.dart';

// Import all screens
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/sign_in_screen.dart';
import '../../presentation/screens/auth/sign_up_screen.dart';
import '../../presentation/screens/auth/role_selection_screen.dart';

// User screens
import '../../presentation/screens/user/home/user_home_screen.dart';
import '../../presentation/screens/user/search/search_bengkel_screen.dart';
import '../../presentation/screens/user/search/bengkel_detail_screen.dart';
import '../../presentation/screens/user/booking/call_montir_screen.dart';
import '../../presentation/screens/user/shop/product_list_screen.dart';
import '../../presentation/screens/user/shop/product_detail_screen.dart';
import '../../presentation/screens/user/shop/cart_screen.dart';
import '../../presentation/screens/user/order/order_list_screen.dart';
import '../../presentation/screens/user/wallet/bengkel_pay_screen.dart';
import '../../presentation/screens/user/wallet/top_up_screen.dart';
import '../../presentation/screens/user/reminder/reminder_list_screen.dart';
import '../../presentation/screens/user/profile/profile_screen.dart';
import '../../presentation/screens/user/profile/edit_profile_screen.dart';

// Seller screens
import '../../presentation/screens/seller/home/seller_home_screen.dart';
import '../../presentation/screens/seller/bengkel/register_bengkel_screen.dart';
import '../../presentation/screens/seller/product/add_product_screen.dart';

// Admin screens
import '../../presentation/screens/admin/home/admin_home_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String register = '/register';
  
  // User routes
  static const String userHome = '/user-home';
  static const String searchBengkel = '/search-bengkel';
  static const String bengkelDetail = '/bengkel-detail';
  static const String callMontir = '/call-montir';
  static const String productList = '/product-list';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String orderList = '/order-list';
  static const String wallet = '/wallet';
  static const String topUp = '/top-up';
  static const String reminderList = '/reminder-list';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  
  // Seller routes
  static const String sellerHome = '/seller-home';
  static const String registerBengkel = '/register-bengkel';
  static const String addProduct = '/add-product';
  
  // Admin routes
  static const String adminHome = '/admin-home';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      // User routes
      case userHome:
        return MaterialPageRoute(builder: (_) => const UserHomeScreen());
      
      case searchBengkel:
        return MaterialPageRoute(builder: (_) => const SearchBengkelScreen());
      
      case bengkelDetail:
        final bengkelId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => BengkelDetailScreen(bengkelId: bengkelId),
        );
      
      case callMontir:
        return MaterialPageRoute(builder: (_) => const CallMontirScreen());
      
      case productList:
        return MaterialPageRoute(builder: (_) => const ProductListScreen());
      
      case productDetail:
        final productId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: productId),
        );
      
      case cart:
        return MaterialPageRoute(builder: (_) => const CartScreen());
      
      case orderList:
        return MaterialPageRoute(builder: (_) => const OrderListScreen());
      
      case wallet:
        return MaterialPageRoute(builder: (_) => const BengkelPayScreen());
      
      case topUp:
        return MaterialPageRoute(builder: (_) => const TopUpScreen());
      
      case reminderList:
        return MaterialPageRoute(builder: (_) => const ReminderListScreen());
      
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      // Seller routes
      case sellerHome:
        return MaterialPageRoute(builder: (_) => const SellerHomeScreen());
      
      case registerBengkel:
        return MaterialPageRoute(builder: (_) => const RegisterBengkelScreen());
      
      case addProduct:
        return MaterialPageRoute(builder: (_) => const AddProductScreen());
      
      // Admin routes
      case adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Route ${settings.name} not found'),
            ),
          ),
        );
    }
  }
}