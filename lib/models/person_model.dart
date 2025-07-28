// lib/models/person_model.dart

class Person {
  final int id;
  final String name;
  final List<String>? alsoKnownAs;
  final String? biography;
  final String? birthday;
  final String? deathday;
  final int? gender;
  final String? homepage;
  final String? imdbId;
  final String? knownForDepartment;
  final String? placeOfBirth;
  final double? popularity;
  final String? profilePath;

  Person({
    required this.id,
    required this.name,
    this.alsoKnownAs,
    this.biography,
    this.birthday,
    this.deathday,
    this.gender,
    this.homepage,
    this.imdbId,
    this.knownForDepartment,
    this.placeOfBirth,
    this.popularity,
    this.profilePath,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    // ID: peut être int ou String
    final rawId = json['id'];
    final int id = rawId is int
        ? rawId
        : rawId is String
            ? int.tryParse(rawId) ?? 0
            : 0;

    // also_known_as : liste de String
    final alsoKnownAs = (json['also_known_as'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();

    // gender : int ou String
    final rawGender = json['gender'];
    final int? gender = rawGender is int
        ? rawGender
        : rawGender is String
            ? int.tryParse(rawGender)
            : null;

    // popularity : num → double
    final popularity = (json['popularity'] as num?)?.toDouble();

    return Person(
      id: id,
      name: json['name'] as String? ?? 'Unknown',
      alsoKnownAs: alsoKnownAs,
      biography: json['biography'] as String?,
      birthday: json['birthday'] as String?,
      deathday: json['deathday'] as String?,
      gender: gender,
      homepage: json['homepage'] as String?,
      imdbId: json['imdb_id'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      popularity: popularity,
      profilePath: json['profile_path'] as String?,
    );
  }
}
