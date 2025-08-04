// lib/providers/friend_provider.dart

import 'package:flutter/material.dart';
import '../models/friend_model.dart';
import '../services/friend_service.dart';

/// Provider gérant l'état des amis et des demandes d'amis.
class FriendProvider extends ChangeNotifier {
  List<Friend> _friends = [];
  List<FriendRequest> _requests = [];

  bool _isLoadingFriends = false;
  bool _isLoadingRequests = false;
  String? _friendsError;
  String? _requestsError;

  List<Friend> get friends => _friends;
  List<FriendRequest> get requests => _requests;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingRequests => _isLoadingRequests;
  String? get friendsError => _friendsError;
  String? get requestsError => _requestsError;

  /// Récupère la liste des amis.
  Future<void> fetchFriends(String token) async {
    _isLoadingFriends = true;
    _friendsError = null;
    notifyListeners();
    try {
      _friends = await FriendService.getFriends(token);
    } catch (e) {
      _friendsError = e.toString();
    }
    _isLoadingFriends = false;
    notifyListeners();
  }

  /// Récupère la liste des demandes d'amis.
  Future<void> fetchFriendRequests(String token) async {
    _isLoadingRequests = true;
    _requestsError = null;
    notifyListeners();
    try {
      _requests = await FriendService.getFriendRequests(token);
    } catch (e) {
      _requestsError = e.toString();
    }
    _isLoadingRequests = false;
    notifyListeners();
  }

  /// Envoie une demande d'ami.
  Future<String?> sendFriendRequest(String token, String email) async {
    try {
      await FriendService.addFriendRequest(token, email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Répond (accepter/refuser) à une demande et rafraîchit les listes.
  Future<void> respondToRequest(
      String token, String senderEmail, int status) async {
    await FriendService.respondToFriendRequest(token, senderEmail, status);
    await fetchFriendRequests(token);
    await fetchFriends(token);
  }

  /// Supprime un ami et rafraîchit la liste des amis.
  Future<void> deleteFriend(String token, String otherEmail) async {
    await FriendService.deleteFriend(token, otherEmail);
    await fetchFriends(token);
  }
}
