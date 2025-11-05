import '../entities/user.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
}
