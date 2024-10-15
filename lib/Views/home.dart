import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Para convertir el JSON
import 'package:app_auticare/Authtentication/login.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Navegando a Home');
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(child: Text("¡Bienvenido a Home!")),
    );
  }
}

