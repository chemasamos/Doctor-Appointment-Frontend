import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil")),
      body: const Center(
        child: Text(
          "Nombre: hola",
          style: TextStyle(fontSize: 18),
        ), // Text
      ), // Center
    ); // Scaffold
  }
}