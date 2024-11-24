import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:app_auticare/Authtentication/selectuser.dart';
import 'package:app_auticare/Views/user_tutor/home_tutor.dart';
import 'package:app_auticare/Views/user_specialist/home_specialist.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = FlutterSecureStorage(); //para guardar el token

  final LocalAuthentication auth = LocalAuthentication();
  final correo = TextEditingController();
  final contrasena = TextEditingController();


  bool isVisible = false;

  bool isLoginTrue = false;


  Future<void> login() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/v1/users/auth/login'); 

    try {
      print('Enviando los siguientes datos:');
      print({
        'correo': correo.text,
        'contrasena': contrasena.text,
      });

      // Realiza el POST a la API
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': correo.text,
          'contrasena': contrasena.text,
        }),
      );

      // Imprimir el código de respuesta de la API
      print('Código de respuesta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData["result"]["token"];
        final userUUid = responseData["result"]["userUUid"];
        final email = responseData["result"]["email"];
        final userType = responseData["result"]["userType"];


        // Verifica que el token no sea nulo o vacío
        if (token != null && token.isNotEmpty) {
          await storage.write(key: 'authToken', value: token);
          await storage.write(key: 'userUUid', value: userUUid);
          await storage.write(key: 'email', value: email);
          print('Token guardado: $token');
             if (userType == "Especialista") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeSpecialist()),
              );
            } else if (userType == "Tutor") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeTutor()),
              );
            }
        } else {
          print('Error: El token recibido es nulo o vacío');
        }
      }
    } catch (e) {
      // Manejar errores de conexión
      print('Error al conectar con la API: $e');
      setState(() {
        isLoginTrue = true;
      });
    }
  }

// Autenticación biométrica
  String _authorized = 'No autorizado';
  bool _isAuthenticating = false;
  _SupportedState _supportedState = _SupportedState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometricTypes;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    final isSupported = await auth.isDeviceSupported();
    final canCheckBiometrics = await auth.canCheckBiometrics;
    
    setState(() {
      _supportedState = isSupported ? _SupportedState.supported : _SupportedState.unsupported;
      _canCheckBiometrics = canCheckBiometrics;
    });

    if (canCheckBiometrics) {
      _getAvailableBiometrics();
    }
  }

  Future<void> _getAvailableBiometrics() async {
    try {
      final availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        _availableBiometricTypes = availableBiometrics;
      });
    } catch (e) {
      print('Error al obtener biométricos disponibles: $e');
    }
  }

  Future<void> _authenticate() async {
    if (!_canCheckBiometrics!) {
      setState(() {
        _authorized = 'La autenticación biométrica no está disponible en este dispositivo';
      });
      return;
    }

    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Autenticando...';
      });

      final authenticated = await auth.authenticate(
        localizedReason: 'Autentícate para acceder a tu cuenta',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      setState(() {
        _isAuthenticating = false;
        _authorized = authenticated ? 'Autorizado' : 'No autorizado';
      });

      if (authenticated) {
        // Recuperar el token y el tipo de usuario del almacenamiento seguro
        final token = await storage.read(key: 'authToken');
        final userType = await storage.read(key: 'userType');

        if (token == null || userType == null) {
          setState(() {
            _authorized = 'No se encontraron datos de sesión previa. Por favor, inicia sesión manualmente.';
          });
          return;
        }

        // Redirigir basado en el tipo de usuario
        if (userType == "Especialista") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeSpecialist()),
          );
        } else if (userType == "Tutor") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeTutor()),
          );
        } else {
          print('Error: Tipo de usuario desconocido');
        }
      }
    } catch (e) {
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error: $e';
      });
      print('Error de autenticación: $e');
    }
  }


  //We have to create global key for our form
  final formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Image.asset(
                    "lib/assets/login.png",
                    width: 210,
                  ),
                  const SizedBox(height: 15),
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: correo,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo requerido";
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

                  //Password field
                  Container(
                    margin: const EdgeInsets.all(8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple.withOpacity(.2)),
                    child: TextFormField(
                      controller: contrasena,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "campo requerido";
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
                                //In here we will create a click to show and hide the password a toggle button
                                setState(() {
                                  //toggle button
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(isVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off))),
                    ),
                  ),

                  const SizedBox(height: 10),
                  //Login button
                  Container(
                    height: 55,
                    width: MediaQuery.of(context).size.width * .9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.deepPurple),
                    child: TextButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            //Login method will be here
                            login();
                          }
                        },
                        child: const Text(
                          "Inicio de sesion",
                          style: TextStyle(color: Colors.white),
                        )),
                  ),

                //biometricos
                if (_supportedState == _SupportedState.supported && _canCheckBiometrics == true) 
                  const Divider(),
                  ElevatedButton(
                    onPressed: _authenticate,
                    child: const Text('Autenticación biométrica'),
                  ),
                  const SizedBox(height: 10),
                  Text(_authorized),
                  //Sign up button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta?"),
                      TextButton(
                          onPressed: () {
                            //Navigate to sign up
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SelectUser()));
                          },
                          child: const Text("Regístrate"))
                    ],
                  ),

                  // We will disable this message in default, when user and pass is incorrect we will trigger this message to user
                  isLoginTrue
                      ? const Text(
                          "Correo o contraseña son incorrectos",
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

enum _SupportedState { unknown, supported, unsupported }