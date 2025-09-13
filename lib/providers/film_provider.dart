import 'package:flutter/material.dart';
import '../services/APINode/recuperer_data.dart';

class FilmProvider with ChangeNotifier {
  // id -> titre ; null = inconnu (404 ou autre échec)
  final Map<String, String?> _titlesCache = {};

  /// Titre nullable (à privilégier pour filtrer l'affichage)
  String? getFilmTitleOrNull(String filmId) => _titlesCache[filmId];

  /// Getter de compatibilité (retourne '' si inconnu au lieu de "Film inconnu")
  String getFilmTitle(String filmId) => _titlesCache[filmId] ?? '';

  /// Indique si on a un titre exploitable (non nul / non vide)
  bool hasKnownTitle(String filmId) {
    final t = _titlesCache[filmId];
    return t != null && t.trim().isNotEmpty;
  }

  /// Charge le titre depuis l’API si pas encore connu (silencieux : pas de logs)
  Future<void> loadTitleIfMissing(String filmId) async {
    if (_titlesCache.containsKey(filmId)) return; // déjà connu (y compris "inconnu")

    try {
      final String? title = await fetchFilmTitleById(filmId); // doit renvoyer null si 404
      if (title != null && title.trim().isNotEmpty) {
        _titlesCache[filmId] = title.trim();
      } else {
        _titlesCache[filmId] = null; // on mémorise "inconnu" sans afficher
      }
    } catch (_) {
      // échec réseau/parse -> on marque "inconnu" silencieusement
      _titlesCache[filmId] = null;
    }

    notifyListeners();
  }
}
