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

  // Coupon and tip state
  final TextEditingController _couponController = TextEditingController();
  String? _appliedCouponCode;
  double _discountAmount = 0.0;
  double _riderTip = 0.0;
  final List<double> _tipOptions = [0, 10, 20, 30, 50, 100];

  static const String userId = 'user_1';

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
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a coupon code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Simple coupon validation - in production, this would call an API
    double discount = 0.0;
    final Map<String, double> couponMap = {
      'SAVE10': 10.0,
      'SAVE20': 20.0,
      'SAVE50': 50.0,
      'SAVE75': 75.0,
      'SAVE100': 100.0,
      'WELCOME': 15.0,
      'FESTIVE25': 25.0,
      'FLAT150': 150.0,
    };

    if (couponMap.containsKey(code)) {
      discount = couponMap[code]!;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid coupon code: $code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _appliedCouponCode = code;
      _discountAmount = discount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Coupon applied! You saved ₹${discount.toStringAsFixed(0)}',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = 0.0;
      _couponController.clear();
    });
  }

  void _selectTip(double tip) {
    setState(() {
      _riderTip = tip;
    });
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
            final baseTotal = subtotal + platformCharge + deliveryCharge + tax;
            final grandTotal = baseTotal - _discountAmount + _riderTip;

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

                  // Coupon Section
                  _buildSectionHeader('Coupon Code'),
                  _buildCouponSection(),

                  // Tip Section
                  _buildSectionHeader('Tip for Rider'),
                  _buildTipSection(),

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
                    _discountAmount,
                    _riderTip,
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
                                          couponCode: _appliedCouponCode,
                                          discountAmount: _discountAmount,
                                          riderTip: _riderTip,
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
              // Show bottom sheet for card payments
              if (method == 'Credit Card' || method == 'Debit Card') {
                _showCardPaymentBottomSheet(context, grandTotal);
              }
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

  Widget _buildCouponSection() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_appliedCouponCode == null) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      decoration: InputDecoration(
                        hintText: 'Enter coupon code',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyCoupon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coupon Applied: $_appliedCouponCode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            'Discount: ₹${_discountAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _removeCoupon,
                      child: Text(
                        'Remove',
                        style: TextStyle(color: Colors.green.shade700),
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
  }

  Widget _buildTipSection() {
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Show your appreciation to the delivery rider',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tipOptions.map((tip) {
                final isSelected = _riderTip == tip;
                return InkWell(
                  onTap: () => _selectTip(tip),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.green : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.green : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      tip == 0 ? 'No Tip' : '₹${tip.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Custom Amount: ', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter amount',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final customTip = double.tryParse(value) ?? 0.0;
                      if (customTip != _riderTip) {
                        setState(() {
                          _riderTip = customTip;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown(
    double subtotal,
    double platformCharge,
    double deliveryCharge,
    double tax,
    double discountAmount,
    double riderTip,
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
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildChargeRow('Discount', -discountAmount, isDiscount: true),
          ],
          if (riderTip > 0) ...[
            const SizedBox(height: 8),
            _buildChargeRow('Tip for Rider', riderTip),
          ],
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
    bool isDiscount = false,
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
          isDiscount
              ? '-₹${amount.abs().toStringAsFixed(2)}'
              : '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14,
            color: isDiscount ? Colors.green : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showCardPaymentBottomSheet(BuildContext context, double grandTotal) {
    final cartState = context.read<CartBloc>().state;
    final items = cartViewModel.getCartItems(cartState);
    final subtotal = cartViewModel.getSubtotal(cartState);
    final platformCharge = cartViewModel.getPlatformCharge(cartState);
    final deliveryCharge = cartViewModel.getDeliveryCharge(cartState);
    final tax = cartViewModel.getTax(cartState);
    final baseTotal = subtotal + platformCharge + deliveryCharge + tax;
    final finalTotal = baseTotal - _discountAmount + _riderTip;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    selectedPaymentMethod == 'Credit Card'
                        ? Icons.credit_card
                        : Icons.credit_card_outlined,
                    color: Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedPaymentMethod,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Review your order and proceed',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Selected Items List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Selected Items',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...items.map<Widget>((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.product.unit != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      item.product.unit!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Qty: ${item.quantity}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        '₹${item.totalPrice.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  // Price Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        _buildChargeRow('Subtotal', subtotal),
                        const SizedBox(height: 8),
                        _buildChargeRow('Platform Charge', platformCharge),
                        const SizedBox(height: 8),
                        _buildChargeRow('Delivery Charge', deliveryCharge),
                        const SizedBox(height: 8),
                        _buildChargeRow('Tax (GST)', tax),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          _buildChargeRow(
                            'Discount',
                            -_discountAmount,
                            isDiscount: true,
                          ),
                        ],
                        if (_riderTip > 0) ...[
                          const SizedBox(height: 8),
                          _buildChargeRow('Tip for Rider', _riderTip),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${finalTotal.toStringAsFixed(0)}',
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
                  ),
                ],
              ),
            ),
            // Payment Button
            Container(
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
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, orderState) {
                  final isLoading = checkoutViewModel.isLoading(orderState);
                  final selectedAddress =
                      BlocProvider.of<AddressBloc>(context).state
                          is AddressesLoaded
                      ? checkoutViewModel.getSelectedAddress(
                          BlocProvider.of<AddressBloc>(context).state,
                        )
                      : null;

                  final canPlaceOrder = selectedAddress != null;

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (isLoading || !canPlaceOrder)
                          ? null
                          : () {
                              Navigator.pop(context);
                              final cartItemIds = items
                                  .map((item) => item.productId)
                                  .toList();

                              checkoutViewModel.createOrder(
                                cartItemIds: cartItemIds,
                                deliveryAddress: selectedAddress,
                                paymentMethod: selectedPaymentMethod,
                                couponCode: _appliedCouponCode,
                                discountAmount: _discountAmount,
                                riderTip: _riderTip,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Pay ₹${finalTotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
