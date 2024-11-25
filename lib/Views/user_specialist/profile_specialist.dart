import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Widgets/app_routes.dart';
import 'package:app_auticare/Views/user_specialist/home_specialist.dart';
import 'package:app_auticare/Views/user_specialist/donation_specialist.dart';
import 'package:app_auticare/Views/user_specialist/profile_edit_specialist.dart';
import 'package:app_auticare/Authtentication/login.dart';

// Modelo para el perfil del usuario
class UserProfile {
  final String nombre;
  final String apellido_paterno;
  final String apellido_materno;
  final String sexo;
  final String correo;
  final String telefono;
  final String fecha_nacimiento;
  final String tipo_usuario;
  final String titulo_especialidad;
  final String cedula_profesional;

  UserProfile({
    required this.nombre,
    required this.apellido_paterno,
    required this.apellido_materno,
    required this.sexo,   
    required this.correo, 
    required this.telefono,  
    required this.fecha_nacimiento,  
    required this.tipo_usuario,  
    required this.titulo_especialidad,
    required this.cedula_profesional,  
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nombre: json['nombre'] ?? '',
      apellido_paterno: json['apellido_paterno'] ?? '',
      apellido_materno: json['apellido_materno'] ?? '',
      sexo: json['sexo'] ?? '',
      correo: json['correo'] ?? '',
      telefono: json['telefono'] ?? '',
      fecha_nacimiento: json['fecha_nacimiento'] ?? '',
      tipo_usuario: json['tipo_usuario'] ?? '',
      titulo_especialidad: json['titulo_especialidad'] ?? '',
      cedula_profesional: json['cedula_profesional'] ?? '',
    );
  }
}


class ProfileSpecialist extends StatefulWidget {
  const ProfileSpecialist({Key? key}) : super(key: key);

  @override
  _ProfileSpecialistState createState() => _ProfileSpecialistState();
}

class _ProfileSpecialistState extends State<ProfileSpecialist> {
  int _selectedIndex = 3;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  UserProfile? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getAwaitProfile();
  }

  Future<void> _logoutProfile(BuildContext context) async {
        // Crear una instancia de FlutterSecureStorage
    final storage = FlutterSecureStorage();

    // Eliminar todos los datos
    await storage.deleteAll();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> _getAwaitProfile() async {
    final String? uuid = await storage.read(key: 'userUUid');
    print('Token recuperado: $uuid');
    if (uuid != null) {
      try {
        final response = await http.get(Uri.parse('http://10.0.2.2:3000/api/v1/users/specialists/$uuid'));

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final nombre = responseData["nombre"];
          await storage.write(key: 'nombre', value: nombre);
          print(nombre);
          final Map<String, dynamic> data = json.decode(response.body);
          setState(() {
            userProfile = UserProfile.fromJson(data);
            isLoading = false;
          });
        } else {
          // Manejo de error
          print('Error al obtener el perfil: ${response.statusCode}');
        }
      } catch (e) {
        print('Error en la solicitud HTTP: $e');
      }
    } else {
      print('UUID no encontrado en el almacenamiento seguro.');
    }
  }

  // Convierte la fecha en un objeto DateTime
    String formatDate(String date) {
      try {
        final DateTime parsedDate = DateTime.parse(date);
        return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
      } catch (e) {
        return "Fecha no disponible";
      }
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE), // Fondo gris muy claro
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed:() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeSpecialist()),
           ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              print("boton presionando");
              _logoutProfile(context);
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Color(0xFF7D6C9E), fontSize: 16),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
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
                  Center(
                    child: Text(
                    "${userProfile?.nombre ?? ''} ${userProfile?.apellido_paterno ?? ''}".trim(),
                      style: const TextStyle(
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
                  _buildInfoRow("Nombre", userProfile?.nombre ?? "N/A"),
                  _buildInfoRow("Apellido paterno", userProfile?.apellido_paterno ?? "N/A"),
                  _buildInfoRow("Apellido materno", userProfile?.apellido_materno ?? "N/A"),
                  _buildInfoRow("Sexo", userProfile?.sexo ?? "N/A"),
                  _buildInfoRow("Correo electrónico", userProfile?.correo ?? "N/A"),
                  _buildInfoRow("Teléfono", userProfile?.telefono ?? "N/A"),
                  _buildInfoRow("Fecha de nacimiento", formatDate(userProfile?.fecha_nacimiento?? "N/A")),
                  _buildInfoRow("Usuario", userProfile?.tipo_usuario ?? "N/A"),
                  _buildInfoRow("Tipo de especialidad", userProfile?.titulo_especialidad ?? "N/A"),
                  _buildInfoRow("Cédula profesional", userProfile?.cedula_profesional ?? "N/A"),
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