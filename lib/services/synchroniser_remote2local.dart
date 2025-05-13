import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../services/APIgo/api_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/film_statut_provider.dart';

class SynchroniserRemote2Local {
  static Future<void> run({
    required String token,
    required AuthProvider authProvider,
    required FilmStatutProvider filmProvider,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(ApiRoutes.getCurrentUser),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        print("❌ Erreur de synchronisation : ${response.statusCode}");
        return;
      }

      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      // 🎥 Films
      final likes = List<String>.from(data['likes'] ?? []);
      final dislikes = List<String>.from(data['dislikes'] ?? []);
      final seen = List<String>.from(data['movies_seen'] ?? []);
      final genres = List<String>.from(data['genres'] ?? []);

      filmProvider.setDataFromServer(
        likes: likes,
        dislikes: dislikes,
        seen: seen,
        genres: genres,
      );

      await prefs.setStringList('local_likes', likes);
      await prefs.setStringList('local_dislikes', dislikes);
      await prefs.setStringList('local_seen', seen);
      await prefs.setStringList('local_genres', genres);

      // 👤 Infos utilisateur
      final user = data['user'] ?? {};
      authProvider.setUserInfoFromServer(
        email: user['email'] ?? '',
        firstname: user['firstname'] ?? '',
        name: user['name'] ?? '',
      );

      await prefs.setString("email", user["email"] ?? "");
      await prefs.setString("firstname", user["firstname"] ?? "");
      await prefs.setString("name", user["name"] ?? "");

      print('✅ Synchronisation complète effectuée avec succès.');
    } catch (e) {
      print('❌ Erreur pendant la synchronisation globale : $e');
    }
  }
}
