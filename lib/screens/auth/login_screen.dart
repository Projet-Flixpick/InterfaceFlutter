import 'package:flutter/material.dart';
import '../home_screen.dart';  // Assurez-vous que ce fichier est bien importé
import '../auth/register_screen.dart';  // Import de la page d'enregistrement

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Méthode appelée lors du clic sur "Se connecter"
  void _onLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),  // Rediriger vers HomeScreen
    );
  }

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
                // Titre de l'application
                Text(
                  "FlixPick",
                  style: TextStyle(
                    fontSize: 40,  // Taille du texte
                    fontWeight: FontWeight.bold,  // Style du texte
                    color: Colors.redAccent,  // Couleur du texte
                  ),
                  textAlign: TextAlign.center,  // Centrer le texte
                ),
                const SizedBox(height: 20),  // Espace

                // Logo de l'application
                Image.asset(
                  'assets/images/Logo_FlixPick.png',  // Assurez-vous que le logo existe dans le bon dossier
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),

                // Champ pour l'email
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),

                // Champ pour le mot de passe
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                  obscureText: true,  // Cacher le mot de passe
                ),
                const SizedBox(height: 20),

                // Bouton de connexion
                ElevatedButton(
                  onPressed: _onLogin, // L'appel de la méthode de connexion
                  child: const Text("Se connecter"),
                ),
                const SizedBox(height: 20),

                // Lien pour aller à la page d'inscription
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
