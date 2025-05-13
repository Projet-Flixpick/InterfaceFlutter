import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Providers
import 'providers/genre_provider.dart';
import 'providers/film_statut_provider.dart';
import 'providers/auth_provider.dart';

// Routes
import 'app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // Lock to portrait mode
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
        ),
        initialRoute: '/',
        routes: appRoutes, // Centralized routes from app_routes.dart
      ),
    );
  }
}
