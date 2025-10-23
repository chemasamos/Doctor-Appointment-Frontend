import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Por ahora, esta pantalla no es funcional, solo muestra un diseño estático.
    // Este es un ejemplo simple que puedes mejorar más adelante.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Lógica de búsqueda (opcional por ahora)
            },
          ),
        ],
      ),
      body: ListView(
        children: List.generate(8, (index) {
          // Lista de ejemplo para simular los chats
          return ListTile(
            leading: const CircleAvatar(
              // Puedes usar una imagen de placeholder o un ícono
              child: Icon(Icons.person),
            ),
            title: Text("Doctor ${index + 1}"),
            subtitle: const Text("Hola, Docotr, are you there? asd..."),
            trailing: const Text("12:30"),
            onTap: () {
              // Lógica para abrir un chat (opcional por ahora)
            },
          );
        }),
      ),
    );
  }
}
