import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';
import '../1.home/home_screen.dart';
import '../../services/synchroniser_remote2local.dart';
import '../../providers/auth_provider.dart';
import '../../providers/film_statut_provider.dart';
import '../../widgets/loader.dart';

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
    print(">>> SPLASH _checkLoginStatus called");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    print(">>> Token = $token");

    await Future.delayed(const Duration(seconds: 2)); // effet de pause

    if (token != null && token.split('.').length == 3) {
      print("🔁 Session existante trouvée, synchronisation en cours...");
      Provider.of<AuthProvider>(context, listen: false).setToken(token);

      await SynchroniserRemote2Local.run(
        token: token,
        authProvider: Provider.of<AuthProvider>(context, listen: false),
        filmProvider: Provider.of<FilmStatutProvider>(context, listen: false),
      );

      if (!mounted) return;
      print(">>> Navigating to HomeScreen (reset stack)");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else {
      print("🔓 Aucun token valide trouvé. Redirection vers Login.");
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("=== SplashScreen build ===");
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedLogo(),
            SizedBox(height: 32),
            Text(
              "Chargement...",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
