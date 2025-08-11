import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../2.films/recommendations_screen.dart';

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
  final TextEditingController _searchCtrl = TextEditingController();

  bool _sendingRequest = false;
  bool _isValidEmail = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.token != null) {
        final fp = context.read<FriendProvider>();
        fp.fetchFriends(auth.token!);
        fp.fetchFriendRequests(auth.token!);
      }
    });
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() => _isValidEmail = emailRegex.hasMatch(value.trim()));
  }

  Future<void> _sendRequest() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _sendingRequest = true);
    final auth = context.read<AuthProvider>();
    final fp = context.read<FriendProvider>();

    final error = await fp.sendFriendRequest(auth.token!, email);
    setState(() => _sendingRequest = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error == null ? 'Demande envoyée.' : error)),
    );
    if (error == null) {
      _emailController.clear();
      _isValidEmail = false;
      fp.fetchFriendRequests(auth.token!);
    }
  }

  Future<void> _refreshFriends() async {
    final auth = context.read<AuthProvider>();
    await context.read<FriendProvider>().fetchFriends(auth.token!);
  }

  Future<void> _refreshRequests() async {
    final auth = context.read<AuthProvider>();
    await context.read<FriendProvider>().fetchFriendRequests(auth.token!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes amis'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Amis'), Tab(text: 'Demandes')],
        ),
      ),
      body: Column(
        children: [
          if (_tabController.index == 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Rechercher un ami…',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                  onRefresh: _refreshFriends,
                  child: _buildFriendsTab(theme),
                ),
                RefreshIndicator(
                  onRefresh: _refreshRequests,
                  child: _buildRequestsTab(theme),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('Add Friend'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
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

  Widget _buildFriendsTab(ThemeData theme) {
    return Consumer3<FriendProvider, AuthProvider, UserProvider>(
      builder: (context, fp, auth, user, _) {
        if (fp.isLoadingFriends) {
          return const Center(child: CircularProgressIndicator());
        }
        if (fp.friendsError != null) {
          return Center(child: Text('Erreur : ${fp.friendsError}'));
        }

        final me = user.email;
        final query = _searchCtrl.text.trim().toLowerCase();

        final items = fp.friends
            .map((f) => f.userIdSender == me ? f.userIdInvite : f.userIdSender)
            .where((mail) => query.isEmpty || mail.toLowerCase().contains(query))
            .toList();

        if (items.isEmpty) {
          return const Center(child: Text('Vous n’avez pas encore d’amis.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final email = items[i];
            final initials = _initialsFromEmail(email);
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 22,
                  child: Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(email, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: const Text('Ami'),
                onTap: () {
                  // NAVIGATION — push simple => retour possible
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RecommendationsScreen(initialFriendId: email),
                    ),
                  );
                },
                trailing: PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'reco') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecommendationsScreen(initialFriendId: email),
                        ),
                      );
                    } else if (v == 'delete') {
                      await fp.deleteFriend(auth.token!, email);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ami supprimé.')),
                        );
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'reco',
                      child: ListTile(
                        leading: Icon(Icons.theaters),
                        title: Text('Voir recommandations communes'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('Supprimer'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab(ThemeData theme) {
    return Consumer2<FriendProvider, AuthProvider>(
      builder: (context, fp, auth, _) {
        if (fp.isLoadingRequests) {
          return const Center(child: CircularProgressIndicator());
        }
        if (fp.requestsError != null) {
          return Center(child: Text('Erreur : ${fp.requestsError}'));
        }

        final requests = fp.requests;
        if (requests.isEmpty) {
          return const Center(child: Text('Aucune demande en attente.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (context, i) {
            final r = requests[i];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(r.senderEmail,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: const Text('Demande reçue'),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      tooltip: 'Accepter',
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () async {
                        await fp.respondToRequest(
                            auth.token!, r.senderEmail, 1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demande acceptée.')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      tooltip: 'Refuser',
                      icon: const Icon(Icons.cancel, color: Colors.red),
                      onPressed: () async {
                        await fp.respondToRequest(
                            auth.token!, r.senderEmail, 0);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demande refusée.')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _initialsFromEmail(String email) {
    final name = email.split('@').first;
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    if (name.isNotEmpty) return name[0].toUpperCase();
    return '?';
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.45),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ajouter un ami',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: _validateEmail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.alternate_email),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: (_sendingRequest || !_isValidEmail)
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await _sendRequest();
                            },
                      icon: _sendingRequest
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add),
                      label: const Text('Envoyer'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
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
