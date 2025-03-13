class Film {
  final int id;
  final String title;
  final String overview;
  final String releaseDate;
  final String posterPath;
  final List<String> genres;  // Liste des genres en tant que chaînes
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String originalLanguage;
  final bool isAdult;
  final String backdropPath;
  final bool isVideo;
  final Map<String, dynamic>? providers;  // Les providers de location/achat
  final List<Cast> cast;  // Liste des acteurs

  Film({
    required this.id,
    required this.title,
    required this.overview,
    required this.releaseDate,
    required String posterPath,  // On garde le nom original du paramètre
    required this.genres,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.isAdult,
    required this.backdropPath,
    required this.isVideo,
    this.providers,
    required this.cast,
  }) : posterPath = posterPath.isNotEmpty 
        ? 'https://image.tmdb.org/t/p/w500$posterPath' 
        : 'https://via.placeholder.com/100x150?text=No+Image'; // Ici, on affecte la valeur à posterPath après la vérification

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Titre inconnu',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '0000-00-00',
      posterPath: json['poster_path'] ?? '',  // Ici, le paramètre est un chemin vide ou non
      genres: (json['genres'] as List<dynamic>?)?.map((genre) => genre.toString()).toList() ?? [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      isAdult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'] ?? '',
      isVideo: json['video'] ?? false,
      providers: json['providers'],  // Les providers viennent directement du JSON
      cast: (json['cast'] as List<dynamic>?)?.map((actorJson) => Cast.fromJson(actorJson)).toList() ?? [],
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Acteur inconnu',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}
