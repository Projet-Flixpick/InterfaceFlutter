import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/4.autre/choisir_genres_screen.dart';

class UserGenresScreen extends StatelessWidget {
  const UserGenresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mes genres")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChoisirGenresScreen()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Modifier mes genres"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text("Liste des genres préférés"),
            ),
          ],
        ),
      ),
    );
  }
}
