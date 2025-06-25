import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/user_provider.dart';
import '../0.auth/login_screen.dart';
import 'user_genres_screen.dart';
import 'user_films_statut_screen.dart';
import 'user_amis_screen.dart';
import 'user_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUser();
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text("${userProvider.prenom} ${userProvider.nom}"),
                subtitle: Text(userProvider.email),
              ),
              _statRow("Role", _mapRights(userProvider.rights)),
              const SizedBox(height: 20),
              const Text("Statistics", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _statRow("Liked movies", userProvider.likesCount.toString()),
              _statRow("Watched movies", userProvider.seenCount.toString()),
              _statRow("Genres selected", userProvider.genres.length.toString()),
              const Divider(height: 32),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('My favorite genres'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserGenresScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.movie),
                title: const Text('My liked / watched movies'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserFilmsStatutScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('My friends'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserAmisScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const UserSettingsScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log out'),
                onTap: _logout,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _mapRights(int rights) {
    switch (rights) {
      case 1: return "Contributor";
      case 2: return "Administrator";
      default: return "User";
    }
  }
}
