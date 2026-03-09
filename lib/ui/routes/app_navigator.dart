import 'package:flutter/material.dart';
import 'package:uztelecom/ui/pages/home_page.dart';
import 'package:uztelecom/ui/pages/auth_pages/login_screen.dart';
import 'package:uztelecom/ui/pages/auth_pages/otp_page.dart';
import 'package:uztelecom/ui/pages/profil.dart';
import 'package:uztelecom/ui/pages/auth_pages/splash_screen.dart';
import 'package:uztelecom/ui/pages/certificates_page.dart';
import 'package:uztelecom/ui/routes/app_routes.dart';
import 'package:uztelecom/ui/widgets/connectivity_gate.dart';

class AppNavigator {
  static String initRoute = AppRoutes.splashScreen;

  static Map<String, WidgetBuilder> get routes {
    return {
      AppRoutes.splashScreen: (_) =>
          const ConnectivityGate(child: SplashScreen()),
      // AppRoutes.startScreen: (_) => const StartScreen(),
      AppRoutes.loginPage: (_) => const ConnectivityGate(child: LoginPage()),
      AppRoutes.otpPage: (context) {
        final login =
            ModalRoute.of(context)?.settings.arguments as String? ?? '';
        return ConnectivityGate(child: OtpPage(login: login));
      },
      AppRoutes.homePage: (_) => const ConnectivityGate(child: HomePage()),
      AppRoutes.certificatesPage: (_) =>
          const ConnectivityGate(child: CertificatesPage()),
      AppRoutes.profilePage: (_) => ConnectivityGate(child: ProfilePage()),
      AppRoutes.myApplications: (_) =>
          ConnectivityGate(child: MyApplicationsPage()),
    };
  }
}
