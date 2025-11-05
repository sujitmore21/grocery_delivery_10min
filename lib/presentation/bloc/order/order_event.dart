import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrder extends OrderEvent {
  final List<String> cartItemIds;
  final Address deliveryAddress;
  final String paymentMethod;

  const CreateOrder({
    required this.cartItemIds,
    required this.deliveryAddress,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [cartItemIds, deliveryAddress, paymentMethod];
}
