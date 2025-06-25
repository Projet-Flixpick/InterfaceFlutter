import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/APIgo/friend_request_service.dart';
import '../../models/friend_request_model.dart';

class UserAmisDemandesScreen extends StatefulWidget {
  const UserAmisDemandesScreen({super.key});

  @override
  State<UserAmisDemandesScreen> createState() => _UserAmisDemandesScreenState();
}

class _UserAmisDemandesScreenState extends State<UserAmisDemandesScreen> {
  List<FriendRequest> pendingRequests = [];
  List<FriendRequest> refusedRequests = [];
  String? currentUserEmail;
  FriendRequestService? service;
  bool showRefused = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final email = prefs.getString('email');

    if (token != null && email != null) {
      service = FriendRequestService(token: token);
      currentUserEmail = email;
      await fetchRequests();
    }
  }

  Future<void> fetchRequests() async {
    if (service == null || currentUserEmail == null) return;

    try {
      final raw = await service!.getPendingRequests(currentUserEmail!);
      final all = raw.map((e) => FriendRequest.fromJson(e)).toList();
      setState(() {
        pendingRequests = all.where((r) => r.invite == currentUserEmail && r.status == 2).toList();
        refusedRequests = all.where((r) => r.invite == currentUserEmail && r.status == 0).toList();
      });
    } catch (e) {
      print("❌ Error fetching requests: $e");
    }
  }

  Future<void> handleResponse(FriendRequest request, bool accept) async {
    if (service == null) return;

    final success = await service!.respondToFriendRequest(request.sender, accept);
    if (success) {
      await fetchRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error updating friend request")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Friend Requests")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Pending Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: pendingRequests.isEmpty
                  ? const Text("No pending requests.")
                  : ListView.builder(
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final request = pendingRequests[index];
                        return Card(
                          child: ListTile(
                            title: Text(request.sender),
                            subtitle: const Text("Waiting for your response"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () => handleResponse(request, true),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => handleResponse(request, false),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            GestureDetector(
              onTap: () => setState(() => showRefused = !showRefused),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Refused Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Icon(showRefused ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
            if (showRefused)
              Expanded(
                child: refusedRequests.isEmpty
                    ? const Text("No refused requests.")
                    : ListView.builder(
                        itemCount: refusedRequests.length,
                        itemBuilder: (context, index) {
                          final request = refusedRequests[index];
                          return Card(
                            child: ListTile(
                              title: Text(request.sender),
                              subtitle: const Text("Refused"),
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
