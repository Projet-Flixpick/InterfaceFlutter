// lib/screens/4.autre/acteurs_list_screen.dart

import 'package:flutter/material.dart';
import '../../models/person_model.dart';
import '../../services/APINode/api_routes_node.dart';
import 'acteur_detail_screen.dart';

class ActeursListScreen extends StatelessWidget {
  const ActeursListScreen({Key? key}) : super(key: key);

  // URL de base pour les images d’acteur (à adapter si besoin)
  static const _baseImageUrl = 'https://image.tmdb.org/t/p/w200';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acteurs')),
      body: FutureBuilder<List<Person>>(
        future: fetchAllPeople(),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Erreur : ${snap.error}'));
          }
          final people = snap.data!;
          return ListView.builder(
            itemCount: people.length,
            itemBuilder: (ctx, i) {
              final person = people[i];
              final imageUrl = (person.profilePath?.isNotEmpty ?? false)
                  ? '$_baseImageUrl${person.profilePath}'
                  : null;

              return ListTile(
                leading: imageUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(imageUrl),
                        onBackgroundImageError: (_, __) {},
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(person.name),
                onTap: () {
                  // on convertit l’ID en String pour éviter le type error
                  Navigator.pushNamed(
                    context,
                    ActeurDetailScreen.routeName,
                    arguments: person.id.toString(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
