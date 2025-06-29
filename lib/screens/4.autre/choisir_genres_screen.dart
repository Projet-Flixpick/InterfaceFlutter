import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../providers/genre_provider.dart';
import '../../../providers/film_statut_provider.dart';
import '../../../models/genre_model.dart';
import '../../../widgets/titre_section.dart';
import '../../../widgets/top_screen_title.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/services/synchroniser_remote2local.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/1.home/home_screen.dart';

class ChoisirGenresScreen extends StatefulWidget {
  const ChoisirGenresScreen({super.key});

  @override
  State<ChoisirGenresScreen> createState() => _ChoisirGenresScreenState();
}

class _ChoisirGenresScreenState extends State<ChoisirGenresScreen> {
  final List<int> selectedGenreIds = [];
  final Set<String> selectedMongoIds = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final filmProvider = Provider.of<FilmStatutProvider>(context, listen: false);
      final genreProvider = Provider.of<GenreProvider>(context, listen: false);

      selectedMongoIds.addAll(filmProvider.preferredGenres);
      for (final genre in genreProvider.genres) {
        if (selectedMongoIds.contains(genre.mongoId)) {
          selectedGenreIds.add(genre.id);
        }
      }
      setState(() {});
    });
  }

  void toggleGenre(Genre genre) {
    setState(() {
      if (selectedGenreIds.contains(genre.id)) {
        selectedGenreIds.remove(genre.id);
        selectedMongoIds.remove(genre.mongoId);
      } else {
        selectedGenreIds.add(genre.id);
        selectedMongoIds.add(genre.mongoId);
      }
    });
  }

  void resetSelection() {
    setState(() {
      selectedGenreIds.clear();
      selectedMongoIds.clear();
    });
  }

  Future<void> continueSelection() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:3000/api/protected/updateGenres'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "genres": selectedMongoIds.toList(),
        }),
      );

      if (response.statusCode == 200) {
        await SynchroniserRemote2Local.run(
          token: token!,
          authProvider: Provider.of<AuthProvider>(context, listen: false),
          filmProvider: Provider.of<FilmStatutProvider>(context, listen: false),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Genres updated with success."),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur API : ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de connexion.")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  IconData getGenreIcon(String name) {
    switch (name.toLowerCase()) {
      case 'drama':
        return Icons.theater_comedy;
      case 'comedy':
        return Icons.emoji_emotions;
      case 'documentary':
        return Icons.menu_book;
      case 'romance':
        return Icons.favorite;
      case 'thriller':
        return Icons.flash_on;
      case 'action':
        return Icons.sports_mma;
      case 'horror':
        return Icons.sick;
      case 'science fiction':
        return Icons.science;
      case 'fantasy':
        return Icons.star;
      case 'animation':
        return Icons.animation;
      case 'music':
        return Icons.music_note;
      case 'history':
        return Icons.history_edu;
      case 'adventure':
        return Icons.explore;
      case 'mystery':
        return Icons.search;
      case 'family':
        return Icons.family_restroom;
      case 'tv movie':
        return Icons.live_tv;
      case 'war':
        return Icons.military_tech;
      case 'crime':
        return Icons.gavel;
      case 'western':
        return Icons.landscape;
      default:
        return Icons.movie;
    }
  }

  @override
  Widget build(BuildContext context) {
    final genreProvider = Provider.of<GenreProvider>(context);
    final genres = genreProvider.genres;

    return Scaffold(
      appBar: TopScreenTitle(title: 'Choose Your Genres'),
      body: genres.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      TitreSection(
                        title: 'Select your favorite genres',
                        sectionColor: Color(0xFFF9E3A8),
                      ),
                      ResetButton(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      itemCount: genres.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        final isSelected = selectedGenreIds.contains(genre.id);
                        return GestureDetector(
                          onTap: () => toggleGenre(genre),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(color: Color(0xFFFF5252), width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  getGenreIcon(genre.name),
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    genre.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Image.asset(
                                      'assets/icones/popcorn_check.png',
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: continueSelection,
        backgroundColor: const Color(0xFFFF5252),
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Save',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final parent = context.findAncestorStateOfType<_ChoisirGenresScreenState>();
    return TextButton.icon(
      onPressed: parent?.resetSelection,
      icon: const Icon(Icons.refresh, color: Color(0xFFFF5252)),
      label: const Text(
        "Reset",
        style: TextStyle(color: Color(0xFFFF5252)),
      ),
    );
  }
}
