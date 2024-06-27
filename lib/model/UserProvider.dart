import 'package:flutter/material.dart';
import 'VUser.dart';

class UserProvider with ChangeNotifier {
  VUser? _user;

  VUser? get user => _user;

  void setUser(VUser newUser) {
    _user = newUser;
    notifyListeners();
  }
}
