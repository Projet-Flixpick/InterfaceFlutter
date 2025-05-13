import 'package:flutter/material.dart';

// Screens
import 'screens/1.home/home_screen.dart';
import 'screens/3.profile/profil_screen.dart';
import 'screens/4.autre/choisir_genres_screen.dart';
import 'screens/0.auth/login_screen.dart';
import 'screens/0.auth/register_screen.dart';
import 'screens/3.profile/user_genres_screen.dart';
import 'screens/3.profile/user_films_statut_screen.dart';
import 'screens/3.profile/user_amis_screen.dart';

// Add more screens as needed

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const LoginScreen(),
  '/home': (context) => const HomeScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/select-genres': (context) => const ChoisirGenresScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/my-genres': (context) => const UserGenresScreen(),
  '/liked-movies': (context) => const UserFilmsStatutScreen(),
  '/my-friends': (context) => const UserAmisScreen(),

  // Add additional routes here
};
