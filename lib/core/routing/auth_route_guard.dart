import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uztelecom/application/use_cases/auth/check_auth_status_use_case.dart';
import 'package:uztelecom/core/routing/app_routes.dart';
import 'package:uztelecom/core/utils/app_logger.dart';

class AuthRouteGuard extends StatefulWidget {
  const AuthRouteGuard({super.key, required this.child});

  final Widget child;

  @override
  State<AuthRouteGuard> createState() => _AuthRouteGuardState();
}

class _AuthRouteGuardState extends State<AuthRouteGuard> {
  bool _authorized = false;
  bool _redirecting = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final isAuthenticated = await context.read<CheckAuthStatusUseCase>()();
      if (!mounted) return;
      if (isAuthenticated) {
        setState(() => _authorized = true);
        return;
      }
    } catch (error, stackTrace) {
      // Invalid or expired auth should fall through to login.
      AppLogger.warning(
        'Auth route guard failed to validate token; redirecting to login.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    if (!mounted || _redirecting) return;
    _redirecting = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_authorized) return widget.child;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
