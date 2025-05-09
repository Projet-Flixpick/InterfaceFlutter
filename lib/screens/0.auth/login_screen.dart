import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../1.home/home_screen.dart';
import 'register_screen.dart';
import 'package:flutter_application_1/screens/4.autre/choisir_genres_screen.dart';
import 'package:flutter_application_1/services/APIgo/auth_api_go.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApiGo _authApi = AuthApiGo();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    final response = await _authApi.login(email, password);

    if (response != null && response.containsKey("error")) {
      setState(() {
        _errorMessage = response["error"];
      });
    } else if (response != null && response.containsKey("token")) {
      final token = response["token"];
      final user = response["user"]; // doit être retourné par l'API !

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);

      // Stockage infos utilisateur
      if (user != null) {
        await prefs.setString("email", user["email"] ?? "");
        await prefs.setString("firstname", user["firstname"] ?? "");
        await prefs.setString("name", user["name"] ?? "");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie !")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }


    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Connecte-toi !")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FlixPick",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/Logo_FlixPick.png',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Mot de passe"),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onLogin,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Se connecter"),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Pas encore de compte ? "),
                    TextButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );

                        // Si un email est retourné → on le pré-remplit
                        if (result != null && result is String) {
                          setState(() {
                            _emailController.text = result;
                          });
                        }
                      },
                      child: const Text("S'inscrire"),
                    ),
                  ],
                ),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChoisirGenresScreen()),
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
