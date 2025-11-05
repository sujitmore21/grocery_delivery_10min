import '../../domain/repositories/address_repository.dart';
import '../../domain/repositories/either.dart';
import '../../domain/entities/address.dart';
import '../../core/errors/failures.dart';

class AddressRepositoryImpl implements AddressRepository {
  // Using in-memory storage for now
  static final List<Address> _addresses = [
    const Address(
      id: 'addr_1',
      label: 'Home',
      fullAddress: '123 Main Street, Apartment 4B',
      landmark: 'Near City Mall',
      latitude: 28.6139,
      longitude: 77.2090,
      contactName: 'John Doe',
      contactPhone: '+91 9876543210',
      isDefault: true,
    ),
    const Address(
      id: 'addr_2',
      label: 'Office',
      fullAddress: '456 Business Park, Floor 5',
      landmark: 'Opposite Metro Station',
      latitude: 28.6140,
      longitude: 77.2091,
      contactName: 'John Doe',
      contactPhone: '+91 9876543210',
      isDefault: false,
    ),
  ];

  @override
  Future<Either<Failure, List<Address>>> getAddresses() async {
    try {
      return Either.right(List.from(_addresses));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> getDefaultAddress() async {
    try {
      final defaultAddress = _addresses.firstWhere(
        (a) => a.isDefault,
        orElse: () => _addresses.first,
      );
      return Either.right(defaultAddress);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> addAddress(Address address) async {
    try {
      _addresses.add(address);
      return Either.right(address);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAddress(Address address) async {
    try {
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index >= 0) {
        _addresses[index] = address;
        return Either.right(null);
      }
      return Either.left(ServerFailure('Address not found'));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      _addresses.removeWhere((a) => a.id == addressId);
      return Either.right(null);
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      for (var address in _addresses) {
        if (address.id == addressId) {
          // Update all addresses to set isDefault correctly
          final index = _addresses.indexWhere((a) => a.id == addressId);
          final updatedAddress = Address(
            id: address.id,
            label: address.label,
            fullAddress: address.fullAddress,
            landmark: address.landmark,
            latitude: address.latitude,
            longitude: address.longitude,
            contactName: address.contactName,
            contactPhone: address.contactPhone,
            isDefault: true,
          );
          _addresses[index] = updatedAddress;

          // Set others to false
          for (int i = 0; i < _addresses.length; i++) {
            if (_addresses[i].id != addressId) {
              final addr = _addresses[i];
              _addresses[i] = Address(
                id: addr.id,
                label: addr.label,
                fullAddress: addr.fullAddress,
                landmark: addr.landmark,
                latitude: addr.latitude,
                longitude: addr.longitude,
                contactName: addr.contactName,
                contactPhone: addr.contactPhone,
                isDefault: false,
              );
            }
          }
          return Either.right(null);
        }
      }
      return Either.left(ServerFailure('Address not found'));
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Address>> getCurrentLocationAddress() async {
    try {
      // TODO: Implement actual location service integration
      return getDefaultAddress();
    } catch (e) {
      return Either.left(ServerFailure(e.toString()));
    }
  }
}
