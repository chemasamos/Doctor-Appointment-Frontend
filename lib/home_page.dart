// home_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'routes.dart';

import 'messages_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePageContent(),
    MessagesPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // El Scaffold y el BottomNavigationBar tomarán el estilo del Theme
    return Scaffold(
      body: IndexedStack(
        // Usamos IndexedStack para mantener el estado de las páginas
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _userName = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (mounted && doc.exists && doc.data()?['nombre'] != null && doc.data()!['nombre'].isNotEmpty) {
        setState(() {
          _userName = doc.data()!['nombre'];
        });
      } else if (mounted) {
        setState(() {
          _userName = user.email?.split('@')[0] ?? 'Usuario';
        });
      }
    } catch (e) {
      print("Error al cargar el nombre del usuario: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> especialistas = [
      'Cardiología', 'Dermatología', 'Neurología', 'Pediatría', 'General'
    ];
    
    // El AppBar tomará el estilo del Theme
    return Scaffold(
      appBar: AppBar(
        title: Text("¡Hola, $_userName!"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Ir a Perfil',
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          // El botón de Logout se movió a SettingsPage, pero lo dejamos
          // aquí si lo prefieres, aunque está duplicado.
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, Routes.login);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NUEVO: Título con estilo del tema
              Text(
                "¿En qué podemos ayudarte?",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildServiceCard(
                    context,
                    Icons.calendar_today_outlined,
                    "Agendar Cita",
                    () {
                      Navigator.pushNamed(context, Routes.citas);
                    },
                  ),
                  const SizedBox(width: 16),
                  _buildServiceCard(
                    context,
                    Icons.lightbulb_outline,
                    "Consejos Médicos",
                    () {
                      // Acción para Consejos Médicos
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // NUEVO: Título con estilo del tema
              Text(
                "Especialistas",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              
              // --- CAMBIO DE DISEÑO: Chips en lugar de Cards ---
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: especialistas.map((especialista) {
                  return Chip(
                    label: Text(especialista),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),

              // NUEVO: Título con estilo del tema
              Text(
                "Doctores Populares",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              
              // --- SECCIÓN MODIFICADA CON GESTOS ---
              // ---------------------------------------------------
              // GESTO 3: GESTURE DETECTOR (Doble Toque)
              // ---------------------------------------------------
              // Envolvemos la Card con el GestureDetector
              GestureDetector(
                onDoubleTap: () {
                  // Acción al hacer doble toque
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Dr. Juan Pérez añadido a favoritos'),
                      backgroundColor: Colors.blueAccent,
                    ),
                  );
                  
                  // --- Explicación para tu PDF ---
                  // En una app real, aquí llamarías a Firebase:
                  //
                  // final user = FirebaseAuth.instance.currentUser;
                  // if (user != null) {
                  //   FirebaseFirestore.instance
                  //       .collection('usuarios')
                  //       .doc(user.uid)
                  //       .collection('favoritos')
                  //       .doc('id_dr_juan_perez') // ID del doctor
                  //       .set({'nombre': 'Dr. Juan Pérez', 'esFavorito': true});
                  // }
                  // ---------------------------------------
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                    ),
                    title: const Text("Dr. Juan Pérez", style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Cardiólogo"),
                    trailing: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text("4.9", style: TextStyle(fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
              ),
              // --- FIN SECCIÓN MODIFICADA ---
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET MEJORADO: _buildServiceCard ---
  Widget _buildServiceCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0), // Coincide con el CardTheme
        child: Card(
          // La Card ya toma el estilo del Theme
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}