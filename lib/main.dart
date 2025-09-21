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
  // El método para guardar las citas ahora vive dentro del State
  // MODIFICADO: Ahora guarda una lista de 10 pacientes de prueba
  Future<void> _guardarCitaDemo() async {
    // Lista de 10 pacientes de ejemplo
    final List<Map<String, dynamic>> pacientesDePrueba = [
      {
        'paciente': 'Erick Estrella',
        'sintoma': 'Dolor de cabeza',
        'fecha': '2025-09-20',
      },
      {
        'paciente': 'Ana López',
        'sintoma': 'Fiebre alta',
        'fecha': '2025-09-21',
      },
      {
        'paciente': 'Carlos Martínez',
        'sintoma': 'Tos persistente',
        'fecha': '2025-09-22',
      },
      {
        'paciente': 'Sofía García',
        'sintoma': 'Dolor de garganta',
        'fecha': '2025-09-23',
      },
      {
        'paciente': 'Javier Rodríguez',
        'sintoma': 'Molestias estomacales',
        'fecha': '2025-09-24',
      },
      {
        'paciente': 'Laura Pérez',
        'sintoma': 'Congestión nasal',
        'fecha': '2025-09-25',
      },
      {
        'paciente': 'Miguel Sánchez',
        'sintoma': 'Revisión general',
        'fecha': '2025-09-26',
      },
      {
        'paciente': 'Isabel Gómez',
        'sintoma': 'Reacción alérgica',
        'fecha': '2025-09-27',
      },
      {
        'paciente': 'David Fernández',
        'sintoma': 'Dolor de espalda',
        'fecha': '2025-09-28',
      },
      {
        'paciente': 'Elena Morales',
        'sintoma': 'Mareos y fatiga',
        'fecha': '2025-09-29',
      },
    ];

    try {
      final collection = FirebaseFirestore.instance.collection('citas_prueba');
      // Usamos un WriteBatch para realizar todas las escrituras en una sola operación
      final batch = FirebaseFirestore.instance.batch();

      for (var pacienteData in pacientesDePrueba) {
        // Creamos una nueva referencia de documento para cada paciente
        final docRef = collection.doc();
        // Añadimos el timestamp a los datos del paciente
        final dataConTimestamp = {
          ...pacienteData,
          'timestamp': FieldValue.serverTimestamp(),
        };
        // Preparamos la operación de escritura en el batch
        batch.set(docRef, dataConTimestamp);
      }
      
      // Ejecutamos todas las operaciones del batch
      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('10 citas de prueba guardadas correctamente ✅')),
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
        tooltip: 'Añadir 10 Citas de Prueba',
        child: const Icon(Icons.add),
      ),
    );
  }
}