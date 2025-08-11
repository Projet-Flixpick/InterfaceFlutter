import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/film_model.dart';
import '../../services/APIgo/api_routes.dart';
import '../../widgets/films_list.dart';
import '../../widgets/titre_section.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({
    Key? key,
    this.initialFriendId, // optionnel : pour ouvrir directement la section Ami
  }) : super(key: key);

  final String? initialFriendId;

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with AutomaticKeepAliveClientMixin<RecommendationsScreen> {
  // Données
  final List<Film> _genreFilms = [];
  final List<Film> _watchedFilms = [];
  final List<Film> _friendFilms = [];

  // Pagination
  int _pageGenre = 1;
  int _pageWatched = 1;
  int _pageFriend = 1;

  // Loaders
  bool _loadingGenre = false;
  bool _loadingWatched = false;
  bool _loadingFriend = false;

  // Ami sélectionné pour la 3e section
  String? _selectedFriendId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // charge les deux premières sections
    _loadMore('genre');
    _loadMore('watched');

    // si on arrive depuis l'écran Amis avec un ami sélectionné
    if (widget.initialFriendId != null && widget.initialFriendId!.isNotEmpty) {
      selectFriend(widget.initialFriendId!);
    }
  }

  // -------------------- API utils --------------------
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<List<dynamic>> _getJsonList(String url, Map<String, String> query) async {
    final token = await _getToken();
    final uri = Uri.parse(url).replace(queryParameters: query);

    final res = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${token ?? ''}',
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = json.decode(res.body);
      if (decoded is List) return decoded;
      if (decoded is Map && decoded['data'] is List) return decoded['data'];
      return const [];
    } else {
      debugPrint('GET ${uri.toString()} -> ${res.statusCode} ${res.body}');
      return const [];
    }
  }

  // -------------------- Chargement paginé --------------------
  Future<void> _loadMore(String section) async {
    if (section == 'genre' && _loadingGenre) return;
    if (section == 'watched' && _loadingWatched) return;
    if (section == 'friend' && _loadingFriend) return;

    setState(() {
      if (section == 'genre') _loadingGenre = true;
      if (section == 'watched') _loadingWatched = true;
      if (section == 'friend') _loadingFriend = true;
    });

    try {
      List<dynamic> raw = [];
      if (section == 'genre') {
        // Recos “profil / genres”
        raw = await _getJsonList(ApiRoutes.getRecommandation, {
          'page': '$_pageGenre',
          'source': 'genres', // ignoré si non géré côté Go
        });
        _pageGenre++;
      } else if (section == 'watched') {
        // Recos “basées sur tes films vus”
        raw = await _getJsonList(ApiRoutes.getRecommandation, {
          'page': '$_pageWatched',
          'source': 'watched',
        });
        _pageWatched++;
      } else if (section == 'friend' && _selectedFriendId != null) {
        raw = await _getJsonList(ApiRoutes.getRecommandationFriends, {
          'page': '$_pageFriend',
          'friendId': _selectedFriendId!, // adapte si ton Go attend un autre nom
        });
        _pageFriend++;
      }

      final films = raw
          .whereType<Map<String, dynamic>>()
          .map((e) => Film.fromJson(e))
          .toList();

      if (!mounted) return;
      setState(() {
        if (section == 'genre') {
          _genreFilms.addAll(films);
          _loadingGenre = false;
        } else if (section == 'watched') {
          _watchedFilms.addAll(films);
          _loadingWatched = false;
        } else if (section == 'friend') {
          _friendFilms.addAll(films);
          _loadingFriend = false;
        }
      });
    } catch (e) {
      debugPrint('loadMore($section) error: $e');
      if (!mounted) return;
      setState(() {
        if (section == 'genre') _loadingGenre = false;
        if (section == 'watched') _loadingWatched = false;
        if (section == 'friend') _loadingFriend = false;
      });
    }
  }

  /// À appeler quand l’utilisateur clique un ami (depuis FriendsScreen)
  void selectFriend(String friendId) {
    setState(() {
      _selectedFriendId = friendId;
      _friendFilms.clear();
      _pageFriend = 1;
    });
    _loadMore('friend');
  }

  // -------------------- UI --------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: ListView(
        key: const PageStorageKey('recommendations_page'),
        children: [
          const TitreSection(title: 'Basées sur vos genres préférés'),
          _genreFilms.isEmpty && _loadingGenre
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : FilmsList(
                  key: const PageStorageKey('genre_recos'),
                  films: _genreFilms,
                  loadMoreFilms: () => _loadMore('genre'),
                ),

          const TitreSection(title: 'Basées sur vos films vus'),
          _watchedFilms.isEmpty && _loadingWatched
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              : FilmsList(
                  key: const PageStorageKey('watched_recos'),
                  films: _watchedFilms,
                  loadMoreFilms: () => _loadMore('watched'),
                ),

          const TitreSection(title: 'Recommandations avec un ami'),
          if (_selectedFriendId == null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Sélectionnez un ami pour voir cette section.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          else if (_friendFilms.isEmpty && _loadingFriend)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            FilmsList(
              key: const PageStorageKey('friend_recos'),
              films: _friendFilms,
              loadMoreFilms: () => _loadMore('friend'),
            ),
        ],
      ),
    );
  }
}
