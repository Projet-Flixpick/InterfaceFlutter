// lib/models/friend_model.dart

/// Modèle représentant un lien d'amitié (accepté ou en attente).
class Friend {
  final String id;
  final DateTime createdAt;
  final int status;
  final String userIdInvite;
  final String userIdSender;

  Friend({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.userIdInvite,
    required this.userIdSender,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as int,
      userIdInvite: json['user_id_invite'] as String,
      userIdSender: json['user_id_sender'] as String,
    );
  }
}

/// Modèle pour une demande d'ami reçue.
class FriendRequest {
  final String id;
  final String? userIdSender;
  final String? userIdInvite;
  final int status;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    this.userIdSender,
    this.userIdInvite,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['_id'] as String,
      userIdSender: json['user_id_sender'] as String?,
      userIdInvite: json['user_id_invite'] as String?,
      status: json['status'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
