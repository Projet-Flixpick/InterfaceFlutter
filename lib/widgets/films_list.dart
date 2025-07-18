import 'package:flutter/material.dart';
import 'films_card.dart';
import '../models/film_model.dart';
import 'popcorn_loader.dart';

class FilmsList extends StatefulWidget {
  final List<Film> films;
  final Future<void> Function() loadMoreFilms;

  const FilmsList({
    Key? key,
    required this.films,
    required this.loadMoreFilms,
  }) : super(key: key);

  @override
  _FilmsListState createState() => _FilmsListState();
}

class _FilmsListState extends State<FilmsList> {
  late final ScrollController _scrollController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading) {
      setState(() => isLoading = true);
      widget.loadMoreFilms().then((_) {
        if (mounted) {
          setState(() => isLoading = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 0),
      child: SizedBox(
        height: 220.0,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.films.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == widget.films.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: PopcornLoader(
                    size: 30,
                    color: Color(0xFFFAD271),
                    strokeWidth: 3,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: FilmsCard(film: widget.films[index]),
            );
          },
        ),
      ),
    );
  }
}
