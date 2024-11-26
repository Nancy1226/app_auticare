import 'package:app_auticare/Views/user_tutor/home_tutor.dart';
import 'package:app_auticare/Widgets/custom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_auticare/Views/user_tutor/profile_tutor.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:app_auticare/Widgets/costum_modal_tutor.dart';
import 'package:app_auticare/Widgets/app_routes.dart';

// Models
class Recommendation {
  final String uuid;
  final String categoria;
  final String consulta;
  final String recomendacion;
  final bool validada;

  Recommendation({
    required this.uuid,
    required this.categoria,
    required this.consulta,
    required this.recomendacion,
    required this.validada,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      uuid: json['uuid'] ?? '',
      categoria: json['categoria'] ?? '',
      consulta: json['consulta'] ?? '',
      recomendacion: json['recomendacion'] ?? '',
      validada: json['validada'] == 1,
    );
  }
}

// Constants
class Categories {
  static const List<String> all = [
    'Diagnóstico y Evaluación',
    'Tratamientos y Terapias',
    'Educación y Apoyo Escolar',
    'Vida Familiar y Social',
    'Salud y Bienestar',
    'Recursos y Servicios'
  ];
}

class Recomendations extends StatefulWidget {
  const Recomendations({Key? key}) : super(key: key);

  @override
  State<Recomendations> createState() => _RecomendationsState();
}

class _RecomendationsState extends State<Recomendations> {
  int _selectedIndex = 0;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;
  String? _nombre;
  String? _selectedCategory;
  List<Recommendation> _recommendations = [];
  String? uuidChild;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadUserData();
    await _loadRecommendations();
  }

  Future<void> _loadUserData() async {
    _token = await _storage.read(key: 'authToken');
    _nombre = await _storage.read(key: 'nombre');
    setState(() {});
    final String? selectedUuid = await _storage.read(key: 'uuidChild');
    if (selectedUuid != null) {
    print('UUID del niño seleccionado: $selectedUuid');
    uuidChild = selectedUuid; 
  } else {
    print('No se ha seleccionado ningún niño');
  }
  }

  Future<List<Recommendation>> _fetchRecommendations() async {
      if (_token == null) {
    throw Exception("Token no disponible");
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/v1/recommendations/validated/child/$uuidChild'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      
      // If no validated recommendations for this child
      if (data.isEmpty || !data.any((rec) => rec['validada'] == 1)) {
        throw Exception('No recommendations');
      }

      return data
          .where((rec) => rec['validada'] == 1)
          .map((rec) => Recommendation.fromJson(rec))
          .toList();
    } else {
      throw Exception('Error al obtener recomendaciones: ${response.body}');
    }
  }

  Future<void> _loadRecommendations() async {
  try {
    // Only fetch if a child is selected
    if (uuidChild == null) {
      setState(() {
        _recommendations = []; // Ensure empty if no child selected
      });
      return;
    }

    final allRecommendations = await _fetchRecommendations();
    
    // Filter recommendations for the specific child
    setState(() {
      _recommendations = allRecommendations
          .where((rec) =>
              (_selectedCategory == null || rec.categoria == _selectedCategory))
          .toList();
    });

    // Only write recommendation UUID if recommendations exist
    if (_recommendations.isNotEmpty) {
      await _storage.write(key: 'uuidRecomendation', value: _recommendations.first.uuid);
    }
  } catch (e) {
    if (e.toString().contains('No recommendations')) {
      // Handle specific case of no recommendations
      setState(() {
        _recommendations = [];
      });
    } else {
      _showErrorDialog('Error al cargar recomendaciones: $e');
    }
  }
 }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToScreen(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.home_tutor);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.board);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.chat);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.profile_childs);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _navigateToScreen,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFF1F5F9),
      elevation: 0,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed:() => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeTutor()),
          ),
        ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola ${_nombre ?? "invitado"}!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            "Revision",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF1F5F9),
            backgroundImage: AssetImage("lib/assets/profile.png"),
          ),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileTutor()),
          ),
        ),
      ],
    );
  }

 Widget _buildBody() {
  return ListView(
    padding: const EdgeInsets.all(16.0),
    children: [
      _buildCategoryDropdown(),
      const SizedBox(height: 16),
      if (_recommendations.isEmpty)
        Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(
                Icons.person_off_outlined, 
                size: 120, 
                color: Colors.black54,
              ),
              const SizedBox(height: 20),
              const Text(
                'No tiene recomendaciones',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Aún no se han generado recomendaciones para este niño.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        )
      else
        ...[
          const SizedBox(height: 16),
          ..._recommendations.map(_buildRecommendationCard),
        ],
    ],
  );
 }

  Widget _buildCategoryDropdown() {
    return DropdownButton<String>(
      value: _selectedCategory,
      hint: const Text(
        'Selecciona una categoría',
        style: TextStyle(fontSize: 14, color: Colors.black54),
      ),
      items: Categories.all
          .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
          .toList(),
      onChanged: (value) {
        setState(() => _selectedCategory = value);
        _loadRecommendations();
      },
    );
  }

  Widget _buildRecommendationCard(Recommendation recommendation) {
    return Container(
      width: 300,
      height: 220,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.white),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  recommendation.categoria,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recommendation.consulta,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          const Spacer(),
          _buildViewMoreButton(recommendation),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(Recommendation recommendation) {
    return ElevatedButton(
      onPressed: () => _showRecommendationModal(recommendation),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text("Ver más"),
    );
  }

  void _showRecommendationModal(Recommendation recommendation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CustomModalTutor(
        title: recommendation.categoria,
        consulta: recommendation.consulta,
        recomendacion: recommendation.recomendacion,
        onValidate: () {
        // Reload recommendations when modal validation is complete
        _loadRecommendations();
      },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
      // Remove uuidChild from storage only if no recommendations and no further action needed
    if (_recommendations.isEmpty) {
      _storage.delete(key: 'uuidChild');
      print('uuidChild eliminado del almacenamiento porque no hay recomendaciones.');
    }
    super.dispose();
  }

}