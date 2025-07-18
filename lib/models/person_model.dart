class Person {
  final String id;
  final String name;
  final String? profilePath;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final int? gender;
  final String? imdbId;
  final String? knownForDepartment;
  final String? placeOfBirth;
  final double? popularity;
  final List<String>? alsoKnownAs;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    this.biography,
    this.birthday,
    this.deathday,
    this.gender,
    this.imdbId,
    this.knownForDepartment,
    this.placeOfBirth,
    this.popularity,
    this.alsoKnownAs,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      biography: json['biography'],
      birthday: json['birthday'],
      deathday: json['deathday'],
      gender: json['gender'],
      imdbId: json['imdb_id'],
      knownForDepartment: json['known_for_department'],
      placeOfBirth: json['place_of_birth'],
      popularity: (json['popularity'] is int)
          ? (json['popularity'] as int).toDouble()
          : (json['popularity'] is double)
              ? json['popularity']
              : null,
      alsoKnownAs: (json['also_known_as'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  String? get profileImageUrl =>
      (profilePath != null && profilePath!.isNotEmpty)
          ? 'https://image.tmdb.org/t/p/w185$profilePath'
          : null;
}