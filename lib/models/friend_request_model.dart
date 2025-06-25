class FriendRequest {
  final String sender;
  final String invite;
  final int status;

  FriendRequest({
    required this.sender,
    required this.invite,
    required this.status,
  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      sender: json['user_id_sender'],
      invite: json['user_id_invite'],
      status: int.tryParse(json['status'].toString()) ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id_sender': sender,
      'user_id_invite': invite,
      'status': status,
    };
  }
}
