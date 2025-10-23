import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Política de Privacidad"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Política de Privacidad",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Tu privacidad es importante para nosotros. En esta política de privacidad, te explicamos qué datos personales recopilamos de ti y cómo los usamos.\n\n"
                "1. Información que recopilamos: Recopilamos la información que nos proporcionas directamente, como tu nombre, correo electrónico, y datos de salud que decidas compartir.\n\n"
                "2. Cómo usamos tu información: Usamos tu información para proporcionarte nuestros servicios, comunicarnos contigo, y mejorar nuestra aplicación.\n\n"
                "3. Cómo compartimos tu información: No compartimos tu información personal con terceros, excepto cuando sea necesario para proporcionar nuestros servicios o cuando la ley lo exija.",
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
