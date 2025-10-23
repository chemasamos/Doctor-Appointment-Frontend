import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart'; // Importamos las rutas para navegar

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la instancia de FirebaseAuth para el LogOut
    final FirebaseAuth auth = FirebaseAuth.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
        // elevation: 1, // Descomenta para una ligera sombra
      ),
      body: ListView(
        children: <Widget>[
          // Opción para ir al Perfil
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navegamos a la página de perfil usando el nombre de la ruta
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          const Divider(),

          // Opción para ir a Privacidad
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacidad'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, Routes.privacy);
            },
          ),
          const Divider(),

          // Opción para ir a Sobre Nosotros
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre nosotros'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, Routes.about);
            },
          ),
          const Divider(),

          // Opción para Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              // Cerramos la sesión en Firebase
              await auth.signOut();
              
              // Muy importante: el `if (context.mounted)` comprueba que la pantalla
              // todavía existe antes de intentar navegar, para evitar errores.
              if (context.mounted) {
                // Usamos `pushNamedAndRemoveUntil` para limpiar todas las pantallas 
                // anteriores (Home, Settings, etc.) y que el usuario no pueda "volver atrás"
                // a la app sin iniciar sesión de nuevo.
                Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
              }
            },
          ),
        ],
      ),
    );
  }
}

