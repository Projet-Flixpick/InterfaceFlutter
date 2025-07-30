import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/APIgo/friend_request_service.dart';
import '../../app_routes.dart';

class UserAmisScreen extends StatefulWidget {
  const UserAmisScreen({Key? key}) : super(key: key);

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
    final userEmail   = prefs.getString('email');

    if (storedToken != null && userEmail != null) {
      setState(() {
        token         = storedToken;
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
      setState(() => friendsList = data);
    } catch (e) {
      print("❌ Error loading friends: $e");
    }
  }

  Future<void> removeFriend(String friendEmail) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer cet ami ?"),
        content: Text("Voulez-vous vraiment supprimer $friendEmail ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Oui")),
        ],
      ),
    );
    if (confirm == true && friendService != null) {
      final success = await friendService!.deleteFriend(friendEmail);
      if (success) {
        setState(() => friendsList.removeWhere((f) => f['id'] == friendEmail));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$friendEmail supprimé.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes amis"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Ajouter un ami',
            onPressed: () => Navigator.pushNamed(context, '/add-friend'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/friend-requests'),
              icon: const Icon(Icons.person_search),
              label: const Text("Voir les demandes"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: friendsList.isEmpty
                  ? const Center(child: Text("Vous n'avez pas encore d'amis."))
                  : ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (ctx, i) {
                        final friendEmail = friendsList[i]['id'];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(friendEmail),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeFriend(friendEmail),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/friend-recommendations'),
              icon: const Icon(Icons.movie),
              label: const Text("Voir films avec un ami"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
