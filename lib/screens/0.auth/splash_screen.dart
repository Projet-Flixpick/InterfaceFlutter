import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../1.home/home_screen.dart';
import '../../services/synchroniser_remote2local.dart';
import '../../providers/auth_provider.dart';
import '../../providers/film_statut_provider.dart';
import '../../widgets/animated_logo.dart'; // à adapter selon ton arborescence

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    await Future.delayed(const Duration(seconds: 3)); // petit effet de pause

    if (token != null && token.split('.').length == 3) {
      print("🔁 Session existante trouvée, synchronisation en cours...");
      Provider.of<AuthProvider>(context, listen: false).setToken(token);

      await SynchroniserRemote2Local.run(
        token: token,
        authProvider: Provider.of<AuthProvider>(context, listen: false),
        filmProvider: Provider.of<FilmStatutProvider>(context, listen: false),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      print("🔓 Aucun token valide trouvé. Redirection vers Login.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AnimatedLogo(), // ici le logo animé personnalisé
      ),
    );
  }
}
