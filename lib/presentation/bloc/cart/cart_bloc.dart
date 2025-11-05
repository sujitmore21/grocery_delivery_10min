import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/cart_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc(this.cartRepository) : super(CartInitial()) {
    on<LoadCart>(_onLoadCart);
    on<AddToCart>(_onAddToCart);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    emit(CartLoading());
    final itemsResult = await cartRepository.getCartItems();
    await itemsResult.fold<Future<void>>(
      (failure) async {
        emit(CartError(failure.message));
      },
      (items) async {
        final totalResult = await cartRepository.getCartTotal();
        totalResult.fold(
          (failure) => emit(CartError(failure.message)),
          (total) => emit(CartLoaded(items, total)),
        );
      },
    );
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    final result = await cartRepository.addToCart(
      event.product,
      event.quantity,
    );
    result.fold((failure) => emit(CartError(failure.message)), (_) {
      add(const LoadCart());
    });
  }

  Future<void> _onUpdateCartItem(
    UpdateCartItem event,
    Emitter<CartState> emit,
  ) async {
    final result = await cartRepository.updateCartItem(
      event.productId,
      event.quantity,
    );
    result.fold((failure) => emit(CartError(failure.message)), (_) {
      add(const LoadCart());
    });
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCart event,
    Emitter<CartState> emit,
  ) async {
    final result = await cartRepository.removeFromCart(event.productId);
    result.fold((failure) => emit(CartError(failure.message)), (_) {
      add(const LoadCart());
    });
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    final result = await cartRepository.clearCart();
    result.fold((failure) => emit(CartError(failure.message)), (_) {
      add(const LoadCart());
    });
  }
}
