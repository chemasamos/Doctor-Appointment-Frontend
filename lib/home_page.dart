import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NUEVA IMPORTACIÓN
import 'routes.dart'; // NUEVO: Importado de tu código anterior

// Importamos las páginas que usaremos en la barra de navegación
import 'messages_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Lista de widgets que se mostrarán según el ítem seleccionado
  // AHORA HomePageContent() es constante porque su estado se maneja internamente
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
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configuración',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ---- CAMBIOS IMPORTANTES AQUÍ ----
// HomePageContent ahora es un StatefulWidget para poder cargar y mostrar el nombre del usuario
class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String _userName = 'Usuario'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Cargamos el nombre del usuario al iniciar la pantalla
  }

  // Función para cargar el nombre desde Firestore
  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
      if (mounted && doc.exists && doc.data()!['nombre'] != null && doc.data()!['nombre'].isNotEmpty) {
        setState(() {
          _userName = doc.data()!['nombre'];
        });
      } else {
        // Si no hay nombre en la base de datos, usamos el del email como fallback
        setState(() {
          _userName = user.email?.split('@')[0] ?? 'Usuario';
        });
      }
    } catch (e) {
      // En caso de error, mantenemos el nombre por defecto
      print("Error al cargar el nombre del usuario: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    // Lista de especialistas de ejemplo
    final List<String> especialistas = [
      'Cardiología', 'Dermatología', 'Neurología', 'Pediatría', 'General'
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("¡Hola, $_userName!"), // Usamos la variable de estado _userName
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
          // NUEVO: Botón de Perfil agregado del código anterior
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Ir a Perfil',
            onPressed: () {
              Navigator.pushNamed(context, Routes.profile);
            },
          ),
          // NUEVO: Botón de Cerrar Sesión agregado del código anterior
          IconButton(
            icon: const Icon(Icons.logout),
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
              const Text(
                "¿En qué podemos ayudarte?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // NUEVO: Se agregó la navegación a Routes.citas en el onTap
                  _buildServiceCard(
                    context, 
                    Icons.calendar_today, 
                    "Agendar\nuna Cita",
                    () {
                      // Esta es la acción del botón "Gestionar Citas"
                      Navigator.pushNamed(context, Routes.citas);
                    }
                  ),
                  _buildServiceCard(
                    context, 
                    Icons.lightbulb_outline, 
                    "Consejos\nMédicos",
                    () {
                      // Acción para Consejos Médicos
                    }
                  ),
                ],
              ),
              const SizedBox(height: 30),

              const Text(
                "Especialistas",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: especialistas.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(especialistas[index]),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                "Doctores Populares",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person)),
                  title: Text("Dr. Juan Pérez"),
                  subtitle: Text("Cardiólogo"),
                  trailing: Icon(Icons.star, color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NUEVO: El método ahora acepta un parámetro `onTap` de tipo VoidCallback
  Widget _buildServiceCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Card(
        elevation: 2.0,
        child: InkWell(
          onTap: onTap, // Usamos el parámetro onTap aquí
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: Theme.of(context).primaryColor),
                const SizedBox(height: 10),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}