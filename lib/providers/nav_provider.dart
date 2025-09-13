import 'package:flutter/foundation.dart';

class NavProvider extends ChangeNotifier {
  int _index = 0;
  String? _pendingFriendId;

  int get index => _index;
  String? takePendingFriendId() {
    final v = _pendingFriendId;
    _pendingFriendId = null;
    return v;
  }

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }

  void goToForYou({String? friendId}) {
    _index = 3; // 0: Home, 1: Top Movies, 2: Top Series, 3: For You, 4: Profile
    _pendingFriendId = friendId;
    notifyListeners();
  }
}
