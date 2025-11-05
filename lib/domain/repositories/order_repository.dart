import '../entities/order.dart';
import '../entities/address.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class OrderRepository {
  Future<Either<Failure, Order>> createOrder({
    required List<String> cartItemIds,
    required Address deliveryAddress,
    required String paymentMethod,
  });
  Future<Either<Failure, List<Order>>> getOrders();
  Future<Either<Failure, Order>> getOrderById(String orderId);
  Future<Either<Failure, void>> cancelOrder(String orderId);
  Future<Either<Failure, Order>> trackOrder(String orderId);
  Stream<Order> getOrderUpdates(String orderId);
}
