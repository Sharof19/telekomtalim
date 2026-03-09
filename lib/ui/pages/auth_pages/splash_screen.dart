import 'package:flutter/material.dart';
import 'package:uztelecom/domain/services/login_service.dart';
import 'package:uztelecom/ui/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LoginService _loginService = LoginService();

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
      final nextRoute = (token != null && token.isNotEmpty)
          ? AppRoutes.homePage
          : AppRoutes.loginPage;
      Navigator.of(context).pushReplacementNamed(nextRoute);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.loginPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
