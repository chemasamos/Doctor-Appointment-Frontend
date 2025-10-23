import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre Nosotros"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sobre DoctorAppointmentApp",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "DoctorAppointmentApp es una aplicación diseñada para facilitar la programación de citas médicas, permitiéndote encontrar especialistas y gestionar tu salud de una manera más sencilla.\n\n"
                "Nuestra misión es conectar a pacientes con profesionales de la salud de una forma eficiente y segura. Creemos que la tecnología puede mejorar la calidad de vida de las personas, y estamos comprometidos con ello.",
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
