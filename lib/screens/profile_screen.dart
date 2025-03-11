import 'package:flutter/material.dart';
import '../widgets/top_screen_title.dart'; // Importer le widget TopScreenTitle

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Liste des genres de films disponibles
  final List<String> genres = [
    "Action",
    "Science-fiction",
    "Comédie",
    "Aventure",
    "Horreur",
    "Romance",
    "Drame",
    "Thriller",
  ];

  // Liste des genres sélectionnés
  Set<String> selectedGenres = {};

  // Fonction pour ouvrir la boîte de dialogue des genres
  void _showGenresDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Sélectionnez vos genres préférés"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: genres.map((genre) {
              return CheckboxListTile(
                title: Text(genre),
                value: selectedGenres.contains(genre),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedGenres.add(genre);
                    } else {
                      selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopScreenTitle(
        title: "Profile Utilisateur", // Titre
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 2.0,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),

            // Avatar Cercle
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Informations de Profil
            const Text(
              "Nom d'utilisateur : John Doe",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Email : johndoe@email.com",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Section des Cercles (Amis, Réglages, Genres)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCircleButton(context, "Amis", Icons.people, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FriendsScreen()),
                  );
                }),
                _buildCircleButton(context, "Réglages", Icons.settings, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()),
                  );
                }),
                _buildCircleButton(context, "Genres", Icons.movie_filter, () {
                  _showGenresDialog();
                }),
              ],
            ),

            const SizedBox(height: 30),

            // Affichage des genres sélectionnés
            const Text(
              "Genres sélectionnés :",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 8.0,
              children: selectedGenres.map((genre) {
                return Chip(label: Text(genre));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour créer un cercle avec un icône
  Widget _buildCircleButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<String> friends = ['Alice', 'Bob', 'Charlie'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Amis"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Amis",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(friends[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              friends.removeAt(index);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.movie, color: Colors.blue),
                          onPressed: () {
                            _showWatchMoviesDialog(context, friends[index]);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => _addFriendDialog(context),
              child: const Text("Ajouter un ami"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher la boîte de dialogue d'ajout d'ami
  void _addFriendDialog(BuildContext context) {
    final TextEditingController friendController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter un ami"),
          content: TextField(
            controller: friendController,
            decoration: const InputDecoration(labelText: "Nom de l'ami"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                if (friendController.text.isNotEmpty) {
                  setState(() {
                    friends.add(friendController.text);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Ajouter"),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher la boîte de dialogue "Regarder des films avec [Nom de l'ami]"
  void _showWatchMoviesDialog(BuildContext context, String friendName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Regarder des films avec $friendName"),
          content: const Text(
              "C'est le moment de regarder des films ensemble ! Choisis un film à regarder."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Réglages"),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Réglages du profil",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text("Modifier le nom d'utilisateur"),
            const SizedBox(height: 10),
            const Text("Gérer les notifications"),
            const SizedBox(height: 10),
            const Text("Changer le mot de passe"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Action pour quitter les réglages ou enregistrer
              },
              child: const Text("Enregistrer les modifications"),
            ),
          ],
        ),
      ),
    );
  }
}
