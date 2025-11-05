import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryId,
    required super.categoryName,
    required super.isAvailable,
    required super.stockQuantity,
    super.discountPrice,
    super.unit,
    super.rating,
    super.reviewCount,
    super.isVegetarian,
    super.isBestSeller,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      categoryName: json['category_name'] ?? json['categoryName'] ?? '',
      isAvailable: json['is_available'] ?? json['isAvailable'] ?? true,
      stockQuantity: json['stock_quantity'] ?? json['stockQuantity'] ?? 0,
      discountPrice: json['discount_price'] != null
          ? (json['discount_price'] as num).toDouble()
          : json['discountPrice'] != null
          ? (json['discountPrice'] as num).toDouble()
          : null,
      unit: json['unit'],
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
      isVegetarian: json['is_vegetarian'] ?? json['isVegetarian'] ?? false,
      isBestSeller: json['is_best_seller'] ?? json['isBestSeller'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_available': isAvailable,
      'stock_quantity': stockQuantity,
      'discount_price': discountPrice,
      'unit': unit,
      'rating': rating,
      'review_count': reviewCount,
      'is_vegetarian': isVegetarian,
      'is_best_seller': isBestSeller,
    };
  }
}
