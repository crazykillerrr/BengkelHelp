import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Text(
          'BengkelHelp',
          style: AppTheme.h1.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
