import 'package:flutter/material.dart';
import 'package:app_auticare/Views/home.dart'; // Asegúrate de importar tus vistas
import 'package:app_auticare/Views/chatbot.dart';
import 'package:app_auticare/Authtentication/login.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String gridView = '/grid';
  static const String chat = '/chat';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case login: 
      return MaterialPageRoute(builder: (_) => LoginScreen());
    case home:
      return MaterialPageRoute(builder: (_) => Home());
    // case gridView:
    //   return MaterialPageRoute(builder: (_) => GridViewScreen());
    case chat:
      return MaterialPageRoute(builder: (_) => Chatbot());
    // case profile:
    //   return MaterialPageRoute(builder: (_) => ProfileScreen());
    default:
      throw Exception('Ruta no definida: ${settings.name}'); // Lanzar una excepción para rutas no definidas
    }
  }
}
