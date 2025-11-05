import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/repositories/either.dart';
import '../../domain/entities/wallet.dart';
import '../../core/errors/failures.dart';

class WalletRepositoryImpl implements WalletRepository {
  final SharedPreferences sharedPreferences;
  static const String walletKey = 'WALLET_BALANCE';
  static const String walletLastUpdatedKey = 'WALLET_LAST_UPDATED';

  WalletRepositoryImpl(this.sharedPreferences);

  @override
  Future<Either<Failure, Wallet>> getWallet(String userId) async {
    try {
      final balance =
          sharedPreferences.getDouble('${walletKey}_$userId') ?? 0.0;
      final lastUpdatedString = sharedPreferences.getString(
        '${walletLastUpdatedKey}_$userId',
      );
      final lastUpdated = lastUpdatedString != null
          ? DateTime.parse(lastUpdatedString)
          : DateTime.now();

      final wallet = Wallet(
        userId: userId,
        balance: balance,
        lastUpdated: lastUpdated,
      );
      return Either.right(wallet);
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> addMoney(String userId, double amount) async {
    try {
      final walletResult = await getWallet(userId);
      return walletResult.fold((failure) => Either.left(failure), (
        wallet,
      ) async {
        final newBalance = wallet.balance + amount;
        await sharedPreferences.setDouble('${walletKey}_$userId', newBalance);
        await sharedPreferences.setString(
          '${walletLastUpdatedKey}_$userId',
          DateTime.now().toIso8601String(),
        );

        final updatedWallet = wallet.copyWith(
          balance: newBalance,
          lastUpdated: DateTime.now(),
        );
        return Either.right(updatedWallet);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Wallet>> deductMoney(
    String userId,
    double amount,
  ) async {
    try {
      final walletResult = await getWallet(userId);
      return walletResult.fold((failure) => Either.left(failure), (
        wallet,
      ) async {
        if (wallet.balance < amount) {
          return Either.left(ServerFailure('Insufficient wallet balance'));
        }

        final newBalance = wallet.balance - amount;
        await sharedPreferences.setDouble('${walletKey}_$userId', newBalance);
        await sharedPreferences.setString(
          '${walletLastUpdatedKey}_$userId',
          DateTime.now().toIso8601String(),
        );

        final updatedWallet = wallet.copyWith(
          balance: newBalance,
          lastUpdated: DateTime.now(),
        );
        return Either.right(updatedWallet);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getBalance(String userId) async {
    try {
      final balance =
          sharedPreferences.getDouble('${walletKey}_$userId') ?? 0.0;
      return Either.right(balance);
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }
}
