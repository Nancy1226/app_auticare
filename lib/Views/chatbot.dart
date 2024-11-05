import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_auticare/Widgets/custom_appbar.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({super.key});

  @override
  State<Chatbot> createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  bool _isConnected = true;

  final String _apiKey = 'AIzaSyA9ejnBH-ZMI0zQFDHk9GTQ3cH5aPHGi0U';

  // Define los colores pastel
  final Color _lightPurple = Color(0xFFDBE1E9); //abajo
  final Color _lightPink = Color(0xFF6A62B7); //arriba
  final Color _darkPurple = Color.fromARGB(255, 255, 255, 255); //color de letra
  final Color _darkBlack = Color.fromARGB(255, 0, 0, 0); //color de letra

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    _loadMessages();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
  }

  void _showNoConnectionAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sin Conexión a Internet"),
          content: Text("Por favor, verifica tu conexión a Internet."),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final String? messagesJson = prefs.getString('chat_messages');
    if (messagesJson != null) {
      setState(() {
        _messages = (jsonDecode(messagesJson) as List)
            .map((item) => Map<String, String>.from(item))
            .toList();
      });
    }
  }

  Future<void> _saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_messages', jsonEncode(_messages));
  }

  Future<void> _sendMessage() async {
    String message = _controller.text.trim();

    if (message.isNotEmpty) {
      setState(() {
        _messages.add({"role": "user", "parts": message});
        _isLoading = true;
        _controller.clear();
      });

      String botResponse = await _getBotResponse(message);

      setState(() {
        _messages.add({"role": "model", "parts": botResponse});
        _isLoading = false;
      });

      _saveMessages();
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey');

    // Preparar el historial de mensajes en el formato correcto
    List<Map<String, dynamic>> formattedMessages = _messages.map((message) {
      return {
        "role": message["role"],
        "parts": [
          {"text": message["parts"]}
        ]
      };
    }).toList();

    // Añadir el mensaje actual del usuario
    formattedMessages.add({
      "role": "user",
      "parts": [
        {"text": userMessage}
      ]
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "contents": formattedMessages,
        "safetySettings": [
          {
            "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
            "threshold": "BLOCK_MEDIUM_AND_ABOVE"
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
          String botMessage =
              data['candidates'][0]['content']['parts'][0]['text']?.trim() ??
                  'No response from bot';
          return botMessage;
        } else {
          return 'No candidates available in response';
        }
      } catch (e) {
        return 'Error parsing response: $e';
      }
    } else {
      return "Error: ${response.statusCode} ${response.body}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: CustomAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  bool isUserMessage = _messages[index]['role'] == 'user';
                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage ? _lightPink : _lightPurple,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        _messages[index]['parts']!,
                        style: TextStyle(
                          color: isUserMessage ? _darkPurple : _darkBlack,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(9.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkPurple),
              ),
            ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Envía un mensaje a Meta AI...",
                        hintStyle: TextStyle(
                          color: Colors.black45,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0xFFF1F5F9),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF0B0D0F),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _isConnected ? _sendMessage : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
