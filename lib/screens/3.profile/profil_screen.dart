import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/screens/0.auth/login_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_genres_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_films_statut_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_amis_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_settings_screen.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool isLoading = true;
  bool notConnected = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() {
        notConnected = true;
        isLoading = false;
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:3000/api/protected/getUser'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        user = UserModel.fromJson(json.decode(response.body));
        isLoading = false;
      });
    } else {
      setState(() {
        notConnected = true;
        isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notConnected
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Vous n'êtes pas connecté.",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.login),
                        label: const Text("Se connecter"),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ListTile(
                      title: Text(user?.name ?? "Utilisateur"),
                      subtitle: Text(user?.email ?? ""),
                      leading: const Icon(Icons.person),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.category),
                      title: const Text('Mes genres préférés'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserGenresScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.movie),
                      title: const Text('Mes films likés / vus'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserFilmsStatutScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.people),
                      title: const Text('Mes amis'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserAmisScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Réglages'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserSettingsScreen()),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Déconnexion'),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
    );
  }
}
