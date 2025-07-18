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
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
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

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('fr'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/"
            "${picked.month.toString().padLeft(2, '0')}/"
            "${picked.year}";
      });
    }
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    if (!_isAccepted) {
      setState(() {
        _isLoading = false;
        _errorMessage = "You must accept the terms and conditions.";
      });
      return;
    }

    final response = await _authApi.signup(email, password, dob, name, firstname);

    if (response == null) {
      setState(() {
        _errorMessage = "Unexpected error. Please try again.";
      });
    } else if (response.containsKey("error")) {
      setState(() {
        _errorMessage = response["error"];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registration successful!")),
      );
      Navigator.pop(context, email);
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
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/images/Logo_FlixPick_Enter.png',
                    height: 150,
                  ),
                  Image.asset(
                    'assets/images/Logo_PopCorn_Solo.png',
                    height: 200,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _firstnameController,
                    decoration: const InputDecoration(labelText: "First Name"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Last Name"),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) => validateEmail(value ?? ""),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => validatePassword(value ?? ""),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Confirm Password"),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return "Passwords do not match.";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () => _pickDate(context),
                    decoration: const InputDecoration(
                      labelText: "Date of Birth (optional)",
                      hintText: "JJ/MM/AAAA",
                    ),
                    validator: (value) => null,
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
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "I have read and accept the terms and privacy policy.",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  if (_errorMessage != null)
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Sign Up", style: TextStyle(fontSize: 16)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already an account ?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("Sign In"),
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
