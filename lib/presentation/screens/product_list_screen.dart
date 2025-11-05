import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ProductListScreen({super.key, this.categoryId, this.categoryName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(context.read<ProductBloc>());
    context.read<ProductBloc>().add(
      LoadProducts(categoryId: widget.categoryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName ?? 'All Products')),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (viewModel.isLoading(state)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError(state)) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.getErrorMessage(state) ?? 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductBloc>().add(
                        LoadProducts(categoryId: widget.categoryId),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final products = viewModel.getProducts(state);

          if (products.isEmpty) {
            return const Center(child: Text('No products found'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ProductBloc>().add(
                LoadProducts(categoryId: widget.categoryId),
              );
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final cartViewModel = CartViewModel(context.read<CartBloc>());
                return ProductCard(
                  product: product,
                  onTap: () {
                    // Navigate to product detail
                  },
                  onAddToCart: () {
                    cartViewModel.addToCart(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to cart'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
