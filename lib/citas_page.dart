// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // NUEVO: Para formatear fechas y horas

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _motivoController = TextEditingController();
  // NUEVO: Controlador para el médico
  final TextEditingController _medicoController = TextEditingController();

  String? _nombreUsuario;
  DateTime? _fechaSeleccionada;
  // NUEVO: Fecha y hora de finalización de la cita
  DateTime? _fechaFinSeleccionada;
  String? _citaEnEdicion; // ID de la cita que estamos editando

  // NUEVO: Formateador para mostrar la fecha y hora de forma legible
  final DateFormat _formatter = DateFormat('dd/MM/yyyy hh:mm a');

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  // Cargar el nombre del usuario desde Firestore
  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await _firestore.collection('usuarios').doc(user.uid).get();
    if (doc.exists && doc.data() != null) {
      setState(() {
        _nombreUsuario = doc.data()!['nombre'] ?? 'Usuario sin nombre';
      });
    }
  }

  // MODIFICADO: Seleccionar solo fecha y hora de INICIO
  Future<void> _seleccionarFechaYHoraInicio() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_fechaSeleccionada ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _fechaSeleccionada = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  // NUEVO: Seleccionar solo la hora de FIN
  Future<void> _seleccionarHoraFin() async {
    // Asegurarse de que la hora de inicio ya fue seleccionada
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecciona primero la hora de inicio")),
      );
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
          _fechaFinSeleccionada ?? _fechaSeleccionada!.add(const Duration(hours: 1))),
    );

    if (pickedTime != null) {
      setState(() {
        // Usamos la misma fecha que la de inicio, solo cambiamos la hora
        _fechaFinSeleccionada = DateTime(
          _fechaSeleccionada!.year,
          _fechaSeleccionada!.month,
          _fechaSeleccionada!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  // MODIFICADO: Agregar o actualizar cita con validaciones
  Future<void> _guardarCita() async {
    // MODIFICADO: Validación de campos
    if (_motivoController.text.isEmpty ||
        _medicoController.text.isEmpty ||
        _fechaSeleccionada == null ||
        _fechaFinSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    // NUEVO: Validación de que la hora de fin sea posterior a la de inicio
    if (!_fechaFinSeleccionada!.isAfter(_fechaSeleccionada!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La hora de fin debe ser posterior a la hora de inicio")),
      );
      return;
    }

    // NUEVO: Validación de superposición de citas 
    // (OldEnd > NewStart) Y (OldStart < NewEnd)
    
    // 1. Convertimos las nuevas fechas a Timestamps
    final newStart = Timestamp.fromDate(_fechaSeleccionada!);
    final newEnd = Timestamp.fromDate(_fechaFinSeleccionada!);

    // 2. Buscamos citas existentes que terminen DESPUÉS de que la nuestra EMPIEZA
    final querySnapshot = await _firestore
        .collection('citas')
        .where('horaFin', isGreaterThan: newStart)
        .get();
        
    bool haySuperposicion = false;
    for (var doc in querySnapshot.docs) {
      // 3. De esos resultados, verificamos si alguno empieza ANTES de que la nuestra TERMINE
      final oldStart = (doc.data()['fechaHora'] as Timestamp);

      // 4. Excluimos el documento que estamos editando de la comprobación
      if (doc.id != _citaEnEdicion && oldStart.toDate().isBefore(newEnd.toDate())) {
        haySuperposicion = true;
        break;
      }
    }

    if (haySuperposicion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: El horario se superpone con otra cita existente.")),
      );
      return; // Detenemos la ejecución
    }
    
    // Si pasa las validaciones, guardamos los datos
    final data = {
      'nombreUsuario': _nombreUsuario ?? 'Sin nombre',
      'motivo': _motivoController.text.trim(),
      'medico': _medicoController.text.trim(), // NUEVO
      'fechaHora': newStart, // MODIFICADO (antes era Timestamp.fromDate(_fechaSeleccionada!))
      'horaFin': newEnd, // NUEVO
      'creadoEn': FieldValue.serverTimestamp(),
    };

    if (_citaEnEdicion == null) {
      // Agregar nueva cita
      await _firestore.collection('citas').add(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cita creada")));
    } else {
      // Actualizar cita existente
      await _firestore.collection('citas').doc(_citaEnEdicion).update(data);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Cita actualizada")));
    }
    _limpiarCampos();
  }

  void _limpiarCampos() {
    _motivoController.clear();
    _medicoController.clear(); // NUEVO
    setState(() {
      _fechaSeleccionada = null;
      _fechaFinSeleccionada = null; // NUEVO
      _citaEnEdicion = null;
    });
  }

  // NUEVO: Diálogo de confirmación para eliminar 
  Future<void> _mostrarDialogoConfirmacion(String id) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // El usuario debe tocar un botón
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const SingleChildScrollView(
            child: Text('¿Estás seguro de que deseas eliminar esta cita?'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                _eliminarCita(id);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Eliminar cita (esta función ahora es llamada por el diálogo)
  Future<void> _eliminarCita(String id) async {
    await _firestore.collection('citas').doc(id).delete();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Cita eliminada")));
  }

  // Preparar cita para edición
  void _editarCita(String id, Map<String, dynamic> data) {
    setState(() {
      _citaEnEdicion = id;
      _motivoController.text = data['motivo'] ?? '';
      _medicoController.text = data['medico'] ?? ''; // NUEVO
      _fechaSeleccionada =
          (data['fechaHora'] as Timestamp?)?.toDate() ?? DateTime.now();
      _fechaFinSeleccionada =
          (data['horaFin'] as Timestamp?)?.toDate(); // NUEVO
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Citas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _nombreUsuario == null
                  ? 'Cargando usuario...'
                  : 'Paciente: $_nombreUsuario',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _motivoController,
              decoration: const InputDecoration(labelText: 'Motivo de la cita'),
            ),
            // NUEVO: Campo para el médico
            TextField(
              controller: _medicoController,
              decoration: const InputDecoration(labelText: 'Médico'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaSeleccionada == null
                        ? 'No se ha seleccionado hora de inicio'
                        // MODIFICADO: Usar formateador
                        : 'Inicio: ${_formatter.format(_fechaSeleccionada!)}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  // MODIFICADO: Llamar a la función específica
                  onPressed: _seleccionarFechaYHoraInicio,
                ),
              ],
            ),
            // NUEVO: Selector de hora de fin
            Row(
              children: [
                Expanded(
                  child: Text(
                    _fechaFinSeleccionada == null
                        ? 'No se ha seleccionado hora de fin'
                        // MODIFICADO: Usar formateador
                        : 'Fin: ${_formatter.format(_fechaFinSeleccionada!)}',
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.access_time_filled),
                  onPressed: _seleccionarHoraFin,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _guardarCita,
              child: Text(
                _citaEnEdicion == null ? 'Programar cita' : 'Guardar cambios',
              ),
            ),
            const SizedBox(height: 20),
            const Text("Próximas Citas", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('citas')
                    .orderBy('fechaHora', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final citas = snapshot.data!.docs;
                  if (citas.isEmpty) {
                    return const Center(child: Text('No hay citas programadas'));
                  }

                  return ListView.builder(
                    itemCount: citas.length,
                    itemBuilder: (context, index) {
                      final cita = citas[index];
                      final data = cita.data() as Map<String, dynamic>;
                      
                      // MODIFICADO: Obtener todas las fechas
                      final fechaInicio = (data['fechaHora'] as Timestamp?)?.toDate();
                      final fechaFin = (data['horaFin'] as Timestamp?)?.toDate();
                      final medico = data['medico'] ?? 'Sin médico';

                      return Card(
                        child: ListTile(
                          // MODIFICADO: Mostrar más info
                          title: Text(
                              "${data['motivo'] ?? 'Sin motivo'} - ($medico)"),
                          subtitle: Text(
                              // MODIFICADO: Mostrar rango de fechas
                              'Paciente: ${data['nombreUsuario'] ?? 'N/A'}\n'
                              'Inicio: ${fechaInicio != null ? _formatter.format(fechaInicio) : 'N/A'}\n'
                              'Fin: ${fechaFin != null ? _formatter.format(fechaFin) : 'N/A'}'),
                          isThreeLine: true, // NUEVO: Para que quepa el subtítulo
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarCita(cita.id, data),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                // MODIFICADO: Llamar al diálogo de confirmación
                                onPressed: () => _mostrarDialogoConfirmacion(cita.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}