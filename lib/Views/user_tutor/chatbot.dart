import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_auticare/Widgets/custom_appbar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Child {
  final String uuidChild;
  final String nombre;

  Child({required this.uuidChild, required this.nombre});
}

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
  bool _isListening = false;
  late stt.SpeechToText _speech;
  final String _apiKey = 'AIzaSyBKQ8JcvejOkTxjMMyF87_gilg3V53-V1w';
  final _storage = const FlutterSecureStorage();
  Set<int> _validatedResponses = {};
  String ? _selectedCategory;

  List<Child> _children = [];
  Child? _selectedChild;


  final Color _lightPurple = Color(0xFFDBE1E9); //abajo
  final Color _lightPink = Color(0xFF6A62B7); //arriba
  final Color _darkPurple = Color.fromARGB(255, 255, 255, 255); //color de letra
  final Color _darkBlack = Color.fromARGB(255, 0, 0, 0); //color de letra

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkInternetConnection();
    _loadMessages();
    _getChilds();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });
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

    if (_selectedCategory == null || _selectedChild == null) {
      // Mostrar un SnackBar con el mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona una categoría y un niño antes de enviar tu mensaje.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (message.isNotEmpty) {
      setState(() {
        _messages.add({
          "role": "user", 
          "parts": "[$_selectedCategory] Consulta sobre ${_selectedChild?.nombre}: $message"
        });
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
     if (_selectedCategory == null || _selectedChild == null) {
      return "Por favor, selecciona una categoría y un niño antes de enviar tu mensaje.";
    }
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=$_apiKey');

        // Definimos el contexto de cada categoría
      Map<String, String> categoryContext = {
        'Diagnóstico y Evaluación': 
          'Experto en identificación de signos tempranos, evaluaciones y diagnóstico diferencial del autismo.',
        'Tratamientos y Terapias': 
          'Especialista en terapias conductuales, del habla, ocupacionales y tratamientos para niños con autismo.',
        'Educación y Apoyo Escolar': 
          'Experto en programas educativos especiales, adaptaciones escolares y transiciones educativas para niños con autismo.',
        'Vida Familiar y Social': 
          'Especialista en apoyo familiar, mejora de relaciones e integración social para niños con autismo.',
        'Salud y Bienestar': 
          'Experto en manejo de condiciones de salud, promoción de hábitos saludables y cuidado personal en niños con autismo.',
        'Recursos y Servicios': 
          'Especialista en conexión con recursos comunitarios, servicios de apoyo y asesoramiento para familias de niños con autismo.'
      };

      String contextPrompt = """
      Actúa como un ${categoryContext[_selectedCategory]}
      
      CONTEXTO:
      - Niño: ${_selectedChild?.nombre}
      - Categoría: $_selectedCategory
      - Consulta: $userMessage
      
      INSTRUCCIONES:
      Proporciona UNA ÚNICA recomendación que sea:
      1. Específica para la situación planteada
      2. Práctica y fácil de implementar
      3. En lenguaje simple y directo
      4. Enfocada exclusivamente en la categoría seleccionada
      5. Menciona para que servirá la recomendación y en que beneficiará al niño

      FORMATO DE RESPUESTA:
      - No uses preámbulos ni explicaciones adicionales
      - No menciones que eres una IA
      - Comienza directamente con la recomendación
    
      """;

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "contents": [{
              "role": "user",
              "parts": [{"text": contextPrompt}]
            }],
            "safetySettings": [
              {
                "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                "threshold": "BLOCK_MEDIUM_AND_ABOVE"
              }
            ],
          }),
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> data = jsonDecode(response.body);
          if (data.containsKey('candidates') && data['candidates'].isNotEmpty) {
            String botMessage = data['candidates'][0]['content']['parts'][0]['text']?.trim() ?? 
                'No se pudo generar una recomendación';

            // Asegurar que la respuesta sea concisa
            if (botMessage.length > 200) {
              int endIndex = botMessage.indexOf('.');
              if (endIndex > 0) {
                botMessage = botMessage.substring(0, endIndex + 1);
              }
            }
           if (_isRelevantResponse(botMessage)) {
            return "Recomendación: $botMessage";
          } else {
            return 'Lo siento, solo puedo responder preguntas relacionadas con el autismo infantil.';
          } 
            // return "Recomendación: $botMessage";
          }
        }
        return "No se pudo generar una recomendación en este momento.";
      } catch (e) {
        return "Error al procesar la solicitud: $e";
      }
  }

  // Método para verificar si la respuesta es relevante al contexto de autismo
  bool _isRelevantResponse(String response) {
    // Palabras clave para verificar relevancia al tema de autismo infantil
    List<String> keywords = [
      "autismo",
      "niños",
      "trastorno",
      "comportamiento",
      "terapia",
      "comunicación",
      "habilidades sociales",
      "diagnóstico",
      "síntomas"
    ];

    // Verifica si al menos una palabra clave está en la respuesta
    return keywords.any(
        (keyword) => response.toLowerCase().contains(keyword.toLowerCase()));
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (errorNotification) =>
            print('Error: $errorNotification.errorMsg'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _controller.text = val.recognizedWords;
          }),
        );
      } else {
        setState(() {
          _controller.text = 'No se pudo iniciar el reconocimiento de voz';
        });
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  List<String> _categories = [
    'Diagnóstico y Evaluación',
    'Tratamientos y Terapias',
    'Educación y Apoyo Escolar',
    'Vida Familiar y Social',
    'Salud y Bienestar',
    'Recursos y Servicios'
  ];

  bool _loading = true; 
  void _getChilds() async {
    setState(() {
    _loading = true;
    _selectedChild = null;
  });

  try {
    final String? uuid = await _storage.read(key: 'userUUid');
    print("UUID del tutor: $uuid");
    
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/v1/users/childs/tutor/$uuid'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      List<Child> fetchedChildren = data.map<Child>((child) => 
        Child(
          uuidChild: child['uuid'].toString(), 
          nombre: child['nombre'] as String
        )
      ).toList();

      setState(() {
        _children = fetchedChildren;
        _loading = false;
      });
    } else {
      print('Error al obtener los datos: ${response.statusCode}');
      setState(() {
        _loading = false;
      });
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      _loading = false;
    });
  }
 }


  Future<void> _sendValidationToApi(int messageIndex) async {
    try {

      final userMessage = _messages[messageIndex - 1];
      final botResponse = _messages[messageIndex];


      final Map<String, dynamic> validationData = {
        "id_nino": _selectedChild?.uuidChild,
        "categoria": _selectedCategory,
        "consulta": userMessage['parts'],
        "recomendacion": botResponse['parts'].toString().replaceFirst('Recomendación:', '').trim()
      };

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/v1/recommendations/'), // Ajusta la URL según tu API
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(validationData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Validación guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Error al guardar la validación
        throw Exception('Error al guardar la validación: ${response.statusCode}');
      }
    } catch (e) {
      // Manejo de errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la validación: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error en la validación: $e');
    }
  }

  // Actualizamos el método _handleValidation para usar la nueva función
  void _handleValidation(int index) async {
    if (!_validatedResponses.contains(index)) {
      setState(() {
        _validatedResponses.add(index);
      });
      
      // Enviamos la validación a la API
      await _sendValidationToApi(index);
    } else {
      // Opcional: Mostrar mensaje si ya está validado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Esta recomendación ya ha sido validada'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildValidateButton({required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF6A62B7),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          'Validar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
    
  @override
  Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color(0xFFF1F5F9),
    appBar: CustomAppBar(),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "¿Qué tipo de problema se te presentó?",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                items: _categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                isExpanded: true, // Hace que el Dropdown ocupe todo el ancho disponible
                hint: Text("Categoría"),
              ),
              SizedBox(height: 16),
              Text(
                "¿Sobre qué niño quieres consultar?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 8),
            _children.isEmpty
              ? Center(
                  child: _loading
                      ? CircularProgressIndicator()
                      : Text("No se encontraron niños disponibles."),
                )
              : DropdownButton<Child>(
                  value: _selectedChild,
                  onChanged: (Child? newValue) {
                    setState(() {
                      _selectedChild = newValue;
                    });
                  },
                  items: _children.map<DropdownMenuItem<Child>>((Child child) {
                    return DropdownMenuItem<Child>(
                      value: child,
                      child: Text(child.nombre),
                    );
                  }).toList(),
                  isExpanded: true,
                  hint: Text("Selecciona un niño"),
                ),
              ],
           ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child:ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUserMessage = _messages[index]['role'] == 'user';
                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    width: MediaQuery.of(context).size.width * 0.85,
                    decoration: BoxDecoration(
                      color: isUserMessage ? _lightPink : Color(0xFFEEEFF2),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isUserMessage)
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0, left: 16.0),
                            child: Row(
                              children: [
                                Icon(Icons.psychology, size: 20, color: Color(0xFF6A62B7)),
                                SizedBox(width: 8),
                                Text(
                                  'Recomendación',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A62B7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            isUserMessage 
                              ? _messages[index]['parts']!
                              : _messages[index]['parts']!.replaceFirst('Recomendación:', '').trim(),
                            style: TextStyle(
                              color: isUserMessage ? _darkPurple : _darkBlack,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!isUserMessage)
                          _buildValidateButton(
                            onPressed: () => _handleValidation(index),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_darkPurple),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
              SizedBox(width: 8.0),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.blue,
                ),
                onPressed: _listen,
              ),
              SizedBox(width: 8.0),
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
