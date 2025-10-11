import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  // asegura q primero jale una cosa para q jale todo
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Citas Médicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // color de la app
        primaryColor: const Color(0xFF00796B), 
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // inicio de sesion 

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: userCredential.user!),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Ocurrió un error.";
        if (e.code == 'user-not-found') {
          message = "No se encontró un usuario con ese correo.";
        } else if (e.code == 'wrong-password') {
          message = "Contraseña incorrecta.";
        } else {
          message = e.message ?? "Error desconocido.";
        }
        _showErrorSnackbar(message);
      }
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        _showSuccessSnackbar("¡Cuenta creada con éxito! Por favor, inicia sesión.");

      } on FirebaseAuthException catch (e) {
        String message = "Ocurrió un error al crear la cuenta.";
        if (e.code == 'weak-password') {
          message = 'La contraseña es muy débil.';
        } else if (e.code == 'email-already-in-use') {
          message = 'El correo electrónico ya está en uso.';
        } else {
           message = e.message ?? "Error desconocido.";
        }
        _showErrorSnackbar(message);
      }
    }
  }
  
  Future<void> _resetPassword() async {
     if (emailController.text.trim().isEmpty) {
        _showErrorSnackbar("Por favor, ingrese su correo para restablecer la contraseña.");
        return;
    }
    try {
        await _auth.sendPasswordResetEmail(email: emailController.text.trim());
        _showSuccessSnackbar("Se ha enviado un enlace para restablecer la contraseña a su correo.");
    } on FirebaseAuthException catch (e) {
        _showErrorSnackbar(e.message ?? "No se pudo enviar el correo de restablecimiento.");
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
     if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Logotipo o Icono
                  Icon(
                    Icons.medical_services_outlined,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Bienvenido de Nuevo",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Inicia sesión para agendar tu cita",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  // 2. Campo de correo electrónico
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 3. Campo de contraseña
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                         borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor ingrese su contraseña";
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // 4. Botón de "Olvidó su contraseña"
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Olvidó su contraseña',
                        style: TextStyle(color: Theme.of(context).primaryColor),
                        ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // 5. Botón para iniciar sesión
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),

                  // 6. Botón de "Crear una cuenta nueva"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta?"),
                      TextButton(
                        onPressed: _createAccount,
                        child: Text(
                          'Crear una cuenta nueva',
                           style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold
                            ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// pantalla de inicio de sesion exitoso
class HomePage extends StatelessWidget {
  final User user;

  const HomePage({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Página Principal"),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¡Bienvenido!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user.email ?? "Usuario",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
