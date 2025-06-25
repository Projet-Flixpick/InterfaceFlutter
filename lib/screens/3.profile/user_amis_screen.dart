import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/APIgo/friend_request_service.dart';

class UserAmisScreen extends StatefulWidget {
  const UserAmisScreen({super.key});

  @override
  State<UserAmisScreen> createState() => _UserAmisScreenState();
}

class _UserAmisScreenState extends State<UserAmisScreen> {
  List<Map<String, dynamic>> friendsList = [];
  FriendRequestService? friendService;
  String? currentUserId;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndUser();
  }

  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final userEmail = prefs.getString('email');

    if (storedToken != null && userEmail != null) {
      setState(() {
        token = storedToken;
        currentUserId = userEmail;
        friendService = FriendRequestService(token: token!);
      });
      fetchFriends();
    }
  }

  Future<void> fetchFriends() async {
    if (friendService == null || currentUserId == null) return;
    try {
      final data = await friendService!.getFriends(currentUserId!);
      setState(() {
        friendsList = data;
      });
    } catch (e) {
      print("❌ Error loading friends: $e");
    }
  }

  Future<void> removeFriend(String friendId) async {
    final confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove this friend?"),
        content: Text("Do you really want to remove $friendId from your friends?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
        ],
      ),
    );

    if (confirm == true && friendService != null) {
      final success = await friendService!.deleteFriend(friendId);
      if (success) {
        setState(() {
          friendsList.removeWhere((friend) => friend['id'] == friendId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$friendId removed.")),
        );
      }
    }
  }

  void navigateToPendingRequests() => Navigator.pushNamed(context, '/friend-requests');
  void navigateToFriendRecommendations() => Navigator.pushNamed(context, '/friend-recommendations');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Friends")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: navigateToPendingRequests,
              icon: const Icon(Icons.person_add),
              label: const Text("View Friend Requests"),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: friendsList.isEmpty
                  ? const Center(child: Text("You don't have any friends yet."))
                  : ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        final friend = friendsList[index];
                        final friendEmail = friend['id'];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(friendEmail),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removeFriend(friendEmail),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: navigateToFriendRecommendations,
              icon: const Icon(Icons.movie),
              label: const Text("Movies with Friends"),
            ),
          ],
        ),
      ),
    );
  }
}
