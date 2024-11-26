import 'package:app_auticare/Views/user_tutor/recomendations.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Widgets/custom_navigation_bar.dart';
import 'package:app_auticare/Widgets/app_routes.dart';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';

class Child {
  final String uuid;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String sexo;

  Child({
    required this.uuid,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.sexo,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';

  String get profileImage {
    return sexo.toLowerCase() == 'femenino' 
      ? 'lib/assets/nina.png' 
      : 'lib/assets/nino.png';
  }

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      uuid: json['uuid'],
      nombre: json['nombre'] ?? 'No disponible',
      apellidoPaterno: json['apellido_paterno'] ?? 'No disponible',
      apellidoMaterno: json['apellido_materno'] ?? 'No disponible',
      sexo: json['sexo'] ?? 'No disponible',
    );
  }
}

class HomeTutor extends StatefulWidget {
  const HomeTutor({Key? key}) : super(key: key);

  @override
  State<HomeTutor> createState() => _HomeTutorState();
}

class _HomeTutorState extends State<HomeTutor> {
  int _selectedIndex = 0;
  final List<Child> _children = [];
  bool _isLoading = true;
  final _storage = const FlutterSecureStorage();
  
  String? _token;
  String? _nombreUser;
  String? _uuidChild; 

  static const baseUrl = 'http://10.0.2.2:3000/api/v1';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    await _fetchChildren();
  }

  Future<void> _loadUserData() async {
    _token = await _storage.read(key: 'authToken');
    _nombreUser = await _storage.read(key: 'nombre');
    setState(() {});
  }  

  Future<void> _fetchChildren() async {
    try {
      final String? uuid = await _storage.read(key: 'userUUid');

      if (uuid == null || uuid.isEmpty) {
        _showErrorDialog('No se encontró un token válido');
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/childs/tutor/$uuid'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);

        setState(() {
          _children.clear();
          _children.addAll(
            data.map((user) => Child.fromJson(user)).toList(),
          );
        });
      } else {
        _showErrorDialog('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      _showErrorDialog('Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    setState(() => _selectedIndex = index);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _navigateToScreen,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola ${_nombreUser ?? "invitado"}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            "Mis niños registrados",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF1F5F9),
            backgroundImage: const AssetImage("lib/assets/profile.png"),
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileTutor()),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _children.isEmpty
      ? const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.child_care, size: 100, color: Colors.grey),
              SizedBox(height: 20),
              Text(
                'No hay niños asociados',
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.grey
                ),
              ),
            ],
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _children.length,
          itemBuilder: (context, index) {
            final child = _children[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: InkWell(
                onTap:() async{
                  setState(() {
                  _uuidChild = child.uuid; 
                });
                await _storage.write(key: 'uuidChild', value: child.uuid);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Recomendations()),
                );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(child.profileImage),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.nombreCompleto,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text('Sexo: ${child.sexo}'),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            );
          },
        );
  }
}