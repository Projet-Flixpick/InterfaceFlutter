import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../1.home/home_screen.dart';
import 'register_screen.dart';
import 'package:flutter_application_1/screens/4.autre/choisir_genres_screen.dart';
import 'package:flutter_application_1/services/APIgo/auth_api_go.dart';
import 'package:flutter_application_1/services/synchroniser_remote2local.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/film_statut_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApiGo _authApi = AuthApiGo();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? validateEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  String? validatePassword(String value) {
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    return null;
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final response = await _authApi.login(email, password);

    if (response != null && response.containsKey("error")) {
      setState(() {
        if (response["error"].toString().toLowerCase().contains("connexion") ||
            response["error"].toString().toLowerCase().contains("401")) {
          _errorMessage = "Email or password incorrect.";
        } else {
          _errorMessage = "Login failed. Please try again.";
        }
        _isLoading = false;
      });
      return;
    }


    if (response != null && response.containsKey("token")) {
      final token = response["token"];
      final user = response["user"];

      print("🎟️ Token JWT reçu : $token");

      if (token == null || token.split('.').length != 3) {
        print("❌ Token mal formé !");
        setState(() {
          _errorMessage = "Erreur : token JWT invalide.";
          _isLoading = false;
        });
        return;
      }

      print("✅ Token JWT bien formé.");

      Provider.of<AuthProvider>(context, listen: false).setToken(token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("jwt_token", token);

      await SynchroniserRemote2Local.run(
        token: token,
        authProvider: Provider.of<AuthProvider>(context, listen: false),
        filmProvider: Provider.of<FilmStatutProvider>(context, listen: false),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Welcome on FlixPick !")),
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
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 90),
                  Image.asset(
                    'assets/images/Logo_FlixPick_Enter.png',
                    height: 150,
                  ),
                  Image.asset(
                    'assets/images/Logo_PopCorn_Solo.png',
                    height: 200,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => validateEmail(value ?? ""),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => validatePassword(value ?? ""),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Se connecter", style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Pas encore de compte ?"),
                      TextButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                          if (result != null && result is String) {
                            setState(() {
                              _emailController.text = result;
                            });
                          }
                        },
                        child: const Text("Inscription"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}