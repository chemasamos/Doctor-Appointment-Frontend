// messages_page.dart
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --- NUEVO: Lista de chats simulados ---
    final List<Map<String, String>> chats = [
      {
        "name": "Dr. Alejandro Mendoza",
        "message": "Hola Jose, ¿cómo sigues del dolor? Tus resultados están listos.",
        "time": "09:15 AM",
      },
      {
        "name": "Dra. Isabel Reyes (Cardiología)",
        "message": "Buenos días, solo para recordarte tu cita de mañana a las 10:00 a.m.",
        "time": "Ayer",
      },
      {
        "name": "Dr. Carlos Herrera",
        "message": "Entendido, por favor, toma el medicamento cada 8 horas.",
        "time": "Ayer",
      },
      {
        "name": "Clínica Bienestar",
        "message": "Estimado paciente, su factura ha sido generada.",
        "time": "25/10/25",
      },
      {
        "name": "Dra. Sofía Navarro",
        "message": "Vi tu historial. ¿Podrías describirme mejor el padecimiento?",
        "time": "24/10/25",
      },
      {
        "name": "Soporte Técnico",
        "message": "Hemos actualizado nuestros términos de servicio.",
        "time": "22/10/25",
      },
    ];
    // --- FIN de la lista simulada ---

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mensajes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      // --- ACTUALIZADO: ListView.separated usa la lista 'chats' ---
      body: ListView.separated(
        itemCount: chats.length, // Usa la longitud de la lista
        separatorBuilder: (context, index) =>
            const Divider(indent: 72, endIndent: 16, height: 1),
        itemBuilder: (context, index) {
          final chat = chats[index]; // Obtiene el chat actual

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Icon(
                // Icono diferente para "Clínica" o "Soporte"
                chat['name']!.contains("Dr.") || chat['name']!.contains("Dra.")
                    ? Icons.person
                    : Icons.business,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(chat['name']!,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(chat['message']!,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing:
                Text(chat['time']!, style: const TextStyle(color: Colors.grey)),
            onTap: () {
              // Lógica para abrir un chat (sin cambios)
            },
          );
        },
      ),
    );
  }
}