import 'package:flutter/material.dart';
import 'package:app_auticare/widgets/custom_navigation_bar.dart';
import 'package:app_auticare/Widgets/app_routes.dart';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);

  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  int _selectedIndex = 1;
  String _selectedFilter = 'Todos';

  // Lista de emociones usando la propiedad assets
  final List<EmotionData> allEmotions = [
    EmotionData(
      imagePath: 'lib/assets/feliz.png',
      label: 'Feliz',
      type: 'Feliz',
    ),
    EmotionData(
      imagePath: 'lib/assets/enojado.png',
      label: 'Enojado',
      type: 'Enojado',
    ),
    EmotionData(
      imagePath: 'lib/assets/triste.png',
      label: 'Triste',
      type: 'Triste',
    ),
    EmotionData(
      imagePath: 'lib/assets/emocionado.png',
      label: 'Emocionado',
      type: 'Emocionado',
    ),
  ];

  void _handleNavigationTap(int index) {
    if (mounted) {
      setState(() {
       _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.of(context).pushReplacementNamed(AppRoutes.home_tutor);
          break;
        case 1:
          break;
        case 2:
          Navigator.of(context).pushReplacementNamed(AppRoutes.chat);
          break;
        case 3:
          Navigator.of(context).pushReplacementNamed(AppRoutes.profile_childs);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<EmotionData> filteredEmotions = _selectedFilter == 'Todos' 
        ? allEmotions 
        : allEmotions.where((emotion) => emotion.type == _selectedFilter).toList();

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home_tutor);
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF1F5F9),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tablero de comunicación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const ProfileTutor()),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.transparent,
                        child: Image(
                          image: AssetImage('lib/assets/profile.png'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '¿Cómo te sientes hoy?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text(
                          'Feliz',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: _selectedFilter == 'Feliz',
                        onSelected: (bool value) {
                          setState(() {
                            _selectedFilter = value ? 'Feliz' : 'Todos';
                          });
                        },
                        backgroundColor: const Color(0xFF6A62B7),
                        selectedColor: const Color(0xFF6A62B7),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text(
                          'Triste',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selected: _selectedFilter == 'Triste',
                        onSelected: (bool value) {
                          setState(() {
                            _selectedFilter = value ? 'Triste' : 'Todos';
                          });
                        },
                        backgroundColor: const Color(0xFF6A62B7),
                        selectedColor: const Color(0xFF6A62B7),
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: filteredEmotions.map((emotion) {
                      return EmotionCard(
                        imagePath: emotion.imagePath,
                        label: emotion.label,
                        onTap: () => _showEmotionDialog(context, emotion),
                        isSelected: emotion.type == _selectedFilter,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(
          selectedIndex: _selectedIndex,
          onItemSelected: _handleNavigationTap,
        ),
      ),
    );
  }

  void _showEmotionDialog(BuildContext context, EmotionData emotion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Me siento ${emotion.label}',
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                image: AssetImage(emotion.imagePath),
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                '¿Quieres contarme más sobre cómo te sientes?',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Color(0xFF6A62B7)),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Registrar emoción',
                style: TextStyle(color: Color(0xFF6A62B7)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _showConfirmationSnackbar(context, emotion);
              },
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationSnackbar(BuildContext context, EmotionData emotion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Has registrado que te sientes ${emotion.label}'),
        backgroundColor: const Color(0xFF6A62B7),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class EmotionCard extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const EmotionCard({
    Key? key,
    required this.imagePath,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6A62B7) : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 0,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage(imagePath),
              height: 80,
              width: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmotionData {
  final String imagePath;
  final String label;
  final String type;

  EmotionData({
    required this.imagePath,
    required this.label,
    required this.type,
  });
}