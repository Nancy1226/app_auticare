import 'package:app_auticare/widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:app_auticare/Widgets/app_routes.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra superior con botón de retroceso y avatar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      // Acción del botón de retroceso
                    },
                  ),
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('lib/assets/profile.png'), // Cambia esto a tu recurso
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Título
              Text(
                'Tablero de comunicación',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Subtítulo
              Text(
                '¿Cómo te sientes hoy?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              // Filtros
              Row(
                children: [
                  FilterChip(
                    label: Text('Feliz'),
                    onSelected: (bool value) {},
                    selected: true,
                    selectedColor: Colors.purple.shade100,
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Triste'),
                    onSelected: (bool value) {},
                    selected: false,
                    labelStyle: TextStyle(color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Grid de emociones
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    EmotionCard(
                      emoji: '😊',
                      label: 'Feliz',
                    ),
                    EmotionCard(
                      emoji: '😡',
                      label: 'Enojado',
                    ),
                    EmotionCard(
                      emoji: '😢',
                      label: 'Triste',
                    ),
                    EmotionCard(
                      emoji: '🤩',
                      label: 'Emocionado',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          // Navega a la ruta correspondiente
          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.home);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.board);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.chat);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.donation);
              break;
          }
        },
      ),
    );
  }
}

class EmotionCard extends StatelessWidget {
  final String emoji;
  final String label;

  const EmotionCard({
    Key? key,
    required this.emoji,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
