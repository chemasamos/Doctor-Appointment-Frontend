import 'package:flutter/material.dart';

// Importaciones de las páginas existentes
import 'home_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'citas_page.dart'; // NUEVO: Importado del primer bloque

// Importaciones de las nuevas páginas
import 'messages_page.dart';
import 'settings_page.dart';
import 'privacy_policy_page.dart';
import 'about_us_page.dart';

class Routes {
  // Rutas existentes
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String citas = '/citas'; // NUEVO: Agregado del primer bloque

  // Rutas para las nuevas pantallas
  static const String messages = '/messages';
  static const String settings = '/settings';
  static const String privacy = '/privacy';
  static const String about = '/about';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    // La variable que recibe la info se llama `settings`
    switch (settings.name) {
      // CORRECCIÓN: Usamos `Routes.` para evitar confundir con la variable `settings`
      case Routes.login:
        return MaterialPageRoute(builder: (_) => LoginPage());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case Routes.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      
      // NUEVO: Caso agregado del primer bloque
      case Routes.citas:
        return MaterialPageRoute(builder: (_) => CitasPage()); // Asumiendo que CitasPage puede no ser const

      case Routes.messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case Routes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case Routes.privacy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      case Routes.about:
        return MaterialPageRoute(builder: (_) => const AboutUsPage());
        
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