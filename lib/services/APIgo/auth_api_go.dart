import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApiGo {
  final String baseUrl = "http://127.0.0.1:3000/api";

  /// Inscription d'un utilisateur
  Future<Map<String, dynamic>?> signup(String email, String password,
      String dob, String name, String firstname) async {
    final String url = "$baseUrl/signup";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "dob": dob,
          "name": name,
          "firstname": firstname
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.body.isNotEmpty ? jsonDecode(response.body) : {};
      } else {
        return {"error": "Échec de l'inscription : ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Erreur réseau : $e"};
    }
  }

  /// Connexion d'un utilisateur
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final String url = "$baseUrl/login";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Échec de la connexion : ${response.statusCode}"};
      }
    } catch (e) {
      return {"error": "Erreur réseau : $e"};
    }
  }
}
