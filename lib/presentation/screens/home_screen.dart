import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_state.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/wallet/wallet_bloc.dart';
import '../bloc/wallet/wallet_event.dart';
import '../bloc/wallet/wallet_state.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../widgets/product_card_v2.dart';
import '../widgets/top_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/promotional_banner.dart';
import '../widgets/category_banner_card.dart';
import '../widgets/floating_cart_button.dart';
import '../widgets/category_card.dart';
import 'profile_screen.dart';
import 'product_list_screen.dart';
import 'categories_screen.dart';
import 'add_money_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeViewModel viewModel;
  final TextEditingController searchController = TextEditingController();
  static const String userId = 'user_1'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    viewModel = HomeViewModel(context.read<ProductBloc>());
    viewModel.loadCategories();
    viewModel.loadBestSellers();
    // Load wallet balance
    context.read<WalletBloc>().add(LoadWallet(userId));
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B761),
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
                      viewModel.loadCategories();
                      viewModel.loadBestSellers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = viewModel.getCategories(state);
          final products = viewModel.getProducts(state);

          final categoryNames = [
            'All',
            ...categories.map((c) => c.name).toList(),
          ];

          return Stack(
            children: [
              Column(
                children: [
                  // Top Bar
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, walletState) {
                      final walletBalance = walletState is WalletLoaded
                          ? walletState.wallet.balance
                          : walletState is MoneyAdded
                          ? walletState.wallet.balance
                          : 0.0;

                      return TopBar(
                        walletBalance: '₹${walletBalance.toStringAsFixed(0)}',
                        onWalletTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMoneyScreen(userId: userId),
                            ),
                          );
                          // Reload wallet after returning from add money screen
                          if (result != null) {
                            context.read<WalletBloc>().add(LoadWallet(userId));
                          }
                        },
                        onProfileTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        onLocationTap: () {},
                      );
                    },
                  ),
                  // Search Bar
                  Container(
                    color: const Color(0xFF00B761),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: (query) {
                          viewModel.searchProducts(query);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search "20000 mah powerbank"',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                          ),
                          suffixIcon: Icon(
                            Icons.mic,
                            color: Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black87),
                      ),
                    ),
                  ),
                  // Category Tabs
                  CategoryTabs(
                    categories: categoryNames,
                    onCategorySelected: (category) {
                      // Handle category selection
                    },
                  ),
                  // Content
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: RefreshIndicator(
                        onRefresh: () async {
                          viewModel.loadCategories();
                          viewModel.loadBestSellers();
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Promotional Banner
                              PromotionalBanner(
                                title: 'LOWEST PRICES EVER',
                                subtitle: 'HOUSEFULL SALE',
                                dateRange: '31ST OCT, 2025 - 7TH NOV, 2025',
                                imageUrl:
                                    'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=1200',
                              ),
                              const SizedBox(height: 8),
                              // Category Banner Cards
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  children: [
                                    CategoryBannerCard(
                                      title: 'AIR PURIFIERS',
                                      discount: 'UP TO 70% OFF',
                                      subtitle: 'Winter Specials',
                                      imageUrls: [
                                        'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800',
                                      ],
                                    ),
                                    CategoryBannerCard(
                                      title: 'BODY LOTIONS',
                                      discount: 'UP TO 55% OFF',
                                      subtitle: 'Self Care & More',
                                      imageUrls: [
                                        'https://images.unsplash.com/photo-1556229010-6c3f2c9ca5f8?w=800',
                                      ],
                                    ),
                                    CategoryBannerCard(
                                      title: 'RICE',
                                      discount: 'UP TO 35% OFF',
                                      subtitle: 'Kitchen Essentials',
                                      imageUrls: [
                                        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800',
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Categories Section
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                color: Colors.white,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Shop by Category',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Navigate to categories screen
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const CategoriesScreen(),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'See All',
                                              style: TextStyle(
                                                color: Color(0xFF00B761),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                        itemCount: categories.length,
                                        itemBuilder: (context, index) {
                                          final category = categories[index];
                                          return CategoryCard(
                                            category: category,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ProductListScreen(
                                                        categoryId: category.id,
                                                        categoryName:
                                                            category.name,
                                                      ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Section Header with Dark Background
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                color: const Color(0xFF00B761),
                                child: Row(
                                  children: [
                                    const Text(
                                      '⚡',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'LOWEST PRICES EVER',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Text(
                                      ' ⚡',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                              ),
                              // Products List with White Background
                              Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(
                                  top: 12,
                                  bottom: 12,
                                ),
                                child: SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, index) {
                                      final product = products[index];
                                      final cartViewModel = CartViewModel(
                                        context.read<CartBloc>(),
                                      );
                                      return ProductCardV2(
                                        product: product,
                                        deliveryTime: '15 MINS',
                                        onAddToCart: () {
                                          cartViewModel.addToCart(product, 1);

                                          final scaffold = ScaffoldMessenger.of(
                                            context,
                                          );
                                          const int totalSeconds = 900;
                                          void showCountdown(int remaining) {
                                            if (remaining <= 0) {
                                              scaffold.showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    '${product.name} added to cart',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                              return;
                                            }

                                            scaffold.showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  '${product.name} added to cart. Closing in ${remaining}s',
                                                ),
                                                duration: const Duration(
                                                  seconds: 1,
                                                ),
                                                backgroundColor: Colors.green,
                                              ),
                                            );

                                            Future.delayed(
                                              const Duration(seconds: 1),
                                              () {
                                                showCountdown(remaining - 1);
                                              },
                                            );
                                          }

                                          showCountdown(totalSeconds);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 100,
                              ), // Space for floating button
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Floating Cart Button
              const FloatingCartButton(),
            ],
          );
        },
      ),
    );
  }
}
