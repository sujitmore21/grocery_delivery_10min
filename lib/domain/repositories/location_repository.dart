import '../../core/errors/failures.dart';
import 'either.dart';

class LocationData {
  final double latitude;
  final double longitude;
  final String? address;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}

abstract class LocationRepository {
  Future<Either<Failure, LocationData>> getCurrentLocation();
  Future<Either<Failure, String>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  );
  Future<Either<Failure, LocationData>> getCoordinatesFromAddress(
    String address,
  );
  Stream<LocationData> watchLocation();
}
