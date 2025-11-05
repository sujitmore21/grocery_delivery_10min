import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';

class HomeViewModel {
  final ProductBloc productBloc;

  HomeViewModel(this.productBloc);

  void loadCategories() {
    productBloc.add(const LoadCategories());
  }

  void loadBestSellers() {
    productBloc.add(const LoadBestSellers());
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      loadBestSellers();
    } else {
      productBloc.add(SearchProducts(query));
    }
  }

  Stream<ProductState> get productState => productBloc.stream;

  List<Category> getCategories(ProductState state) {
    if (state is CategoriesLoaded) {
      return state.categories;
    }
    return [];
  }

  List<Product> getProducts(ProductState state) {
    if (state is ProductsLoaded) {
      return state.products;
    }
    return [];
  }

  bool isLoading(ProductState state) => state is ProductLoading;
  bool hasError(ProductState state) => state is ProductError;
  String? getErrorMessage(ProductState state) {
    if (state is ProductError) {
      return state.message;
    }
    return null;
  }
}
