import '../entities/wallet.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class WalletRepository {
  Future<Either<Failure, Wallet>> getWallet(String userId);
  Future<Either<Failure, Wallet>> addMoney(String userId, double amount);
  Future<Either<Failure, Wallet>> deductMoney(String userId, double amount);
  Future<Either<Failure, double>> getBalance(String userId);
}
