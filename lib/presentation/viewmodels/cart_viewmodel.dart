import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_event.dart';
import '../bloc/cart/cart_state.dart';
import '../../core/constants/app_constants.dart';

class CartViewModel {
  final CartBloc cartBloc;

  CartViewModel(this.cartBloc);

  void loadCart() {
    cartBloc.add(const LoadCart());
  }

  void addToCart(Product product, int quantity) {
    cartBloc.add(AddToCart(product, quantity));
  }

  void updateCartItem(String productId, int quantity) {
    cartBloc.add(UpdateCartItem(productId, quantity));
  }

  void removeFromCart(String productId) {
    cartBloc.add(RemoveFromCart(productId));
  }

  void clearCart() {
    cartBloc.add(const ClearCart());
  }

  Stream<CartState> get cartState => cartBloc.stream;

  List<CartItem> getCartItems(CartState state) {
    if (state is CartLoaded) {
      return state.items;
    }
    return [];
  }

  double getCartTotal(CartState state) {
    if (state is CartLoaded) {
      return state.total;
    }
    return 0.0;
  }

  // Get subtotal (items total)
  double getSubtotal(CartState state) {
    if (state is CartLoaded) {
      return state.total;
    }
    return 0.0;
  }

  // Get platform charge
  double getPlatformCharge(CartState state) {
    final subtotal = getSubtotal(state);
    return (subtotal * AppConstants.platformChargePercent) / 100;
  }

  // Get delivery charge
  double getDeliveryCharge(CartState state) {
    return AppConstants.deliveryFee;
  }

  // Get tax
  double getTax(CartState state) {
    final subtotal = getSubtotal(state);
    return (subtotal * AppConstants.taxRate) / 100;
  }

  // Get grand total (subtotal + platform charge + delivery charge + tax)
  double getGrandTotal(CartState state) {
    final subtotal = getSubtotal(state);
    final platformCharge = getPlatformCharge(state);
    final deliveryCharge = getDeliveryCharge(state);
    final tax = getTax(state);
    return subtotal + platformCharge + deliveryCharge + tax;
  }

  int getCartItemCount(CartState state) {
    if (state is CartLoaded) {
      return state.items.fold(0, (sum, item) => sum + item.quantity);
    }
    return 0;
  }

  bool isLoading(CartState state) => state is CartLoading;
  bool hasError(CartState state) => state is CartError;
  String? getErrorMessage(CartState state) {
    if (state is CartError) {
      return state.message;
    }
    return null;
  }
}
