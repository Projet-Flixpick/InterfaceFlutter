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

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/select-genres': (context) => const ChoisirGenresScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/my-genres': (context) => const UserGenresScreen(),
  '/liked-movies': (context) => const UserFilmsStatutScreen(),
  '/my-friends': (context) => const UserAmisScreen(),
};
