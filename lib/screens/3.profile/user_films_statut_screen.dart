import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/film_statut_provider.dart';
import '../../providers/film_provider.dart';
import '../../widgets/titre_section.dart';

class UserFilmsStatutScreen extends StatelessWidget {
  const UserFilmsStatutScreen({Key? key}) : super(key: key);

  List<String> _filterDisplayableIds(
    List<String> ids,
    FilmProvider filmProvider,
  ) {
    final display = <String>[];
    for (final id in ids) {
      filmProvider.loadTitleIfMissing(id); // déclenche le fetch si besoin
      final t = filmProvider.getFilmTitleOrNull(id);
      if (t != null && t.trim().isNotEmpty) {
        display.add(id); // on n'ajoute que les titres connus
      }
    }
    return display;
  }

  @override
  Widget build(BuildContext context) {
    final statut = context.watch<FilmStatutProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Movies')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<FilmProvider>(
          builder: (context, filmProvider, _) {
            final likedIds = _filterDisplayableIds(statut.likedFilms, filmProvider);
            final seenIds  = _filterDisplayableIds(statut.seenFilms,  filmProvider);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TitreSection(title: 'Liked Movies'),
                const SizedBox(height: 8),
                Expanded(
                  child: likedIds.isEmpty
                      ? const Center(child: Text('No liked movies.'))
                      : ListView.separated(
                          itemCount: likedIds.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final id = likedIds[index];
                            final title = filmProvider.getFilmTitleOrNull(id)!;
                            return ListTile(
                              leading: const Icon(Icons.thumb_up, color: Colors.green),
                              title: Text(title),
                            );
                          },
                        ),
                ),
                const TitreSection(title: 'Watched Movies'),
                const SizedBox(height: 8),
                Expanded(
                  child: seenIds.isEmpty
                      ? const Center(child: Text('No watched movies.'))
                      : ListView.separated(
                          itemCount: seenIds.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final id = seenIds[index];
                            final title = filmProvider.getFilmTitleOrNull(id)!;
                            return ListTile(
                              leading: const Icon(Icons.remove_red_eye, color: Colors.blue),
                              title: Text(title),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
