import '../entities/cart_item.dart';
import '../entities/product.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCartItems();
  Future<Either<Failure, void>> addToCart(Product product, int quantity);
  Future<Either<Failure, void>> updateCartItem(String productId, int quantity);
  Future<Either<Failure, void>> removeFromCart(String productId);
  Future<Either<Failure, void>> clearCart();
  Future<Either<Failure, double>> getCartTotal();
}
