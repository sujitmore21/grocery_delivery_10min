import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends ProductEvent {
  const LoadCategories();
}

class LoadProducts extends ProductEvent {
  final String? categoryId;
  final String? searchQuery;
  final bool? isBestSeller;

  const LoadProducts({this.categoryId, this.searchQuery, this.isBestSeller});

  @override
  List<Object?> get props => [categoryId, searchQuery, isBestSeller];
}

class LoadProductById extends ProductEvent {
  final String productId;

  const LoadProductById(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadBestSellers extends ProductEvent {
  const LoadBestSellers();
}
