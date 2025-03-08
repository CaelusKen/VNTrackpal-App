import 'package:flutter/foundation.dart';

class UserData extends ChangeNotifier {
  String _name = '';
  String _username = '';

  String get name => _name;
  String get username => _username;

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }
  
  void setUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }
}