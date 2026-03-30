import 'package:flutter/material.dart';
import 'package:uztelecom/data/repositories/auth_repository.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthRepository _loginService = AuthRepository();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _loginService.dispose();
    super.dispose();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final token = await _loginService.getValidAccessToken();
      if (!mounted) return;
      if (token != null && token.isNotEmpty) {
        await AppNavigator.replaceWithHome(context);
      } else {
        await AppNavigator.replaceWithLogin(context);
      }
    } catch (_) {
      if (!mounted) return;
      await AppNavigator.replaceWithLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.authBackground,
      body: const Center(child: _SplashLogo()),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
    );
  }
}
