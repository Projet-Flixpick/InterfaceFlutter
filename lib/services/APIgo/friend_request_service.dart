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

  Future<List<Map<String, dynamic>>> getFriends(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiRoutes.getFriends}?userId=$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur récupération amis');
    }
  }

  Future<List<Map<String, dynamic>>> getPendingRequests(String userId) async {
    final response = await http.get(
      Uri.parse('${ApiRoutes.getFriendRequests}?userId=$userId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Erreur récupération demandes');
    }
  }

  Future<bool> respondToFriendRequest(String senderId, bool accept) async {
    final response = await http.post(
      Uri.parse(ApiRoutes.friendRequestResponse),
      headers: _headers,
      body: jsonEncode({
        'user_id_sender': senderId,
        'response': accept ? 1 : 0,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteFriend(String friendId) async {
    final response = await http.post(
      Uri.parse(ApiRoutes.deleteFriend),
      headers: _headers,
      body: jsonEncode({'friend_id': friendId}),
    );
    return response.statusCode == 200;
  }
}
