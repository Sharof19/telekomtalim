import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/check_auth_status_use_case.dart';
import 'package:uztelecom/core/config/app_assets.dart';
import 'package:uztelecom/core/routing/app_navigator.dart';
import 'package:uztelecom/core/theme/app_colors.dart';
import 'package:uztelecom/core/utils/app_logger.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late final CheckAuthStatusUseCase _checkAuthStatus;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus = context.read<CheckAuthStatusUseCase>();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      final isAuthenticated = await _checkAuthStatus();
      if (!mounted) return;
      if (isAuthenticated) {
        await AppNavigator.replaceWithHome(context);
      } else {
        await AppNavigator.replaceWithLogin(context);
      }
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Splash auth check failed; redirecting to login.',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      await AppNavigator.replaceWithLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: const Center(child: _SplashLogo()),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoWidth = ((screenWidth * 0.55) * 0.8)
        .clamp(144.0, 256.0)
        .toDouble();

    return SizedBox(
      width: logoWidth,
      child: AspectRatio(
        aspectRatio: AppAssets.lmsLogoAspectRatio,
        child: Image.asset(
          AppAssets.lmsLogo,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
