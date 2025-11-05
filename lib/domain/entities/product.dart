import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;
  final String categoryName;
  final bool isAvailable;
  final int stockQuantity;
  final double? discountPrice;
  final String? unit; // e.g., "500g", "1kg", "1 piece"
  final double rating;
  final int reviewCount;
  final bool isVegetarian;
  final bool isBestSeller;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
    required this.categoryName,
    required this.isAvailable,
    required this.stockQuantity,
    this.discountPrice,
    this.unit,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isVegetarian = false,
    this.isBestSeller = false,
  });

  double get finalPrice => discountPrice ?? price;
  double get discountPercentage => discountPrice != null
      ? ((price - discountPrice!) / price * 100).roundToDouble()
      : 0.0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    imageUrl,
    categoryId,
    categoryName,
    isAvailable,
    stockQuantity,
    discountPrice,
    unit,
    rating,
    reviewCount,
    isVegetarian,
    isBestSeller,
  ];
}
