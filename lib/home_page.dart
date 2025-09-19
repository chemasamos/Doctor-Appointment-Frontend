import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Método adaptado para guardar el documento que pide la actividad
  Future<void> _guardarCitaDemo(BuildContext context) async {
    try {
      // ADAPTACIÓN 1: Cambiamos el nombre de la colección
      await FirebaseFirestore.instance.collection('citas_prueba').add({
        // ADAPTACIÓN 2: Ajustamos los campos y valores
        'paciente': 'Erick Estrella',
        'sintoma': 'Dolor de cabeza',
        'fecha': '2025-09-20',
        'timestamp': FieldValue.serverTimestamp(), // Buena práctica para ordenar
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita de prueba guardada correctamente ✅')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Cita de Prueba'),
        // Pequeño ajuste estético para que coincida con el contexto
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _guardarCitaDemo(context),
          child: const Text('Guardar Cita de Prueba'),
        ),
      ),
    );
  }
}
