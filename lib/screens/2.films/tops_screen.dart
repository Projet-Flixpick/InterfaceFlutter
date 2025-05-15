import 'package:flutter/material.dart';
import '../../models/film_model.dart';
import 'package:flutter_application_1/services/APINode/auth_api_node.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';

class TopsScreen extends StatefulWidget {
  const TopsScreen({super.key});

  @override
  _TopsScreenState createState() => _TopsScreenState();
}

class _TopsScreenState extends State<TopsScreen>
    with AutomaticKeepAliveClientMixin<TopsScreen> {
  List<Film> popularFilms = [];
  List<Film> weeklyFilms = [];
  List<Film> shortFilms = [];
  List<Film> weeklyShortFilms = [];

  int currentPagePopular = 1;
  int currentPageWeekly = 1;
  int currentPageShort = 1;
  int currentPageWeeklyShort = 1;

  bool isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadFilms();
  }

  Future<void> _loadFilms() async {
    final api = AuthApiNode();

    final popData      = await api.getMovies(page: currentPagePopular);
    final weekData     = await api.getMovies(page: currentPageWeekly);
    final shortData    = await api.getMovies(page: currentPageShort);
    final weekShortData= await api.getMovies(page: currentPageWeeklyShort);

    if (!mounted) return;
    setState(() {
      popularFilms     .addAll(popData.take(5).map((j) => Film.fromJson(j)));
      weeklyFilms      .addAll(weekData.take(5).map((j) => Film.fromJson(j)));
      shortFilms       .addAll(shortData.take(5).map((j) => Film.fromJson(j)));
      weeklyShortFilms .addAll(weekShortData.take(5).map((j) => Film.fromJson(j)));
      isLoading = false;
    });
  }

  Future<void> _loadMoreFilms(String section) async {
    if (isLoading) return;
    setState(() => isLoading = true);

    final api = AuthApiNode();
    List<Film> newBatch = [];

    switch (section) {
      case 'popular':
        final data = await api.getMovies(page: currentPagePopular++);
        newBatch = data.take(5).map((j) => Film.fromJson(j)).toList();
        popularFilms.addAll(newBatch);
        break;
      case 'weekly':
        final data = await api.getMovies(page: currentPageWeekly++);
        newBatch = data.take(5).map((j) => Film.fromJson(j)).toList();
        weeklyFilms.addAll(newBatch);
        break;
      case 'short':
        final data = await api.getMovies(page: currentPageShort++);
        newBatch = data.take(5).map((j) => Film.fromJson(j)).toList();
        shortFilms.addAll(newBatch);
        break;
      case 'weeklyShort':
        final data = await api.getMovies(page: currentPageWeeklyShort++);
        newBatch = data.take(5).map((j) => Film.fromJson(j)).toList();
        weeklyShortFilms.addAll(newBatch);
        break;
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              key: const PageStorageKey('tops_page'),
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TitreSection(
                    title: 'Top Popular Movies',
                    sectionColor: Colors.blueAccent,
                  ),
                ),
                FilmsList(
                  key: const PageStorageKey('popular_films'),
                  films: popularFilms,
                  loadMoreFilms: () => _loadMoreFilms('popular'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TitreSection(
                    title: 'This Week\'s Movies',
                    sectionColor: Colors.indigo,
                  ),
                ),
                FilmsList(
                  key: const PageStorageKey('weekly_films'),
                  films: weeklyFilms,
                  loadMoreFilms: () => _loadMoreFilms('weekly'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TitreSection(
                    title: 'Top Short Films',
                    sectionColor: Colors.teal,
                  ),
                ),
                FilmsList(
                  key: const PageStorageKey('short_films'),
                  films: shortFilms,
                  loadMoreFilms: () => _loadMoreFilms('short'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TitreSection(
                    title: 'This Week\'s Short Films',
                    sectionColor: Colors.tealAccent,
                  ),
                ),
                FilmsList(
                  key: const PageStorageKey('weekly_short_films'),
                  films: weeklyShortFilms,
                  loadMoreFilms: () => _loadMoreFilms('weeklyShort'),
                ),
              ],
            ),
    );
  }
}
