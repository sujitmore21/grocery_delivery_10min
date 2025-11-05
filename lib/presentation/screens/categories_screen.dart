import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/top_bar.dart';
import '../widgets/category_banner_card.dart';
import 'product_list_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late HomeViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(context.read<ProductBloc>());
    viewModel.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              const TopBar(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    viewModel.loadCategories();
                  },
                  child: viewModel.isLoading(state)
                      ? const Center(child: CircularProgressIndicator())
                      : viewModel.hasError(state)
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                viewModel.getErrorMessage(state) ??
                                    'An error occurred',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => viewModel.loadCategories(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _buildCategoriesGrid(state),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesGrid(ProductState state) {
    final categories = viewModel.getCategories(state);

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.grid_view_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No categories available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return CategoryBannerCard(
          title: category.name,
          discount: '${category.productCount} ITEMS',
          subtitle: 'Browse products',
          imageUrls: [category.imageUrl],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductListScreen(
                  categoryId: category.id,
                  categoryName: category.name,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
