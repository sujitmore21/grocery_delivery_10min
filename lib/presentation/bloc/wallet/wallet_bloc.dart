import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository walletRepository;

  WalletBloc(this.walletRepository) : super(WalletInitial()) {
    on<LoadWallet>(_onLoadWallet);
    on<AddMoney>(_onAddMoney);
    on<DeductMoney>(_onDeductMoney);
  }

  Future<void> _onLoadWallet(
    LoadWallet event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await walletRepository.getWallet(event.userId);
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(WalletLoaded(wallet)),
    );
  }

  Future<void> _onAddMoney(AddMoney event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await walletRepository.addMoney(event.userId, event.amount);
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(MoneyAdded(wallet)),
    );
  }

  Future<void> _onDeductMoney(
    DeductMoney event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());
    final result = await walletRepository.deductMoney(
      event.userId,
      event.amount,
    );
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(WalletLoaded(wallet)),
    );
  }
}
