import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';

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
  final String cargo;

  UserProfile({
    required this.nombre,
    required this.apellido_paterno,
    required this.apellido_materno,
    required this.sexo,   
    required this.correo, 
    required this.telefono,  
    required this.fecha_nacimiento,  
    required this.tipo_usuario,  
    required this.cargo,  
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
      cargo: json['cargo'] ?? '',
    );
  }
}

class Profile_Edit_Tutor extends StatefulWidget {
  const Profile_Edit_Tutor({Key? key}) : super(key: key);

  @override
  _Profile_Edit_Tutor_State createState() => _Profile_Edit_Tutor_State();
}

class _Profile_Edit_Tutor_State extends State<Profile_Edit_Tutor> {
  final _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage storage = FlutterSecureStorage();
  UserProfile? userProfile;
  
  bool isLoading = true;

  // Separar los controladores para cada campo
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _secondLastNameController;
  late TextEditingController _genderController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _roleController;
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _lastNameController = TextEditingController();
    _secondLastNameController = TextEditingController();
    _genderController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _roleController = TextEditingController();
    _getAwaitProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _getAwaitProfile() async {
    final String? uuid = await storage.read(key: 'userUUid');
    if (uuid != null) {
      try {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:3000/api/v1/users/tutors/$uuid'),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          setState(() {
            userProfile = UserProfile.fromJson(data);
            _nameController.text = userProfile!.nombre;
            _lastNameController.text = userProfile!.apellido_paterno;
            _secondLastNameController.text = userProfile!.apellido_materno;
            _genderController.text = userProfile!.sexo;
            _emailController.text = userProfile!.correo;
            _phoneController.text = userProfile!.telefono;
            _roleController.text = userProfile!.cargo;
            if (userProfile!.fecha_nacimiento.isNotEmpty) {
              _birthDate = DateTime.parse(userProfile!.fecha_nacimiento);
            }
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar el perfil')),
          );
        }
      } catch (e) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final String? uuid = await storage.read(key: 'userUUid');
    if (uuid == null) return;

    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3000/api/v1/users/tutors/$uuid'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': _nameController.text,
          'apellido_paterno': _lastNameController.text,
          'apellido_materno': _secondLastNameController.text,
          'sexo': _genderController.text,
          'correo': _emailController.text,
          'telefono': _phoneController.text,
          'fecha_nacimiento': _birthDate?.toIso8601String(),
          'cargo': _roleController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileTutor()),
        );
      } else {
        throw Exception('Error al actualizar el perfil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $e')),
      );
    }
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date != null
                        ? "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}"
                        : "Seleccionar fecha",
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null ? Colors.black : Colors.grey,
                    ),
                  ),
                  const Icon(Icons.calendar_today, color: Color(0xFF6A62B7)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    Future<void> _selectDate() async {
    DateTime initialDate = _birthDate ?? DateTime(2000);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6A62B7),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _birthDate = pickedDate;
      });
    }
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hint,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6A62B7)),
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: Color(0xFFF1F5F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed:() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileTutor()),
           ),
        )
      ),
      body: Container(
        color: Color(0xFFF1F5F9),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage("lib/assets/profile.png"),
                        backgroundColor: Color(0xFFF1F5F9),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _buildFormField(
                  "Nombre",
                  _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El nombre es requerido' : null,
                ),
                _buildFormField(
                  "Apellido Paterno",
                  _lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El apellido paterno es requerido' : null,
                ),
                _buildFormField(
                  "Apellido Materno",
                  _secondLastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El apellido materno es requerido' : null,
                ),
                _buildFormField(
                  "Sexo",
                  _genderController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El sexo es requerido' : null,
                ),
                _buildFormField(
                  "Correo electrónico",
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El correo es requerido' : null,
                ),
                _buildFormField(
                  "Teléfono",
                  _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Teléfono requerido' : null,
                ),
                _buildDateField("Fecha de nacimiento", _birthDate, _selectDate),
                _buildFormField(
                  "Cargo",
                  _roleController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'El cargo es requerido' : null,
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  margin: const EdgeInsets.only(bottom: 24),
                  child: ElevatedButton(
                    onPressed: _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A62B7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Guardar cambios",
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
      ),
      ),
    );
  }
}