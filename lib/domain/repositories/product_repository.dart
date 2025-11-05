import '../entities/product.dart';
import '../entities/category.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    String? searchQuery,
    bool? isBestSeller,
  });
  Future<Either<Failure, Product>> getProductById(String id);
  Future<Either<Failure, List<Product>>> getBestSellers();
  Future<Either<Failure, List<Product>>> searchProducts(String query);
}
