import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/genre_provider.dart';
import 'providers/film_statut_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/0.auth/splash_screen.dart';
import 'theme/theme.dart'; // Ton fichier de thème personnalisé

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
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()..loadGenres()),
        ChangeNotifierProvider(create: (_) => FilmStatutProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlixPick',

        // ✅ Utilisation du thème global défini dans theme.dart
        theme: flixPickTheme,

        // ✅ Localisations
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // Tu peux ajouter 'fr' ici si besoin
        ],

        home: const SplashScreen(),
      ),
    );
  }
}
