// settings_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // --- NUEVO: Widget helper para los ListTile ---
  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    
    // El AppBar tomará el estilo del Theme
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuración"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        children: <Widget>[
          // NUEVO: Título de sección
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("CUENTA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline,
            title: 'Perfil',
            route: Routes.profile,
          ),
          
          const Divider(indent: 16, endIndent: 16),
          
          // NUEVO: Título de sección
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text("LEGAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacidad',
            route: Routes.privacy,
          ),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Sobre nosotros',
            route: Routes.about,
          ),
          
          const Divider(indent: 16, endIndent: 16),
          const SizedBox(height: 20),

          // Opción para Cerrar Sesión (con estilo)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
            onTap: () async {
              // NUEVO: Diálogo de confirmación para cerrar sesión
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancelar'),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    TextButton(
                      child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                      onPressed: () async {
                        await auth.signOut();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}