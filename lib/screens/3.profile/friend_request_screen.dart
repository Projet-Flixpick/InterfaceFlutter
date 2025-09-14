import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../../providers/friend_provider.dart';
import '../../providers/auth_provider.dart';

class FriendRequestScreen extends StatefulWidget {
  const FriendRequestScreen({Key? key}) : super(key: key);
  static const routeName = '/friend-requests';

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {
  @override
  void initState() {
    super.initState();
    // Différer après le 1er build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final token = auth.token;
      if (token != null && token.isNotEmpty) {
        context.read<FriendProvider>().fetchFriendRequests(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes d’amis')),
      body: Consumer2<FriendProvider, AuthProvider>(
        builder: (context, friendProv, authProv, _) {
          if (friendProv.isLoadingRequests) {
            return const Center(child: CircularProgressIndicator());
          }
          if (friendProv.requestsError != null) {
            return Center(child: Text(friendProv.requestsError!));
          }

          final reqs = friendProv.requests;
          if (reqs.isEmpty) {
            return const Center(child: Text('Aucune demande en attente.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            itemCount: reqs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, i) {
              final r = reqs[i];
              final sender = (r.userIdSender?.trim().isNotEmpty ?? false)
                  ? r.userIdSender!.trim()
                  : 'Utilisateur inconnu';


              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(sender, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: const Text('Vous a envoyé une demande'),
                  trailing: Wrap(
                    spacing: 6,
                    children: [
                      IconButton(
                        tooltip: 'Accepter',
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          final token = authProv.token;
                          if (token == null) return;
                          await friendProv.respondToRequest(token, sender, 1);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demande acceptée')),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: 'Refuser',
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          final token = authProv.token;
                          if (token == null) return;
                          await friendProv.respondToRequest(token, sender, 0);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Demande refusée')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
