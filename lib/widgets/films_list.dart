import 'package:flutter/material.dart';
import 'films_card.dart';
import '../models/film_model.dart';

class FilmsList extends StatefulWidget {
  final List<Film> films; // List of already loaded films
  final Function loadMoreFilms; // Function to load more films

  const FilmsList({Key? key, required this.films, required this.loadMoreFilms}) 
      : super(key: key);

  @override
  _FilmsListState createState() => _FilmsListState();
}

class _FilmsListState extends State<FilmsList> {
  late ScrollController _scrollController;
  bool isLoading = false; // Local state for loading

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener); // Scroll listener
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // When reaching the end of the list, load more films
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !isLoading) {
      setState(() {
        isLoading = true; // Set loading to true while fetching more films
      });
      widget.loadMoreFilms().then((_) {
        setState(() {
          isLoading = false; // Reset loading after fetch
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220.0, // Fixed height for horizontal list
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.films.length + (isLoading ? 1 : 0), // Add 1 for loader if needed
        itemBuilder: (context, index) {
          if (index == widget.films.length) {
            return const Center(child: CircularProgressIndicator()); // Show loader
          } else {
            return Padding(
              padding: const EdgeInsets.only(right: 5), // Space between film cards
              child: FilmsCard(film: widget.films[index]),
            );
          }
        },
      ),
    );
  }
}
