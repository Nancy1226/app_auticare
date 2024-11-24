import 'package:app_auticare/Views/user_specialist/donation_specialist.dart';
import 'package:app_auticare/Views/user_specialist/profile_edit_specialist.dart';
import 'package:app_auticare/Widgets/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:app_auticare/Views/user_tutor/donation_tutor.dart';
import 'package:app_auticare/Views/user_tutor/profile_edit_tutor.dart';
import 'package:app_auticare/widgets/custom_navigation_bar.dart';

class ProfileSpecialist extends StatefulWidget {
  const ProfileSpecialist({Key? key}) : super(key: key);

  @override
  _ProfileSpecialistState createState() => _ProfileSpecialistState();
}

class _ProfileSpecialistState extends State<ProfileSpecialist> {
  int _selectedIndex = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Fondo gris muy claro
      appBar: AppBar(
        title: const Text(""),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Acción para cerrar sesión
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(
                color: Color(0xFF7D6C9E),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView( // Scroll general
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  child: const Image(
                    image: AssetImage("lib/assets/profile.png"),
                    fit: BoxFit.cover, // Ajusta la imagen para llenar el espacio
                    width: 120.0, // Ancho deseado
                    height: 120.0, // Altura deseada
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Nancy Jimenez",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Acerca de ti",
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow("Nombre", "Nancy Jimenez Escobar"),
              _buildInfoRow("Sexo", "Femenino"),
              _buildInfoRow("Correo electrónico", "nancy-12_03@hotmail.com"),
              _buildInfoRow("Teléfono", "9612545998"),
              _buildInfoRow("Fecha de nacimiento", "12.12.2003"),
              _buildInfoRow("Cargo", "Madre"),
              const SizedBox(height: 32), // Espaciado para separar de los botones
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DonationSpecialist()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F0FF), // Fondo lavanda muy claro
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Realizar una donación",
                        style: TextStyle(
                          color: Color(0xFF7D6C9E),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF7D6C9E),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Profile_Edit_Specialist()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A62B7), // Color morado
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Actualizar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
              Navigator.pushNamed(context, AppRoutes.home_specialist);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.donation_specialist);
              break;
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF2D2D2D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
