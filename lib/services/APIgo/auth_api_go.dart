import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AuthApiGo {
  final String baseUrl = "http://127.0.0.1:3000/api";

  // Gestion du cache
  final CacheManager _cacheManager = DefaultCacheManager();

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
    final String url = "$baseUrl/login";

    // Vérifier le cache
    final file = await _cacheManager.getFileFromCache(url);
    if (file != null) {
      final cachedData = await file.file.readAsString();
      return jsonDecode(cachedData);
    }

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        _cacheManager.putFile(url, response.bodyBytes); // Mise en cache
        return jsonDecode(response.body);
      } else {
        return {"error": "Échec de la connexion"};
      }
    } catch (e) {
      return {"error": "Erreur réseau : $e"};
    }
  }
}
