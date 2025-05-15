class UserModel {
  final String id;
  final String name;
  final String firstname;
  final String email;
  final String dateOfBirth;
  final String? password;
  final List<String>? genres;
  final List<String>? likes;
  final List<String>? dislikes;
  final List<String>? moviesSeen;
  final int rights;

  UserModel({
    required this.id,
    required this.name,
    required this.firstname,
    required this.email,
    required this.dateOfBirth,
    this.password,
    this.genres,
    this.likes,
    this.dislikes,
    this.moviesSeen,
    required this.rights,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      firstname: json['firstname'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      password: json['password'],
      genres: (json['genres'] as List?)?.map((g) => g.toString()).toList(),
      likes: (json['likes'] as List?)?.map((id) => id.toString()).toList(),
      dislikes: (json['dislikes'] as List?)?.map((id) => id.toString()).toList(),
      moviesSeen:
          (json['movies_seen'] as List?)?.map((id) => id.toString()).toList(),
      rights: json['rights'] ?? 0,
    );
  }
}
