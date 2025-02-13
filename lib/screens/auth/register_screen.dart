import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("S'inscrire")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Centrer le titre "FlixPick"
              Center(
                child: Text(
                  "FlixPick",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                  height: 20), // Espacement entre le titre et l'image

              // Centrer l'image du logo
              Center(
                child: Image.asset(
                  'assets/images/Logo_FlixPick.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(
                  height: 20), // Espacement entre l'image et les champs

              // Champ Email
              const TextField(
                decoration: InputDecoration(labelText: "Email"),
              ),

              // Champ Pseudo
              const TextField(
                decoration: InputDecoration(labelText: "Pseudo"),
              ),

              // Champ Mot de passe
              const TextField(
                decoration: InputDecoration(labelText: "Mot de passe"),
                obscureText: true,
              ),

              // Champ Confirmer Mot de passe
              const TextField(
                decoration:
                    InputDecoration(labelText: "Confirmer le mot de passe"),
                obscureText: true,
              ),

              // Champ Date de naissance
              TextField(
                decoration: const InputDecoration(
                  labelText: "Date de naissance",
                  hintText: "JJ/MM/AAAA",
                ),
                keyboardType: TextInputType.datetime,
              ),

              const SizedBox(
                  height: 20), // Espacement entre les champs et le bouton

              // Case à cocher pour accepter les conditions générales
              Row(
                children: [
                  Checkbox(
                    value: _isAccepted,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAccepted = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text(
                          "J'ai lu et j'accepte les conditions générales, et la politique de confidentialité.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20), // Espacement avant le bouton

              // Bouton S'inscrire
              ElevatedButton(
                onPressed: _isAccepted
                    ? () {
                        // Logique pour s'inscrire
                        print("Utilisateur inscrit");
                      }
                    : null, // Le bouton est désactivé si les conditions ne sont pas acceptées
                child: const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
