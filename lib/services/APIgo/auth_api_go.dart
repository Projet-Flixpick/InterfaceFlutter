import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiGo {
  final String baseUrl = "http://172.20.10.6:3000/api";

  /// Inscription d'un utilisateur
  Future<Map<String, dynamic>?> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Échec de l'inscription"};
      }
    } catch (e) {
      return {"error": "Erreur réseau : $e"};
    }
  }

  /// Connexion d'un utilisateur
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Échec de la connexion"};
      }
    } catch (e) {
      return {"error": "Erreur réseau : $e"};
    }
  }
}
