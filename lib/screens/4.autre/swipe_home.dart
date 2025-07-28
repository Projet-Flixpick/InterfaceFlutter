// lib/screens/4.autre/swipe_home.dart

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';

import '../../models/film_model.dart';
import '../../services/APINode/api_routes_node.dart';
import '../../providers/film_statut_provider.dart';
import '../../providers/auth_provider.dart';
import '../2.films/film_detail_screen.dart';

class SwipeHomePage extends StatefulWidget {
  const SwipeHomePage({Key? key}) : super(key: key);

  @override
  State<SwipeHomePage> createState() => _SwipeHomePageState();
}

class _SwipeHomePageState extends State<SwipeHomePage> {
  List<Film> _films = [];
  int _currentPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  Future<void> _loadPage(int page) async {
    setState(() => _isLoading = true);
    try {
      final fetched = await fetchPopularMovies(page: page);
      setState(() {
        _films = fetched;       // <-- on remplace complètement la liste
        _currentPage = page + 1;
      });
    } catch (e) {
      debugPrint('Erreur chargement page $page : $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _onSwipe(int prev, int? _, CardSwiperDirection dir) {
    final film = _films[prev];
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final statutProv = Provider.of<FilmStatutProvider>(context, listen: false);

    if (token != null) {
      if (dir == CardSwiperDirection.right) {
        statutProv.toggleLike(film.mongoId, token);
      } else if (dir == CardSwiperDirection.left) {
        statutProv.toggleDislike(film.mongoId, token);
      }
    }

    // Si on a swipé la dernière carte, on charge la page suivante
    if (prev == _films.length - 1) {
      _loadPage(_currentPage);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Movies')),
      body: Stack(
        children: [
          if (_isLoading && _films.isEmpty)
            // chargement initial
            const Center(child: CircularProgressIndicator())
          else
            SafeArea(
              child: CardSwiper(
                cardsCount: _films.length,
                onSwipe: _onSwipe,
                allowedSwipeDirection:
                    AllowedSwipeDirection.only(left: true, right: true),
                cardBuilder: (context, index, px, py) {
                  final film = _films[index];
                  final scale = 1 - (px.abs() * 0.1).clamp(0.0, 0.1);
                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FilmDetailScreen(film: film),
                      ),
                    ),
                    child: Transform.scale(
                      scale: scale,
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(film.posterPath, fit: BoxFit.cover),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [Colors.black54, Colors.transparent],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16, right: 16, bottom: 24,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    film.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    film.overview,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_isLoading && _films.isNotEmpty)
            // mini-spinner au reload
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
