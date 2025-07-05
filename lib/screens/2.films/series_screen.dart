import 'package:flutter/material.dart';
import '../../models/film_model.dart';
import '../../services/APINode/api_routes_node.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';
import '../../widgets/popcorn_loader.dart';

class SeriesScreen extends StatefulWidget {
  const SeriesScreen({super.key});

  @override
  _SeriesScreenState createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen>
    with AutomaticKeepAliveClientMixin<SeriesScreen> {
  List<Film> popularSeries = [];
  List<Film> topRatedSeries = [];
  List<Film> unvotedSeries = [];

  int popularPage = 1;
  int topPage = 1;
  int unvotedPage = 1;

  bool isLoadingPopular = true;
  bool isLoadingTop = true;
  bool isLoadingUnvoted = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadPopular();
    _loadTop();
    _loadUnvoted();
  }

  Future<void> _loadPopular() async {
    try {
      final data = await fetchPopularSeries(page: popularPage);
      if (!mounted) return;
      setState(() {
        popularSeries = data.take(10).toList();
        isLoadingPopular = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingPopular = false);
    }
  }

  Future<void> _loadTop() async {
    try {
      final data = await fetchTopSeries(page: topPage);
      if (!mounted) return;
      setState(() {
        topRatedSeries = data.take(10).toList();
        isLoadingTop = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingTop = false);
    }
  }

  Future<void> _loadUnvoted() async {
    try {
      final data = await fetchUnvotedSeries(page: unvotedPage);
      if (!mounted) return;
      setState(() {
        unvotedSeries = data.take(10).toList();
        isLoadingUnvoted = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoadingUnvoted = false);
    }
  }

  Future<void> _loadMore(String section) async {
    switch (section) {
      case 'popular':
        final data = await fetchPopularSeries(page: ++popularPage);
        if (!mounted) return;
        setState(() {
          popularSeries.addAll(data.take(10));
        });
        break;
      case 'top':
        final data = await fetchTopSeries(page: ++topPage);
        if (!mounted) return;
        setState(() {
          topRatedSeries.addAll(data.take(10));
        });
        break;
      case 'unvoted':
        final data = await fetchUnvotedSeries(page: ++unvotedPage);
        if (!mounted) return;
        setState(() {
          unvotedSeries.addAll(data.take(10));
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ListView(
        key: const PageStorageKey('series_page'),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TitreSection(
              title: 'Most Popular Series',
              sectionColor: Colors.purpleAccent,
            ),
          ),
          isLoadingPopular
              ? const Center(
                  child: PopcornLoader(
                    size: 28,
                    strokeWidth: 2.5,
                    color: Color(0xFFFAD271),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                )
              : FilmsList(
                  key: const PageStorageKey('popular_series'),
                  films: popularSeries,
                  loadMoreFilms: () => _loadMore('popular'),
                ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TitreSection(
              title: 'Top Rated Series',
              sectionColor: Colors.green,
            ),
          ),
          isLoadingTop
              ? const Center(
                  child: PopcornLoader(
                    size: 28,
                    strokeWidth: 2.5,
                    color: Color(0xFFFAD271),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                )
              : FilmsList(
                  key: const PageStorageKey('top_series'),
                  films: topRatedSeries,
                  loadMoreFilms: () => _loadMore('top'),
                ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TitreSection(
              title: 'Unvoted Series',
              sectionColor: Colors.grey,
            ),
          ),
          isLoadingUnvoted
              ? const Center(
                  child: PopcornLoader(
                    size: 28,
                    strokeWidth: 2.5,
                    color: Color(0xFFFAD271),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                )
              : FilmsList(
                  key: const PageStorageKey('unvoted_series'),
                  films: unvotedSeries,
                  loadMoreFilms: () => _loadMore('unvoted'),
                ),
        ],
      ),
    );
  }
}
