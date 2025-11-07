import 'package:flutter/material.dart';
import 'dart:math' as math;

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre Nosotros"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sobre DoctorAppointmentApp",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                "DoctorAppointmentApp es una aplicación diseñada para facilitar la programación de citas médicas, permitiéndote encontrar especialistas y gestionar tu salud de una manera más sencilla.\n\n"
                "Nuestra misión es conectar a pacientes con profesionales de la salud de una forma eficiente y segura. Creemos que la tecnología puede mejorar la calidad de vida de las personas, y estamos comprometidos con ello.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                    ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 40),

              // 🔮 Botón secreto
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecretitoMagicoPage(),
                      ),
                    );
                  },
                  child: const Text("Secretito mágico 💫"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🌟 Nueva página del “secretito mágico”
class SecretitoMagicoPage extends StatefulWidget {
  const SecretitoMagicoPage({super.key});

  @override
  State<SecretitoMagicoPage> createState() => _SecretitoMagicoPageState();
}

class _SecretitoMagicoPageState extends State<SecretitoMagicoPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      appBar: AppBar(
        title: const Text("✨ Secretito Mágico ✨"),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _controller.value * 2 * math.pi,
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/novia.jpg',
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "m gustas guapetona 💖",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
