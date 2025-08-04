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
    // On différé le fetch après le premier build pour éviter setState durant build
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.token != null) {
        Provider.of<FriendProvider>(context, listen: false)
            .fetchFriendRequests(auth.token!);
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
          final requests = friendProv.requests;
          if (requests.isEmpty) {
            return const Center(child: Text('Aucune demande en attente.'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, i) {
              final r = requests[i];
              return ListTile(
                title: Text(r.senderEmail),
                subtitle: const Text('Vous a envoyé une demande'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await friendProv.respondToRequest(
                          authProv.token!,
                          r.senderEmail,
                          1,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demande acceptée')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await friendProv.respondToRequest(
                          authProv.token!,
                          r.senderEmail,
                          0,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Demande refusée')),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
