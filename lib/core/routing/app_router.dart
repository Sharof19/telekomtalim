import 'package:flutter/material.dart';
import 'package:uztelecom/core/routing/app_route_registry.dart';
import 'package:uztelecom/core/routing/app_routes.dart';

class AppRouter {
  static const String initialRoute = AppRoutes.splash;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    if (routeName == null || routeName.isEmpty) {
      return _unknownRoute(settings, issue: 'Route name is null or empty.');
    }

    final entry = AppRouteRegistry.find(routeName);
    if (entry == null) {
      return _unknownRoute(settings, issue: 'Route is not registered.');
    }

    try {
      return entry.toRoute(settings);
    } on AppRouteBuildException catch (error) {
      if (routeName == AppRoutes.otp) {
        return _redirectToLogin(
          issue:
              'OTP route requires valid OtpRouteArgs. Redirected to login. ${error.message}',
        );
      }
      return _unknownRoute(settings, issue: error.message);
    } catch (error) {
      return _unknownRoute(
        settings,
        issue: 'Route build failed: ${error.runtimeType}.',
      );
    }
  }

  static MaterialPageRoute<dynamic> _unknownRoute(
    RouteSettings settings, {
    String? issue,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => _UnknownRoutePage(
        routeName: settings.name,
        arguments: settings.arguments,
        issue: issue,
      ),
    );
  }

  static Route<dynamic> _redirectToLogin({required String issue}) {
    final loginEntry = AppRouteRegistry.find(AppRoutes.login);
    if (loginEntry != null) {
      return loginEntry.toRoute(
        RouteSettings(name: AppRoutes.login, arguments: null),
      );
    }
    return _unknownRoute(
      const RouteSettings(name: AppRoutes.login),
      issue: issue,
    );
  }
}

class _UnknownRoutePage extends StatelessWidget {
  final String? routeName;
  final Object? arguments;
  final String? issue;

  const _UnknownRoutePage({this.routeName, this.arguments, this.issue});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final routeLabel = routeName == null || routeName!.isEmpty
        ? '<null>'
        : routeName!;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        title: const Text(
          'Route error',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unknown route or invalid arguments.',
              style: TextStyle(
                color: scheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Route: $routeLabel',
              style: TextStyle(color: scheme.onSurface),
            ),
            if (arguments != null) ...[
              const SizedBox(height: 8),
              Text(
                'Arguments: ${arguments.runtimeType}',
                style: TextStyle(color: scheme.onSurface),
              ),
            ],
            if (issue != null && issue!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                issue!,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.72),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.splash, (route) => false),
              child: const Text('Back to splash'),
            ),
          ],
        ),
      ),
    );
  }
}
