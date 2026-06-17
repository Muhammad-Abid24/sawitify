
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _userToken = "USER_TOKEN";
  static const String _isLoggedIn = "ISLOGGEDIN";

  static const String _userId = "USER_ID";
  static const String _userName = "USERNAME";
  static const String _email = "EMAIL";
  static const String _photoUrl = "PHOTO_URL";

  static const String _userLogin = "USER_LOGIN";
  static const String _lastLoginAt = "lastLoginAt";
  static const String _googleAccessToken = "GOOGLE_ACCESS_TOKEN";
  static const String _googleIdToken = "GOOGLE_ID_TOKEN";


  static Future<Map<String, dynamic>> getDataUSerLogin() async {
    final prefData = await SharedPreferences.getInstance();

    return {
      "user_id": prefData.getString(_userId),
      "username": prefData.getString(_userName),
      "email": prefData.getString(_email),
      "photo_url": prefData.getString(_photoUrl),
    };
  }

  static Future<void> setDataUserLogin( {
    required String userId,
    required String userName,
    required String email,
    required String photoUrl,
}) async {
  final prefData = await SharedPreferences.getInstance();
  await prefData.setString(_userId, userId);
  await prefData.setString(_userName, userName);
  await prefData.setString(_email, email);
  await prefData.setString(_photoUrl, photoUrl);
  await prefData.setBool(_isLoggedIn, true);
}

  // GETTERS
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userLogin);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userToken);
  }

  static Future<bool> isUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedIn) ?? false;
  }

  // LOGOUT
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // TIMESTAMP
  static Future<void> setLoginTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastLoginAt, timestamp);
  }

  static Future<int> getLoginTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastLoginAt) ?? 0;
  }

  // GOOGLE TOKENS
  static Future<void> setGoogleTokens({
    required String accessToken,
    required String idToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_googleAccessToken, accessToken);
    await prefs.setString(_googleIdToken, idToken);
  }

  static Future<String?> getGoogleAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleAccessToken);
  }

  static Future<String?> getGoogleIdToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_googleIdToken);
  }

  static Future<bool> hasGoogleTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_googleAccessToken);
    final idToken = prefs.getString(_googleIdToken);
    return accessToken != null && idToken != null;
  }
}