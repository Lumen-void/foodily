import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tiers = const ['Silver', 'Gold', 'Platinum'];
  final _priceBands = const ['budget', 'mid', 'premium'];

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late City _selectedCity;
  late Zone _selectedZone;
  late String _selectedTier;
  late String _selectedPriceBand;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final customer = widget.appState.currentCustomer;
    _nameController = TextEditingController(text: customer.name);
    _phoneController = TextEditingController(text: customer.phone);
    _addressController = TextEditingController(text: customer.primaryAddress);
    _selectedCity = MockData.cities.firstWhere(
      (city) => city.id == customer.cityId,
      orElse: () => widget.appState.selectedCity,
    );
    final zones = AppState.zonesForCity(_selectedCity.id);
    _selectedZone = zones.firstWhere(
      (zone) => zone.id == customer.zoneId,
      orElse: () => zones.isNotEmpty ? zones.first : widget.appState.selectedZone,
    );
    _selectedTier = _tiers.contains(customer.tier) ? customer.tier : _tiers[0];
    _selectedPriceBand = _priceBands.contains(customer.preferredPriceBand)
        ? customer.preferredPriceBand
        : _priceBands[1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    widget.appState.updateCurrentCustomerProfile(
      name: _nameController.text,
      phone: _phoneController.text,
      cityId: _selectedCity.id,
      zoneId: _selectedZone.id,
      tier: _selectedTier,
      primaryAddress: _addressController.text,
      preferredPriceBand: _selectedPriceBand,
    );

    await widget.appState.loadHomeFeed();
    await widget.appState.fetchOrders();

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final zones = AppState.zonesForCity(_selectedCity.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<City>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              items: MockData.cities
                  .map(
                    (city) =>
                        DropdownMenuItem(value: city, child: Text(city.name)),
                  )
                  .toList(),
              onChanged: (city) {
                if (city == null) return;
                final nextZones = AppState.zonesForCity(city.id);
                setState(() {
                  _selectedCity = city;
                  _selectedZone = nextZones.isNotEmpty
                      ? nextZones.first
                      : widget.appState.selectedZone;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Zone>(
              initialValue: zones.any((zone) => zone.id == _selectedZone.id)
                  ? _selectedZone
                  : (zones.isNotEmpty ? zones.first : null),
              decoration: const InputDecoration(
                labelText: 'Area',
                prefixIcon: Icon(Icons.pin_drop_outlined),
              ),
              items: zones
                  .map(
                    (zone) =>
                        DropdownMenuItem(value: zone, child: Text(zone.name)),
                  )
                  .toList(),
              onChanged: (zone) {
                if (zone == null) return;
                setState(() {
                  _selectedZone = zone;
                });
              },
              validator: (zone) => zone == null ? 'Select an area' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedTier,
              decoration: const InputDecoration(
                labelText: 'Tier',
                prefixIcon: Icon(Icons.workspace_premium_outlined),
              ),
              items: _tiers
                  .map(
                    (tier) =>
                        DropdownMenuItem(value: tier, child: Text(tier)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedTier = value;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedPriceBand,
              decoration: const InputDecoration(
                labelText: 'Preferred price band',
                prefixIcon: Icon(Icons.currency_rupee_outlined),
              ),
              items: _priceBands
                  .map(
                    (band) =>
                        DropdownMenuItem(value: band, child: Text(band)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPriceBand = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Primary address',
                prefixIcon: Icon(Icons.home_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_saving ? 'Saving...' : 'Save profile'),
            ),
          ],
        ),
      ),
    );
  }
}
