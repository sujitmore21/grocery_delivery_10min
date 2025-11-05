import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/either.dart';
import '../../core/errors/failures.dart';
import '../models/product_model.dart';

class CartRepositoryImpl implements CartRepository {
  final SharedPreferences sharedPreferences;
  static const String cartKey = 'CART_ITEMS';

  CartRepositoryImpl(this.sharedPreferences);

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      final jsonString = sharedPreferences.getString(cartKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        final items = <CartItem>[];

        for (var itemJson in jsonList) {
          final product = ProductModel.fromJson(itemJson['product']);
          items.add(
            CartItem(
              productId: itemJson['productId'],
              product: product,
              quantity: itemJson['quantity'],
            ),
          );
        }
        return Either.right(items);
      }
      return Either.right([]);
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(Product product, int quantity) async {
    try {
      final itemsResult = await getCartItems();
      return itemsResult.fold((failure) => Either.left(failure), (items) async {
        final existingIndex = items.indexWhere(
          (item) => item.productId == product.id,
        );

        List<CartItem> updatedItems;
        if (existingIndex >= 0) {
          updatedItems = List.from(items);
          updatedItems[existingIndex] = CartItem(
            productId: product.id,
            product: product,
            quantity: items[existingIndex].quantity + quantity,
          );
        } else {
          updatedItems = [
            ...items,
            CartItem(
              productId: product.id,
              product: product,
              quantity: quantity,
            ),
          ];
        }

        await _saveCartItems(updatedItems);
        return Either.right(null);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCartItem(
    String productId,
    int quantity,
  ) async {
    try {
      final itemsResult = await getCartItems();
      return itemsResult.fold((failure) => Either.left(failure), (items) async {
        if (quantity <= 0) {
          return removeFromCart(productId);
        }

        final updatedItems = items.map((item) {
          if (item.productId == productId) {
            return CartItem(
              productId: item.productId,
              product: item.product,
              quantity: quantity,
            );
          }
          return item;
        }).toList();

        await _saveCartItems(updatedItems);
        return Either.right(null);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String productId) async {
    try {
      final itemsResult = await getCartItems();
      return itemsResult.fold((failure) => Either.left(failure), (items) async {
        final updatedItems = items
            .where((item) => item.productId != productId)
            .toList();
        await _saveCartItems(updatedItems);
        return Either.right(null);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await sharedPreferences.remove(cartKey);
      return Either.right(null);
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getCartTotal() async {
    try {
      final itemsResult = await getCartItems();
      return itemsResult.fold((failure) => Either.left(failure), (items) {
        final total = items.fold<double>(
          0.0,
          (sum, item) => sum + item.totalPrice,
        );
        return Either.right(total);
      });
    } catch (e) {
      return Either.left(CacheFailure(e.toString()));
    }
  }

  Future<void> _saveCartItems(List<CartItem> items) async {
    final jsonList = items.map((item) {
      final productJson = item.product is ProductModel
          ? (item.product as ProductModel).toJson()
          : {
              'id': item.product.id,
              'name': item.product.name,
              'description': item.product.description,
              'price': item.product.price,
              'image_url': item.product.imageUrl,
              'category_id': item.product.categoryId,
              'category_name': item.product.categoryName,
              'is_available': item.product.isAvailable,
              'stock_quantity': item.product.stockQuantity,
              'discount_price': item.product.discountPrice,
              'unit': item.product.unit,
              'rating': item.product.rating,
              'review_count': item.product.reviewCount,
              'is_vegetarian': item.product.isVegetarian,
              'is_best_seller': item.product.isBestSeller,
            };
      return {
        'productId': item.productId,
        'product': productJson,
        'quantity': item.quantity,
      };
    }).toList();

    await sharedPreferences.setString(cartKey, json.encode(jsonList));
  }
}
