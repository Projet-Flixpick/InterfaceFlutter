import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  String? _email;
  String? _firstname;
  String? _name;

  String? get token => _token;
  String? get email => _email;
  String? get firstname => _firstname;
  String? get name => _name;

  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  void setToken(String token) {
    if (token.split('.').length == 3) {
      _token = token;
      print('🔐 Token JWT stocké dans AuthProvider : $_token');
      notifyListeners();
    } else {
      print('❌ Tentative de stockage d’un token mal formé : $token');
    }
  }

  void clearToken() {
    _token = null;
    _email = null;
    _firstname = null;
    _name = null;
    print('🧹 Token et infos utilisateur supprimés.');
    notifyListeners();
  }

  void setUserInfoFromServer({
    required String email,
    required String firstname,
    required String name,
  }) {
    _email = email;
    _firstname = firstname;
    _name = name;
    notifyListeners();
  }
}
