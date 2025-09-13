import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../models/genre_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/genre_provider.dart';
import '../../services/APIgo/api_routes.dart';
import '../../widgets/popcorn_loader.dart';
import '../../widgets/titre_section.dart';

class ContributeurScreen extends StatefulWidget {
  const ContributeurScreen({Key? key}) : super(key: key);

  @override
  State<ContributeurScreen> createState() => _ContributeurScreenState();
}

class _ContributeurScreenState extends State<ContributeurScreen> {
  // --- Form state ---
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _overviewCtrl = TextEditingController();
  final _releaseDateCtrl = TextEditingController();

  Set<int> _selectedGenreIds = {};
  String _selectedType = 'film'; // film | serie | court

  // --- Data ---
  List<dynamic> _myContribs = [];
  bool _loading = true;

  // --- Rights ---
  bool _isContributor = false; // rights >= 1
  bool _checkingRight = true;

  // --- Couleurs de texte pour la liste "My contributions" ---
  static const Color _kTitleColor    = Color(0xFF2B2B2B); // titre bien lisible
  static const Color _kSubtitleColor = Color(0xFF3A3A3A); // remplace le gris #BBB2B2

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _overviewCtrl.dispose();
    _releaseDateCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Loads / Rights
  // ---------------------------------------------------------------------------

  Future<void> _refreshAll() async {
    await Future.wait([_checkContributorRight(), _loadMyContribs()]);
  }

  Future<void> _checkContributorRight() async {
    setState(() => _checkingRight = true);
    try {
      final token = context.read<AuthProvider>().token;
      final resp = await http.get(
        Uri.parse(ApiRoutes.getCurrentUser),
        headers: {'Authorization': 'Bearer $token'},
      );
      bool ok = false;
      if (resp.statusCode == 200) {
        ok = _extractContributorFlag(json.decode(resp.body));
      }
      setState(() {
        _isContributor = ok;
        _checkingRight = false;
      });
    } catch (_) {
      setState(() => _checkingRight = false);
    }
  }

  /// Retourne true si la réponse contient `rights >= 1` ou équivalent.
  bool _extractContributorFlag(dynamic node) {
    bool found = false;
    void walk(dynamic n) {
      if (found) return;
      if (n is Map) {
        final role = n['role'] ?? n['rights'];
        final isC = n['isContributor'] ?? n['is_contributor'] ?? n['contributor'];

        if (role is num && role.toInt() >= 1) { found = true; return; }
        if (role is String) {
          final i = int.tryParse(role.trim());
          if (i != null && i >= 1) { found = true; return; }
        }

        if (isC != null) {
          if (isC is bool && isC) { found = true; return; }
          if (isC is num && isC.toInt() >= 1) { found = true; return; }
          if (isC is String) {
            final i = int.tryParse(isC.trim());
            if ((i != null && i >= 1) || isC.toLowerCase() == 'true') { found = true; return; }
          }
        }

        for (final v in n.values) walk(v);
      } else if (n is List) {
        for (final v in n) walk(v);
      }
    }
    walk(node);
    return found;
  }

  Future<void> _loadMyContribs() async {
    try {
      final token = context.read<AuthProvider>().token;
      final resp = await http.get(
        Uri.parse(ApiRoutes.getContributorContributions),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final list = data is List ? data : (data is Map<String, dynamic> ? [data] : <dynamic>[]);
        setState(() {
          _myContribs = list;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
        _showSnack('Loading Error : ${resp.statusCode}', error: true);
      }
    } catch (_) {
      setState(() => _loading = false);
      _showSnack('Loading Error', error: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Form helpers
  // ---------------------------------------------------------------------------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) {
      _releaseDateCtrl.text = date.toIso8601String().split('T').first;
    }
  }

  Future<void> _pickGenres() async {
    final genres = context.read<GenreProvider>().genres;
    if (genres.isEmpty) {
      await showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(height: 100, child: Center(child: PopcornLoader())),
        ),
      );
      return;
    }

    final selected = Set<int>.from(_selectedGenreIds);

    final result = await showDialog<Set<int>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Propose a Content', style: TextStyle(color: Colors.red)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: genres.length,
              itemBuilder: (_, i) {
                final Genre g = genres[i];
                final isSel = selected.contains(g.id);
                return ListTile(
                  title: Text(g.name),
                  trailing: isSel
                      ? SizedBox(width: 32, height: 32, child: Image.asset('assets/icones/popcorn_check.png'))
                      : const SizedBox(width: 32, height: 32),
                  onTap: () {
                    if (isSel) {
                      selected.remove(g.id);
                    } else if (selected.length < 4) {
                      selected.add(g.id);
                    }
                    setDlgState(() {});
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.red))),
            TextButton(onPressed: () => Navigator.pop(ctx, selected), child: const Text('OK', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );

    if (result != null) setState(() => _selectedGenreIds = result);
  }

  String _mapTypeForApi(String v) => v == 'serie' ? 'serie' : v;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedGenreIds.isEmpty) {
      _showSnack('Please fill in all fields', error: true);
      return;
    }
    if (!_isContributor) {
      _showSnack('Access denied: your account must have contributor rights.', error: true);
      return;
    }

    final token = context.read<AuthProvider>().token;
    final body = {
      'title': _titleCtrl.text.trim(),
      'type': _mapTypeForApi(_selectedType),
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
      await _loadMyContribs();
      _showSnack('Contribution envoyée !', error: false);
    } else if (resp.statusCode == 403) {
      await _checkContributorRight();
      final msg = _isContributor
          ? 'Failed to send contribution. Please try again later.'
          : 'Access denied: your account must have contributor rights.';
      _showSnack(msg, error: true);
    } else {
      _showSnack('Failed to send : ${resp.statusCode} ${resp.body}', error: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Bottom sheet "Détails contribution"
  // ---------------------------------------------------------------------------

  Color _statusColor(int s) {
    switch (s) {
      case 1: return const Color(0xFF2E7D32); // ✔︎ vert
      case 2: return const Color(0xFFC62828); // ✕ rouge
      default: return const Color(0xFFFB8C00); // ⌛ orange
    }
  }

  IconData _statusIcon(int s) {
    switch (s) {
      case 1: return Icons.check;                 // check simple
      case 2: return Icons.close;                 // croix simple
      default: return Icons.hourglass_empty_rounded;
    }
  }

  String _statusLabel(int s) {
    switch (s) {
      case 1: return 'Accepted';
      case 2: return 'Rejected';
      default: return 'Pending';
    }
  }

  String _formatTypeHuman(String? t) {
    switch (t) {
      case 'film': return 'Movie';
      case 'serie': return 'Series';
      case 'court': return 'Short Movie';
      default: return t ?? '—';
    }
  }

  String? _extractRejectionReason(Map<String, dynamic> c) {
    final candidates = [
      'reason','reject_reason','rejection_reason',
      'admin_comment','moderation_comment','comment','message','motif','details',
      'review.reason','review.comment',
    ];
    for (final key in candidates) {
      if (key.contains('.')) {
        dynamic cur = c;
        for (final p in key.split('.')) {
          if (cur is Map && cur.containsKey(p)) {
            cur = cur[p];
          } else {
            cur = null; break;
          }
        }
        if (cur is String && cur.trim().isNotEmpty) return cur.trim();
      } else {
        final v = c[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  List<String> _genreNamesFromIds(List ids) {
    final all = context.read<GenreProvider>().genres;
    final setIds = ids.whereType<int>().toSet();
    return all.where((g) => setIds.contains(g.id)).map((g) => g.name).toList();
  }

  Future<void> _openContributionDetails(Map<String, dynamic> c) async {
    final data = (c['movie_data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final status = (c['status'] as int?) ?? 0;
    final title = data['title'] as String? ?? '—';
    final overview = data['overview'] as String?;
    final type = data['type'] as String?;
    final releaseDate = data['release_date'] as String?;
    final genreIds = (data['genre_ids'] as List?) ?? (c['genre_ids'] as List?) ?? const [];
    final genreNames = genreIds is List ? _genreNamesFromIds(genreIds) : const <String>[];
    final reason = status == 2 ? _extractRejectionReason(c) : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.70,
        minChildSize: 0.50,
        maxChildSize: 0.95,
        builder: (ctx, controller) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: ListView(
            controller: controller,
            children: [
              Row(
                children: [
                  Icon(_statusIcon(status), color: _statusColor(status), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_statusLabel(status)),
                    backgroundColor: _statusColor(status).withOpacity(.12),
                    labelStyle: TextStyle(color: _statusColor(status), fontWeight: FontWeight.w600),
                    side: BorderSide(color: _statusColor(status).withOpacity(.35)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (overview != null && overview.trim().isNotEmpty) ...[
                const Text('Overview', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(overview, style: const TextStyle(height: 1.35)),
                const SizedBox(height: 14),
              ],

              const Text('Details', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _infoChip(Icons.local_movies_outlined, _formatTypeHuman(type)),
                  _infoChip(Icons.event_outlined, releaseDate ?? '—'),
                  if (genreNames.isNotEmpty)
                    _infoChip(Icons.category_outlined, genreNames.join(', ')),
                ],
              ),
              const SizedBox(height: 16),

              if (status == 2) ...[
                const Text('Reason for Rejection', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.red)),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(.25)),
                  ),
                  child: SelectableText(
                    (reason == null || reason.isEmpty) ? 'Not specified' : reason,
                    style: const TextStyle(height: 1.35),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fermer'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  String _mapStatus(int s) {
    switch (s) {
      case 0: return 'Pending';
      case 1: return 'Accepted';
      case 2: return 'Rejected';
      default: return s.toString();
    }
  }

  void _showSnack(String msg, {required bool error}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final genres = context.watch<GenreProvider>().genres;
    final formDisabled = _checkingRight || !_isContributor;

    return Scaffold(
      appBar: AppBar(title: const Text('Contributor Space')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TitreSection(title: 'Propose a Content'),

          if (_checkingRight)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),

          if (!_checkingRight && !_isContributor)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withOpacity(.3)),
                ),
                child: const Text(
                    'You do not have contributor rights. If the admin just granted you access, please log out and log back in.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

          AbsorbPointer(
            absorbing: formDisabled,
            child: Opacity(
              opacity: formDisabled ? 0.6 : 1,
              child: Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Title *'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _overviewCtrl,
                    maxLines: 3,
                    maxLength: 3000,
                    decoration: const InputDecoration(labelText: 'Description (max 3000 chars) *'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length > 3000) return '3000 characters max';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _releaseDateCtrl,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Release Date *', hintText: 'YYYY-MM-DD'),
                    onTap: _pickDate,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(labelText: 'Type *'),
                    items: const [
                      DropdownMenuItem(value: 'film',  child: Text('Movie')),
                      DropdownMenuItem(value: 'serie', child: Text('Series')),
                      DropdownMenuItem(value: 'court', child: Text('Short Movies')),
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
                            ? 'Select up to 4 genres *'
                            : 'Genres : ${genres.where((g) => _selectedGenreIds.contains(g.id)).map((g) => g.name).join(', ')}',
                        style: TextStyle(color: _selectedGenreIds.isEmpty ? Colors.red : null),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: formDisabled ? null : _submit,
                      child: const Text('Submit'),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          const TitreSection(title: 'My contributions'),
          const SizedBox(height: 4),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _myContribs.isEmpty
                    ? const Center(child: Text('No contributions.'))
                    : ListView.builder(
                        itemCount: _myContribs.length,
                        itemBuilder: (ctx, i) {
                          final c = _myContribs[i] as Map<String, dynamic>;
                          final data = (c['movie_data'] as Map?)?.cast<String, dynamic>();
                          final title = data?['title'] ?? '—';
                          final status = c['status'] as int? ?? 0;

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openContributionDetails(c),
                              child: Card(
                                color: Colors.red.withOpacity(.05),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Icon(_statusIcon(status), color: _statusColor(status)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: _kTitleColor, // ✅ couleur forcée (plus de #BBB2B2)
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Statut : ${_mapStatus(status)}',
                                              style: const TextStyle(
                                                color: _kSubtitleColor,  // ✅ sous-titre lisible
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                ),
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
