import '../../core/constants/app_routes.dart';

/// Lightweight router constants adapter used across the UI.
/// Maps older `AppRouter` references to the centralized `AppRoutes` constants.
class AppRouter {
  static const String splash = '/';
  static const String signIn = AppRoutes.login;
  static const String signUp = AppRoutes.register;

  static const String userHome = AppRoutes.userHome;
  static const String sellerHome = AppRoutes.sellerHome;
  static const String adminHome = AppRoutes.adminHome;

  static const String search = AppRoutes.searchBengkel;
  static const String shop = AppRoutes.productList;
  static const String profile = AppRoutes.profile;
  static const String wallet = AppRoutes.wallet;
  static const String booking = AppRoutes.callMontir;
}
