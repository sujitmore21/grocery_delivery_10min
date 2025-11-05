import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/constants/api_constants.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Initialize Dio with token if available
  final authLocalDataSource = AuthLocalDataSourceImpl(sharedPreferences);
  final cachedToken = await authLocalDataSource.getCachedToken();

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        if (cachedToken != null) 'Authorization': 'Bearer $cachedToken',
      },
    ),
  );
  getIt.registerLazySingleton<Dio>(() => dio);

  // Data sources
  getIt.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<CartRepository>()),
  );
  getIt.registerLazySingleton<AddressRepository>(() => AddressRepositoryImpl());
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );
}
