import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class CustomModalTutor extends StatefulWidget {
  final String title;
  final String consulta;
  final String recomendacion;
  // final String nameSpecialist;
  // final String tituloSpecialist;
  final VoidCallback onValidate;

  const CustomModalTutor({
    Key? key,
    required this.title,
    required this.consulta,
    required this.recomendacion,
    // required this.nameSpecialist,
    // required this.tituloSpecialist,
    required this.onValidate,
  }) : super(key: key);

  @override
  State<CustomModalTutor> createState() => _CustomModalTutorState();
}

class _CustomModalTutorState extends State<CustomModalTutor> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  

  Future<void> _handleData() async {
    // final String? uuid = await _storage.read(key: 'userUUid');
    // final String? uuidRecomendation = await _storage.read(key: 'uuidRecomendation');
    // print('User UUID: $uuid');
    // print('Recommendation UUID: $uuidRecomendation');
    // final url = Uri.parse('http://10.0.2.2:3000/api/v1/recommendations/feedback/');

    // // Datos a enviar en el cuerpo del PATCH
    // final data = {
    //   "id": uuidRecomendation,
    //   "id_especialista": uuid
    // };

    // try {
    //   // Realizar la solicitud PATCH
    //   final response = await http.patch(
    //     url,
    //     headers: {
    //       'Content-Type': 'application/json',
    //     },
    //     body: json.encode(data),
    //   );

    //   print(response.statusCode);
    //   if (response.statusCode == 200) {
    //     widget.onValidate();
    //     Navigator.pop(context);
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text('Error: ${response.statusCode}'),
    //         backgroundColor: Colors.red,
    //       ),
    //     );
    //   }
    // } catch (e) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Error de conexión: $e'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.7,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "Consulta:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.consulta,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(
              "Recomendación:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.recomendacion,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            // Text(
            //   "${widget.nameSpecialist} - ${widget.tituloSpecialist}",
            //   style: const TextStyle(fontSize: 14, color: Colors.black54),
            // ),
            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6A62B7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                    child: const Text(
                      "Aprobar",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB7626D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                    ),
                    child: const Text(
                      "Rechazar",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}