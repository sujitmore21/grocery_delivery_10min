import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/injection.dart';
import 'domain/repositories/product_repository.dart';
import 'domain/repositories/cart_repository.dart';
import 'domain/repositories/order_repository.dart';
import 'domain/repositories/address_repository.dart';
import 'domain/repositories/wallet_repository.dart';
import 'presentation/bloc/product/product_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/order/order_bloc.dart';
import 'presentation/bloc/address/address_bloc.dart';
import 'presentation/bloc/wallet/wallet_bloc.dart';
import 'presentation/screens/main_screen.dart';

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
        title: '10 Minute Delivery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
