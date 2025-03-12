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

    // Vérifier si la réponse est déjà en cache
    final file = await _cacheManager.getFileFromCache(url);

    if (file != null) {
      // Si les films sont dans le cache, on les retourne directement
      final cachedData = await file.file.readAsString();
      return jsonDecode(cachedData);
    }

    try {
      // Si pas de cache, on fait l'appel API
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Mettre en cache la réponse pour les prochaines requêtes
        _cacheManager.putFile(url, response.bodyBytes);
        
        // Retourner les films décodés
        return jsonDecode(response.body);
      } else {
        throw Exception("Échec du chargement des films");
      }
    } catch (e) {
      throw Exception("Erreur réseau : $e");
    }
  }
}
