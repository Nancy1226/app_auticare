import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Views/user_tutor/profile_childs.dart'; 


class ProfileChild extends StatefulWidget {
  const ProfileChild({Key? key}) : super(key: key);

  @override
  _ProfileChild createState() => _ProfileChild();
}

class _ProfileChild extends State<ProfileChild> {
  final _formKey = GlobalKey<FormState>();
  int _selectedIndex = 0;
  final FlutterSecureStorage storage = FlutterSecureStorage();
  String? token;
  bool isLoading = true;

  // Controllers para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController(text: ""); // Inicialmente vacío
  final TextEditingController _tipoAutismoController = TextEditingController();
  final TextEditingController _informacionMedicaController = TextEditingController();


  // Método para enviar datos a la API
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaNacimientoController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una fecha de nacimiento')),
        );
        return;
      }

      final String? uuid = await storage.read(key: 'userUUid');
      final Map<String, dynamic> data = {
        "id_tutor":uuid,
        "nombre": _nombreController.text,
        "apellido_paterno": _apellidoPaternoController.text,
        "apellido_materno": _apellidoMaternoController.text,
        "sexo": _sexoController.text,
        "fecha_nacimiento": _fechaNacimientoController.text,
        "tipo_autismo": _tipoAutismoController.text,
        "informacion_medica": _informacionMedicaController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3000/api/v1/users/childs'),
          headers: {"Content-Type": "application/json"},
          body: json.encode(data),
        );

        print(response.statusCode);
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Formulario enviado correctamente')),
          );
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileChilds()),
    );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar datos: $e')),
        );
      }
    }
  }

  // Método para abrir el DatePicker
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _fechaNacimientoController.text =
            "${pickedDate.toLocal()}".split(' ')[0]; // Formato: YYYY-MM-DD
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar circular con la imagen
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFC0CB), // Color rosa claro
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'lib/assets/nina.png', // Asegúrate de tener esta imagen en tu proyecto
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Campos de texto
                _buildTextField(label: "Nombre", controller: _nombreController),
                _buildTextField(label: "Apellido paterno", controller: _apellidoPaternoController),
                _buildTextField(label: "Apellido materno", controller: _apellidoMaternoController),
                _buildTextField(label: "Sexo", controller: _sexoController),
                
                Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda
                children: [
                  const Text(
                    "Fecha de nacimiento", // Texto encima del campo
                    style: TextStyle(
                      fontSize: 16, // Tamaño de fuente
                      fontWeight: FontWeight.w500, // Peso de fuente
                      color: Colors.black87, // Color del texto
                    ),
                  ),
                  const SizedBox(height: 8), // Espacio entre el texto y el campo
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16), // Margen superior e inferior
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // Bordes redondeados
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3), // Color del borde con opacidad
                        ),
                        color: Colors.white, // Fondo blanco
                      ),
                      child: TextFormField(
                        controller: _fechaNacimientoController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Campo obligatorio";
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            border: InputBorder.none,         // Sin borde adicional
                            hintText: "Seleccionar fecha",    // Texto placeholder
                            hintStyle: TextStyle(
                              color: Colors.grey,             // Color del texto del placeholder
                              fontSize: 16,                   // Tamaño de fuente
                            ),
                          ),
                          readOnly: true, // Hace que el campo sea de solo lectura
                          style: const TextStyle(
                            fontSize: 16, // Tamaño del texto seleccionado
                          ),
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              _fechaNacimientoController.text =
                                  "${pickedDate.toLocal()}".split(' ')[0]; // Formato: YYYY-MM-DD
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                _buildTextField(label: "Tipo de autismo", controller: _tipoAutismoController),
                _buildTextField(
                  label: "Información médica",
                  controller: _informacionMedicaController,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Botón de registro
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A62B7), // Color morado
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Registrarse',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    bool isDateField = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: label == "Fecha de nacimiento" ? "Seleccionar fecha" : null,
              filled: true,
              fillColor: const Color(0xFFF3F0FF).withOpacity(0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF6A62B7),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor completa este campo';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
