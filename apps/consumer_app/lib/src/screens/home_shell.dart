import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'home_discover_screen.dart';
import 'profile_screen.dart';
import 'subscription_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.appState,
    required this.locale,
    required this.onLocaleChanged,
  });

  final AppState appState;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  Timer? _syncTimer;
  DateTime? _lastSyncAt;

  @override
  void initState() {
    super.initState();
    _primeData();
    _syncTimer = Timer.periodic(const Duration(seconds: 45), (_) async {
      await widget.appState.backgroundSync();
      if (!mounted) return;
      setState(() {
        _lastSyncAt = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _primeData() async {
    await widget.appState.loadHomeFeed();
    await widget.appState.fetchOrders();
    if (!mounted) return;
    setState(() {
      _lastSyncAt = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final screens = <Widget>[
      HomeDiscoverScreen(appState: widget.appState, locale: widget.locale),
      SubscriptionScreen(appState: widget.appState),
      ProfileScreen(
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
        appState: widget.appState,
        onStateChanged: () {
          setState(() {});
        },
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: screens[_index]),
          if (_lastSyncAt != null && _index <= 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _primeData,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2937)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${'Synced'.tr(context)} ${_formatSyncTime(_lastSyncAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home'.tr(context),
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Meals'.tr(context),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile'.tr(context),
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
    );
  }

  String _formatSyncTime(DateTime value) {
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.hour}:$minute';
  }
}
