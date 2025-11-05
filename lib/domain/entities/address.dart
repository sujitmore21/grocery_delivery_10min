import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String id;
  final String label; // e.g., "Home", "Office"
  final String fullAddress;
  final String landmark;
  final double latitude;
  final double longitude;
  final String contactName;
  final String contactPhone;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    required this.contactName,
    required this.contactPhone,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [
    id,
    label,
    fullAddress,
    landmark,
    latitude,
    longitude,
    contactName,
    contactPhone,
    isDefault,
  ];
}
