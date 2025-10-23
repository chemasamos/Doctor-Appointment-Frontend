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

  // Controladores para los campos del formulario
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController edadController = TextEditingController();
  final TextEditingController lugarNacimientoController = TextEditingController();
  final TextEditingController padecimientosController = TextEditingController();

  bool _loading = true; // Inicia en true para mostrar "cargando" al entrar

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Cargar datos del usuario desde Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final doc = await _firestore.collection('usuarios').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        nombreController.text = data['nombre'] ?? '';
        edadController.text = data['edad'] ?? '';
        lugarNacimientoController.text = data['lugar_nacimiento'] ?? '';
        padecimientosController.text = data['padecimientos'] ?? '';
      }
    } catch (e) {
      // Manejo de errores
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar datos: $e")),
        );
      }
    } finally {
      // Nos aseguramos de quitar el indicador de carga
      if(mounted) {
        setState(() => _loading = false);
      }
    }
  }

  // Guardar datos del usuario en Firestore
  Future<void> _saveUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Validar que los campos no estén vacíos (opcional pero recomendado)
    if (nombreController.text.isEmpty || edadController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nombre y edad son campos obligatorios.")),
        );
        return;
    }


    setState(() => _loading = true);

    try {
      await _firestore.collection('usuarios').doc(user.uid).set({
        'nombre': nombreController.text.trim(),
        'edad': edadController.text.trim(),
        'lugar_nacimiento': lugarNacimientoController.text.trim(),
        'padecimientos': padecimientosController.text.trim(),
        'email': user.email, // Guardamos también el email
      }, SetOptions(merge: true)); // merge:true actualiza los campos sin borrar otros

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Información guardada exitosamente")),
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar datos: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Editar Perfil")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Correo: ${user?.email ?? 'No disponible'}",
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // FORMULARIO
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: "Nombre completo"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: edadController,
                      decoration: const InputDecoration(labelText: "Edad"),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: lugarNacimientoController,
                      decoration: const InputDecoration(labelText: "Lugar de nacimiento"),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: padecimientosController,
                      decoration: const InputDecoration(labelText: "Padecimientos"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed: _saveUserData,
                      child: const Text("Guardar informacion"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
