import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';  // Pour utiliser le cache HTTP

class AuthApiNode {
  final String baseUrl = "http://localhost:8080";
  
  // Instancier un cache manager pour la gestion du cache
  final CacheManager _cacheManager = DefaultCacheManager();

  /// Récupérer la liste des films avec une pagination
  Future<List<dynamic>> getMovies({int page = 1}) async {
  final String url = "$baseUrl/movies?page=$page";

  // Vérification du cache
  final file = await _cacheManager.getFileFromCache(url);
  if (file != null) {
    final cachedData = await file.file.readAsString();
    final jsonData = jsonDecode(cachedData);
    return jsonData['data']; // Extraire la liste des films
  }

  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      _cacheManager.putFile(url, response.bodyBytes); // Stocker dans le cache
      return jsonData['data']; // Extraire la liste des films
    } else {
      throw Exception("Échec du chargement des films");
    }
  } catch (e) {
    throw Exception("Erreur réseau : $e");
    }
  }
}
