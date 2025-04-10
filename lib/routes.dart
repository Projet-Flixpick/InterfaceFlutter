import 'package:flutter/material.dart';
import 'screens/1.home/home_screen.dart';
import 'screens/3.profile/profil_screen.dart';
import 'screens/4.autre/choisir_genres_screen.dart';
import 'screens/0.auth/login_screen.dart';
import 'screens/0.auth/register_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_genres_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_films_statut_screen.dart';
import 'package:flutter_application_1/screens/3.profile/user_amis_screen.dart';

// Ajoute ici tous les autres écrans

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const HomeScreen(),
  '/profil': (context) => const ProfileScreen(),
  '/choisir-genres': (context) => const ChoisirGenresScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/mes-genres': (context) => const UserGenresScreen(),
  '/films-likes': (context) => const UserFilmsStatutScreen(),
  '/mes-amis': (context) => const UserAmisScreen(),

  // ...
};
