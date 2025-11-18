import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;

  OrderBloc(this.orderRepository) : super(OrderInitial()) {
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    final result = await orderRepository.createOrder(
      cartItemIds: event.cartItemIds,
      deliveryAddress: event.deliveryAddress,
      paymentMethod: event.paymentMethod,
      couponCode: event.couponCode,
      discountAmount: event.discountAmount,
      riderTip: event.riderTip,
    );
    result.fold(
      (failure) => emit(OrderError(failure.message)),
      (order) => emit(OrderCreated(order)),
    );
  }
}
