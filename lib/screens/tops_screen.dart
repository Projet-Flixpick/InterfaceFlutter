// lib/screens/tops_screen.dart

import 'package:flutter/material.dart';
import '../models/film_model.dart';
import '../services/film_loader.dart';  // Assure-toi d'importer la méthode depuis film_loader.dart
import '../widgets/films_card.dart';

class TopsScreen extends StatefulWidget {
  const TopsScreen({super.key});

  @override
  _TopsScreenState createState() => _TopsScreenState();
}

class _TopsScreenState extends State<TopsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Films'),
      ),
      body: FutureBuilder<List<Film>>(
        future: loadFilms(), // Appelle la méthode loadFilms() importée
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Erreur de chargement des films.'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun film trouvé.'));
          }

          // Si tout va bien, on a les films à afficher
          List<Film> films = snapshot.data!;

          return ListView.builder(
            itemCount: films.length,
            itemBuilder: (context, index) {
              return FilmsCard(film: films[index]);
            },
          );
        },
      ),
    );
  }
}
