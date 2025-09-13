import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/film_model.dart';
import '../../services/APIgo/api_routes.dart';
import '../../services/APIPython/auth_api_python.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';
import '../../widgets/popcorn_loader.dart';
import '../../providers/user_provider.dart';
import '../../providers/friend_provider.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({Key? key, this.initialFriendId}) : super(key: key);

  final String? initialFriendId; // conservé pour compat (non utilisé)

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with AutomaticKeepAliveClientMixin<RecommendationsScreen> {
  // Données
  final List<Film> _movieRecs = [];
  final List<Film> _seriesRecs = [];
  final List<Film> _friendRecs = [];

  // Loaders & états
  bool _loadingMovies = false;
  bool _loadingSeries = false;
  bool _loadingFriend = false;
  bool _moviesLoaded = false;
  bool _seriesLoaded = false;
  bool _friendLoaded = false; // ✅ bloque tout reload “scroll”

  // UI (facultatif)
  String? _selectedFriendId;

  // Réglages
  static const int _limit = 10;
  static const int _mergeLimit = 10; // ✅ tu voulais 10 éléments
  static const MediaType _mergeMediaType = MediaType.serie;

  // ID ami FIXE
  static const String _pinnedFriendId = '686bd4951bbaa93f58495489';

  // Fallback si ID courant indispo
  static const String _devFallbackUserId = '686bd4951bbaa93f58495497';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _loadMovies();
    _loadSeries();

    // Juste pour remplir la liste du dropdown (aucun message auto)
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        context.read<FriendProvider>().fetchFriends(token);
      }
    });
  }

  // ---------- Helpers ----------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  String _currentMongoIdOrFallback() {
    try {
      final up = context.read<UserProvider>();
      final dynamic maybe = (up as dynamic).mongoId ?? (up as dynamic).id ?? null;
      if (maybe is String && PythonRecoApi.looksLikeMongoId(maybe)) return maybe;
    } catch (_) {}
    return _devFallbackUserId;
  }

  Future<List<Film>> _fetchFromGo(String url, Map<String, String> query) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse(url).replace(queryParameters: query);
      final res = await http.get(uri, headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      });
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final decoded = json.decode(res.body);
        final List raw = decoded is List
            ? decoded
            : (decoded is Map && decoded['data'] is List ? decoded['data'] : const []);
        return raw.whereType<Map<String, dynamic>>().map((e) => Film.fromJson(e)).toList();
      }
      return const <Film>[];
    } catch (_) {
      return const <Film>[];
    }
  }

  // ---------- Loads ----------
  Future<void> _loadMovies() async {
    if (_loadingMovies || _moviesLoaded) return;
    setState(() => _loadingMovies = true);

    final uid = _currentMongoIdOrFallback();
    final films = await PythonRecoApi.recommendForUser(
      userId: uid,
      mediaType: MediaType.movie,
      limit: _limit,
      bearerToken: await _getToken(),
    );

    if (!mounted) return;
    setState(() {
      _movieRecs.addAll(films);
      _loadingMovies = false;
      _moviesLoaded = true;
    });
  }

  Future<void> _loadSeries() async {
    if (_loadingSeries || _seriesLoaded) return;
    setState(() => _loadingSeries = true);

    final uid = _currentMongoIdOrFallback();
    final films = await PythonRecoApi.recommendForUser(
      userId: uid,
      mediaType: MediaType.serie,
      limit: _limit,
      bearerToken: await _getToken(),
    );

    if (!mounted) return;
    setState(() {
      _seriesRecs.addAll(films);
      _loadingSeries = false;
      _seriesLoaded = true;
    });
  }

  /// Recos “avec un ami” — **2 ObjectId** (le second est **fixe**)
  Future<void> _loadFriend() async {
    // ✅ Empêche tout rechargement (scroll atteint la fin, etc.)
    if (_loadingFriend || _friendLoaded) return;

    setState(() {
      _loadingFriend = true;
      _friendLoaded = false;
      _friendRecs.clear();
    });

    final me = _currentMongoIdOrFallback();

    List<Film> films = [];
    if (PythonRecoApi.looksLikeMongoId(me) &&
        PythonRecoApi.looksLikeMongoId(_pinnedFriendId)) {
      films = await PythonRecoApi.recommendMerge(
        user1Id: me,
        user2Id: _pinnedFriendId,
        mediaType: _mergeMediaType,
        limit: _mergeLimit,
        bearerToken: await _getToken(),
      );
    }

    if (!mounted) return;
    setState(() {
      _friendRecs.addAll(films);
      _loadingFriend = false;
      _friendLoaded = true; // ✅ on ne rechargera plus tant que la liste vit
    });
  }

  void _onFriendSelected(String? friendId) async {
    if (friendId == null) return;

    setState(() {
      _selectedFriendId = friendId.trim();
      _friendRecs.clear();
      _friendLoaded = false;   // autorise un nouveau fetch
    });

  // Recharge immédiatement les recos (user2_id reste l’ID fixé)
  await _loadFriend();
}

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final meEmail = context.read<UserProvider>().email;
    final friendsIds = context.select<FriendProvider, List<String>>((fp) {
      return fp.friends
          .map((f) => f.userIdSender == meEmail ? f.userIdInvite : f.userIdSender)
          .toList();
    });

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const PageStorageKey('recommendations_page'),
          children: [
            const TitreSection(title: 'Films recommandés pour vous'),
            _movieRecs.isEmpty && _loadingMovies
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: PopcornLoader()),
                  )
                : FilmsList(
                    key: const PageStorageKey('movie_recs'),
                    films: _movieRecs,
                    loadMoreFilms: _loadMovies,
                  ),

            const TitreSection(title: 'Séries recommandées pour vous'),
            _seriesRecs.isEmpty && _loadingSeries
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: PopcornLoader()),
                  )
                : FilmsList(
                    key: const PageStorageKey('series_recs'),
                    films: _seriesRecs,
                    loadMoreFilms: _loadSeries,
                  ),

            const TitreSection(title: 'Recommandations avec un ami'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: (_selectedFriendId != null && friendsIds.contains(_selectedFriendId))
                          ? _selectedFriendId
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Sélectionnez un ami (facultatif)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: friendsIds
                          .map((id) => DropdownMenuItem(
                                value: id,
                                child: Text(id, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: _onFriendSelected,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _loadingFriend ? null : _loadFriend,
                    icon: _loadingFriend
                        ? const SizedBox(
                            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.theaters),
                    label: const Text('Voir'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: const Size(88, 52),
                    ),
                  ),
                ],
              ),
            ),

            if (_friendRecs.isEmpty && _loadingFriend)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: PopcornLoader()),
              )
            else if (_friendRecs.isNotEmpty)
              // ✅ Carrousel affiché, pas de reload en fin de scroll
              FilmsList(
                key: const PageStorageKey('friend_recs'),
                films: _friendRecs,
                loadMoreFilms: _loadFriend, // safe car _friendLoaded bloque l'appel
              ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
