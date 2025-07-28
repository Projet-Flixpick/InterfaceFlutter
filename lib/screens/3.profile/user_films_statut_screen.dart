// lib/screens/3.profile/user_films_statut_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/film_statut_provider.dart';
import '../../providers/film_provider.dart';
import '../../widgets/titre_section.dart';  // <-- import du widget

class UserFilmsStatutScreen extends StatelessWidget {
  const UserFilmsStatutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filmStatutProvider = Provider.of<FilmStatutProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Movies")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre “Liked Movies” via le widget TitreSection
            const TitreSection(title: "👍 Liked Movies"),
            const SizedBox(height: 8),
            Expanded(
              child: filmStatutProvider.likedFilms.isEmpty
                  ? const Center(child: Text("No liked movies."))
                  : Consumer<FilmProvider>(
                      builder: (context, filmProvider, _) {
                        return ListView.builder(
                          itemCount: filmStatutProvider.likedFilms.length,
                          itemBuilder: (context, index) {
                            final filmId = filmStatutProvider.likedFilms[index];
                            filmProvider.loadTitleIfMissing(filmId);

                            return ListTile(
                              leading:
                                  const Icon(Icons.thumb_up, color: Colors.green),
                              title: Text(filmProvider.getFilmTitle(filmId)),
                              onTap: () {
                                // si besoin, ajoute la navigation ici
                              },
                            );
                          },
                        );
                      },
                    ),
            ),

            // Titre “Watched Movies” via le widget TitreSection
            const TitreSection(title: "👁️ Watched Movies"),
            const SizedBox(height: 8),
            Expanded(
              child: filmStatutProvider.seenFilms.isEmpty
                  ? const Center(child: Text("No watched movies."))
                  : Consumer<FilmProvider>(
                      builder: (context, filmProvider, _) {
                        return ListView.builder(
                          itemCount: filmStatutProvider.seenFilms.length,
                          itemBuilder: (context, index) {
                            final filmId = filmStatutProvider.seenFilms[index];
                            filmProvider.loadTitleIfMissing(filmId);

                            return ListTile(
                              leading: const Icon(Icons.remove_red_eye,
                                  color: Colors.blue),
                              title: Text(filmProvider.getFilmTitle(filmId)),
                              onTap: () {
                                // si besoin, ajoute la navigation ici
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
