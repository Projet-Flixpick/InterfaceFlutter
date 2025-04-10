import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIgo/api_routes.dart';

class UserService {
  Future<Map<String, dynamic>?> fetchCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse(ApiRoutes.getCurrentUser),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Erreur getUser ${response.statusCode} : ${response.body}");
      return null;
    }
  }

  Future<bool> updateUser(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse(ApiRoutes.updateUser),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> updateGenres(String token, List<String> genreIds) async {
    final response = await http.put(
      Uri.parse(ApiRoutes.updateGenres),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({"genres": genreIds}),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteUser(String token) async {
    final response = await http.delete(
      Uri.parse(ApiRoutes.deleteUser),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}
