import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/APIgo/auth_api_go.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final AuthApiGo _authApi = AuthApiGo();

  bool _isAccepted = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _firstnameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String name = _nameController.text.trim();
    final String firstname = _firstnameController.text.trim();
    final String dob = _dobController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty || firstname.isEmpty || dob.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Veuillez remplir tous les champs.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Les mots de passe ne correspondent pas.";
      });
      return;
    }

    if (!_isAccepted) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Vous devez accepter les conditions générales.";
      });
      return;
    }

    final response = await _authApi.signup(email, password, dob, name, firstname);

    if (response != null && response.containsKey("error")) {
      setState(() {
        _errorMessage = response["error"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie !")),
      );
      Navigator.pop(context);
    }

    setState(() {
      _isLoading = false;
    });
  }

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
              const SizedBox(height: 20),
              Center(
                child: Image.asset(
                  'assets/images/Logo_FlixPick.png',
                  height: 200,
                  width: 200,
                ),
              ),
              const SizedBox(height: 20),

              // Champs utilisateur
              TextField(
                controller: _firstnameController,
                decoration: const InputDecoration(labelText: "Prénom"),
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Nom"),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Mot de passe"),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Confirmer le mot de passe"),
              ),
              TextField(
                controller: _dobController,
                decoration: const InputDecoration(
                  labelText: "Date de naissance",
                  hintText: "JJ/MM/AAAA",
                ),
                keyboardType: TextInputType.datetime,
              ),

              const SizedBox(height: 20),
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
                      children: const [
                        Text(
                          "J'ai lu et j'accepte les conditions générales et la politique de confidentialité.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _onRegister,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
