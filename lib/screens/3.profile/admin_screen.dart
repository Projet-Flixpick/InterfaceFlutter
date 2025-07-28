import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/APIgo/api_routes.dart';
import '../../widgets/titre_section.dart';
import '../../providers/auth_provider.dart';
import 'contributeur_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> _contributions = [];
  bool _loadingContributions = true;

  final _emailDelCtrl   = TextEditingController();
  final _emailRoleCtrl  = TextEditingController();
  final _contentDelCtrl = TextEditingController();
  String? _selectedRole;
  final _roleOptions = ['user', 'contributeur', 'admin'];

  @override
  void initState() {
    super.initState();
    _fetchContributions();
  }

  Future<void> _fetchContributions() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final resp = await http.get(
      Uri.parse(ApiRoutes.getContributions),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      setState(() {
        _contributions = data is List ? data : [];
        _loadingContributions = false;
      });
    } else {
      setState(() => _loadingContributions = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur chargement : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _respondToContribution(String contribId, bool accept) async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    String? refuseNote;
    if (!accept) {
      refuseNote = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: const Text("Raison du refus (max 100 chars)"),
            content: TextField(
              controller: ctrl,
              maxLength: 100,
              decoration: const InputDecoration(hintText: "Ex : Film déjà existant"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Annuler")),
              TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text("Envoyer")),
            ],
          );
        },
      );
      if (refuseNote == null) return;
    }

    final body = {
      'contribution_id': contribId,
      'accept': accept,
      if (refuseNote != null) 'refuse_note': refuseNote,
    };

    final resp = await http.put(
      Uri.parse(ApiRoutes.checkContribution),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (resp.statusCode == 200) {
      setState(() {
        _contributions.removeWhere((c) {
          final rawId = c['_id'];
          final idStr = rawId is Map ? rawId['\$oid'] as String : rawId.toString();
          return idStr == contribId;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(accept ? 'Contribution approuvée.' : 'Contribution rejetée.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec réponse : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _changeUserRole() async {
    final email = _emailRoleCtrl.text.trim();
    if (email.isEmpty || _selectedRole == null) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final body = {
      'target_email': email,
      'new_rights': _roleOptions.indexOf(_selectedRole!),
    };
    final resp = await http.put(
      Uri.parse(ApiRoutes.updateUserRights),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );
    if (resp.statusCode == 200) {
      _emailRoleCtrl.clear();
      setState(() => _selectedRole = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Droits mis à jour."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec mise à jour : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteUser() async {
    final email = _emailDelCtrl.text.trim();
    if (email.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final resp = await http.delete(
      Uri.parse(ApiRoutes.deleteUserByEmail),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': email}),
    );
    if (resp.statusCode == 200) {
      _emailDelCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Utilisateur supprimé."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec suppression : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteContent() async {
    final id = _contentDelCtrl.text.trim();
    if (id.isEmpty) return;
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final resp = await http.delete(
      Uri.parse(ApiRoutes.deleteContent),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'movie_id': id}),
    );
    if (resp.statusCode == 200) {
      _contentDelCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contenu supprimé."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Échec suppression : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Espace Administrateur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            leading: const Icon(Icons.library_add),
            title: const Text('Proposer un contenu'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContributeurScreen()),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          const TitreSection(title: "Contributions en attente"),
          const SizedBox(height: 8),
          if (_loadingContributions)
            const Center(child: CircularProgressIndicator())
          else if (_contributions.isEmpty)
            const Text("Aucune contribution en attente.")
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _contributions.length,
              itemBuilder: (ctx, i) {
                final c = _contributions[i] as Map<String, dynamic>;
                final rawId = c['_id'];
                final idStr = rawId is Map ? rawId['\$oid'] as String : rawId.toString();
                final movieData = c['movie_data'] as Map<String, dynamic>?;
                final title = movieData?['title'] ?? '—';
                final email = c['user_email'] as String? ?? '—';
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(title),
                    subtitle: Text("Proposé par : $email"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () => _respondToContribution(idStr, true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _respondToContribution(idStr, false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),
          const Divider(),

          const TitreSection(title: "Gestion des utilisateurs"),
          const SizedBox(height: 8),
          const Text("Utilisateur à supprimer (email)"),
          TextField(controller: _emailDelCtrl, decoration: const InputDecoration(hintText: "user33@example.com")),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _deleteUser, child: const Text("Supprimer")),

          const SizedBox(height: 16),
          const Text("Utilisateur à modifier (email + rôle)"),
          TextField(controller: _emailRoleCtrl, decoration: const InputDecoration(hintText: "user33@example.com")),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedRole,
            hint: const Text("Choisir un rôle"),
            items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedRole = v),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _changeUserRole, child: const Text("Mettre à jour")),

          const SizedBox(height: 24),
          const Divider(),

          const TitreSection(title: "Supprimer un film/série/court-métrage"),
          const SizedBox(height: 8),
          const Text("ID du contenu à supprimer"),
          TextField(controller: _contentDelCtrl, decoration: const InputDecoration(hintText: "685562eed269aa77365e73da")),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _deleteContent, child: const Text("Supprimer")),
        ]),
      ),
    );
  }
}
