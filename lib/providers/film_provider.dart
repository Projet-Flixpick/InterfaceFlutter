import 'package:flutter/material.dart';
import '../services/APINode/recuperer_data.dart';

class FilmProvider with ChangeNotifier {
  final Map<String, String> _titlesCache = {}; // filmId → title

  /// Lire un titre (ou message temporaire si en attente)
  String getFilmTitle(String filmId) {
    return _titlesCache[filmId] ?? "Chargement...";
  }

  /// Charger le titre depuis l’API si pas encore connu
  Future<void> loadTitleIfMissing(String filmId) async {
    if (!_titlesCache.containsKey(filmId)) {
      final title = await fetchFilmTitleById(filmId);
      if (title != null) {
        _titlesCache[filmId] = title;
        notifyListeners(); // met à jour l’UI
      } else {
        _titlesCache[filmId] = "Film inconnu";
        notifyListeners();
      }
    }
  }
}
