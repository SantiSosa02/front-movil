import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = "https://api-postgress.onrender.com/api/usuarios";

Future<Map<String, dynamic>> login(String email, String password) async {
  final body = jsonEncode({'correo': email, 'contrasena': password});

  final response = await http.post(
    Uri.parse('$apiUrl/login'),
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
    },
    body: body,
  );

  // Verifica si la respuesta contiene un token
  if (response.statusCode == 200 && response.body.contains('token')) {
    final responseData = jsonDecode(response.body);
    final token = responseData['token'];

    // Almacena el token en algún lugar accesible (puedes usar SharedPreferences, por ejemplo)
    saveTokenLocally(token);

    return responseData;
  } else {
    throw Exception('Inicio de sesión fallido');
  }
}

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('user');
    prefs.remove('authStatus');
  }

// Método para almacenar el token localmente
void saveTokenLocally(String token) {
  // Puedes utilizar SharedPreferences, secure storage o cualquier otro método de almacenamiento
  // Aquí te muestro cómo hacerlo con SharedPreferences
  // Asegúrate de agregar el paquete a tu archivo pubspec.yaml: dependencies: shared_preferences: ^2.0.8
  // Importa el paquete: import 'package:shared_preferences/shared_preferences.dart';

  SharedPreferences.getInstance().then((prefs) {
    prefs.setString('token', token);
  });
}
}


