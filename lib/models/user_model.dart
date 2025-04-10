class UserModel {
  final String id;
  final String name;
  final String firstname;
  final String email;
  final String dateOfBirth;
  final List<String>? genres;

  UserModel({
    required this.id,
    required this.name,
    required this.firstname,
    required this.email,
    required this.dateOfBirth,
    this.genres,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      firstname: json['firstname'] ?? '',
      email: json['email'] ?? '',
      dateOfBirth: json['date_of_birth'] ?? '',
      genres: (json['genres'] as List?)?.map((g) => g.toString()).toList(),
    );
  }
}
