import 'package:dio/dio.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/category.dart';
import '../../../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts({
    String? categoryId,
    String? searchQuery,
    bool? isBestSeller,
  });
  Future<Product> getProductById(String id);
  Future<List<Product>> getBestSellers();
  Future<List<Product>> searchProducts(String query);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await dio.get(ApiConstants.categories);
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  @override
  Future<List<Product>> getProducts({
    String? categoryId,
    String? searchQuery,
    bool? isBestSeller,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['category_id'] = categoryId;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (isBestSeller != null) queryParams['best_seller'] = isBestSeller;

      final response = await dio.get(
        ApiConstants.products,
        queryParameters: queryParams,
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  @override
  Future<Product> getProductById(String id) async {
    try {
      final response = await dio.get('${ApiConstants.products}/$id');
      final data = response.data['data'] ?? response.data;
      return ProductModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }

  @override
  Future<List<Product>> getBestSellers() async {
    return getProducts(isBestSeller: true);
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await dio.get(
        ApiConstants.search,
        queryParameters: {'q': query},
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
}
