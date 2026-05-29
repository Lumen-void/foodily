import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/delivery_state.dart';
import 'jobs_screen.dart';

class DeliveryLoginScreen extends StatefulWidget {
  const DeliveryLoginScreen({super.key});

  @override
  State<DeliveryLoginScreen> createState() => _DeliveryLoginScreenState();
}

class _DeliveryLoginScreenState extends State<DeliveryLoginScreen> {
  final _phoneController = TextEditingController(text: '+91 ');
  FoodPlace _selectedRestaurant = MockData.foodPlaces.first;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0E3A6D), Color(0xFF1E67D1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foodily Restaurant',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manage orders, menus, images and fulfillment in one app',
                      style: TextStyle(color: Color(0xFFD7EBFF)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Restaurant login with OTP',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          prefixIcon: Icon(Icons.phone_android_outlined),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<FoodPlace>(
                        isExpanded: true,
                        initialValue: _selectedRestaurant,
                        decoration: const InputDecoration(
                          labelText: 'Demo restaurant account',
                          prefixIcon: Icon(Icons.store_outlined),
                        ),
                        items: MockData.foodPlaces
                            .map(
                              (restaurant) => DropdownMenuItem(
                                value: restaurant,
                                child: Text(
                                  '${restaurant.name} • ${restaurant.cityId.toUpperCase()}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        selectedItemBuilder: (context) => MockData.foodPlaces
                            .map(
                              (restaurant) => Text(
                                '${restaurant.name} • ${restaurant.cityId.toUpperCase()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                            .toList(),
                        onChanged: (restaurant) {
                          if (restaurant == null) return;
                          setState(() {
                            _selectedRestaurant = restaurant;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            final state = DeliveryState();
                            state.setRestaurant(_selectedRestaurant);
                            state.reloadJobs();
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => JobsScreen(state: state),
                              ),
                            );
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Send OTP'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Demo mode: choose a restaurant and continue directly.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
