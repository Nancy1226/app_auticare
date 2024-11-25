import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_auticare/Views/user_specialist/profile_specialist.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Widgets/cuestom_navigation_bar_specialist.dart';
import 'package:app_auticare/Widgets/custom_modal.dart';
import 'package:app_auticare/Widgets/app_routes.dart'; 


class HomeSpecialist extends StatefulWidget {
  const HomeSpecialist({Key? key}) : super(key: key);

  @override
  State<HomeSpecialist> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeSpecialist> {
   int _selectedIndex = 0;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? token;
  String? nombre;
  String? selectedCategory;

  final List<String> categories = [
    'Diagnóstico y Evaluación',
    'Tratamientos y Terapias',
    'Educación y Apoyo Escolar',
    'Vida Familiar y Social',
    'Salud y Bienestar',
    'Recursos y Servicios'
  ];

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    token = await storage.read(key: 'authToken');
    nombre = await storage.read(key: 'nombre');

    print('Token recuperado: $token');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola ${nombre ?? "invitado"}!',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "Revision",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFF1F5F9),
              backgroundImage: AssetImage("lib/assets/profile.png"),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfileSpecialist()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            hint: Text(
              'Selecciona una categoría',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            items: categories
                .map((category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),
          buildActivityCard(
            color: Color(0xFF515AA7),
            icon: Icons.book,
            title: "Leer un libro",
            psychologist: "Psic. Ariana Alexia",
            validated: true,
            image: "lib/assets/book.png",
          ),
          const SizedBox(height: 16),
          buildActivityCard(
            color: Color(0xFFF29826),
            icon: Icons.directions_walk,
            title: "Salir a caminar",
            psychologist: "Psic. Ariana Alexia",
            validated: true,
            image: "lib/assets/walking.png",
          ),
          const SizedBox(height: 16),
          buildActivityCard(
            color: Color(0xFFEC694E),
            icon: Icons.music_note,
            title: "Escuchar música",
            psychologist: "Psic. Ariana Alexia",
            validated: true,
            image: "lib/assets/music.png",
          ),
        ],
      ),
      bottomNavigationBar: CustomNavigationBarSpecialist(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navega a la ruta correspondiente
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.home_specialist);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.profile_specialist);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile_specialist);
              break;
          }
        },
      ),
    );
  }

  Widget buildActivityCard({
    required Color color,
    required IconData icon,
    required String title,
    required String psychologist,
    required bool validated,
    required String image,
  }) {
    return Container(
      width: 300,
      height: 220,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(title,
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
              if (validated)
                const Text(
                  "✔ Por validar",
                  style: TextStyle(color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ElevatedButton(
              onPressed: () {
                // Mostrar el modal al presionar el botón
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true, // Permite que el modal se ajuste a su contenido
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return CustomModal(); // Llama al componente del modal
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Ver más"),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    psychologist,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              Image.asset(
                image,
                height: 100,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

