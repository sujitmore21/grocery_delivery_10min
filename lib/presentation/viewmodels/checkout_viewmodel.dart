import '../../domain/entities/address.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/order/order_event.dart';
import '../bloc/order/order_state.dart';
import '../bloc/address/address_bloc.dart';
import '../bloc/address/address_event.dart';
import '../bloc/address/address_state.dart';

class CheckoutViewModel {
  final OrderBloc orderBloc;
  final AddressBloc addressBloc;

  CheckoutViewModel(this.orderBloc, this.addressBloc);

  void loadAddresses() {
    addressBloc.add(const LoadAddresses());
  }

  void selectAddress(Address address) {
    addressBloc.add(SelectAddress(address));
  }

  void createOrder({
    required List<String> cartItemIds,
    required Address deliveryAddress,
    required String paymentMethod,
    String? couponCode,
    double discountAmount = 0.0,
    double riderTip = 0.0,
  }) {
    orderBloc.add(
      CreateOrder(
        cartItemIds: cartItemIds,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        discountAmount: discountAmount,
        riderTip: riderTip,
      ),
    );
  }

  bool isLoading(OrderState state) => state is OrderLoading;
  bool isOrderCreated(OrderState state) => state is OrderCreated;
  bool hasOrderError(OrderState state) => state is OrderError;
  String? getOrderErrorMessage(OrderState state) {
    if (state is OrderError) {
      return state.message;
    }
    return null;
  }

  bool isAddressLoading(AddressState state) => state is AddressLoading;
  bool hasAddressError(AddressState state) => state is AddressError;
  String? getAddressErrorMessage(AddressState state) {
    if (state is AddressError) {
      return state.message;
    }
    return null;
  }

  List<Address> getAddresses(AddressState state) {
    if (state is AddressesLoaded) {
      return state.addresses;
    }
    return [];
  }

  Address? getSelectedAddress(AddressState state) {
    if (state is AddressesLoaded) {
      return state.selectedAddress;
    }
    return null;
  }
}
