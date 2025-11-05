import 'dart:convert';
import 'dart:math';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/either.dart';
import '../../core/errors/failures.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final result = await remoteDataSource.login(email, password);
      final user = result['user'] as User;
      final token = result['token'] as String?;

      await localDataSource.cacheUser(user);
      if (token != null && token.isNotEmpty) {
        await localDataSource.cacheToken(token);
      }
      return Either.right(user);
    } catch (e) {
      // If network fails, try to authenticate locally
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null && cachedUser.email == email) {
        // User exists in cache, allow login (offline mode)
        final token = await localDataSource.getCachedToken();
        if (token == null || token.isEmpty) {
          // Generate a local token for offline mode
          final localToken = _generateLocalToken(email);
          await localDataSource.cacheToken(localToken);
        }
        return Either.right(cachedUser);
      }
      // Check if it's a network error - if so, provide better message
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('connection error') ||
          errorMsg.contains('SocketException')) {
        return Either.left(
          NetworkFailure(
            'Unable to connect to server. Please check your internet connection.',
          ),
        );
      }
      return Either.left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final result = await remoteDataSource.signup(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      final user = result['user'] as User;
      final token = result['token'] as String?;

      await localDataSource.cacheUser(user);
      if (token != null && token.isNotEmpty) {
        await localDataSource.cacheToken(token);
      }
      return Either.right(user);
    } catch (e) {
      // If network fails, create user locally (offline mode)
      final errorMsg = e.toString();
      if (errorMsg.contains('Failed host lookup') ||
          errorMsg.contains('connection error') ||
          errorMsg.contains('SocketException')) {
        // Create user locally for offline mode
        try {
          final localUser = UserModel(
            id: 'local_${DateTime.now().millisecondsSinceEpoch}',
            name: name,
            email: email,
            phone: phone,
            createdAt: DateTime.now(),
          );
          final localToken = _generateLocalToken(email);

          await localDataSource.cacheUser(localUser);
          await localDataSource.cacheToken(localToken);

          return Either.right(localUser);
        } catch (localError) {
          return Either.left(
            CacheFailure(
              'Failed to create local account: ${localError.toString()}',
            ),
          );
        }
      }
      return Either.left(ServerFailure('Signup failed: ${e.toString()}'));
    }
  }

  // Generate a simple local token for offline mode
  String _generateLocalToken(String email) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    final tokenData = '$email:$timestamp:$random';
    return base64Encode(utf8.encode(tokenData));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return Either.right(null);
    } catch (e) {
      // Clear local cache even if remote logout fails
      await localDataSource.clearCache();
      return Either.right(null);
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Either.right(user);
    } catch (e) {
      return Either.left(
        CacheFailure('Failed to get cached user: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final isAuth = await localDataSource.isAuthenticated();
      return Either.right(isAuth);
    } catch (e) {
      return Either.left(
        CacheFailure('Failed to check authentication: ${e.toString()}'),
      );
    }
  }
}
