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
  String _userRol = 'paciente'; // NUEVO: Estado para el rol
  bool _isLoading = true; // NUEVO: Estado de carga

  @override
  void initState() {
    super.initState();
    _loadUserData(); // MODIFICADO: Renombramos la función
  }

  // MODIFICADO: Ahora carga nombre y rol
  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      final data = doc.data();

      if (mounted && doc.exists && data != null) {
        _userName = data['nombre'] ?? user.email?.split('@')[0] ?? 'Usuario';
        _userRol = data['rol'] ?? 'paciente'; // Obtenemos el rol
      } else if (mounted) {
        // Fallback si no hay documento en firestore
        _userName = user.email?.split('@')[0] ?? 'Usuario';
        _userRol = 'paciente'; // Rol por defecto
      }
    } catch (e) {
      print("Error al cargar datos del usuario: $e");
      if (mounted) {
        _userName = user.email?.split('@')[0] ?? 'Usuario';
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> especialistas = [
      'Cardiología', 'Dermatología', 'Neurología', 'Pediatría', 'General'
    ];

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
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, Routes.login);
              }
            },
          )
        ],
      ),
      body: _isLoading // NUEVO: Muestra un indicador de carga
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "¿En qué podemos ayudarte?",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // --- INICIO DE LÓGICA CONDICIONAL ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // MODIFICADO: El primer botón cambia según el rol
                        if (_userRol == 'medico')
                          _buildServiceCard(
                            context,
                            Icons.dashboard_outlined, // Icono de Dashboard
                            "Ver Dashboard", // Texto para médico
                            () {
                              // Navega al dashboard
                              Navigator.pushNamed(context, Routes.dashboard);
                            },
                          )
                        else
                          _buildServiceCard(
                            context,
                            Icons.calendar_today_outlined, // Icono de Cita
                            "Agendar Cita", // Texto para paciente
                            () {
                              // Navega a la páginda de citas
                              Navigator.pushNamed(context, Routes.citas);
                            },
                          ),
                        // --- FIN DE LÓGICA CONDICIONAL ---

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

                    Text(
                      "Especialistas",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),

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

                    Text(
                      "Doctores Populares",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    
                    GestureDetector(
                      onDoubleTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Dr. Juan Pérez añadido a favoritos'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
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
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildServiceCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Card(
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