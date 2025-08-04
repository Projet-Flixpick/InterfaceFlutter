import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../models/friend_model.dart';
import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({Key? key}) : super(key: key);
  static const routeName = '/my-friends';

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _emailController = TextEditingController();
  bool _sendingRequest = false;

  // Validation email
  bool _isValidEmail = false;
  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isValidEmail = emailRegex.hasMatch(value.trim());
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        final friendProvider =
            Provider.of<FriendProvider>(context, listen: false);
        friendProvider.fetchFriends(auth.token!);
        friendProvider.fetchFriendRequests(auth.token!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _sendingRequest = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final friendProvider = Provider.of<FriendProvider>(context, listen: false);

    final error =
        await friendProvider.sendFriendRequest(auth.token!, email);
    setState(() => _sendingRequest = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error == null ? 'Demande envoyée.' : error)),
    );
    if (error == null) {
      _emailController.clear();
      _isValidEmail = false; // reset validation
      friendProvider.fetchFriendRequests(auth.token!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Amis'),
            Tab(text: 'Demandes'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add, color: Colors.white),
                label: const Text(
                  'Add Friend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                onPressed: _showAddFriendDialog,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer2<FriendProvider, AuthProvider>(
      builder: (context, friendProvider, authProvider, _) {
        if (friendProvider.isLoadingFriends) {
          return const Center(child: CircularProgressIndicator());
        }
        if (friendProvider.friendsError != null) {
          return Center(child: Text('Erreur : ${friendProvider.friendsError}'));
        }

        final friends = friendProvider.friends;
        if (friends.isEmpty) {
          return const Center(child: Text('Vous n’avez pas encore d’amis.'));
        }

        final currentEmail =
            Provider.of<UserProvider>(context, listen: false).email;

        return ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final f = friends[index];
            final other = f.userIdSender == currentEmail
                ? f.userIdInvite
                : f.userIdSender;
            return ListTile(
              title: Text(other),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  await friendProvider.deleteFriend(
                      authProvider.token!, other);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ami supprimé.')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return Consumer2<FriendProvider, AuthProvider>(
      builder: (context, friendProvider, authProvider, _) {
        if (friendProvider.isLoadingRequests) {
          return const Center(child: CircularProgressIndicator());
        }
        if (friendProvider.requestsError != null) {
          return Center(
              child: Text('Erreur : ${friendProvider.requestsError}'));
        }

        final requests = friendProvider.requests;
        if (requests.isEmpty) {
          return const Center(child: Text('Aucune demande en attente.'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final r = requests[index];
            return ListTile(
              title: Text(r.senderEmail),
              subtitle: const Text('Demande reçue'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      await friendProvider.respondToRequest(
                          authProvider.token!, r.senderEmail, 1);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demande acceptée.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      await friendProvider.respondToRequest(
                          authProvider.token!, r.senderEmail, 0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demande refusée.')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ajouter un ami',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: _isValidEmail ? Colors.green : Colors.redAccent,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _isValidEmail ? Colors.green : Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: _isValidEmail ? Colors.green : Colors.redAccent,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 210,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: _sendingRequest
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Add Friend'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 0,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: (_sendingRequest || !_isValidEmail)
                            ? null
                            : () async {
                                Navigator.pop(context);
                                await _sendRequest();
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
