import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/APIgo/api_routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FilmStatutProvider with ChangeNotifier {
  Set<String> _likes = {};
  Set<String> _dislikes = {};
  Set<String> _vu = {};

  Set<String> get likes => _likes;
  Set<String> get dislikes => _dislikes;
  Set<String> get vu => _vu;

  bool isLiked(String filmId) => _likes.contains(filmId);
  bool isDisliked(String filmId) => _dislikes.contains(filmId);
  bool isSeen(String filmId) => _vu.contains(filmId);

  Future<void> toggleLike(String filmId) async {
    print("👉 toggleLike filmId: $filmId");

    if (_likes.contains(filmId)) {
      // Supprimer le like
      final success = await _sendFilmId(ApiRoutes.deleteLike, filmId);
      if (success) _likes.remove(filmId);
    } else {
      // Ajouter le like
      final success = await _sendFilmId(ApiRoutes.addLike, filmId);
      if (success) {
        _likes.add(filmId);
        if (_dislikes.contains(filmId)) {
          await _sendFilmId(ApiRoutes.deleteDislike, filmId);
          _dislikes.remove(filmId);
        }
      }
    }

    print("✅ Likes actuels: $_likes");
    notifyListeners();
  }

  Future<void> toggleDislike(String filmId) async {
    print("👉 toggleDislike filmId: $filmId");

    if (_dislikes.contains(filmId)) {
      // Supprimer le dislike
      final success = await _sendFilmId(ApiRoutes.deleteDislike, filmId);
      if (success) _dislikes.remove(filmId);
    } else {
      // Ajouter le dislike
      final success = await _sendFilmId(ApiRoutes.addDislike, filmId);
      if (success) {
        _dislikes.add(filmId);
        if (_likes.contains(filmId)) {
          await _sendFilmId(ApiRoutes.deleteLike, filmId);
          _likes.remove(filmId);
        }
      }
    }

    print("✅ Dislikes actuels: $_dislikes");
    notifyListeners();
  }

  Future<void> toggleVu(String filmId) async {
    print("👉 toggleVu filmId: $filmId");

    if (_vu.contains(filmId)) {
      final success = await _sendFilmId(ApiRoutes.deleteSeenMovie, filmId);
      if (success) _vu.remove(filmId);
    } else {
      final success = await _sendFilmId(ApiRoutes.addSeenMovie, filmId);
      if (success) _vu.add(filmId);
    }

    print("✅ Films vus actuels: $_vu");
    notifyListeners();
  }

  Future<bool> _sendFilmId(String url, String filmId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return false;

    print("📤 Envoi à $url avec filmId: $filmId");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'filmId': filmId}),
      );

      print("📥 Réponse ${response.statusCode} : ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      print("❌ Exception API : $e");
      return false;
    }
  }
}
