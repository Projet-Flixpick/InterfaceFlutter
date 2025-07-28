// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/genre_provider.dart';
import 'providers/film_statut_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/film_provider.dart';
import 'providers/user_provider.dart';

// Screens
import 'screens/3.profile/admin_screen.dart';
import 'screens/3.profile/contributeur_screen.dart';
import 'screens/0.auth/splash_screen.dart';
import 'screens/1.home/home_screen.dart';
import 'screens/0.auth/login_screen.dart';
import 'screens/0.auth/register_screen.dart';
import 'screens/4.autre/choisir_genres_screen.dart';
import 'screens/3.profile/profil_screen.dart';
import 'screens/3.profile/user_genres_screen.dart';
import 'screens/3.profile/user_films_statut_screen.dart';
import 'screens/3.profile/user_amis_screen.dart';
import 'screens/3.profile/user_amis_demandes_screen.dart';
import 'screens/4.autre/swipe_home.dart';
import 'screens/4.autre/acteurs_list_screen.dart';
import 'screens/4.autre/acteur_detail_screen.dart';

import 'theme/theme.dart';

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
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GenreProvider()..loadGenres()),
        ChangeNotifierProvider(create: (_) => FilmStatutProvider()),
        ChangeNotifierProvider(create: (_) => FilmProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FlixPick',
        theme: flixPickTheme,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/select-genres': (context) => const ChoisirGenresScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/my-genres': (context) => const UserGenresScreen(),
          '/liked-movies': (context) => const UserFilmsStatutScreen(),
          '/my-friends': (context) => const UserAmisScreen(),
          '/friend-requests': (context) => const UserAmisDemandesScreen(),
          '/swipe': (context) => const SwipeHomePage(),
          '/actors': (context) => const ActeursListScreen(),
          '/admin': (context) => const AdminScreen(),
          '/contributeur': (context) => const ContributeurScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == ActeurDetailScreen.routeName) {
            // accepte int ou String, convertit en String
            final raw = settings.arguments;
            final personId = raw is String ? raw : raw.toString();
            return MaterialPageRoute(
              builder: (_) => ActeurDetailScreen(personId: personId),
            );
          }
          return null;
        },
      ),
    );
  }
}
