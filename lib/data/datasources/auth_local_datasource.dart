import 'package:shared_preferences/shared_preferences.dart';
import '../../../domain/entities/user.dart';
import '../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(User user);
  Future<void> cacheToken(String token);
  Future<User?> getCachedUser();
  Future<String?> getCachedToken();
  Future<void> clearCache();
  Future<bool> isAuthenticated();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'cached_token';

  AuthLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> cacheUser(User user) async {
    final userJson = UserModel.toJson(user);
    await sharedPreferences.setString(_userKey, jsonEncode(userJson));
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(_tokenKey, token);
  }

  @override
  Future<User?> getCachedUser() async {
    final userJson = sharedPreferences.getString(_userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString(_tokenKey);
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_userKey);
    await sharedPreferences.remove(_tokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getCachedToken();
    final user = await getCachedUser();
    return token != null && user != null;
  }
}
