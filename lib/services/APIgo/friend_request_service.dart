// lib/services/APIgo/friend_request_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_routes.dart';

class FriendRequestService {
  final String token;

  FriendRequestService({required this.token});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  /// Envoie une demande d’amitié à l’adresse [targetEmail].
  Future<bool> sendFriendRequest(String targetEmail) async {
    final response = await http.post(
      Uri.parse(ApiRoutes.addFriendRequest),
      headers: _headers,
      body: jsonEncode({'email_invite': targetEmail}),
    );
    return response.statusCode == 200;
  }

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final res = await http.get(
      Uri.parse('${ApiRoutes.getFriends}?userId=$userId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Erreur récupération amis');
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    final res = await http.get(
      Uri.parse('${ApiRoutes.getFriendRequests}?userId=$userId'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body) as List;
      return data.cast<Map<String, dynamic>>();
    }
    throw Exception('Erreur récupération demandes');
  }

  Future<bool> respondToFriendRequest(String senderEmail, bool accept) async {
    final res = await http.post(
      Uri.parse(ApiRoutes.friendRequestResponse),
      headers: _headers,
      body: jsonEncode({
        'sender_email': senderEmail,
        'status': accept ? 1 : 0,
      }),
    );
    return res.statusCode == 200;
  }

  Future<bool> deleteFriend(String otherEmail) async {
    final res = await http.post(
      Uri.parse(ApiRoutes.deleteFriend),
      headers: _headers,
      body: jsonEncode({'other_email': otherEmail}),
    );
    return res.statusCode == 200;
  }
}
