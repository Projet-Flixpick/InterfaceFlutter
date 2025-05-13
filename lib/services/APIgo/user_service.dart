import 'dart:convert';
import 'package:http/http.dart' as http;
import '../APIgo/api_routes.dart';

class UserService {
  final String token;

  UserService({required this.token}) {
    print('[UserService] ✅ Token reçu : $token');
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // --- LIKE ---
  Future<bool> likeMovie(String movieId) {
    print('[LIKE] filmId = $movieId');
    return _postMovieAction(ApiRoutes.addLike, movieId);
  }

  Future<bool> deleteLike(String movieId) {
    print('[DELETE LIKE] filmId = $movieId');
    return _deleteMovieAction(ApiRoutes.deleteLike, movieId);
  }

  // --- DISLIKE ---
  Future<bool> dislikeMovie(String movieId) {
    print('[DISLIKE] filmId = $movieId');
    return _postMovieAction(ApiRoutes.addDislike, movieId);
  }

  Future<bool> deleteDislike(String movieId) {
    print('[DELETE DISLIKE] filmId = $movieId');
    return _deleteMovieAction(ApiRoutes.deleteDislike, movieId);
  }

  // --- SEEN ---
  Future<bool> markMovieAsSeen(String movieId) {
    print('[SEEN] filmId = $movieId');
    return _postMovieAction(ApiRoutes.addSeenMovie, movieId);
  }

  Future<bool> deleteSeenMovie(String movieId) {
    print('[DELETE SEEN] filmId = $movieId');
    return _deleteMovieAction(ApiRoutes.deleteSeenMovie, movieId);
  }

  // --- Utilitaires internes ---
  Future<bool> _postMovieAction(String url, String movieId) async {
    print('[POST] URL: $url');
    print('[POST] Headers: $_headers');
    print('[POST] Body: {"movie_id": {"\$oid": "$movieId"}}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'movie_id': {'\$oid': movieId},
        }),
      );

      print('[POST] Status: ${response.statusCode}');
      print('[POST] Response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur POST API ($url): $e');
      return false;
    }
  }

  Future<bool> _deleteMovieAction(String url, String movieId) async {
    print('[DELETE] URL: $url');
    print('[DELETE] Headers: $_headers');
    print('[DELETE] Body: {"movie_id": {"\$oid": "$movieId"}}');

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: _headers,
        body: jsonEncode({
          'movie_id': {'\$oid': movieId},
        }),
      );

      print('[DELETE] Status: ${response.statusCode}');
      print('[DELETE] Response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Erreur DELETE API ($url): $e');
      return false;
    }
  }
}
