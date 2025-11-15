import 'package:flutter/material.dart';

// Importaciones de las páginas existentes
import 'home_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'citas_page.dart';

// Importaciones de las nuevas páginas
import 'messages_page.dart';
import 'settings_page.dart';
import 'privacy_policy_page.dart';
import 'about_us_page.dart';
import 'dashboard_page.dart'; // NUEVO: Importar la página del dashboard

class Routes {
  // Rutas existentes
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String citas = '/citas';

  // Rutas para las nuevas pantallas
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String about = '/about';
  static const String dashboard = '/dashboard'; // NUEVO: Definir la ruta

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage()); // Convertido a const
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());

      case Routes.citas:
        return MaterialPageRoute(builder: (_) => CitasPage());

      case Routes.messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      case Routes.about:
        return MaterialPageRoute(builder: (_) => const AboutUsPage());

      // NUEVO: Caso para la ruta del dashboard
      case Routes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}