import 'package:flutter/material.dart';
import '../../models/film_model.dart';
import '../../services/APINode/api_routes_node.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';
import '../../widgets/popcorn_loader.dart';

class TopsScreen extends StatefulWidget {
  const TopsScreen({super.key});

  @override
  _TopsScreenState createState() => _TopsScreenState();
}

class _TopsScreenState extends State<TopsScreen>
    with AutomaticKeepAliveClientMixin<TopsScreen> {
  List<Film> popularFilms = [];
  List<Film> topRatedFilms = [];
  List<Film> unvotedFilms = [];

  int popularPage = 1;
  int topPage = 1;
  int unvotedPage = 1;

  bool isPopularLoading = false;
  bool isTopLoading = false;
  bool isUnvotedLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadInitialFilms();
  }

  Future<void> _loadInitialFilms() async {
    await _loadMoreFilms('popular');
    await _loadMoreFilms('top');
    await _loadMoreFilms('unvoted');
  }

  Future<void> _loadMoreFilms(String section) async {
    switch (section) {
      case 'popular':
        if (isPopularLoading) return;
        setState(() => isPopularLoading = true);
        final data = await fetchPopularMovies(page: popularPage++);
        final valid = data.where((f) => f.voteAverage != 5).toList();
        if (!mounted) return;
        setState(() {
          popularFilms.addAll(valid);
          isPopularLoading = false;
        });
        break;

      case 'top':
        if (isTopLoading) return;
        setState(() => isTopLoading = true);
        List<Film> validTop = [];
        while (validTop.isEmpty && topPage < 5) {
          final data = await fetchTopMovies(page: topPage++);
          validTop = data.where((f) => f.voteAverage != 5).toList();
        }
        if (!mounted) return;
        setState(() {
          topRatedFilms.addAll(validTop);
          isTopLoading = false;
        });
        break;

      case 'unvoted':
        if (isUnvotedLoading) return;
        setState(() => isUnvotedLoading = true);
        final data = await fetchUnvotedMovies(page: unvotedPage++);
        if (!mounted) return;
        setState(() {
          unvotedFilms.addAll(data);
          isUnvotedLoading = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      key: const PageStorageKey('tops_page'),
      children: [
        TitreSection(title: 'Most Popular Films'),
        popularFilms.isEmpty
            ? const Center(child: PopcornLoader())
            : FilmsList(
                key: const PageStorageKey('popular_films'),
                films: popularFilms,
                loadMoreFilms: () => _loadMoreFilms('popular'),
              ),
        TitreSection(title: 'Top Rated Films'),
        topRatedFilms.isEmpty
            ? const Center(child: PopcornLoader())
            : FilmsList(
                key: const PageStorageKey('top_films'),
                films: topRatedFilms,
                loadMoreFilms: () => _loadMoreFilms('top'),
              ),
        TitreSection(title: 'Unvoted Films'),
        unvotedFilms.isEmpty
            ? const Center(child: PopcornLoader())
            : FilmsList(
                key: const PageStorageKey('unvoted_films'),
                films: unvotedFilms,
                loadMoreFilms: () => _loadMoreFilms('unvoted'),
              ),
      ],
    );
  }
}
