import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para convertir el JSON
import 'package:app_auticare/Authtentication/login.dart';

class SignUpEspecialista extends StatefulWidget {
  const SignUpEspecialista({super.key});

  @override
  State<SignUpEspecialista> createState() => _SignUpEspecialistaState();
}

class _SignUpEspecialistaState extends State<SignUpEspecialista> {
  final nombre = TextEditingController();
  final apellido_paterno = TextEditingController();
  final apellido_materno = TextEditingController();
  final sexo = TextEditingController();
  final correo = TextEditingController();
  final contrasena = TextEditingController();
  final confirmPassword = TextEditingController();
  final telefono = TextEditingController();
  final fecha_nacimiento = TextEditingController();
  final titulo_especialidad = TextEditingController();
  final cedula_profesional = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isVisible = false;
  
  Future<void> _selectDate(BuildContext context) async {
  DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Fecha inicial en el selector
      firstDate: DateTime(1900),    // Fecha mínima
      lastDate: DateTime(2100),     // Fecha máxima
    );

    if (pickedDate != null) {
      setState(() {
        // Formatea la fecha seleccionada como texto y la muestra en el TextField
        fecha_nacimiento.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }


  // Función para registrar un nuevo usuario consumiendo la API
  Future<void> signup() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/v1/especialistas/'); // URL de tu API
    
    try {
      print('Enviando los siguientes datos:');
      print({
          'nombre': nombre.text,
          'apellido_paterno': apellido_paterno.text,
          'apellido_materno': apellido_materno.text,
          'sexo': sexo.text,
          'correo': correo.text,
          'contrasena': contrasena.text,
          'telefono': telefono.text,
          'fecha_nacimiento': fecha_nacimiento.text,
          'titulo_especialidad': titulo_especialidad.text,
          'cedula_profesional': cedula_profesional.text,
      });

      // Realiza el POST a la API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre.text,
          'apellido_paterno': apellido_paterno.text,
          'apellido_materno': apellido_materno.text,
          'sexo': sexo.text,
          'correo': correo.text,
          'contrasena': contrasena.text,
          'telefono': telefono.text,
          'fecha_nacimiento': fecha_nacimiento.text,
          'titulo_especialidad': titulo_especialidad.text,
          'cedula_profesional': cedula_profesional.text,
        }),
      );

      print('Mostrando el status:');
      print(response.statusCode);
      // if (response.statusCode == 201) {
      //   // Registro exitoso, redirigir al login
      //   if (!mounted) return;
       Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      // } else {
      //   // Manejar error de registro
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text('Error en el registro. Inténtalo de nuevo.')),
      //   );
      // }
    } catch (e) {
      // Manejar errores de conexión
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: ${e.toString()}')),
      );
    }
  }

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
                      "Registro Especialista",
                      style: TextStyle(
                          fontSize: 50, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Campo de texto para el nombre de usuario
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: nombre,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Nombre",
                      ),
                    ),
                  ),
                  // Campo de texto para el apellido paterno del usuario
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: apellido_paterno,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.badge),
                        border: InputBorder.none,
                        hintText: "Apellido paterno",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: apellido_materno,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.badge),
                        border: InputBorder.none,
                        hintText: "Apellido materno",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: sexo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: "Sexo",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: correo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.email),
                        border: InputBorder.none,
                        hintText: "Correo",
                      ),
                    ),
                  ),
                  // Campo de texto para la contraseña
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: contrasena,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo es requerido";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Contraseña",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),
                  // Confirmar contraseña
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: confirmPassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        } else if (contrasena.text != confirmPassword.text) {
                          return "Las contraseñas no coinciden";
                        }
                        return null;
                      },
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: "Confirmar contraseña",
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: telefono,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.phone),
                        border: InputBorder.none,
                        hintText: "Telefono",
                      ),
                    ),
                  ),
                                    Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: fecha_nacimiento,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        border: InputBorder.none,
                        hintText: "Fecha de nacimiento",
                      ),
                      readOnly: true, // Hace que el campo sea de solo lectura
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          fecha_nacimiento.text = "${pickedDate.toLocal()}".split(' ')[0];
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: titulo_especialidad,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person_outlined),
                        border: InputBorder.none,
                        hintText: "Especialidad",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: cedula_profesional,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo obligatorio";
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person_outlined),
                        border: InputBorder.none,
                        hintText: "Cédula profesional",
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Botón de registro
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            signup();
                          }
                        },
                        child: const Text(
                          "Registrarse",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  // Botón de navegación a Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿Ya tiene una cuenta?"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LoginScreen()));
                          },
                          child: const Text("Inicio de sesion"))
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}