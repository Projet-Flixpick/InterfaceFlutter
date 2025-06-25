import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../0.auth/login_screen.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen({super.key});

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<UserProvider>(context, listen: false).loadUser();
  }

  void _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Provider.of<UserProvider>(context, listen: false).deleteUser();
      if (success && context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deletion failed.")),
        );
      }
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    if (context.mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('User Settings')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile("Last name", userProvider.nom),
                _infoTile("First name", userProvider.prenom),
                _infoTile("Email", userProvider.email),
                _infoTile("Birthdate", userProvider.birthday.isEmpty ? "Not specified" : userProvider.birthday),
                _infoTile("Role", _mapRights(userProvider.rights)),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Delete my account"),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: _deleteAccount,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Log out"),
                  onPressed: _logout,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Text(value, style: const TextStyle(color: Colors.black87)),
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
