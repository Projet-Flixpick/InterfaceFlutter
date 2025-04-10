class Genre {
  final String mongoId; // MongoDB ID
  final int id;
  final String name;

  Genre({
    required this.mongoId,
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      mongoId: json['_id'],
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': mongoId,
      'id': id,
      'name': name,
    };
  }
}
