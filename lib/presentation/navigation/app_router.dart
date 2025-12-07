import '../../core/constants/app_routes.dart';

/// Lightweight router constants adapter used across the UI.
/// Maps older `AppRouter` references to the centralized `AppRoutes` constants.
class AppRouter {
  // Auth Routes
  static const String splash = '/';
  static const String signIn = AppRoutes.login;
  static const String signUp = AppRoutes.register;

  // Home Routes
  static const String userHome = AppRoutes.userHome;
  static const String sellerHome = AppRoutes.sellerHome;
  static const String adminHome = AppRoutes.adminHome;

  // User - Search & Bengkel
  static const String searchBengkel= AppRoutes.searchBengkel;
  static const String bengkelDetail = AppRoutes.bengkelDetail;
  static const String searchScreen = AppRoutes.searchScreen;
  
  // User - Booking & Service
  static const String booking = AppRoutes.booking;
  static const String callMontir = AppRoutes.callMontir;
  
  
  // User - Shop
  static const String shop = AppRoutes.productList;
  static const String productList = AppRoutes.productList;
  static const String productDetail = AppRoutes.productDetail;
  static const String cart = AppRoutes.cart;
  
  // User - Order
  static const String order = AppRoutes.orderList;
  static const String orderList = AppRoutes.orderList;
  
  // User - Wallet
  static const String walletScreen= AppRoutes.walletScreen;
  //static const String bengkelPay = AppRoutes.bengkelPay;
  static const String topUp = AppRoutes.topUp;
  
  // User - Reminder
  static const String reminderList = AppRoutes.reminderList;
  
  // User - Profile
  static const String profile = AppRoutes.profile;
  static const String editProfile = AppRoutes.editProfile;
}