import 'package:flutter/material.dart';
import '../home_screen.dart'; // Import de la page d'accueil
import '../auth/register_screen.dart'; // Import de la page de register


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Connectes toi !")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                // Titre en grand au centre
                Text(
                  "FlixPick",
                  style: TextStyle(
                    fontSize: 40,  // Taille 
                    fontWeight: FontWeight.bold,  // Style
                    color: Colors.redAccent ,  // Couleur
                  ),
                  textAlign: TextAlign.center,  // Centrer
                ),
                const SizedBox(height: 20),  // Espacement

                // Image en haut de la page
                Image.asset(
                  'assets/images/Logo_FlixPick.png',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20), // Espace entre l'image et les champs

                // Champs de saisie
                TextField(
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,
                ),
                const SizedBox(height: 20),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: const Text("Se connecter"),
                ),
                const SizedBox(height: 20),

                // Invitation à s'inscrire
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pas encore de compte ? "),
                    TextButton(
                      onPressed: () {
                         Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    );
                      },
                      child: const Text("S'inscrire"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
