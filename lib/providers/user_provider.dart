// lib/providers/user_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../services/APIgo/api_routes.dart';

class UserProvider with ChangeNotifier {
  String email = '';
  String nom = '';
  String prenom = '';
  String birthday = '';
  int rights = 0;
  int likesCount = 0;
  int seenCount = 0;
  List<String> genres = [];

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final res = await http.get(
        Uri.parse(ApiRoutes.getCurrentUser),
        headers: {'Authorization': 'Bearer $token'},
      );

      print("==> GET /getUser status: ${res.statusCode}");
      print("==> Réponse brute: ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        email = data['email'] ?? '';
        nom = data['name'] ?? '';
        prenom = data['firstname'] ?? '';
        birthday = data['birthday'] ?? '';
        rights = data['rights'] ?? 0;

        likesCount = (data['likes'] as List?)?.length ?? 0;
        seenCount = (data['movies_seen'] as List?)?.length ?? 0;
        genres = List<String>.from(data['genres'] ?? []);

        print("==> Utilisateur : $prenom $nom ($email)");
        print("==> Rôle: $rights | Likes: $likesCount | Seen: $seenCount");
        notifyListeners();
      } else {
        print("❌ Échec de récupération user : ${res.statusCode}");
      }
    } catch (e) {
      print("❌ Exception loadUser : $e");
    }
  }

  Future<bool> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final res = await http.delete(
        Uri.parse(ApiRoutes.deleteUser),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        await prefs.remove('jwt_token');
        return true;
      }
      print("❌ Suppression échouée : ${res.statusCode}");
      return false;
    } catch (e) {
      print("❌ Exception deleteUser : $e");
      return false;
    }
  }
}
