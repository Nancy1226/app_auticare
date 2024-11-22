import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para convertir el JSON
import 'package:app_auticare/Authtentication/user_tutor/signupespecialista.dart';
import 'package:app_auticare/Authtentication/user_specialist/signuptutor.dart';

class SelectUser extends StatefulWidget {
  const SelectUser({super.key});

  @override
  State<SelectUser> createState() => _SelectUserState();
}

class _SelectUserState extends State<SelectUser> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final List<String> userTypes = ["Tutor", "Especialista"];
  String? selectedUserType;
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ListTile(
                    title: Text(
                      "Bienvenido a nuestra app",
                      style: TextStyle(
                          fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Por favor selecciona el tipo de usuario",
                    style: TextStyle(fontSize: 16, color: Color.fromARGB(171, 0, 0, 0)),
                    textAlign: TextAlign.center,
                  ),
                ),
                 // Contenedor personalizado para el DropdownButton
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Color(0xFFE1CFEA)),
                    ),
                    child: DropdownButton<String>(
                      value: selectedUserType,
                      hint: Row(
                        children: [
                          Icon(Icons.person, color: Colors.black),
                          const SizedBox(width: 8),
                          Text(
                            "Selecciona una opción",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                      isExpanded: true,
                      underline: SizedBox(), // Quitar la línea debajo del dropdown
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedUserType = newValue;
                        });
                      },
                      items: userTypes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Icon(Icons.person, color: Colors.black),
                              const SizedBox(width: 8),
                              Text(value),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Botón Siguiente
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                       if (selectedUserType != null) {
                          print("Tipo de usuario seleccionado: $selectedUserType");
                          if (selectedUserType == "Tutor") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpTutor()),
                            );
                          } else if (selectedUserType == "Especialista") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUpEspecialista()),
                            );
                          }
                        } else {
                          print("Por favor selecciona un tipo de usuario");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C4BA5), // Color púrpura similar al de la imagen
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Siguiente",
                        style: TextStyle(color: Colors.white, fontSize: 16),
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
