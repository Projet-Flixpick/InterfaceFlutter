import 'package:flutter/material.dart';
import '../services/APIgo/user_service.dart';

class FilmStatutProvider with ChangeNotifier {
  final List<String> _likedFilms = [];
  final List<String> _dislikedFilms = [];
  final List<String> _seenFilms = [];
  final List<String> _preferredGenres = [];

  List<String> get likedFilms => _likedFilms;
  List<String> get dislikedFilms => _dislikedFilms;
  List<String> get seenFilms => _seenFilms;
  List<String> get preferredGenres => _preferredGenres;

  bool isLiked(String id) => _likedFilms.contains(id);
  bool isDisliked(String id) => _dislikedFilms.contains(id);
  bool isSeen(String id) => _seenFilms.contains(id);

  void setDataFromServer({
    required List<String> likes,
    required List<String> dislikes,
    required List<String> seen,
    required List<String> genres,
  }) {
    _likedFilms
      ..clear()
      ..addAll(likes);
    _dislikedFilms
      ..clear()
      ..addAll(dislikes);
    _seenFilms
      ..clear()
      ..addAll(seen);
    _preferredGenres
      ..clear()
      ..addAll(genres);

    notifyListeners();
  }

  Future<void> toggleLike(String filmId, String token) async {
    final service = UserService(token: token);

    if (_likedFilms.contains(filmId)) {
      _likedFilms.remove(filmId);
      await service.deleteLike(filmId);
    } else {
      _likedFilms.add(filmId);
      await service.likeMovie(filmId);

      if (_dislikedFilms.contains(filmId)) {
        _dislikedFilms.remove(filmId);
        await service.deleteDislike(filmId);
      }
    }

    notifyListeners();
  }

  Future<void> toggleDislike(String filmId, String token) async {
    final service = UserService(token: token);

    if (_dislikedFilms.contains(filmId)) {
      _dislikedFilms.remove(filmId);
      await service.deleteDislike(filmId);
    } else {
      _dislikedFilms.add(filmId);
      await service.dislikeMovie(filmId);

      if (_likedFilms.contains(filmId)) {
        _likedFilms.remove(filmId);
        await service.deleteLike(filmId);
      }
    }

    notifyListeners();
  }

  Future<void> toggleVu(String filmId, String token) async {
    final service = UserService(token: token);

    if (_seenFilms.contains(filmId)) {
      _seenFilms.remove(filmId);
      await service.deleteSeenMovie(filmId);
    } else {
      _seenFilms.add(filmId);
      await service.markMovieAsSeen(filmId);
    }

    notifyListeners();
  }
}
