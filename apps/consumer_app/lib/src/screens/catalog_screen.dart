import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final places = appState.foodPlacesForCity(appState.selectedCity.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog size')),
      body: places.isEmpty
          ? const Center(child: Text('No catalog entries available right now.'))
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: places.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final place = places[index];
                final totalMeals = MockData.meals
                    .where((meal) => meal.placeId == place.id)
                    .length;

                return Card(
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        place.imageUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) => Container(
                          width: 48,
                          height: 48,
                          color: const Color(0xFFE2E8F0),
                          alignment: Alignment.center,
                          child: const Icon(Icons.storefront_outlined),
                        ),
                      ),
                    ),
                    title: Text(place.name),
                    subtitle: Text(
                      'Catalog size: $totalMeals meals • Rating ${place.rating.toStringAsFixed(1)}',
                    ),
                    trailing: Text('${place.avgDeliveryMinutes} mins'),
                  ),
                );
              },
            ),
    );
  }
}
