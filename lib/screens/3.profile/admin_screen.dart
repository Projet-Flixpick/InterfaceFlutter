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
  final _roleOptions = ['user', 'contributor', 'admin'];

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
          content: Text("Error loading : ${resp.statusCode}"),
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
            title: const Text("Reason for Rejection (max 100 chars)"),
            content: TextField(
              controller: ctrl,
              maxLength: 100,
              decoration: const InputDecoration(hintText: "E.g.: Film already exists"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text("Send")),
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
          content: Text(accept ? 'Contribution approved.' : 'Contribution rejected.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot respond : ${resp.statusCode}"),
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
          content: Text("Rights updated."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot update rights : ${resp.statusCode}"),
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
          content: Text("User deleted."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot delete user : ${resp.statusCode}"),
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
          content: Text("Content deleted."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cannot delete content : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Propose Content link
          ListTile(
            leading: const Icon(Icons.library_add),
            title: const Text('Propose Content'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ContributeurScreen()),
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),

          // Pending Contributions section
          const TitreSection(title: "Pending Contributions"),
          const SizedBox(height: 8),
          if (_loadingContributions)
            const Center(child: CircularProgressIndicator())
          else if (_contributions.isEmpty)
            const Text("No pending contributions.")
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
                    subtitle: Text("Proposed by: $email"),
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

          // User Management
          const TitreSection(title: "User Management"),
          const SizedBox(height: 8),

          TextField(
            controller: _emailDelCtrl,
            decoration: const InputDecoration(
              labelText: "User to delete (email)",
              hintText: "user33@example.com",
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _deleteUser, child: const Text("Delete")),

          const SizedBox(height: 16),
          TextField(
            controller: _emailRoleCtrl,
            decoration: const InputDecoration(
              labelText: "User to modify (email + role)",
              hintText: "user33@example.com",
            ),
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedRole,
            hint: const Text("Choose a role"),
            items: _roleOptions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedRole = v),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _changeUserRole, child: const Text("Update")),

          const SizedBox(height: 24),
          const Divider(),

          // Delete Content
          const TitreSection(title: "Delete a movie/series/short film"),
          const SizedBox(height: 8),
          TextField(
            controller: _contentDelCtrl,
            decoration: const InputDecoration(
              labelText: "ID of the content to delete",
              hintText: "685562eed269aa77365e73da",
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _deleteContent, child: const Text("Delete")),
        ]),
      ),
    );
  }
}
