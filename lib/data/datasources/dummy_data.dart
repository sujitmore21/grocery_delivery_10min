import '../models/category_model.dart';
import '../models/product_model.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/address.dart';

class DummyData {
  static List<Category> getDummyCategories() {
    return [
      const CategoryModel(
        id: 'cat_1',
        name: 'Fruits & Vegetables',
        imageUrl:
            'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
        productCount: 25,
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_2',
        name: 'Dairy & Eggs',
        imageUrl:
            'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
        productCount: 18,
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_3',
        name: 'Beverages',
        imageUrl:
            'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400',
        productCount: 32,
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_4',
        name: 'Snacks',
        imageUrl:
            'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=400',
        productCount: 45,
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_5',
        name: 'Bakery',
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
        productCount: 15,
        isActive: true,
      ),
      const CategoryModel(
        id: 'cat_6',
        name: 'Frozen Foods',
        imageUrl:
            'https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=400',
        productCount: 28,
        isActive: true,
      ),
    ];
  }

  static List<Product> getDummyProducts({
    String? categoryId,
    String? searchQuery,
    bool? isBestSeller,
  }) {
    List<Product> allProducts = _getAllDummyProducts();

    // Filter by category
    if (categoryId != null && categoryId.isNotEmpty) {
      allProducts = allProducts
          .where((p) => p.categoryId == categoryId)
          .toList();
    }

    // Filter by search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      allProducts = allProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query),
          )
          .toList();
    }

    // Filter best sellers
    if (isBestSeller == true) {
      allProducts = allProducts.where((p) => p.isBestSeller).toList();
    }

    return allProducts;
  }

  static Product? getDummyProductById(String id) {
    try {
      return _getAllDummyProducts().firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Product> _getAllDummyProducts() {
    return [
      // Fruits & Vegetables
      const ProductModel(
        id: 'prod_1',
        name: 'Fresh Apples',
        description: 'Fresh, crisp red apples - 1kg',
        price: 149.0,
        discountPrice: 119.0,
        imageUrl:
            'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
        categoryId: 'cat_1',
        categoryName: 'Fruits & Vegetables',
        isAvailable: true,
        stockQuantity: 50,
        unit: '1kg',
        rating: 4.5,
        reviewCount: 128,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_2',
        name: 'Bananas',
        description: 'Fresh yellow bananas - 1 dozen',
        price: 59.0,
        imageUrl:
            'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
        categoryId: 'cat_1',
        categoryName: 'Fruits & Vegetables',
        isAvailable: true,
        stockQuantity: 75,
        unit: '1 dozen',
        rating: 4.3,
        reviewCount: 89,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_3',
        name: 'Fresh Tomatoes',
        description: 'Red ripe tomatoes - 500g',
        price: 45.0,
        imageUrl:
            'https://images.unsplash.com/photo-1546470427-e26264be0af9?w=400',
        categoryId: 'cat_1',
        categoryName: 'Fruits & Vegetables',
        isAvailable: true,
        stockQuantity: 60,
        unit: '500g',
        rating: 4.2,
        reviewCount: 67,
        isVegetarian: true,
        isBestSeller: false,
      ),
      const ProductModel(
        id: 'prod_4',
        name: 'Fresh Spinach',
        description: 'Organic fresh spinach leaves - 250g',
        price: 39.0,
        imageUrl:
            'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
        categoryId: 'cat_1',
        categoryName: 'Fruits & Vegetables',
        isAvailable: true,
        stockQuantity: 40,
        unit: '250g',
        rating: 4.4,
        reviewCount: 45,
        isVegetarian: true,
        isBestSeller: false,
      ),

      // Dairy & Eggs
      const ProductModel(
        id: 'prod_5',
        name: 'Fresh Milk',
        description: 'Pure cow milk - 1 liter',
        price: 65.0,
        imageUrl:
            'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
        categoryId: 'cat_2',
        categoryName: 'Dairy & Eggs',
        isAvailable: true,
        stockQuantity: 100,
        unit: '1L',
        rating: 4.6,
        reviewCount: 234,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_6',
        name: 'Farm Fresh Eggs',
        description: 'Organic farm eggs - 12 pieces',
        price: 95.0,
        discountPrice: 79.0,
        imageUrl:
            'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400',
        categoryId: 'cat_2',
        categoryName: 'Dairy & Eggs',
        isAvailable: true,
        stockQuantity: 80,
        unit: '12 pieces',
        rating: 4.7,
        reviewCount: 189,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_7',
        name: 'Butter',
        description: 'Fresh unsalted butter - 200g',
        price: 85.0,
        imageUrl:
            'https://images.unsplash.com/photo-1618164436196-4471650c1f5f?w=400',
        categoryId: 'cat_2',
        categoryName: 'Dairy & Eggs',
        isAvailable: true,
        stockQuantity: 55,
        unit: '200g',
        rating: 4.5,
        reviewCount: 112,
        isVegetarian: true,
        isBestSeller: false,
      ),
      const ProductModel(
        id: 'prod_8',
        name: 'Yogurt',
        description: 'Plain Greek yogurt - 500g',
        price: 75.0,
        imageUrl:
            'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
        categoryId: 'cat_2',
        categoryName: 'Dairy & Eggs',
        isAvailable: true,
        stockQuantity: 65,
        unit: '500g',
        rating: 4.4,
        reviewCount: 98,
        isVegetarian: true,
        isBestSeller: false,
      ),

      // Beverages
      const ProductModel(
        id: 'prod_9',
        name: 'Orange Juice',
        description: 'Fresh squeezed orange juice - 1 liter',
        price: 129.0,
        discountPrice: 99.0,
        imageUrl:
            'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
        categoryId: 'cat_3',
        categoryName: 'Beverages',
        isAvailable: true,
        stockQuantity: 45,
        unit: '1L',
        rating: 4.5,
        reviewCount: 156,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_10',
        name: 'Coffee Beans',
        description: 'Premium Arabica coffee beans - 500g',
        price: 499.0,
        discountPrice: 399.0,
        imageUrl:
            'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
        categoryId: 'cat_3',
        categoryName: 'Beverages',
        isAvailable: true,
        stockQuantity: 30,
        unit: '500g',
        rating: 4.8,
        reviewCount: 203,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_11',
        name: 'Green Tea',
        description: 'Organic green tea leaves - 100g',
        price: 199.0,
        imageUrl:
            'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=400',
        categoryId: 'cat_3',
        categoryName: 'Beverages',
        isAvailable: true,
        stockQuantity: 50,
        unit: '100g',
        rating: 4.6,
        reviewCount: 145,
        isVegetarian: true,
        isBestSeller: false,
      ),
      const ProductModel(
        id: 'prod_12',
        name: 'Mineral Water',
        description: 'Natural mineral water - 1 liter pack of 6',
        price: 120.0,
        imageUrl:
            'https://images.unsplash.com/photo-1523362628745-0c100150b504?w=400',
        categoryId: 'cat_3',
        categoryName: 'Beverages',
        isAvailable: true,
        stockQuantity: 90,
        unit: '6 x 1L',
        rating: 4.3,
        reviewCount: 78,
        isVegetarian: true,
        isBestSeller: false,
      ),

      // Snacks
      const ProductModel(
        id: 'prod_13',
        name: 'Potato Chips',
        description: 'Crunchy salted potato chips - 150g',
        price: 55.0,
        imageUrl:
            'https://images.unsplash.com/photo-1599490659213-e2b9527bd087?w=400',
        categoryId: 'cat_4',
        categoryName: 'Snacks',
        isAvailable: true,
        stockQuantity: 120,
        unit: '150g',
        rating: 4.4,
        reviewCount: 267,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_14',
        name: 'Dark Chocolate',
        description: 'Premium dark chocolate bar - 100g',
        price: 149.0,
        discountPrice: 129.0,
        imageUrl:
            'https://images.unsplash.com/photo-1511381939415-e44015466834?w=400',
        categoryId: 'cat_4',
        categoryName: 'Snacks',
        isAvailable: true,
        stockQuantity: 70,
        unit: '100g',
        rating: 4.7,
        reviewCount: 198,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_15',
        name: 'Mixed Nuts',
        description: 'Roasted mixed nuts - 200g',
        price: 299.0,
        imageUrl:
            'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400',
        categoryId: 'cat_4',
        categoryName: 'Snacks',
        isAvailable: true,
        stockQuantity: 45,
        unit: '200g',
        rating: 4.6,
        reviewCount: 134,
        isVegetarian: true,
        isBestSeller: false,
      ),

      // Bakery
      const ProductModel(
        id: 'prod_16',
        name: 'Fresh Bread',
        description: 'Soft white bread - 400g',
        price: 45.0,
        imageUrl:
            'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
        categoryId: 'cat_5',
        categoryName: 'Bakery',
        isAvailable: true,
        stockQuantity: 60,
        unit: '400g',
        rating: 4.3,
        reviewCount: 89,
        isVegetarian: true,
        isBestSeller: true,
      ),
      const ProductModel(
        id: 'prod_17',
        name: 'Croissant',
        description: 'Buttery croissants - pack of 4',
        price: 129.0,
        imageUrl:
            'https://images.unsplash.com/photo-1555507036-ab1f4038808a?w=400',
        categoryId: 'cat_5',
        categoryName: 'Bakery',
        isAvailable: true,
        stockQuantity: 35,
        unit: '4 pieces',
        rating: 4.5,
        reviewCount: 112,
        isVegetarian: true,
        isBestSeller: false,
      ),

      // Frozen Foods
      const ProductModel(
        id: 'prod_18',
        name: 'Frozen Peas',
        description: 'Fresh frozen peas - 500g',
        price: 85.0,
        imageUrl:
            'https://images.unsplash.com/photo-1593113598332-cd288d649433?w=400',
        categoryId: 'cat_6',
        categoryName: 'Frozen Foods',
        isAvailable: true,
        stockQuantity: 55,
        unit: '500g',
        rating: 4.2,
        reviewCount: 67,
        isVegetarian: true,
        isBestSeller: false,
      ),
      const ProductModel(
        id: 'prod_19',
        name: 'Ice Cream',
        description: 'Vanilla ice cream - 500ml',
        price: 149.0,
        discountPrice: 119.0,
        imageUrl:
            'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=400',
        categoryId: 'cat_6',
        categoryName: 'Frozen Foods',
        isAvailable: true,
        stockQuantity: 40,
        unit: '500ml',
        rating: 4.8,
        reviewCount: 223,
        isVegetarian: true,
        isBestSeller: true,
      ),
    ];
  }

  static User getDummyUser() {
    return User(
      id: 'user_1',
      name: 'John Doe',
      email: 'john.doe@example.com',
      phone: '+91 9876543210',
      profileImageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      createdAt: DateTime(2024, 1, 1),
    );
  }

  static List<Order> getDummyOrders() {
    final products = _getAllDummyProducts();
    final address = const Address(
      id: 'addr_1',
      label: 'Home',
      fullAddress: '123 Main Street, Apartment 4B',
      landmark: 'Near City Mall',
      latitude: 28.6139,
      longitude: 77.2090,
      contactName: 'John Doe',
      contactPhone: '+91 9876543210',
      isDefault: true,
    );

    return [
      // Active order
      Order(
        id: 'order_1',
        orderNumber: 'ORD-2024-001',
        items: [
          CartItem(
            productId: products[0].id,
            product: products[0],
            quantity: 2,
          ),
          CartItem(
            productId: products[4].id,
            product: products[4],
            quantity: 1,
          ),
        ],
        subtotal: 363.0,
        deliveryFee: 30.0,
        totalAmount: 393.0,
        deliveryAddress: address,
        status: OrderStatus.outForDelivery,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(minutes: 15)),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 5)),
        deliveryPartnerId: 'delivery_1',
        deliveryPartnerName: 'Rajesh Kumar',
        deliveryPartnerLatitude: 28.6140,
        deliveryPartnerLongitude: 77.2091,
      ),
      // Preparing order
      Order(
        id: 'order_2',
        orderNumber: 'ORD-2025-002',
        items: [
          CartItem(
            productId: products[8].id,
            product: products[8],
            quantity: 1,
          ),
          CartItem(
            productId: products[13].id,
            product: products[13],
            quantity: 2,
          ),
        ],
        subtotal: 377.0,
        deliveryFee: 30.0,
        totalAmount: 407.0,
        deliveryAddress: address,
        status: OrderStatus.preparing,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(minutes: 5)),
        estimatedDeliveryTime: DateTime.now().add(const Duration(minutes: 10)),
      ),

      // Delivered order
      Order(
        id: 'order_3',
        orderNumber: 'ORD-2025-003',
        items: [
          CartItem(
            productId: products[5].id,
            product: products[5],
            quantity: 1,
          ),
        ],
        subtotal: 79.0,
        deliveryFee: 30.0,
        totalAmount: 109.0,
        deliveryAddress: address,
        status: OrderStatus.delivered,
        paymentStatus: PaymentStatus.paid,
        orderDate: DateTime.now().subtract(const Duration(days: 1)),
        estimatedDeliveryTime: DateTime.now().subtract(
          const Duration(hours: 23),
        ),
        actualDeliveryTime: DateTime.now().subtract(
          const Duration(hours: 23, minutes: 50),
        ),
        deliveryPartnerId: 'delivery_2',
        deliveryPartnerName: 'Amit Sharma',
      ),
    ];
  }

  static Order? getDummyOrderById(String id) {
    try {
      return getDummyOrders().firstWhere((o) => o.id == id);
    } catch (e) {
      return null;
    }
  }
}
