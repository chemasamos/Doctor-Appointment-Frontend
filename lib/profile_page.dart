import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart'; // NUEVO

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nombre: Adrián Aguilar",
              style: TextStyle(fontSize: 18),
            ), // Text
            const SizedBox(height: 20),

            // Botón para volver al menú principal
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Volver al Menú Principal"),
            ), // ElevatedButton

            const SizedBox(height: 20),

            // Botón para cerrar sesión
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.pushReplacementNamed(context, Routes.login);
              },
              child: const Text("Cerrar sesión"),
            ), // ElevatedButton
          ],
        ), // Column
      ), // Center
    ); // Scaffold
  }
}