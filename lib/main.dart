import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'core/constants/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/bengkel_provider.dart';
import 'data/providers/product_provider.dart';
import 'data/providers/order_provider.dart';
import 'data/providers/cart_provider.dart';
import 'data/providers/wallet_provider.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // On web, Firebase requires explicit FirebaseOptions or index.html config.
    // Wrap initialization in try/catch so missing web options don't crash the app.
    await Firebase.initializeApp();
  } catch (e) {
    // If initialization fails (e.g., web with missing FirebaseOptions), log and continue.
    // Many features that depend on Firebase will be non-functional until properly configured.
    debugPrint('Warning: Firebase.initializeApp() failed: $e');
    if (kIsWeb) {
      debugPrint('Running on web — ensure FirebaseOptions are provided for web in main.dart or generated firebase_options.dart');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BengkelProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
      ],
      child: MaterialApp(
        title: 'BengkelHelp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
