// login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class LoginPage extends StatefulWidget {
  // Convertido a const
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // NUEVO: Estado de carga para el botón
  bool _isLoading = false;

  // NUEVO: Función de login separada
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Bienvenido ${userCredential.user!.email}"),
            backgroundColor: Theme.of(context).colorScheme.primary),
      );
      Navigator.pushReplacementNamed(context, Routes.home);
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta";
      } else {
        message = e.message ?? "Ocurrió un error";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Quitamos el AppBar para un look de login más limpio
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // NUEVO: Título elegante
                    Icon(
                      Icons.medical_services_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Bienvenido de Vuelta",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Inicia sesión para continuar",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                    const SizedBox(height: 32),
                    
                    // El TextFormField ya toma el estilo del InputDecorationTheme
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Correo electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return "Por favor ingresa un correo válido";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // El TextFormField ya toma el estilo del InputDecorationTheme
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Por favor ingresa tu contraseña";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // El ElevatedButton ya toma el estilo del Theme
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text("Iniciar sesión"),
                    ),
                    const SizedBox(height: 16),

                    // CAMBIO: Botón secundario para la acción "Cerrar sesión"
                    OutlinedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sesión cerrada")),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).textTheme.bodySmall?.color,
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text("Cerrar sesión (Botón Secundario)"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}