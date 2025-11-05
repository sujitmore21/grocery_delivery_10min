import '../../domain/entities/category.dart';
import '../models/category_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

abstract class ProductLocalDataSource {
  Future<List<Category>> getCachedCategories();
  Future<void> cacheCategories(List<Category> categories);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String cachedCategoriesKey = 'CACHED_CATEGORIES';

  ProductLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<Category>> getCachedCategories() async {
    final jsonString = sharedPreferences.getString(cachedCategoriesKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheCategories(List<Category> categories) async {
    final jsonList = categories.map((cat) {
      if (cat is CategoryModel) {
        return cat.toJson();
      }
      return {
        'id': cat.id,
        'name': cat.name,
        'image_url': cat.imageUrl,
        'product_count': cat.productCount,
        'is_active': cat.isActive,
      };
    }).toList();
    await sharedPreferences.setString(
      cachedCategoriesKey,
      json.encode(jsonList),
    );
  }
}
