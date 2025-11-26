import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ten_minute_delivery/presentation/screens/cart_screen.dart';
import 'package:ten_minute_delivery/presentation/screens/checkout_screen.dart';
import 'package:ten_minute_delivery/presentation/screens/home_screen.dart';
import 'package:ten_minute_delivery/presentation/screens/login_screen.dart';
import 'package:ten_minute_delivery/presentation/screens/orders_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/injection.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/address_repository.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/order/order_bloc.dart';
import 'presentation/bloc/address/address_bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await setupDependencyInjection();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(getIt<AuthRepository>())),
        BlocProvider(
          create: (context) => ProductBloc(getIt<ProductRepository>()),
        ),
        BlocProvider(create: (context) => CartBloc(getIt<CartRepository>())),
        BlocProvider(create: (context) => OrderBloc(getIt<OrderRepository>())),
        BlocProvider(
          create: (context) => AddressBloc(getIt<AddressRepository>()),
        ),
        BlocProvider(
          create: (context) => WalletBloc(getIt<WalletRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Fast Delivery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.system,
        navigatorKey: GlobalKey<NavigatorState>(),
        initialRoute: '/',
        routes: {
          // Core delivery app routes. Replace the placeholder SplashScreen with real screens
          // when they exist (LoginScreen, HomeScreen, ProductDetailsScreen, etc).
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/product': (context) =>
              const SplashScreen(), // TODO: replace with ProductDetailsScreen()
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/orders': (context) => const OrdersScreen(),
          '/addresses': (context) =>
              const SplashScreen(), // TODO: replace with AddressScreen()
          '/wallet': (context) =>
              const SplashScreen(), // TODO: replace with WalletScreen()
        },
        onUnknownRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const SplashScreen()),
      ),
    );
  }
}
