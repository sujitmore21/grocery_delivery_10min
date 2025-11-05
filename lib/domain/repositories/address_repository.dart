import '../entities/address.dart';
import '../../core/errors/failures.dart';
import 'either.dart';

abstract class AddressRepository {
  Future<Either<Failure, List<Address>>> getAddresses();
  Future<Either<Failure, Address>> getDefaultAddress();
  Future<Either<Failure, Address>> addAddress(Address address);
  Future<Either<Failure, void>> updateAddress(Address address);
  Future<Either<Failure, void>> deleteAddress(String addressId);
  Future<Either<Failure, void>> setDefaultAddress(String addressId);
  Future<Either<Failure, Address>> getCurrentLocationAddress();
}
