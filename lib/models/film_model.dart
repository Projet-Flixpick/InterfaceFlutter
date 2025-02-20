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
    required String posterPath, // Ne change rien ici
    required this.genres,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.isAdult,
    required this.backdropPath,
    required this.isVideo,
  }) : posterPath = posterPath.isNotEmpty 
        ? 'https://image.tmdb.org/t/p/w500$posterPath' 
        : 'https://via.placeholder.com/100x150?text=No+Image'; // <-- Ajout d'un fallback


factory Film.fromJson(Map<String, dynamic> json) {
  return Film(
    id: json['id'] ?? 0,
    title: json['title'] ?? 'Titre inconnu',
    overview: json['overview'] ?? '',
    releaseDate: json['release_date'] ?? '0000-00-00',
    posterPath: json['poster_path'] ?? '', // Ne pas ajouter l'URL ici
    genres: (json['genres'] as List<dynamic>?)
            ?.map((genre) => Genre.fromJson(genre))
            .toList() ?? [],
    popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
    voteCount: json['vote_count'] ?? 0,
    originalLanguage: json['original_language'] ?? '',
    isAdult: json['adult'] ?? false,
    backdropPath: json['backdrop_path'] ?? '',
    isVideo: json['video'] ?? false,
  );
}

}


class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  // Méthode pour créer un Genre depuis un JSON
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0, // Valeur par défaut si null
      name: json['name'] ?? 'Genre inconnu', // Valeur par défaut si null
    );
  }
}