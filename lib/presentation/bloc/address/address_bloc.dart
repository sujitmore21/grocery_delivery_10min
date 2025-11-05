import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/address_repository.dart';
import '../../../domain/entities/address.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository addressRepository;

  AddressBloc(this.addressRepository) : super(AddressInitial()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<LoadDefaultAddress>(_onLoadDefaultAddress);
    on<SelectAddress>(_onSelectAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await addressRepository.getAddresses();
    result.fold((failure) => emit(AddressError(failure.message)), (addresses) {
      Address? defaultAddress;
      try {
        defaultAddress = addresses.firstWhere((a) => a.isDefault);
      } catch (e) {
        defaultAddress = addresses.isNotEmpty ? addresses.first : null;
      }
      emit(
        AddressesLoaded(addresses: addresses, selectedAddress: defaultAddress),
      );
    });
  }

  Future<void> _onLoadDefaultAddress(
    LoadDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());
    final result = await addressRepository.getDefaultAddress();
    result.fold(
      (failure) => emit(AddressError(failure.message)),
      (address) =>
          emit(AddressesLoaded(addresses: [address], selectedAddress: address)),
    );
  }

  void _onSelectAddress(SelectAddress event, Emitter<AddressState> emit) {
    if (state is AddressesLoaded) {
      final currentState = state as AddressesLoaded;
      emit(
        AddressesLoaded(
          addresses: currentState.addresses,
          selectedAddress: event.address,
        ),
      );
    }
  }
}
