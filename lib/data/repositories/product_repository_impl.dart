import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/either.dart';
import '../../core/errors/failures.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/dummy_data.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final categories = await remoteDataSource.getCategories();
      await localDataSource.cacheCategories(categories);
      return Either.right(categories);
    } catch (e) {
      // Try to get from cache
      try {
        final cachedCategories = await localDataSource.getCachedCategories();
        if (cachedCategories.isNotEmpty) {
          return Either.right(cachedCategories);
        }
      } catch (_) {}
      // Return dummy data if API and cache both fail
      return Either.right(DummyData.getDummyCategories());
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    String? searchQuery,
    bool? isBestSeller,
  }) async {
    try {
      final products = await remoteDataSource.getProducts(
        categoryId: categoryId,
        searchQuery: searchQuery,
        isBestSeller: isBestSeller,
      );
      // Return dummy data if API returns empty list
      if (products.isEmpty) {
        return Either.right(
          DummyData.getDummyProducts(
            categoryId: categoryId,
            searchQuery: searchQuery,
            isBestSeller: isBestSeller,
          ),
        );
      }
      return Either.right(products);
    } catch (e) {
      // Return dummy data if API fails
      return Either.right(
        DummyData.getDummyProducts(
          categoryId: categoryId,
          searchQuery: searchQuery,
          isBestSeller: isBestSeller,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final product = await remoteDataSource.getProductById(id);
      return Either.right(product);
    } catch (e) {
      // Try to get from dummy data
      final dummyProduct = DummyData.getDummyProductById(id);
      if (dummyProduct != null) {
        return Either.right(dummyProduct);
      }
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getBestSellers() async {
    try {
      final products = await remoteDataSource.getBestSellers();
      // Return dummy data if API returns empty list
      if (products.isEmpty) {
        return Either.right(DummyData.getDummyProducts(isBestSeller: true));
      }
      return Either.right(products);
    } catch (e) {
      // Return dummy data if API fails
      return Either.right(DummyData.getDummyProducts(isBestSeller: true));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await remoteDataSource.searchProducts(query);
      // Return dummy data if API returns empty list
      if (products.isEmpty) {
        return Either.right(DummyData.getDummyProducts(searchQuery: query));
      }
      return Either.right(products);
    } catch (e) {
      // Return dummy data if API fails
      return Either.right(DummyData.getDummyProducts(searchQuery: query));
    }
  }
}
