import 'package:app_auticare/Views/user_specialist/profile_specialist.dart';
import 'package:app_auticare/Views/user_tutor/donation_tutor.dart';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Profile_Edit_Specialist extends StatefulWidget {
  const Profile_Edit_Specialist({Key? key}) : super(key: key);

  @override
  _Profile_Edit_State createState() => _Profile_Edit_State();
}

class _Profile_Edit_State extends State<Profile_Edit_Specialist> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController(text: "Nancy Jimenez Escobar");
  final TextEditingController _genderController = TextEditingController(text: "Femenino");
  final TextEditingController _emailController = TextEditingController(text: "nancy-12_03@hotmail.com");
  final TextEditingController _phoneController = TextEditingController(text: "9612545998");
  final TextEditingController _roleController = TextEditingController(text: "Madre");

  DateTime? _birthDate;

  // Regex for validations
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¡Éxito!'),
          content: const Text('Los datos se han actualizado correctamente.'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    DateTime initialDate = _birthDate ?? DateTime(2000);
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
            ),
            validator: validator,
          ),
        ],
      ),
    );
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
              child: Text(
                date != null
                    ? "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}"
                    : "Seleccionar fecha",
                style: const TextStyle(fontSize: 16, color: Color(0xFF666666)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Perfil"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Acción para cerrar sesión
            },
            child: const Text(
              "Cerrar sesión",
              style: TextStyle(color: Color(0xFF7D6C9E), fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        backgroundColor: Colors.grey[200],
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
                  "Nombre completo",
                  _nameController,
                  validator: (value) => value == null || value.isEmpty
                      ? 'El nombre es requerido'
                      : (!nameRegex.hasMatch(value) ? 'Solo letras' : null),
                ),
                _buildFormField(
                  "Sexo",
                  _genderController,
                  validator: (value) => value == null || value.isEmpty ? 'El sexo es requerido' : null,
                ),
                _buildFormField(
                  "Correo electrónico",
                  _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || value.isEmpty
                      ? 'El correo es requerido'
                      : (!emailRegex.hasMatch(value) ? 'Correo inválido' : null),
                ),
                _buildFormField(
                  "Teléfono",
                  _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value == null || value.isEmpty
                      ? 'Teléfono requerido'
                      : (value.length != 10 ? '10 dígitos requeridos' : null),
                ),
                _buildDateField("Fecha de nacimiento", _birthDate, _selectDate),
                _buildFormField(
                  "Cargo",
                  _roleController,
                  validator: (value) => value == null || value.isEmpty ? 'El cargo es requerido' : null,
                ),
                const SizedBox(height: 32),
                Container(
                width: double.infinity,
                height: 56,
                margin: const EdgeInsets.only(bottom: 24),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileSpecialist()),
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
    );
  }
}
