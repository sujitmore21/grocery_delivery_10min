import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final int productCount;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.productCount,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, productCount, isActive];
}
