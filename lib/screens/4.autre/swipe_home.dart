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
  final List<Film> _queue = [];
  int _moviePage = 1;
  int _seriesPage = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMore(); // charge la première catégorie
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final statutProv = Provider.of<FilmStatutProvider>(context, listen: false);

    // 1. Films populaires
    final movies = await fetchPopularMovies(page: _moviePage++);
    final moviesFiltered = movies.where((f) =>
      !statutProv.isLiked(f.mongoId) &&
      !statutProv.isDisliked(f.mongoId)
    ).toList();
    if (moviesFiltered.isNotEmpty) {
      setState(() => _queue.addAll(moviesFiltered));
      setState(() => _isLoading = false);
      return;
    }

    // 2. Séries populaires
    final series = await fetchPopularSeries(page: _seriesPage++);
    final seriesFiltered = series.where((f) =>
      !statutProv.isLiked(f.mongoId) &&
      !statutProv.isDisliked(f.mongoId)
    ).toList();
    if (seriesFiltered.isNotEmpty) {
      setState(() => _queue.addAll(seriesFiltered));
      setState(() => _isLoading = false);
      return;
    }

    // 3. Si aucune catégorie n'a rien
    setState(() => _isLoading = false);
  }

  bool _onSwipe(int prev, int? _, CardSwiperDirection dir, List<Film> available) {
    final film   = available[prev];
    final token  = Provider.of<AuthProvider>(context, listen: false).token;
    final statut = Provider.of<FilmStatutProvider>(context, listen: false);

    if (token != null) {
      if (dir == CardSwiperDirection.right) {
        statut.toggleLike(film.mongoId, token);
      } else {
        statut.toggleDislike(film.mongoId, token);
      }
    }

    // Charge plus si dernière carte dispo swipée
    if (prev >= available.length - 1) {
      _loadMore();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final statutProv = Provider.of<FilmStatutProvider>(context);

    // Filtrage à la volée (si on a déjà liké/disliké un film par le provider)
    final available = _queue.where((f) =>
      !statutProv.isLiked(f.mongoId) &&
      !statutProv.isDisliked(f.mongoId)
    ).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Movies')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Slide left to dislike',
                        style: TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      TextSpan(
                        text: '   •   ',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      TextSpan(
                        text: 'Slide right to like',
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: available.isEmpty
                ? Center(
                    child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          "No more items to swipe",
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                  )
                : CardSwiper(
                    cardsCount: available.length,
                    isLoop: false,
                    numberOfCardsDisplayed: 1,
                    allowedSwipeDirection:
                        AllowedSwipeDirection.only(left: true, right: true),
                    onSwipe: (i, _, dir) => _onSwipe(i, _, dir, available),
                    cardBuilder: (ctx, index, px, py) {
                      final film     = available[index];
                      final progress = (px / 100).clamp(-1.0, 1.0);
                      final opacity  = progress.abs().clamp(0.0, 0.7);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FilmDetailScreen(film: film),
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Transform.scale(
                              scale: 1 - (px.abs() * 0.1).clamp(0.0, 0.1),
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      film.posterPath,
                                      fit: BoxFit.cover,
                                    ),
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
                            if (px != 0)
                              Container(
                                color: progress > 0
                                    ? Colors.green.withOpacity(opacity)
                                    : Colors.red.withOpacity(opacity),
                              ),
                            if (px.abs() > 20)
                              Positioned(
                                top: 40,
                                left: progress > 0 ? 20 : null,
                                right: progress < 0 ? 20 : null,
                                child: Icon(
                                  progress > 0 ? Icons.thumb_up : Icons.thumb_down,
                                  size: 80,
                                  color: Colors.white.withOpacity(opacity),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
            ),
            if (_isLoading && _queue.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
