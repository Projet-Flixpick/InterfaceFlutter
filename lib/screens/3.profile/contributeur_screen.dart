import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../services/APIgo/api_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/genre_provider.dart';
import '../../models/genre_model.dart';
import '../../widgets/titre_section.dart';
import '../../widgets/popcorn_loader.dart';

class ContributeurScreen extends StatefulWidget {
  const ContributeurScreen({Key? key}) : super(key: key);

  @override
  _ContributeurScreenState createState() => _ContributeurScreenState();
}

class _ContributeurScreenState extends State<ContributeurScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl       = TextEditingController();
  final _overviewCtrl    = TextEditingController();
  final _releaseDateCtrl = TextEditingController();

  Set<int> _selectedGenreIds = {};
  String _selectedType = 'film';

  List<dynamic> _myContribs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyContribs();
  }

  Future<void> _loadMyContribs() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final resp = await http.get(
      Uri.parse(ApiRoutes.getContributorContributions),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final list = data is List
          ? data
          : data is Map<String, dynamic>
              ? [data]
              : <dynamic>[];
      setState(() {
        _myContribs = list;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur chargement : ${resp.statusCode}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) {
      _releaseDateCtrl.text = date.toIso8601String().split('T').first;
    }
  }

  Future<void> _pickGenres() async {
    final genres = Provider.of<GenreProvider>(context, listen: false).genres;
    if (genres.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          content: const SizedBox(
            height: 100,
            child: Center(child: PopcornLoader()),
          ),
        ),
      );
      return;
    }

    final selected = Set<int>.from(_selectedGenreIds);

    final result = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDlgState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text("Proposer un contenu", style: TextStyle(color: Colors.red)),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: genres.length,
                  itemBuilder: (_, i) {
                    final g = genres[i];
                    final isSel = selected.contains(g.id);
                    return ListTile(
                      title: Text(g.name),
                      trailing: isSel
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: Image.asset('assets/icones/popcorn_check.png'),
                            )
                          : const SizedBox(width: 24, height: 24),
                      onTap: () {
                        if (isSel)
                          selected.remove(g.id);
                        else if (selected.length < 4)
                          selected.add(g.id);
                        setDlgState(() {});
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Annuler", style: TextStyle(color: Colors.red))),
                TextButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text("OK", style: TextStyle(color: Colors.red))),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => _selectedGenreIds = result);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedGenreIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs"), backgroundColor: Colors.red),
      );
      return;
    }

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final body = {
      'title': _titleCtrl.text.trim(),
      'type': _selectedType,
      'overview': _overviewCtrl.text.trim(),
      'release_date': _releaseDateCtrl.text.trim(),
      'genre_ids': _selectedGenreIds.toList(),
    };

    final resp = await http.post(
      Uri.parse(ApiRoutes.addContribution),
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      _titleCtrl.clear();
      _overviewCtrl.clear();
      _releaseDateCtrl.clear();
      setState(() => _selectedGenreIds.clear());
      _loadMyContribs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contribution envoyée !"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Échec envoi : ${resp.statusCode}"), backgroundColor: Colors.red),
      );
    }
  }

  String _mapStatus(int s) {
    switch (s) {
      case 0:
        return "En attente";
      case 1:
        return "Accepté";
      case 2:
        return "Rejeté";
      default:
        return s.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final genres = Provider.of<GenreProvider>(context).genres;

    return Scaffold(
      appBar: AppBar(title: const Text("Espace Contributeur")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TitreSection(title: "Proposer un contenu"),
          Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Titre *"),
                validator: (v) => (v == null || v.isEmpty) ? "Obligatoire" : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _overviewCtrl,
                maxLines: 3,
                maxLength: 3000,
                decoration: const InputDecoration(labelText: "Description (max 3000 chars) *"),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Obligatoire";
                  if (v.length > 3000) return "3000 caractères max";
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _releaseDateCtrl,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Date de sortie *", hintText: "YYYY-MM-DD"),
                onTap: _pickDate,
                validator: (v) => (v == null || v.isEmpty) ? "Obligatoire" : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: "Type *"),
                items: const [
                  DropdownMenuItem(value: 'film', child: Text('Film')),
                  DropdownMenuItem(value: 'série', child: Text('Série')),
                  DropdownMenuItem(value: 'court', child: Text('Court-métrage')),
                ],
                onChanged: (v) => setState(() => _selectedType = v!),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: _pickGenres,
                  child: Text(
                    _selectedGenreIds.isEmpty
                        ? "Sélectionner jusqu’à 4 genres *"
                        : "Genres : " +
                            genres
                                .where((g) => _selectedGenreIds.contains(g.id))
                                .map((g) => g.name)
                                .join(', '),
                    style: TextStyle(color: _selectedGenreIds.isEmpty ? Colors.red : null),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: ElevatedButton(onPressed: _submit, child: const Text("Soumettre"))),
            ]),
          ),

          const SizedBox(height: 24),
          const Divider(),

          const TitreSection(title: "Mes contributions"),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _myContribs.isEmpty
                    ? const Center(child: Text("Aucune contribution."))
                    : ListView.builder(
                        itemCount: _myContribs.length,
                        itemBuilder: (ctx, i) {
                          final c = _myContribs[i] as Map<String, dynamic>;
                          final data = c['movie_data'] as Map<String, dynamic>?;
                          final title = data?['title'] ?? '—';
                          final status = c['status'] as int? ?? 0;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text("Statut : ${_mapStatus(status)}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ]),
      ),
    );
  }
}
