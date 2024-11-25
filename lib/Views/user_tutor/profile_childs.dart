import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Views/user_tutor/profile_child.dart';
import 'package:app_auticare/widgets/custom_navigation_bar.dart';
import 'package:app_auticare/Widgets/app_routes.dart';

// Data model for the user
class ChildUser {
  final String name;
  final String paternalSurname;
  final String maternalSurname;
  final String gender;
  final String birthDate;
  final String autismType;
  final String medicalInfo;

  ChildUser({
    required this.name,
    required this.paternalSurname,
    required this.maternalSurname,
    required this.gender,
    required this.birthDate,
    required this.autismType,
    required this.medicalInfo,
  });

  factory ChildUser.fromJson(Map<String, dynamic> json) {
    return ChildUser(
      name: json['nombre'] ?? 'No disponible',
      paternalSurname: json['apellido_paterno'] ?? 'No disponible',
      maternalSurname: json['apellido_materno'] ?? 'No disponible',
      gender: json['sexo'] ?? 'No disponible',
      birthDate: json['fecha_nacimiento'] ?? 'No disponible',
      autismType: json['tipo_autismo'] ?? 'No disponible',
      medicalInfo: json['informacion_medica'] ?? 'No disponible',
    );
  }
}

class ProfileChilds extends StatefulWidget {
  const ProfileChilds({super.key});

  @override
  State<ProfileChilds> createState() => _ProfileChildsState();
}

class _ProfileChildsState extends State<ProfileChilds> {
  final List<ChildUser> _users = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();
  final Map<int, bool> _expandedCards = {};
  int _selectedIndex = 3;

  // Constants
  static const baseUrl = 'http://10.0.2.2:3000/api/v1';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final String? uuid = await _storage.read(key: 'userUUid');

      if (uuid == null || uuid.isEmpty) {
        _showErrorMessage('No se encontró un token válido');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/childs/tutor/$uuid'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _users.clear();
          _users.addAll(
            data.map((user) => ChildUser.fromJson(user)).toList(),
          );
        });
      } else {
        _showErrorMessage('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorMessage('Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildUserCard(int index) {
    final user = _users[index];
    final bool isExpanded = _expandedCards[index] ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/nina.png'),
                    radius: 30,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.blue,
                    ),
                    onPressed: () => setState(() {
                      _expandedCards[index] = !isExpanded;
                    }),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const Divider(),
                _buildUserDetails(user),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserDetails(ChildUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailRow('Apellido Paterno', user.paternalSurname),
        _buildDetailRow('Apellido Materno', user.maternalSurname),
        _buildDetailRow('Sexo', user.gender),
        _buildDetailRow('Fecha de Nacimiento', user.birthDate),
        _buildDetailRow('Tipo de Autismo', user.autismType),
        _buildDetailRow('Información Médica', user.medicalInfo),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Usuarios registrados',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay usuarios registrados',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _users.length,
      itemBuilder: (context, index) => _buildUserCard(index),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileChild()),
      ),
      backgroundColor: const Color(0xFF7D6C9E),
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text(
        'Agregar Registro',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: 
      _buildAppBar()
      ,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushNamed(context, AppRoutes.home_tutor);
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.board);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.chat);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile_childs);
              break;
          }
        },
      ),
    );
  }
}