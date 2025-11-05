import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';
import '../bloc/order/order_bloc.dart';
import '../bloc/order/order_state.dart';
import '../bloc/address/address_bloc.dart';
import '../bloc/address/address_state.dart';
import '../bloc/wallet/wallet_bloc.dart';
import '../bloc/wallet/wallet_event.dart';
import '../bloc/wallet/wallet_state.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/checkout_viewmodel.dart';
import '../../domain/entities/address.dart';
import '../../core/constants/app_constants.dart';
import 'delivery_tracking_screen.dart';
import 'add_money_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late CartViewModel cartViewModel;
  late CheckoutViewModel checkoutViewModel;
  String selectedPaymentMethod = 'Cash on Delivery';
  final List<String> paymentMethods = [
    'Cash on Delivery',
    'UPI',
    'Credit Card',
    'Debit Card',
    'Wallet',
  ];

  static const String userId = 'user_1'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    cartViewModel = CartViewModel(context.read<CartBloc>());
    checkoutViewModel = CheckoutViewModel(
      context.read<OrderBloc>(),
      context.read<AddressBloc>(),
    );
    checkoutViewModel.loadAddresses();
    cartViewModel.loadCart();
    context.read<WalletBloc>().add(LoadWallet(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderCreated) {
                // Clear cart and navigate to tracking
                cartViewModel.clearCart();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeliveryTrackingScreen(),
                  ),
                  (route) => route.isFirst,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Order placed successfully! Order #${state.order.orderNumber}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is OrderError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartViewModel.isLoading(cartState)) {
              return const Center(child: CircularProgressIndicator());
            }

            if (cartViewModel.hasError(cartState)) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cartViewModel.getErrorMessage(cartState) ??
                          'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => cartViewModel.loadCart(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final items = cartViewModel.getCartItems(cartState);
            final subtotal = cartViewModel.getSubtotal(cartState);
            final platformCharge = cartViewModel.getPlatformCharge(cartState);
            final deliveryCharge = cartViewModel.getDeliveryCharge(cartState);
            final tax = cartViewModel.getTax(cartState);
            final grandTotal = cartViewModel.getGrandTotal(cartState);

            if (items.isEmpty) {
              return const Center(child: Text('Your cart is empty'));
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Section
                  _buildSectionHeader('Order Summary'),
                  _buildOrderItems(items),

                  // Delivery Address Section
                  _buildSectionHeader('Delivery Address'),
                  BlocBuilder<AddressBloc, AddressState>(
                    builder: (context, addressState) {
                      if (checkoutViewModel.isAddressLoading(addressState)) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (checkoutViewModel.hasAddressError(addressState)) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                checkoutViewModel.getAddressErrorMessage(
                                      addressState,
                                    ) ??
                                    'Error loading addresses',
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    checkoutViewModel.loadAddresses(),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      final addresses = checkoutViewModel.getAddresses(
                        addressState,
                      );
                      final selectedAddress = checkoutViewModel
                          .getSelectedAddress(addressState);

                      if (addresses.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Text('No addresses found'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to add address screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Add address feature coming soon',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Add Address'),
                              ),
                            ],
                          ),
                        );
                      }

                      return _buildAddressSelection(addresses, selectedAddress);
                    },
                  ),

                  // Payment Method Section
                  _buildSectionHeader('Payment Method'),
                  BlocBuilder<WalletBloc, WalletState>(
                    builder: (context, walletState) {
                      final walletBalance = walletState is WalletLoaded
                          ? walletState.wallet.balance
                          : walletState is MoneyAdded
                          ? walletState.wallet.balance
                          : 0.0;
                      return _buildPaymentMethodSelection(
                        walletBalance,
                        grandTotal,
                      );
                    },
                  ),

                  // Price Breakdown Section
                  _buildSectionHeader('Price Breakdown'),
                  _buildPriceBreakdown(
                    subtotal,
                    platformCharge,
                    deliveryCharge,
                    tax,
                    grandTotal,
                  ),

                  // Place Order Button
                  BlocBuilder<OrderBloc, OrderState>(
                    builder: (context, orderState) {
                      final isLoading = checkoutViewModel.isLoading(orderState);
                      final selectedAddress =
                          BlocProvider.of<AddressBloc>(context).state
                              is AddressesLoaded
                          ? checkoutViewModel.getSelectedAddress(
                              BlocProvider.of<AddressBloc>(context).state,
                            )
                          : null;

                      final walletState = context.watch<WalletBloc>().state;
                      final walletBalance = walletState is WalletLoaded
                          ? walletState.wallet.balance
                          : walletState is MoneyAdded
                          ? walletState.wallet.balance
                          : 0.0;

                      final canPlaceOrder =
                          selectedAddress != null &&
                          (selectedPaymentMethod != 'Wallet' ||
                              walletBalance >= grandTotal);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (selectedPaymentMethod == 'Wallet' &&
                                walletBalance < grandTotal) ...[
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Insufficient balance. Add ₹${(grandTotal - walletBalance).toStringAsFixed(0)} more',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.orange.shade900,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                AddMoneyScreen(userId: userId),
                                          ),
                                        );
                                        if (result != null) {
                                          context.read<WalletBloc>().add(
                                            LoadWallet(userId),
                                          );
                                        }
                                      },
                                      child: const Text('Add Money'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: (isLoading || !canPlaceOrder)
                                    ? null
                                    : () {
                                        final cartItemIds = items
                                            .map((item) => item.productId)
                                            .toList();

                                        // Deduct from wallet if wallet payment
                                        if (selectedPaymentMethod == 'Wallet') {
                                          context.read<WalletBloc>().add(
                                            DeductMoney(
                                              userId: userId,
                                              amount: grandTotal,
                                            ),
                                          );
                                        }

                                        checkoutViewModel.createOrder(
                                          cartItemIds: cartItemIds,
                                          deliveryAddress: selectedAddress,
                                          paymentMethod: selectedPaymentMethod,
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Place Order - ₹${grandTotal.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderItems(List items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...items.map<Widget>((item) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.product.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qty: ${item.quantity} × ₹${item.product.finalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAddressSelection(
    List<Address> addresses,
    Address? selectedAddress,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: addresses.map((address) {
          final isSelected = selectedAddress?.id == address.id;
          return InkWell(
            onTap: () => checkoutViewModel.selectAddress(address),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 4,
                  ),
                ),
                color: isSelected ? Colors.green.withOpacity(0.05) : null,
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address.label,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.green : Colors.black,
                              ),
                            ),
                            if (address.isDefault) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address.fullAddress,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (address.landmark.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Near ${address.landmark}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          '${address.contactName} • ${address.contactPhone}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodSelection(double walletBalance, double grandTotal) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethod == method;
          final isWallet = method == 'Wallet';
          final hasInsufficientBalance = isWallet && walletBalance < grandTotal;

          return InkWell(
            onTap: () {
              setState(() {
                selectedPaymentMethod = method;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSelected ? Colors.green : Colors.transparent,
                    width: 4,
                  ),
                ),
                color: isSelected ? Colors.green.withOpacity(0.05) : null,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              method,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? Colors.green : Colors.black,
                              ),
                            ),
                            if (isWallet) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                  ),
                                ),
                                child: Text(
                                  '₹${walletBalance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasInsufficientBalance)
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                    ],
                  ),
                  if (isWallet && hasInsufficientBalance) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Balance: ₹${walletBalance.toStringAsFixed(0)} | Required: ₹${grandTotal.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddMoneyScreen(userId: userId),
                                ),
                              );
                              if (result != null) {
                                context.read<WalletBloc>().add(
                                  LoadWallet(userId),
                                );
                              }
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Add Money',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPriceBreakdown(
    double subtotal,
    double platformCharge,
    double deliveryCharge,
    double tax,
    double grandTotal,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChargeRow('Subtotal', subtotal),
          const SizedBox(height: 8),
          _buildChargeRow(
            'Platform Charge',
            platformCharge,
            showInfo: true,
            infoText: '${AppConstants.platformChargePercent}% of subtotal',
          ),
          const SizedBox(height: 8),
          _buildChargeRow(
            'Delivery Charge',
            deliveryCharge,
            showInfo: deliveryCharge == 0,
            infoText: deliveryCharge == 0 ? 'Free delivery' : null,
          ),
          const SizedBox(height: 8),
          _buildChargeRow(
            'Tax (GST)',
            tax,
            showInfo: true,
            infoText: '${AppConstants.taxRate}% of subtotal',
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChargeRow(
    String label,
    double amount, {
    bool showInfo = false,
    String? infoText,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            if (showInfo && infoText != null) ...[
              const SizedBox(width: 4),
              Tooltip(
                message: infoText,
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
