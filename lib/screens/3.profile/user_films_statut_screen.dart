import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/film_statut_provider.dart';

class UserFilmsStatutScreen extends StatelessWidget {
  const UserFilmsStatutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final filmProvider = Provider.of<FilmStatutProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mes Films")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "👍 Films Likés",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filmProvider.likedFilms.isEmpty
                  ? const Text("Aucun film liké.")
                  : ListView.builder(
                      itemCount: filmProvider.likedFilms.length,
                      itemBuilder: (context, index) {
                        final filmId = filmProvider.likedFilms[index];
                        return ListTile(
                          leading: const Icon(Icons.thumb_up, color: Colors.green),
                          title: Text("Film ID : $filmId"),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            const Text(
              "👁️ Films Vus",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filmProvider.seenFilms.isEmpty
                  ? const Text("Aucun film vu.")
                  : ListView.builder(
                      itemCount: filmProvider.seenFilms.length,
                      itemBuilder: (context, index) {
                        final filmId = filmProvider.seenFilms[index];
                        return ListTile(
                          leading: const Icon(Icons.remove_red_eye, color: Colors.blue),
                          title: Text("Film ID : $filmId"),
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
