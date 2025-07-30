import 'package:flutter/material.dart';

// Vos imports d'écrans existants
import 'screens/1.home/home_screen.dart';
import 'screens/0.auth/login_screen.dart';
import 'screens/0.auth/register_screen.dart';
import 'screens/4.autre/choisir_genres_screen.dart';
import 'screens/3.profile/profil_screen.dart';
import 'screens/3.profile/user_genres_screen.dart';
import 'screens/3.profile/user_films_statut_screen.dart';
import 'screens/3.profile/user_amis_screen.dart';

// Nouveaux imports
import 'screens/3.profile/user_amis_demandes_screen.dart';
import 'screens/3.profile/add_friend_screen.dart';
import 'screens/2.films/recommendations_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home':               (ctx) => const HomeScreen(),
  '/login':              (ctx) => const LoginScreen(),
  '/register':           (ctx) => const RegisterScreen(),
  '/select-genres':      (ctx) => const ChoisirGenresScreen(),
  '/profile':            (ctx) => const ProfileScreen(),
  '/my-genres':          (ctx) => const UserGenresScreen(),
  '/liked-movies':       (ctx) => const UserFilmsStatutScreen(),
  '/my-friends':         (ctx) => const UserAmisScreen(),

  // --- Routes Amis ---
  '/add-friend':             (ctx) => const AddFriendScreen(),
  '/friend-requests':        (ctx) => const UserAmisDemandesScreen(),
  '/friend-recommendations': (ctx) => const RecommendationsScreen(),
};
