# 10 Minute Delivery App 🚀

A production-ready Flutter application for ultra-fast delivery services (similar to Blinkit, Zepto, or Instamart), built with Clean Architecture, MVVM pattern, and BLoC state management.

## 🏗️ Architecture

The app follows **Clean Architecture** principles with **MVVM + BLoC** pattern:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Data sources, models, and repository implementations
- **Presentation Layer**: UI, BLoC, and ViewModels

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed architecture documentation.

## ✨ Features

### Implemented
- ✅ Browse products by categories
- ✅ Search products
- ✅ Shopping cart with persistent storage
- ✅ Product details with images
- ✅ Best sellers section
- ✅ Modern Material Design 3 UI
- ✅ Pull-to-refresh
- ✅ Error handling and loading states
- ✅ Offline support (cached categories)

### Planned
- 🔄 Order creation and tracking
- 🔄 Real-time delivery tracking
- 🔄 Address management
- 🔄 User authentication
- 🔄 Payment integration
- 🔄 Push notifications

## 📦 Tech Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: BLoC (flutter_bloc)
- **Architecture**: MVVM + Clean Architecture
- **Dependency Injection**: get_it
- **Networking**: Dio + HTTP
- **Local Storage**: SharedPreferences
- **Image Loading**: cached_network_image
- **Location**: geolocator, geocoding
- **Real-time**: web_socket_channel

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator / Physical device

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ten_minute_delivery
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API endpoints**
   - Update `lib/core/constants/api_constants.dart` with your backend URL
   - Modify `ApiConstants.baseUrl` to point to your API server

4. **Run the app**
   ```bash
   flutter run
   ```

### Code Generation (Optional)

If you plan to use code generation for models:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📱 App Structure

```
lib/
├── core/                    # Core utilities
│   ├── constants/          # App constants
│   ├── errors/             # Error handling
│   ├── theme/              # App theme
│   └── utils/              # Utilities & DI
│
├── domain/                  # Business Logic
│   ├── entities/           # Domain models
│   └── repositories/       # Repository interfaces
│
├── data/                    # Data Layer
│   ├── datasources/       # API & Local data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
│
└── presentation/           # UI Layer
    ├── bloc/               # State management
    ├── viewmodels/         # ViewModels
    ├── screens/            # UI Screens
    └── widgets/             # Reusable widgets
```

## 🔧 Configuration

### API Configuration
Update `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com';
```

### App Constants
Customize app settings in `lib/core/constants/app_constants.dart`:
- Minimum order value
- Delivery time
- Delivery fee
- Maximum quantity per item

## 🎨 UI/UX

The app features:
- Modern Material Design 3
- Responsive layouts
- Smooth animations
- Loading states
- Error handling with retry
- Pull-to-refresh
- Empty states

## 📝 API Endpoints Expected

The app expects the following REST API endpoints:

- `GET /api/categories` - Get all categories
- `GET /api/products` - Get products (supports filters: category_id, search, best_seller)
- `GET /api/products/:id` - Get product details
- `GET /api/search?q=query` - Search products

### Response Format
```json
{
  "data": [
    {
      "id": "product_id",
      "name": "Product Name",
      "description": "Product description",
      "price": 99.0,
      "image_url": "https://...",
      "category_id": "category_id",
      "category_name": "Category Name",
      "is_available": true,
      "stock_quantity": 100,
      "discount_price": 79.0,
      "unit": "500g",
      "rating": 4.5,
      "review_count": 120,
      "is_vegetarian": true,
      "is_best_seller": false
    }
  ]
}
```

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📄 License

This project is open source and available under the MIT License.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

Built with ❤️ using Flutter
