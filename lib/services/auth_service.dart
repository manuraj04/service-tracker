import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static const _userNameKey = 'user_name';

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Guest';
  }

  static Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return !prefs.containsKey(_userNameKey);
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }
}