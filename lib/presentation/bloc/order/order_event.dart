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
  final String? couponCode;
  final double discountAmount;
  final double riderTip;

  const CreateOrder({
    required this.cartItemIds,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.couponCode,
    this.discountAmount = 0.0,
    this.riderTip = 0.0,
  });

  @override
  List<Object?> get props => [
    cartItemIds,
    deliveryAddress,
    paymentMethod,
    couponCode,
    discountAmount,
    riderTip,
  ];
}
