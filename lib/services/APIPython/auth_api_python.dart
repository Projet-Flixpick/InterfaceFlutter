import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:http/http.dart' as http;

import '../../models/film_model.dart';

enum MediaType { movie, serie, shortmovie }

extension _MediaTypeX on MediaType {
  String get value => switch (this) {
        MediaType.movie => 'movie',
        MediaType.serie => 'serie',
        MediaType.shortmovie => 'shortmovie',
      };
}

class PythonRecoApi {
  PythonRecoApi._();

  /// Désactiver les logs par défaut.
  static bool debugLogs = false;

  static String get _host {
    if (kIsWeb) {
      return const String.fromEnvironment('PY_API', defaultValue: 'http://localhost:5000');
    }
    if (Platform.isAndroid) {
      return const String.fromEnvironment('PY_API', defaultValue: 'http://10.0.2.2:5000');
    }
    return const String.fromEnvironment('PY_API', defaultValue: 'http://127.0.0.1:5000');
  }

  static String get base => _host;

  static Uri _userUri(String userId) => Uri.parse('$base/recommend/$userId');
  static Uri get _mergeUri => Uri.parse('$base/recommend/merge');

  static void _logRequest(Uri uri, Map<String, String> headers, Map<String, Object?> body) {
    if (!debugLogs) return;
    final masked = Map<String, String>.from(headers);
    if (masked.containsKey('Authorization')) masked['Authorization'] = 'Bearer ***';
    debugPrint('[PY API] POST $uri');
    debugPrint('[PY API] headers=$masked');
    debugPrint('[PY API] body=${jsonEncode(body)}');
  }

  static Future<List<Film>> _postFilms(
    Uri uri, {
    required Map<String, Object?> body,
    String? bearerToken,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (bearerToken != null && bearerToken.isNotEmpty) 'Authorization': 'Bearer $bearerToken',
    };

    _logRequest(uri, headers, body);

    try {
      final res = await http.post(uri, headers: headers, body: jsonEncode(body));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        final rawBody = res.body;
        dynamic decoded;
        try {
          decoded = jsonDecode(rawBody);
        } on FormatException catch (_) {
          final sanitized = rawBody.replaceAll(RegExp(r'\bNaN\b'), 'null');
          decoded = jsonDecode(sanitized);
        }
        final List data = decoded is List ? decoded : (decoded is Map ? (decoded['data'] ?? []) : []);
        return data.whereType<Map<String, dynamic>>().map((e) => Film.fromJson(e)).toList();
      } else {
        debugPrint('PythonRecoApi POST $uri -> ${res.statusCode} ${res.body}');
        return <Film>[];
      }
    } catch (e) {
      debugPrint('PythonRecoApi error: $e');
      return <Film>[];
    }
  }

  static Future<List<Film>> recommendForUser({
    required String userId,
    required MediaType mediaType,
    required int limit,
    int? page,
    String? bearerToken,
  }) {
    final body = <String, Object?>{
      'limit': limit,
      'media_type': mediaType.value,
      if (page != null) 'page': page,
    };
    return _postFilms(_userUri(userId), body: body, bearerToken: bearerToken);
  }

  static Future<List<Film>> recommendMerge({
    required String user1Id,
    required String user2Id,
    required MediaType mediaType,
    required int limit,
    int? page,
    String? bearerToken,
  }) {
    final body = <String, Object?>{
      'user1_id': user1Id,
      'user2_id': user2Id,
      'limit': limit,
      'media_type': mediaType.value,
      if (page != null) 'page': page,
    };
    return _postFilms(_mergeUri, body: body, bearerToken: bearerToken);
  }

  static bool looksLikeMongoId(String v) => RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v.trim());
}
