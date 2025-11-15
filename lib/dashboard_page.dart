// NUEVO ARCHIVO: lib/dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Médico'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Resumen de Actividad',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Indicador 1: Total de Citas
              _buildIndicatorCard(
                context: context,
                stream: FirebaseFirestore.instance.collection('citas').snapshots(),
                title: 'Total de Citas',
                icon: Icons.calendar_month,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),

              // Indicador 2: Citas Pendientes (Próximas)
              _buildIndicatorCard(
                context: context,
                stream: FirebaseFirestore.instance
                    .collection('citas')
                    .where('fecha', isGreaterThan: Timestamp.now()) // Asume que tienes un campo 'fecha'
                    .snapshots(),
                title: 'Citas Pendientes',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),

              // Indicador 3: Total de Pacientes
              _buildIndicatorCard(
                context: context,
                stream: FirebaseFirestore.instance
                    .collection('usuarios') // Asegúrate que tu colección se llame 'usuarios'
                    .where('rol', isEqualTo: 'paciente')
                    .snapshots(),
                title: 'Total de Pacientes',
                icon: Icons.group,
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para los indicadores con StreamBuilder
  Widget _buildIndicatorCard({
    required BuildContext context,
    required Stream<QuerySnapshot> stream,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Este es el StreamBuilder que actualiza el dato en tiempo real
                  StreamBuilder<QuerySnapshot>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 3),
                        );
                      }
                      if (snapshot.hasError) {
                        return const Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        // Obtenemos el total de documentos
                        final count = snapshot.data!.docs.length;
                        return Text(
                          count.toString(),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                        );
                      }
                      return const Text(
                        '0',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}