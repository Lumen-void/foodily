import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';
import 'package:flutter_ui/flutter_ui.dart';

import '../state/app_state.dart';
import 'tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _plan = 'One-time';
  String _window = '1:00 PM - 1:30 PM';
  String _paymentMode = 'UPI';
  bool _walletAutoApply = true;
  String? _selectedAddressId;

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await widget.appState.fetchCheckoutPreferences();
    final addresses = await widget.appState.fetchAddresses();
    final smartDefault = await widget.appState.getSmartDefaultAddress();

    _window = prefs.preferredWindow;
    _paymentMode = prefs.preferredPaymentMode;
    _walletAutoApply = prefs.walletAutoApply;
    _plan = prefs.defaultCadence == 'Monthly'
        ? 'Monthly Subscription'
        : (prefs.defaultCadence == 'Weekly'
              ? 'Weekly Subscription'
              : 'One-time');

    if (smartDefault != null) {
      _selectedAddressId = smartDefault.id;
    } else if (addresses.isNotEmpty) {
      _selectedAddressId = addresses.first.id;
    }
  }

  void _applyQuickPreset({
    required String plan,
    required String window,
    required String paymentMode,
    required bool walletAutoApply,
  }) {
    setState(() {
      _plan = plan;
      _window = window;
      _paymentMode = paymentMode;
      _walletAutoApply = walletAutoApply;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;

    return Scaffold(
      appBar: AppBar(title: Text('Checkout'.tr(context))),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          final addresses = state.cachedAddresses;
          final selectedAddress = addresses.firstWhere(
            (entry) => entry.id == _selectedAddressId,
            orElse: () => addresses.isEmpty
                ? const _AddressPlaceholder().asAddress
                : addresses.first,
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick checkout presets'.tr(context),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _CheckoutPresetChip(
                            label: 'Morning Rush'.tr(context),
                            icon: Icons.wb_sunny_outlined,
                            onTap: () => _applyQuickPreset(
                              plan: 'One-time',
                              window: '9:00 AM - 9:30 AM',
                              paymentMode: 'UPI',
                              walletAutoApply: true,
                            ),
                          ),
                          _CheckoutPresetChip(
                            label: 'Lunch Standard'.tr(context),
                            icon: Icons.lunch_dining_outlined,
                            onTap: () => _applyQuickPreset(
                              plan: 'Weekly Subscription',
                              window: '1:00 PM - 1:30 PM',
                              paymentMode: 'UPI',
                              walletAutoApply: true,
                            ),
                          ),
                          _CheckoutPresetChip(
                            label: 'Evening Family'.tr(context),
                            icon: Icons.nightlight_outlined,
                            onTap: () => _applyQuickPreset(
                              plan: 'Monthly Subscription',
                              window: '8:00 PM - 8:30 PM',
                              paymentMode: 'Card',
                              walletAutoApply: false,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _plan,
                decoration: InputDecoration(
                  labelText: 'Order type'.tr(context),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'One-time',
                    child: Text('One-time'.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Weekly Subscription',
                    child: Text('Weekly Subscription'.tr(context)),
                  ),
                  DropdownMenuItem(
                    value: 'Monthly Subscription',
                    child: Text('Monthly Subscription'.tr(context)),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _plan = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _window,
                decoration: InputDecoration(
                  labelText: 'Preferred delivery window'.tr(context),
                ),
                items: [
                  DropdownMenuItem(
                    value: '9:00 AM - 9:30 AM',
                    child: Text('9:00 AM - 9:30 AM'),
                  ),
                  DropdownMenuItem(
                    value: '1:00 PM - 1:30 PM',
                    child: Text('1:00 PM - 1:30 PM'),
                  ),
                  DropdownMenuItem(
                    value: '8:00 PM - 8:30 PM',
                    child: Text('8:00 PM - 8:30 PM'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _window = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _paymentMode,
                decoration: InputDecoration(
                  labelText: 'Payment mode'.tr(context),
                ),
                items: [
                  DropdownMenuItem(value: 'UPI', child: Text('UPI')),
                  DropdownMenuItem(value: 'Card', child: Text('Card')),
                  DropdownMenuItem(
                    value: 'Cash',
                    child: Text('Cash on delivery'.tr(context)),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _paymentMode = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (addresses.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'No addresses available for this account.'.tr(context),
                    ),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedAddressId,
                  decoration: InputDecoration(
                    labelText: 'Delivery address'.tr(context),
                  ),
                  items: addresses
                      .map(
                        (address) => DropdownMenuItem(
                          value: address.id,
                          child: Text(
                            '${address.label} • ${address.addressLine}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedAddressId = value;
                    });
                  },
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Auto-apply wallet credits'.tr(context)),
                subtitle: Text(
                  'Use wallet balance within cap on checkout'.tr(context),
                ),
                value: _walletAutoApply,
                onChanged: (value) {
                  setState(() {
                    _walletAutoApply = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (addresses.isNotEmpty)
                Card(
                  color: selectedAddress.serviceable
                      ? null
                      : Theme.of(context).colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          selectedAddress.serviceable
                              ? Icons.verified_outlined
                              : Icons.warning_amber_rounded,
                          color: selectedAddress.serviceable
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            selectedAddress.serviceable
                                ? 'Address is serviceable and ready for one-tap checkout.'
                                      .tr(context)
                                : 'Selected address is outside active serviceable zone.'
                                      .tr(context),
                            style: TextStyle(
                              color: selectedAddress.serviceable
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (addresses.isNotEmpty) const SizedBox(height: 12),
              Text('Delivery confirmation'.tr(context)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8EDF7)),
                ),
                child: Text(
                  '${'Order will be delivered to'.tr(context)} ${selectedAddress.addressLine} ${'in slot'.tr(context)} $_window',
                ),
              ),
              const SizedBox(height: 14),
              PriceBlock(
                total: state.cartTotal,
                walletApplied: _walletAutoApply ? state.walletApplied : 0,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => TrackingScreen(appState: state),
                    ),
                  );
                },
                child: Text('Pay with Razorpay (Sandbox)'.tr(context)),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await state.updateCheckoutPreferences(
                    state.checkoutPreferences.copyWith(
                      preferredWindow: _window,
                      preferredPaymentMode: _paymentMode,
                      walletAutoApply: _walletAutoApply,
                      defaultCadence: _plan.contains('Monthly')
                          ? 'Monthly'
                          : (_plan.contains('Weekly') ? 'Weekly' : 'One-time'),
                    ),
                  );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'One-tap checkout preferences saved.'.tr(context),
                      ),
                    ),
                  );
                },
                child: Text('Save as one-tap defaults'.tr(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AddressPlaceholder {
  const _AddressPlaceholder();

  AddressOption get asAddress => const AddressOption(
    id: 'placeholder',
    customerId: 'placeholder',
    label: 'Address unavailable',
    addressLine: 'Add a serviceable address in profile.',
    cityId: 'none',
    zoneId: 'none',
    serviceable: false,
  );
}

class _CheckoutPresetChip extends StatelessWidget {
  const _CheckoutPresetChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 16, color: scheme.primary),
      label: Text(
        label,
        style: TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w700),
      ),
      side: BorderSide(color: scheme.outlineVariant),
      backgroundColor: scheme.surface,
      onPressed: onTap,
    );
  }
}
