# 10 Minute Delivery App - Architecture Documentation

## Overview
This is a Flutter-based delivery app built with Clean Architecture principles, implementing MVVM pattern with BLoC for state management. The app follows a production-ready architecture optimized for scalability and maintainability.

## Architecture Pattern: MVVM + BLoC

### Layer Structure

```
lib/
├── core/                    # Core utilities and constants
│   ├── constants/          # App and API constants
│   ├── errors/             # Error handling and failures
│   ├── theme/              # App theme configuration
│   └── utils/              # Utility functions and DI setup
│
├── domain/                  # Business Logic Layer
│   ├── entities/           # Domain models (pure Dart classes)
│   └── repositories/       # Repository interfaces (abstractions)
│
├── data/                    # Data Layer
│   ├── datasources/        # Remote and local data sources
│   ├── models/             # Data models (with JSON serialization)
│   └── repositories/       # Repository implementations
│
└── presentation/           # Presentation Layer
    ├── bloc/               # BLoC for state management
    │   ├── product/        # Product-related BLoC
    │   └── cart/           # Cart-related BLoC
    ├── viewmodels/         # ViewModels (MVVM pattern)
    ├── screens/            # UI Screens
    └── widgets/             # Reusable widgets
```

## Key Components

### 1. Domain Layer
- **Entities**: Pure Dart classes representing business objects
  - `Product`, `Category`, `CartItem`, `Order`, `Address`, `User`
- **Repositories**: Abstract interfaces defining data operations
  - `ProductRepository`, `CartRepository`, `OrderRepository`, `AddressRepository`

### 2. Data Layer
- **Data Sources**: 
  - Remote: API communication via Dio
  - Local: SharedPreferences for caching
- **Models**: Data transfer objects with JSON serialization
- **Repository Implementations**: Concrete implementations of domain repositories

### 3. Presentation Layer
- **BLoC**: State management using flutter_bloc
  - Events: User actions
  - States: UI states
  - BLoC: Business logic component
- **ViewModels**: Bridge between Views and BLoC
- **Screens**: UI screens
- **Widgets**: Reusable UI components

## State Management Flow

```
User Action → ViewModel → BLoC Event → BLoC → Repository → Data Source
                                                              ↓
UI Update ← BLoC State ← ViewModel ← BLoC Stream ← Repository Response
```

## Dependency Injection

Using `get_it` for dependency injection. All dependencies are registered in `lib/core/utils/injection.dart`.

## Features Implemented

1. **Product Management**
   - Browse categories
   - View products by category
   - Search products
   - View best sellers

2. **Shopping Cart**
   - Add/remove items
   - Update quantities
   - Calculate totals
   - Persistent cart storage

3. **UI/UX**
   - Modern Material Design 3
   - Responsive layouts
   - Loading states
   - Error handling
   - Pull-to-refresh

## API Integration

The app is configured to work with a REST API. Update `ApiConstants.baseUrl` with your backend URL.

### Expected API Endpoints:
- `GET /api/categories` - Get all categories
- `GET /api/products` - Get products (with optional filters)
- `GET /api/products/:id` - Get product details
- `GET /api/search?q=query` - Search products

## Next Steps for Full Implementation

1. **Order Management**
   - Implement order creation
   - Order tracking with real-time updates
   - Order history

2. **Location Services**
   - Get user location
   - Address management
   - Delivery tracking

3. **Authentication**
   - User login/signup
   - Session management
   - Profile management

4. **Real-time Updates**
   - WebSocket integration for order tracking
   - Push notifications

5. **Payment Integration**
   - Payment gateway integration
   - Payment history

## Running the App

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

3. For code generation (if using freezed/json_serializable):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Testing Strategy

- Unit tests for repositories and use cases
- Widget tests for UI components
- BLoC tests for state management
- Integration tests for user flows

## Best Practices

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Dependency Inversion**: Dependencies point inward (domain doesn't depend on data/presentation)
3. **Single Responsibility**: Each class has one reason to change
4. **Error Handling**: Proper error handling with Either type
5. **State Management**: BLoC pattern for predictable state management
6. **Type Safety**: Strong typing throughout the codebase

## Notes

- The app uses local storage (SharedPreferences) for cart persistence
- API endpoints are configurable via `ApiConstants`
- The app is designed to handle offline scenarios (cached categories)
- All UI follows Material Design 3 guidelines

