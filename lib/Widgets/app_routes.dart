import 'package:flutter/material.dart';
import 'package:app_auticare/Views/user_tutor/home.dart'; // Asegúrate de importar tus vistas
import 'package:app_auticare/Views/user_tutor/chatbot.dart';
import 'package:app_auticare/Views/user_tutor/donation.dart';
import 'package:app_auticare/Authtentication/login.dart';
import 'package:app_auticare/Views/user_tutor/board.dart';
import 'package:app_auticare/Views/user_tutor/profile.dart';
import 'package:app_auticare/Views/user_tutor/profile_edit.dart';

class AppRoutes {
  static const String login = '/login';
  static const String home = '/';
  static const String gridView = '/grid';
  static const String chat = '/chat';
  static const String profile = '/profile';
  static const String profile_edit = '/profile';
  static const String donation = '/donation';
  static const String board = '/board';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case home:
        return MaterialPageRoute(builder: (_) => Home());
      case board:
        return MaterialPageRoute(builder: (_) => Board());
      case chat:
        return MaterialPageRoute(builder: (_) => Chatbot());
      case donation:
        return MaterialPageRoute(builder: (_) => Donation());
      case profile:
        return MaterialPageRoute(builder: (_) => Profile());
      case profile_edit:
        return MaterialPageRoute(builder: (_) => Profile_Edit());
      default:
        throw Exception(
            'Ruta no definida: ${settings.name}'); // Lanzar una excepción para rutas no definidas
    }
  }
}
