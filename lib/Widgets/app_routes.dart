import 'package:flutter/material.dart';
import 'package:app_auticare/Authtentication/verification.dart';
import 'package:app_auticare/Authtentication/login.dart';
//tutor
import 'package:app_auticare/Views/user_tutor/home_tutor.dart';
import 'package:app_auticare/Views/user_tutor/board.dart';
import 'package:app_auticare/Views/user_tutor/chatbot.dart';
import 'package:app_auticare/Views/user_tutor/profile_edit_tutor.dart';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';
import 'package:app_auticare/Views/user_tutor/donation_tutor.dart';
import 'package:app_auticare/Views/user_tutor/profile_child.dart';
import 'package:app_auticare/Views/user_tutor/profile_childs.dart';

//especialista
import 'package:app_auticare/Views/user_specialist/home_specialist.dart';
import 'package:app_auticare/Views/user_specialist/donation_specialist.dart';
import 'package:app_auticare/Views/user_specialist/profile_edit_specialist.dart';
import 'package:app_auticare/Views/user_specialist/profile_specialist.dart';


class AppRoutes {
  static const String login = '/';
  static const String verification = '/verification';
  //tutor
  static const String home_tutor= '/home_tutor';
  static const String donation_tutor = '/donation_tutor';
  static const String chat = '/chat';
  static const String profile_tutor = '/profile_tutor';
  static const String profile_edit_tutor = '/profile_edit_tutor';
  static const String board = '/board';
  static const String profile_child = '/profile_child';
  static const String profile_childs = '/profile_childs';

  //especialista
  static const String home_specialist= '/home_specialist';
  static const String donation_specialist= '/donation_specialist';
  static const String profile_specialist= '/profile_specialist';
  static const String profile_edit_specialist= '/profile_edit_specialist';
  // static const String gridView = '/grid';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case verification: 
        return MaterialPageRoute(builder: (_)=> VerificationScreen());
      
      //tutor
      case home_tutor:
        return MaterialPageRoute(builder: (_) => HomeTutor());
      case board:
        return MaterialPageRoute(builder: (_) => Board());
      case chat:
        return MaterialPageRoute(builder: (_) => Chatbot());
      case donation_tutor:
        return MaterialPageRoute(builder: (_) => DonationTutor());
      case profile_child:
        return MaterialPageRoute(builder: (_) => ProfileChild());
      case profile_childs:
        return MaterialPageRoute(builder: (_) => ProfileChilds());
      case profile_tutor:
        return MaterialPageRoute(builder: (_) => ProfileTutor());
      case profile_edit_tutor:
        return MaterialPageRoute(builder: (_) => Profile_Edit_Tutor());

      //especialista
      case home_specialist:
        return MaterialPageRoute(builder: (_) => HomeSpecialist());
      case donation_specialist:
        return MaterialPageRoute(builder: (_) => DonationSpecialist());
      case profile_specialist:
        return MaterialPageRoute(builder: (_) => ProfileSpecialist());
      case profile_edit_specialist:
        return MaterialPageRoute(builder: (_) => Profile_Edit_Specialist());

      default:
        throw Exception(
            'Ruta no definida: ${settings.name}'); // Lanzar una excepción para rutas no definidas
    }
  }
}
