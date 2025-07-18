class Film {
  final String mongoId;
  final int id;
  final String title;
  final String originalTitle;
  final String overview;
  final String releaseDate;
  final String posterPath;
  final List<String> genres;
  final List<int> genreIds;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String originalLanguage;
  final bool isAdult;
  final String backdropPath;
  final bool isVideo;
  final Map<String, dynamic>? providers;
  final List<Cast> cast;
  final bool isSerie;

  Film({
    required this.mongoId,
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.overview,
    required this.releaseDate,
    required String posterPath,
    required this.genres,
    required this.genreIds,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.originalLanguage,
    required this.isAdult,
    required this.backdropPath,
    required this.isVideo,
    this.providers,
    required this.cast,
    required this.isSerie,
  }) : posterPath = posterPath.isNotEmpty
            ? 'https://image.tmdb.org/t/p/w500$posterPath'
            : 'https://via.placeholder.com/100x150?text=No+Image';

  factory Film.fromJson(Map<String, dynamic> json) {
    return Film(
      mongoId: json['_id'] ?? '',
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Titre inconnu',
      originalTitle: json['original_title'] ?? '',
      overview: json['overview'] ?? '',
      releaseDate: json['release_date'] ?? '0000-00-00',
      posterPath: json['poster_path'] ?? '',
      genres: (json['genres'] as List<dynamic>?)
              ?.map((genre) => genre.toString())
              .toList() ??
          [],
      genreIds: (json['genre_ids'] as List<dynamic>?)
              ?.map((id) => id as int)
              .toList() ??
          [],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      originalLanguage: json['original_language'] ?? '',
      isAdult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'] ?? '',
      isVideo: json['video'] ?? false,
      providers: json['providers'],
      cast: (json['cast'] as List<dynamic>?)
              ?.map((actorJson) => Cast.fromJson(actorJson))
              .toList() ??
          [],
      isSerie: json['type'] == 'serie'
    );
  }
}

class Cast {
  final String mongoId;
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.mongoId,
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      mongoId: json['_id'] ?? '',
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Acteur inconnu',
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}
