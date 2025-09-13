  // ✅ lib/providers/user_provider.dart
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:http/http.dart' as http;
  import '../../services/APIgo/api_routes.dart';

  class UserProvider with ChangeNotifier {
    final bool debugMode = false;

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

        if (debugMode) {
          print("==> GET /getUser status: ${res.statusCode}");
          print("==> Raw response: ${res.body}");
        }

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);

          if (debugMode) {
            print("==> Parsed keys:");
            for (final entry in data.entries) {
              print("   ${entry.key} = ${entry.value}");
            }
          }

          email = data['email'] ?? '';
          nom = data['name'] ?? '';
          prenom = data['firstname'] ?? '';
          birthday = data['birthday'] ?? '';
          rights = data['rights'] ?? 0;

          if (debugMode) {
            print("==> Role brut (from JSON): ${data['rights']}");
          }

          likesCount = (data['likes'] as List?)?.length ?? 0;
          seenCount = (data['movies_seen'] as List?)?.length ?? 0;
          genres = List<String>.from(data['genres'] ?? []);

          if (debugMode) {
            print("==> User: $prenom $nom ($email)");
            print("==> Role: $rights | Likes: $likesCount | Seen: $seenCount");
          }

          notifyListeners();
        } else {
          if (debugMode) {
            print("❌ Failed to fetch user: ${res.statusCode}");
          }
        }
      } catch (e) {
        if (debugMode) {
          print("❌ Exception in loadUser: $e");
        }
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
        if (debugMode) {
          print("❌ Failed to delete user: ${res.statusCode}");
        }
        return false;
      } catch (e) {
        if (debugMode) {
          print("❌ Exception in deleteUser: $e");
        }
        return false;
      }
    }
  }
