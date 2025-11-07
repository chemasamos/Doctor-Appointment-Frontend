// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CitasPage extends StatefulWidget {
  const CitasPage({super.key});

  @override
  State<CitasPage> createState() => _CitasPageState();
}

class _CitasPageState extends State<CitasPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _sintomasController = TextEditingController();
  final TextEditingController _buscarUsuarioController = TextEditingController();

  String? _nombreUsuario;
  String? _usuarioSeleccionadoId;
  String? _doctorSeleccionado;
  DateTime? _fechaSeleccionada;
  DateTime? _fechaFinSeleccionada;
  String? _citaEnEdicion;
  bool _isSaving = false;

  final DateFormat _formatter = DateFormat('dd/MM/yyyy hh:mm a');

  // Lista de doctores predeterminados
  final List<String> _doctores = [
    'Dr. García Martínez',
    'Dra. López Hernández',
    'Dr. Rodríguez Silva',
    'Dra. Fernández Torres',
    'Dr. Sánchez Morales',
  ];

  @override
  void initState() {
    super.initState();
    _cargarNombreUsuario();
  }

  Future<void> _cargarNombreUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists && doc.data() != null && mounted) {
        setState(() {
          _nombreUsuario = doc.data()!['nombre'] ?? 'Usuario sin nombre';
          _usuarioSeleccionadoId = user.uid;
        });
      } else {
        _nombreUsuario = 'Usuario Anónimo';
      }
    } catch (e) {
      print("⚠️ Error cargando nombre usuario: $e");
    }
  }

  Future<void> _guardarCita() async {
    if (_sintomasController.text.isEmpty ||
        _doctorSeleccionado == null ||
        _fechaSeleccionada == null ||
        _fechaFinSeleccionada == null ||
        _usuarioSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completa todos los campos"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_fechaFinSeleccionada!.isAfter(_fechaSeleccionada!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("La hora de fin debe ser posterior a la de inicio"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("No hay usuario autenticado");

      print("✅ Usuario autenticado: ${user.uid}");
      print("🕓 Guardando cita en Firestore...");

      final data = {
        'uid': _usuarioSeleccionadoId,
        'nombreUsuario': _nombreUsuario ?? 'Usuario anónimo',
        'sintomas': _sintomasController.text.trim(),
        'medico': _doctorSeleccionado,
        'fechaHora': Timestamp.fromDate(_fechaSeleccionada!),
        'horaFin': Timestamp.fromDate(_fechaFinSeleccionada!),
        'creadoEn': FieldValue.serverTimestamp(),
        'creadoPor': user.uid,
      };

      await _firestore.collection('citas').add(data);

      print("✅ Cita guardada correctamente");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cita guardada correctamente"),
          backgroundColor: Colors.green,
        ),
      );

      _limpiarCampos();
    } on FirebaseException catch (e) {
      print("🔥 Error de Firebase: ${e.code} - ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error de Firebase: ${e.message}"),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("🔥 Error general al guardar cita: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al guardar cita: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _limpiarCampos() {
    _sintomasController.clear();
    _buscarUsuarioController.clear();
    setState(() {
      _fechaSeleccionada = null;
      _fechaFinSeleccionada = null;
      _citaEnEdicion = null;
      _doctorSeleccionado = null;
      // Mantener el usuario actual seleccionado
      _cargarNombreUsuario();
    });
  }

  // --- MODIFICACIÓN GESTOS ---
  // 1. Muestra el diálogo de confirmación para el Dismissible
  Future<bool> _mostrarDialogoConfirmacion() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas cancelar esta cita?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancelar Cita'),
          ),
        ],
      ),
    );
    // Si el usuario cierra el diálogo sin presionar, devolvemos 'false'
    return confirmacion ?? false;
  }

  // 2. Lógica de eliminación en Firebase
  Future<void> _eliminarCitaDeFirebase(String citaId) async {
    try {
      await _firestore.collection('citas').doc(citaId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cita cancelada correctamente"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cancelar cita: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // 3. Función para el RefreshIndicator
  Future<void> _handleRefresh() async {
    // El StreamBuilder se reconstruirá solo.
    // Damos un pequeño delay para que la animación del spinner sea visible.
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // Forzar la reconstrucción del widget y, por ende, del StreamBuilder
    });
  }
  // --- FIN MODIFICACIÓN GESTOS ---


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

  Future<void> _seleccionarHoraFin() async {
    if (_fechaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Selecciona primero la hora de inicio"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _fechaFinSeleccionada ??
            _fechaSeleccionada!.add(const Duration(hours: 1)),
      ),
    );

    if (pickedTime != null) {
      setState(() {
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

  void _mostrarSelectorUsuarios() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Seleccionar Usuario',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _buscarUsuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar usuario',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('usuarios').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var usuarios = snapshot.data!.docs;

                  // Filtrar usuarios según búsqueda
                  if (_buscarUsuarioController.text.isNotEmpty) {
                    usuarios = usuarios.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = (data['nombre'] ?? '').toLowerCase();
                      final busqueda =
                          _buscarUsuarioController.text.toLowerCase();
                      return nombre.contains(busqueda);
                    }).toList();
                  }

                  if (usuarios.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron usuarios'),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: usuarios.length,
                    itemBuilder: (context, index) {
                      final doc = usuarios[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = data['nombre'] ?? 'Sin nombre';
                      final email = data['email'] ?? 'Sin email';

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(nombre[0].toUpperCase()),
                        ),
                        title: Text(nombre),
                        subtitle: Text(email),
                        trailing: _usuarioSeleccionadoId == doc.id
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : null,
                        onTap: () {
                          setState(() {
                            _usuarioSeleccionadoId = doc.id;
                            _nombreUsuario = nombre;
                            _buscarUsuarioController.clear();
                          });
                          Navigator.pop(context);
                        },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Citas'),
      ),
      body: Column(
        children: [
          // Formulario de nueva cita
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nueva Cita',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Selector de usuario
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(_nombreUsuario ?? 'Seleccionar usuario'),
                      subtitle: const Text('Toca para cambiar'),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _mostrarSelectorUsuarios,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Selector de doctor
                  DropdownButtonFormField<String>(
                    value: _doctorSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Doctor',
                      prefixIcon: Icon(Icons.medical_services),
                      border: OutlineInputBorder(),
                    ),
                    items: _doctores.map((doctor) {
                      return DropdownMenuItem(
                        value: doctor,
                        child: Text(doctor),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _doctorSeleccionado = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Campo de síntomas
                  TextField(
                    controller: _sintomasController,
                    decoration: const InputDecoration(
                      labelText: 'Síntomas',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      border: OutlineInputBorder(),
                      hintText: 'Describe los síntomas',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _seleccionarFechaYHoraInicio,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(_fechaSeleccionada == null
                        ? 'Seleccionar hora de inicio'
                        : 'Inicio: ${_formatter.format(_fechaSeleccionada!)}'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _seleccionarHoraFin,
                    icon: const Icon(Icons.access_time_outlined),
                    label: Text(_fechaFinSeleccionada == null
                        ? 'Seleccionar hora de fin'
                        : 'Fin: ${_formatter.format(_fechaFinSeleccionada!)}'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _guardarCita,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : const Text('Guardar Cita',
                            style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 2),
          
          // --- SECCIÓN MODIFICADA CON GESTOS ---
          // Lista de citas
          Expanded(
            flex: 2,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Citas Agendadas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('citas')
                        .orderBy('fechaHora', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final citas = snapshot.data!.docs;

                      if (citas.isEmpty) {
                        return const Center(
                          child: Text('No hay citas agendadas'),
                        );
                      }

                      // ---------------------------------------------------
                      // GESTO 1: REFRESH INDICATOR (Deslizar para Recargar)
                      // ---------------------------------------------------
                      // Envolvemos el ListView.builder con el RefreshIndicator
                      return RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: ListView.builder(
                          itemCount: citas.length,
                          itemBuilder: (context, index) {
                            final cita = citas[index];
                            final data = cita.data() as Map<String, dynamic>;
                            final fechaHora =
                                (data['fechaHora'] as Timestamp).toDate();
                            final horaFin = data['horaFin'] != null
                                ? (data['horaFin'] as Timestamp).toDate()
                                : null;

                            // ---------------------------------------------------
                            // GESTO 2: DISMISSIBLE (Deslizar para Eliminar)
                            // ---------------------------------------------------
                            // Envolvemos la Card con el Dismissible
                            return Dismissible(
                              // Key única para que Flutter sepa qué item es
                              key: Key(cita.id),
                              // Dirección del gesto
                              direction: DismissDirection.endToStart,
                              
                              // 1. Pide confirmación ANTES de deslizar
                              confirmDismiss: (direction) async {
                                return await _mostrarDialogoConfirmacion();
                              },
                              
                              // 2. Si se confirma, se llama a esta función
                              onDismissed: (direction) {
                                _eliminarCitaDeFirebase(cita.id);
                              },

                              // Fondo rojo que aparece al deslizar
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20.0),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white),
                                    Text("Cancelar", style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              
                              // El widget original (tu Card)
                              child: Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.calendar_today),
                                  ),
                                  title: Text(
                                    data['nombreUsuario'] ?? 'Sin nombre',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Doctor: ${data['medico'] ?? 'N/A'}'),
                                      Text('Síntomas: ${data['sintomas'] ?? data['motivo'] ?? 'N/A'}'),
                                      Text(_formatter.format(fechaHora)),
                                      if (horaFin != null)
                                        Text('Hasta: ${_formatter.format(horaFin)}'),
                                    ],
                                  ),
                                  // ¡Ya no necesitamos el botón de basura!
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // --- FIN SECCIÓN MODIFICADA ---
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sintomasController.dispose();
    _buscarUsuarioController.dispose();
    super.dispose();
  }
}