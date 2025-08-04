// lib/services/friend_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/APIgo/api_routes.dart';
import '../models/friend_model.dart';

class FriendService {
  static Future<void> addFriendRequest(String token, String emailInvite) async {
    final url = Uri.parse(ApiRoutes.addFriendRequest);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{'email_invite': emailInvite}),
    );

    // Gestion du code 409
    if (response.statusCode == 409) {
      throw Exception("Une demande existe déjà ou cet utilisateur est déjà votre ami.");
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de l\'envoi de la demande d\'ami (${response.statusCode})');
    }
  }

  static Future<List<FriendRequest>> getFriendRequests(String token) async {
    final url = Uri.parse(ApiRoutes.getFriendRequests);
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la récupération des demandes (${response.statusCode})');
    }
    final body = response.body;
    if (body.isEmpty || body == 'null') {
      return <FriendRequest>[];
    }
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded.map((e) => FriendRequest.fromJson(e)).toList();
  }

  static Future<void> respondToFriendRequest(
      String token, String senderEmail, int status) async {
    final url = Uri.parse(ApiRoutes.friendRequestResponse);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        <String, dynamic>{'sender_email': senderEmail, 'status': status},
      ),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la réponse à la demande d\'ami (${response.statusCode})');
    }
  }

  static Future<List<Friend>> getFriends(String token) async {
    final url = Uri.parse(ApiRoutes.getFriends);
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la récupération des amis (${response.statusCode})');
    }
    final body = response.body;
    if (body.isEmpty || body == 'null') {
      return <Friend>[];
    }
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded.map((e) => Friend.fromJson(e)).toList();
  }

  static Future<void> deleteFriend(String token, String otherEmail) async {
    final url = Uri.parse(ApiRoutes.deleteFriend);
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, String>{'other_email': otherEmail}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Erreur lors de la suppression de l\'ami (${response.statusCode})');
    }
  }
}
