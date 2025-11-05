import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  final String userId;

  const LoadWallet(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddMoney extends WalletEvent {
  final String userId;
  final double amount;

  const AddMoney({required this.userId, required this.amount});

  @override
  List<Object?> get props => [userId, amount];
}

class DeductMoney extends WalletEvent {
  final String userId;
  final double amount;

  const DeductMoney({required this.userId, required this.amount});

  @override
  List<Object?> get props => [userId, amount];
}
