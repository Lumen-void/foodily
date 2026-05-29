import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  late Future<List<AddressOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.appState.fetchAddresses();
  }

  Future<void> _reload() async {
    setState(() {
      _future = widget.appState.fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage addresses'.tr(context))),
      body: RefreshIndicator(
        onRefresh: () => _reload(),
        child: FutureBuilder<List<AddressOption>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Unable to load addresses'.tr(context)),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _reload,
                        child: Text('Retry'.tr(context)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final addresses = snapshot.data ?? const <AddressOption>[];

            if (addresses.isEmpty) {
              return Center(
                child: Text(
                  'No addresses available for this customer.'.tr(context),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.only(top: 12, bottom: 24),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return ListTile(
                  leading: const Icon(Icons.location_on_outlined),
                  title: Text(address.label),
                  subtitle: Text(address.addressLine),
                  trailing: address.serviceable
                      ? Chip(
                          label: Text('Serviceable'.tr(context)),
                          backgroundColor: const Color(0xFFE8F5E9),
                        )
                      : Chip(
                          label: Text('Not serviceable'.tr(context)),
                          backgroundColor: const Color(0xFFFFEEE6),
                        ),
                );
              },
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemCount: addresses.length,
            );
          },
        ),
      ),
    );
  }
}
