import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/APIgo/api_routes.dart';

class FilmStatutProvider with ChangeNotifier {
  Set<String> _likes = {};
  Set<String> _dislikes = {};
  Set<String> _vu = {};

  Set<String> get likes => _likes;
  Set<String> get dislikes => _dislikes;
  Set<String> get vu => _vu;

  bool isLiked(String id) => _likes.contains(id);
  bool isDisliked(String id) => _dislikes.contains(id);
  bool isSeen(String id) => _vu.contains(id);

  void toggleLike(String id) async {
    final alreadyLiked = _likes.contains(id);

    if (alreadyLiked) {
      _likes.remove(id);
      await _callStatutApi(ApiRoutes.deleteLike, id);
    } else {
      _likes.add(id);
      _dislikes.remove(id);
      await _callStatutApi(ApiRoutes.addLike, id);
    }

    notifyListeners();
  }

  void toggleDislike(String id) async {
    final alreadyDisliked = _dislikes.contains(id);

    if (alreadyDisliked) {
      _dislikes.remove(id);
      await _callStatutApi(ApiRoutes.deleteDislike, id);
    } else {
      _dislikes.add(id);
      _likes.remove(id);
      await _callStatutApi(ApiRoutes.addDislike, id);
    }

    notifyListeners();
  }

  void toggleVu(String id) async {
    final alreadySeen = _vu.contains(id);

    if (alreadySeen) {
      _vu.remove(id);
      await _callStatutApi(ApiRoutes.deleteSeenMovie, id);
    } else {
      _vu.add(id);
      await _callStatutApi(ApiRoutes.addSeenMovie, id);
    }

    notifyListeners();
  }

  Future<void> _callStatutApi(String url, String filmId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"filmId": filmId}),
      );

      if (response.statusCode != 200) {
        debugPrint("❌ Statut API error [$url] : ${response.statusCode} — ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Connexion échouée à $url : $e");
    }
  }

  // 🔄 Pour synchroniser depuis le user (optionnel)
  void setFromUserData(Map<String, dynamic> data) {
    _likes = Set<String>.from(data["likes"] ?? []);
    _dislikes = Set<String>.from(data["dislikes"] ?? []);
    _vu = Set<String>.from(data["movies_seen"] ?? []);
    notifyListeners();
  }
}
