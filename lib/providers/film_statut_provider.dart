import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/APIgo/api_routes.dart';

class FilmStatutProvider with ChangeNotifier {
  final List<String> _likedFilms = [];
  final List<String> _dislikedFilms = [];
  final List<String> _seenFilms = [];

  List<String> get likedFilms => _likedFilms;
  List<String> get dislikedFilms => _dislikedFilms;
  List<String> get seenFilms => _seenFilms;

  bool isLiked(String id) => _likedFilms.contains(id);
  bool isDisliked(String id) => _dislikedFilms.contains(id);
  bool isSeen(String id) => _seenFilms.contains(id);

  Future<void> toggleLike(String filmId, String token) async {
    if (_likedFilms.contains(filmId)) {
      _likedFilms.remove(filmId);
      notifyListeners();
      await http.delete(
        Uri.parse('${ApiRoutes.deleteLike}/$filmId'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      _likedFilms.add(filmId);
      notifyListeners();
      await http.post(
        Uri.parse(ApiRoutes.addLike),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'movieId': filmId}),
      );
    }
  }

  Future<void> toggleDislike(String filmId, String token) async {
    if (_dislikedFilms.contains(filmId)) {
      _dislikedFilms.remove(filmId);
      notifyListeners();
      await http.delete(
        Uri.parse('${ApiRoutes.deleteDislike}/$filmId'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      _dislikedFilms.add(filmId);
      notifyListeners();
      await http.post(
        Uri.parse(ApiRoutes.addDislike),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'movieId': filmId}),
      );
    }
  }

  Future<void> toggleVu(String filmId, String token) async {
    if (_seenFilms.contains(filmId)) {
      _seenFilms.remove(filmId);
      notifyListeners();
      await http.delete(
        Uri.parse('${ApiRoutes.deleteSeenMovie}/$filmId'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } else {
      _seenFilms.add(filmId);
      notifyListeners();
      await http.post(
        Uri.parse(ApiRoutes.addSeenMovie),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'movieId': filmId}),
      );
    }
  }
}
