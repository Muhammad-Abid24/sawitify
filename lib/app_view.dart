import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sawitify/presentation/pages/main_navigation_page.dart';
import 'package:sawitify/presentation/pages/intro_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import 'core/storage/session_manager.dart';

class MainAppView extends StatefulWidget {
  const MainAppView({super.key});

  @override
  State<MainAppView> createState() => _MainAppViewState();
}

class _MainAppViewState extends State<MainAppView> {
  bool _showIntro = true;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final isLogin = await SessionManager.isUserLoggedIn();

    if (!mounted) return;

    setState(() {
      _isLoggedIn = isLogin;
      _isLoading = false;
    });


    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstTime = prefs.getBool('isFirstTime') ?? true;

      if (!mounted) return;

      setState(() {
        _showIntro = isFirstTime;
      });
    } catch (e) {
      debugPrint('Error checking first time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sawitify",
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          surface: AppColors.background1,
          onSurface: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary1,
          tertiary: AppColors.secondary2,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
      ),
      themeMode: ThemeMode.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isLoggedIn) {
      return const MainNavigationPage();
    }

    return _showIntro ? const IntroScreen() : const IntroScreen();
  }
}
