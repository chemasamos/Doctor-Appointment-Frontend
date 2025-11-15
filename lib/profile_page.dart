import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController fechaNacimientoController = TextEditingController();
  final TextEditingController padecimientosController = TextEditingController();

  // NUEVO: Variable de estado para el rol
  String? _selectedRol = 'paciente'; // Valor por defecto

  bool _isLoading = true;
  bool _isSaving = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    _user = _auth.currentUser;

    if (_user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final doc = await _firestore.collection('usuarios').doc(_user!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        nombreController.text = data['nombre'] ?? '';
        edadController.text = data['edad']?.toString() ?? '';
        fechaNacimientoController.text = data['fechaNacimiento'] ?? '';
        padecimientosController.text = data['padecimientos'] ?? '';
        // NUEVO: Cargar el rol guardado
        _selectedRol = data['rol'] ?? 'paciente';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al cargar datos: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate() || _user == null) return;
    setState(() => _isSaving = true);

    try {
      final data = {
        'nombre': nombreController.text.trim(),
        'edad': int.tryParse(edadController.text.trim()) ?? 0, // MODIFICADO: guardamos como número
        'fechaNacimiento': fechaNacimientoController.text.trim(),
        'padecimientos': padecimientosController.text.trim(),
        'email': _user!.email,
        'rol': _selectedRol, // NUEVO: Guardar el rol
      };

      await _firestore
          .collection('usuarios')
          .doc(_user!.uid)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Información guardada correctamente"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    edadController.dispose();
    fechaNacimientoController.dispose();
    padecimientosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_user?.email != null)
                        Card(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              'Email: ${_user!.email}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // NUEVO: Dropdown para seleccionar ROL
                      DropdownButtonFormField<String>(
                        value: _selectedRol,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de Usuario (Rol)',
                          prefixIcon: Icon(Icons.admin_panel_settings_outlined), // <-- ÍCONO CORREGIDO
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'paciente',
                            child: Text('Paciente'),
                          ),
                          DropdownMenuItem(
                            value: 'medico',
                            child: Text('Médico'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRol = value;
                          });
                        },
                        validator: (v) => v == null ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: nombreController,
                        decoration: const InputDecoration(
                          labelText: "Nombre completo",
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: edadController,
                        decoration: const InputDecoration(
                          labelText: "Edad",
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: fechaNacimientoController,
                        decoration: const InputDecoration(
                          labelText: "Fecha de nacimiento",
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: padecimientosController,
                        decoration: const InputDecoration(
                          labelText: "Padecimientos (alergias, etc.)",
                          prefixIcon: Icon(Icons.healing_outlined),
                        ),
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveUserData,
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text("Guardar Información"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}