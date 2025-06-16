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
    required List<dynamic> likes,
    required List<dynamic> dislikes,
    required List<dynamic> seen,
    required List<dynamic> genres,
  }) {
    print("🟡 DEBUG - setDataFromServer()");
    print("→ likes: $likes");
    print("→ dislikes: $dislikes");
    print("→ seen: $seen");
    print("→ genres: $genres");

    try {
      _likedFilms
        ..clear()
        ..addAll(_extractIds(likes));
      print("✅ likedFilms: $_likedFilms");

      _dislikedFilms
        ..clear()
        ..addAll(_extractIds(dislikes));
      print("✅ dislikedFilms: $_dislikedFilms");

      _seenFilms
        ..clear()
        ..addAll(_extractIds(seen));
      print("✅ seenFilms: $_seenFilms");

      _preferredGenres
        ..clear()
        ..addAll(_extractIds(genres));
      print("✅ preferredGenres: $_preferredGenres");

      notifyListeners();
    } catch (e, stack) {
      print("❌ ERREUR dans setDataFromServer: $e");
      print(stack);
    }
  }

  List<String> _extractIds(List<dynamic> data) {
    print("🔍 DEBUG - _extractIds()");
    print("→ Entrée: $data");

    return data.map((e) {
      try {
        final result = e.toString();
        print("→ Transformé: $e => $result");
        return result;
      } catch (err) {
        print("❌ Erreur conversion ID: $e → $err");
        return "Erreur";
      }
    }).toList();
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
