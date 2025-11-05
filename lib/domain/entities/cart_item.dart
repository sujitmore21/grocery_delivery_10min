import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final String productId;
  final Product product;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.finalPrice * quantity;

  CartItem copyWith({String? productId, Product? product, int? quantity}) {
    return CartItem(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [productId, product, quantity];
}
