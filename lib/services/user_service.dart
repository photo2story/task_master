import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static const String _userNameKey = 'userName';
  final SharedPreferences _prefs;

  UserService(this._prefs);

  String? get userName => _prefs.getString(_userNameKey);
  
  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
  }

  bool get isLoggedIn => userName != null;
} 