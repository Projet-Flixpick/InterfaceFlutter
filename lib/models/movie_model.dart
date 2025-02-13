// movie_model.dart

class Film {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final String posterPath;
  final List<Genre> genres;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String originalLanguage;
  final bool isAdult;
  final String backdropPath;
  final bool isVideo;

  Film({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required this.posterPath,
    required this.genres,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.isAdult,
    required this.backdropPath,
    required this.isVideo,
  });
}

class Genre {
  final int id;
  final String name;  // Ajout du nom du genre

  Genre({
    required this.id,
    required this.name,
  });
}