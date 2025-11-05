import 'package:equatable/equatable.dart';
import '../../../domain/entities/address.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

class AddressLoading extends AddressState {}

class AddressesLoaded extends AddressState {
  final List<Address> addresses;
  final Address? selectedAddress;

  const AddressesLoaded({required this.addresses, this.selectedAddress});

  @override
  List<Object?> get props => [addresses, selectedAddress];
}

class AddressError extends AddressState {
  final String message;

  const AddressError(this.message);

  @override
  List<Object?> get props => [message];
}
