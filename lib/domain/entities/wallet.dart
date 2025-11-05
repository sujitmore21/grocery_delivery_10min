import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String userId;
  final double balance;
  final DateTime lastUpdated;

  const Wallet({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  Wallet copyWith({String? userId, double? balance, DateTime? lastUpdated}) {
    return Wallet(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [userId, balance, lastUpdated];
}
