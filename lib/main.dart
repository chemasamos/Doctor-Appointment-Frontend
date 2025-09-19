import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// Convertido a StatefulWidget para manejar la interacción en tiempo real
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // El método para guardar la cita ahora vive dentro del State
  Future<void> _guardarCitaDemo() async {
    try {
      await FirebaseFirestore.instance.collection('citas_prueba').add({
        'paciente': 'Erick Estrella',
        'sintoma': 'Dolor de cabeza',
        'fecha': '2025-09-20',
        'timestamp': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita guardada correctamente ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
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
        title: const Text('Citas Médicas de Prueba'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // Usamos un StreamBuilder para escuchar los datos de Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('citas_prueba').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay citas guardadas.'));
          }

          final citas = snapshot.data!.docs;
          // Mostramos los datos en una lista
          return ListView.builder(
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.receipt_long),
                title: Text('Paciente: ${cita['paciente']}'),
                subtitle: Text('Síntoma: ${cita['sintoma']}  |  Fecha: ${cita['fecha']}'),
              );
            },
          );
        },
      ),
      // Botón flotante para añadir nuevas citas
      floatingActionButton: FloatingActionButton(
        onPressed: _guardarCitaDemo,
        tooltip: 'Añadir Cita de Prueba',
        child: const Icon(Icons.add),
      ),
    );
  }
}