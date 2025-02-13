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

  // Méthode pour créer un Film depuis un JSON
  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] ?? 0, // Valeur par défaut si null
      title: json['title'] ?? 'Titre inconnu', // Valeur par défaut si null
      overview: json['overview'] ?? '', // Valeur par défaut si null
      releaseDate: json['releaseDate'] ?? '', // Valeur par défaut si null
      posterPath: json['posterPath'] ?? '', // Valeur par défaut si null
      genres: (json['genres'] as List?)
              ?.map((genreJson) => Genre.fromJson(genreJson))
              .toList() ??
          [], // Valeur par défaut si genres est null
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0, // Valeur par défaut si null
      voteAverage: (json['voteAverage'] as num?)?.toDouble() ?? 0.0, // Valeur par défaut si null
      voteCount: json['voteCount'] ?? 0, // Valeur par défaut si null
      originalLanguage: json['originalLanguage'] ?? '', // Valeur par défaut si null
      isAdult: json['isAdult'] ?? false, // Valeur par défaut si null
      backdropPath: json['backdropPath'] ?? '', // Valeur par défaut si null
      isVideo: json['isVideo'] ?? false, // Valeur par défaut si null
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