import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data['data'] ?? response.data;
      final user = UserModel.fromJson(data['user'] ?? data);
      final token = data['token'] ?? data['accessToken'] ?? '';

      // Store token in headers for future requests
      if (token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return {'user': user, 'token': token};
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        },
      );
      final data = response.data['data'] ?? response.data;
      final user = UserModel.fromJson(data['user'] ?? data);
      final token = data['token'] ?? data['accessToken'] ?? '';

      // Store token in headers for future requests
      if (token.isNotEmpty) {
        dio.options.headers['Authorization'] = 'Bearer $token';
      }

      return {'user': user, 'token': token};
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
      dio.options.headers.remove('Authorization');
    } catch (e) {
      // Even if logout fails on server, clear local auth
      dio.options.headers.remove('Authorization');
    }
  }
}
