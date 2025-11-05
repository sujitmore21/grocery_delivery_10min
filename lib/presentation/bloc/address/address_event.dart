import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

class LoadDefaultAddress extends AddressEvent {
  const LoadDefaultAddress();
}

class SelectAddress extends AddressEvent {
  final Address address;

  const SelectAddress(this.address);

  @override
  List<Object?> get props => [address];
}
