class ShortFilm {
  final String id;
  final String videoId;
  final String title;
  final String overview;
  final String creator;
  final String language;
  final String releaseDate;
  final String genre;
  final String posterPath;
  final String linkVideo;

  ShortFilm({
    required this.id,
    required this.videoId,
    required this.title,
    required this.overview,
    required this.creator,
    required this.language,
    required this.releaseDate,
    required this.genre,
    required this.posterPath,
    required this.linkVideo,
  });

  // Factory method to create a ShortFilm from JSON data
  factory ShortFilm.fromJson(Map<String, dynamic> json) {
    return ShortFilm(
      id: json['_id'] ?? '',
      videoId: json['videoId'] ?? '',
      title: json['title'] ?? 'Titre inconnu',
      overview: json['overview'] ?? '',
      creator: json['creator'] ?? 'Créateur inconnu',
      language: json['language'] ?? '',
      releaseDate: json['release_date'] ?? '0000-00-00',
      genre: json['genre'] ?? '',
      posterPath: json['poster_path'] ?? '',
      linkVideo: json['linkVideo'] ?? '',
    );
  }
}
