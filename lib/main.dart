// main.dart (Corregido)

import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
// Importado
import 'routes.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Paleta de colores ---
const Color kPrimaryColor = Color(0xFF00897B);
const Color kPrimaryLightColor = Color(0xFFE0F2F1);
const Color kBackgroundColor = Color(0xFFF5F5F5);
const Color kCardColor = Colors.white;
const Color kTextColor = Color(0xFF333333);
const Color kSecondaryTextColor = Color(0xFF757575);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializamos Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ❌ LÍNEA ELIMINADA ❌
  // Se eliminó 'await FirebaseAuth.instance.signInAnonymously();'
  // para permitir que tu página de login maneje la autenticación.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimaryColor,
        primary: kPrimaryColor,
        background: kBackgroundColor,
        surface: kCardColor,
        onBackground: kTextColor,
        onSurface: kTextColor,
      ),
      scaffoldBackgroundColor: kBackgroundColor,
      textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme).apply(
        bodyColor: kTextColor,
        displayColor: kTextColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: kCardColor,
        foregroundColor: kPrimaryColor,
        elevation: 0.5,
        centerTitle: false,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: kPrimaryColor,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          textStyle: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kPrimaryColor, width: 2.0),
        ),
        labelStyle: const TextStyle(color: kSecondaryTextColor),
      ),
      cardTheme: CardThemeData(
  color: kCardColor,
  elevation: 1.0,
  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12.0),
    side: BorderSide(color: Colors.grey[200]!, width: 0.5),
  ),
),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: kCardColor,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: kSecondaryTextColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        elevation: 1.0,
      ),
    );

    return MaterialApp(
      title: 'DoctorAppointmentApp',
      theme: theme,
      // Esta configuración es correcta. 'routes.dart' decidirá
      // que la primera página en mostrarse es '/login'.
      initialRoute: Routes.login,
      onGenerateRoute: Routes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}