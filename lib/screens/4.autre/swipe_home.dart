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
  final Set<String> _seenIds = {}; // anti doublons (queue + déjà swipés)
  int _moviePage = 1;
  int _seriesPage = 1;
  bool _isLoading = false;

  // seuil de confort : on essaye de garder au moins N cartes d’avance
  static const int _bufferTarget = 8;
  static const int _maxAttemptsPerLoad = 6; // limite pour éviter des boucles infinies

  @override
  void initState() {
    super.initState();
    _loadMore(minToAdd: _bufferTarget);
  }

  // Filtre + anti-doublons + statut (like/dislike)
  List<Film> _filterNew(List<Film> list) {
    final statutProv = context.read<FilmStatutProvider>();
    final added = <Film>[];
    for (final f in list) {
      final id = f.mongoId;
      if (id.isEmpty) continue;
      if (_seenIds.contains(id)) continue;
      if (statutProv.isLiked(id) || statutProv.isDisliked(id)) continue;
      _seenIds.add(id);
      added.add(f);
    }
    return added;
  }

  Future<void> _loadMore({int minToAdd = 4}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final added = <Film>[];
    int attempts = 0;

    // alterne films/séries et avance les pages tant qu'on n'a pas de matière
    while (added.length < minToAdd && attempts < _maxAttemptsPerLoad) {
      attempts++;

      // priorité à la catégorie la moins parcourue pour équilibrer
      final tryMoviesFirst = _moviePage <= _seriesPage;

      if (tryMoviesFirst) {
        // Movies
        final movies = await fetchPopularMovies(page: _moviePage++);
        added.addAll(_filterNew(movies));

        if (added.length < minToAdd) {
          // Series
          final series = await fetchPopularSeries(page: _seriesPage++);
          added.addAll(_filterNew(series));
        }
      } else {
        // Series
        final series = await fetchPopularSeries(page: _seriesPage++);
        added.addAll(_filterNew(series));

        if (added.length < minToAdd) {
          // Movies
          final movies = await fetchPopularMovies(page: _moviePage++);
          added.addAll(_filterNew(movies));
        }
      }
    }

    if (mounted) {
      setState(() {
        _queue.addAll(added);
        _isLoading = false;
      });
    }
  }

  bool _onSwipe(int prev, int? _, CardSwiperDirection dir, List<Film> available) {
    final film   = available[prev];
    final token  = context.read<AuthProvider>().token;
    final statut = context.read<FilmStatutProvider>();

    if (token != null) {
      if (dir == CardSwiperDirection.right) {
        statut.toggleLike(film.mongoId, token);
      } else {
        statut.toggleDislike(film.mongoId, token);
      }
    }

    // Précharge dès qu'il reste peu de cartes visibles
    final remaining = available.length - 1 - prev;
    if (remaining <= 2) {
      _loadMore(minToAdd: _bufferTarget);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final statutProv = context.watch<FilmStatutProvider>();

    // Filtrage live (si like/dislike déclenché par ailleurs)
    final available = _queue.where((f) =>
      !statutProv.isLiked(f.mongoId) &&
      !statutProv.isDisliked(f.mongoId)
    ).toList();

    // Si on a très peu de cartes (ex: retour d’écran), tente un préchargement
    if (!_isLoading && available.length < (_bufferTarget ~/ 2)) {
      // petit délai pour laisser build se finir
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadMore(minToAdd: _bufferTarget);
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Swipe Movies')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.thumb_down, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Slide left to dislike'),
                    SizedBox(width: 20),
                    Icon(Icons.thumb_up, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Slide right to like'),
                  ],
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
                    allowedSwipeDirection: const AllowedSwipeDirection.only(left: true, right: true),
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
