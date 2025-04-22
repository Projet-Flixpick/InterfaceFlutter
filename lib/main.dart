import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/genre_provider.dart';
import 'providers/film_statut_provider.dart'; // <-- ajoute ce provider

// Screens
import 'screens/0.auth/login_screen.dart';
import 'screens/4.autre/choisir_genres_screen.dart';
import 'screens/1.home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GenreProvider()..loadGenres()),
        ChangeNotifierProvider(create: (_) => FilmStatutProvider()), // <-- ici
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Movies App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/choisir-genres': (context) => const ChoisirGenresScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
