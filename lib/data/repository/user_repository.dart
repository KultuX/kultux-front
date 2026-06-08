import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kultux/core/models/user.dart';

class UserRepository {
  static const String _key = 'usuario_actual';

  static Future<void> save(User user) async {
    User.activeUser = user;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<User?> load() async {
    if (User.activeUser != null) return User.activeUser;

    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_key);

    if (json == null) return null;

    final user = User.fromJson(jsonDecode(json));
    User.activeUser = user;
    return user;
  }

  static Future<bool> activeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(_key);
    return json != null;
  }

  static Future<void> closeSession() async {
    User.activeUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
