import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/either.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/address.dart';
import '../../core/errors/failures.dart';
import '../../core/constants/app_constants.dart';
import '../datasources/dummy_data.dart';
import '../../domain/repositories/cart_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final CartRepository cartRepository;

  OrderRepositoryImpl(this.cartRepository);

  @override
  Future<Either<Failure, Order>> createOrder({
    required List<String> cartItemIds,
    required Address deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      // Get cart items
      final cartItemsResult = await cartRepository.getCartItems();
      return cartItemsResult.fold((failure) => Either.left(failure), (
        cartItems,
      ) async {
        // Filter items by IDs
        final orderItems = cartItems
            .where((item) => cartItemIds.contains(item.productId))
            .toList();

        if (orderItems.isEmpty) {
          return Either.left(ServerFailure('No items found in cart'));
        }

        // Calculate totals
        final subtotal = orderItems.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        final platformCharge =
            (subtotal * AppConstants.platformChargePercent) / 100;
        final deliveryFee = AppConstants.deliveryFee;
        final tax = (subtotal * AppConstants.taxRate) / 100;
        final totalAmount = subtotal + platformCharge + deliveryFee + tax;

        // Create order
        final order = Order(
          id: 'order_${DateTime.now().millisecondsSinceEpoch}',
          orderNumber:
              'ORD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          items: orderItems,
          subtotal: subtotal,
          deliveryFee: deliveryFee,
          totalAmount: totalAmount,
          deliveryAddress: deliveryAddress,
          status: OrderStatus.pending,
          paymentStatus: paymentMethod == 'Cash on Delivery'
              ? PaymentStatus.pending
              : PaymentStatus.paid,
          orderDate: DateTime.now(),
          estimatedDeliveryTime: DateTime.now().add(
            const Duration(minutes: 10),
          ),
        );

        return Either.right(order);
      });
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      // Return dummy orders for now
      return Either.right(DummyData.getDummyOrders());
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = DummyData.getDummyOrderById(orderId);
      if (order != null) {
        return Either.right(order);
      }
      return Either.left(ServerFailure('Order not found'));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      // TODO: Implement actual cancellation logic
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Order>> trackOrder(String orderId) async {
    return getOrderById(orderId);
  }

  @override
  Stream<Order> getOrderUpdates(String orderId) {
    // TODO: Implement real-time order updates
    return Stream.empty();
  }
}
