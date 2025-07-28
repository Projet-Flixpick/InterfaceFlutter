// lib/models/film_model.dart

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
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : rawId is String
            ? int.tryParse(rawId) ?? 0
            : 0;

    final genreIds = (json['genre_ids'] as List<dynamic>?)
            ?.map((e) {
              if (e is int) return e;
              if (e is String) return int.tryParse(e) ?? 0;
              return 0;
            })
            .toList() ??
        [];

    final genres = (json['genres'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final popularity = (json['popularity'] as num?)?.toDouble() ?? 0.0;
    final voteAverage = (json['vote_average'] as num?)?.toDouble() ?? 0.0;
    final voteCount = json['vote_count'] is int
        ? json['vote_count'] as int
        : json['vote_count'] is String
            ? int.tryParse(json['vote_count']) ?? 0
            : 0;

    final isSerie = (json['type'] as String?)?.toLowerCase() == 'serie';

    return Film(
      mongoId: json['_id'] as String? ?? '',
      id: id,
      title: json['title'] as String? ?? 'Titre inconnu',
      originalTitle: json['original_title'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      releaseDate: json['release_date'] as String? ?? '',
      posterPath: json['poster_path'] as String? ?? '',
      genres: genres,
      genreIds: genreIds,
      popularity: popularity,
      voteAverage: voteAverage,
      voteCount: voteCount,
      originalLanguage: json['original_language'] as String? ?? '',
      isAdult: json['adult'] as bool? ?? false,
      backdropPath: json['backdrop_path'] as String? ?? '',
      isVideo: json['video'] as bool? ?? false,
      providers: json['providers'] as Map<String, dynamic>?,
      cast: (json['cast'] as List<dynamic>?)
              ?.map((actorJson) => Cast.fromJson(actorJson as Map<String, dynamic>))
              .toList() ??
          [],
      isSerie: isSerie,
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
    final rawId = json['id'];
    final id = rawId is int
        ? rawId
        : rawId is String
            ? int.tryParse(rawId) ?? 0
            : 0;

    return Cast(
      mongoId: json['_id'] as String? ?? '',
      id: id,
      name: json['name'] as String? ?? 'Acteur inconnu',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }
}
