import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'address.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

enum PaymentStatus { pending, paid, failed, refunded }

class Order extends Equatable {
  final String id;
  final String orderNumber;
  final List<CartItem> items;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final Address deliveryAddress;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String? deliveryPartnerId;
  final String? deliveryPartnerName;
  final double? deliveryPartnerLatitude;
  final double? deliveryPartnerLongitude;
  final String? couponCode;
  final double discountAmount;
  final double riderTip;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.deliveryPartnerId,
    this.deliveryPartnerName,
    this.deliveryPartnerLatitude,
    this.deliveryPartnerLongitude,
    this.couponCode,
    this.discountAmount = 0.0,
    this.riderTip = 0.0,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    items,
    subtotal,
    deliveryFee,
    totalAmount,
    deliveryAddress,
    status,
    paymentStatus,
    orderDate,
    estimatedDeliveryTime,
    actualDeliveryTime,
    deliveryPartnerId,
    deliveryPartnerName,
    deliveryPartnerLatitude,
    deliveryPartnerLongitude,
    couponCode,
    discountAmount,
    riderTip,
  ];
}
