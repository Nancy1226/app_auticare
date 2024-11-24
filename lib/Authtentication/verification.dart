import 'package:app_auticare/Authtentication/login.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final token = TextEditingController();

  bool isLoginTrue = false;

  //funcion alerta
  void _showAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Verificación exitosa"),
        content: const Text("Se verificó correctamente la cuenta."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el cuadro de diálogo
            },
            child: const Text("Aceptar"),
          ),
        ],
      );
    },
  );
}



  //Función de login que consume la API
  Future<void> verification() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/v1/notifications/tokens/verify'); // URL de tu API

    try {
      // Imprimir los datos que estás enviando
      print('Enviando los siguientes datos:');
      print({
        'token': token.text
      });

      // Realiza el POST a la API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token.text,
        }),
      );

      // Imprimir el código de respuesta de la API
      print('Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Verficacion exitosa');
        _showAlert(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Manejar errores de conexión
      print('Error al conectar con la API: $e');
      setState(() {
        isLoginTrue = true;
      });
    }
  }

  //We have to create global key for our form
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FF),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Auticare",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    "lib/assets/logo.png",
                    width: 150,
                  ),
                  const SizedBox(height: 20),
                      Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Por favor, ingresa el código de verificación que hemos enviado a tu número de teléfono registrado.",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
Container(
                    margin: EdgeInsets.all(8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: token,
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
                        hintText: "1234",
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Login method will be here
                            verification();
                          }
                        },
                        child: const Text(
                          "Confirmar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20),
                  isLoginTrue
                      ? const Text(
                          "El código ingresado es incorrecto.",
                          style: TextStyle(color: Colors.red),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
