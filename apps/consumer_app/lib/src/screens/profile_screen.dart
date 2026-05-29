import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

import '../state/app_state.dart';
import 'addresses_screen.dart';
import 'catalog_screen.dart';
import 'edit_profile_screen.dart';
import 'language_selection_screen.dart';
import 'orders_screen.dart';
import 'support_inbox_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.locale,
    required this.onLocaleChanged,
    required this.appState,
    required this.onStateChanged,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final AppState appState;
  final VoidCallback onStateChanged;

  @override
  Widget build(BuildContext context) {
    final customer = appState.currentCustomer;
    final isDemo = appState.isDemoMode;
    final health = appState.dataHealth;
    final initials = customer.name.isEmpty
        ? 'U'
        : customer.name.trim().split(' ').map((item) => item[0]).take(2).join();

    return Scaffold(
      appBar: AppBar(title: Text('Profile'.tr(context))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004274), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(FoodilyRadii.lg),
              boxShadow: FoodilyShadows.premium,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  child: Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${customer.phone} • ${customer.tier}',
                        style: const TextStyle(color: Color(0xFFDCEBFF)),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    final updated = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(appState: appState),
                      ),
                    );
                    if (updated == true) {
                      onStateChanged();
                    }
                  },
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.14),
                  ),
                  tooltip: 'Edit profile'.tr(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _QuickActionCard(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders'.tr(context),
                      subtitle: 'Order history'.tr(context),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrdersScreen(appState: appState),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _QuickActionCard(
                      icon: Icons.location_on_outlined,
                      title: 'Addresses'.tr(context),
                      subtitle: 'Saved places'.tr(context),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddressesScreen(appState: appState),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _QuickActionCard(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment'.tr(context),
                      subtitle: 'Wallet & offers'.tr(context),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => WalletScreen(appState: appState),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _QuickActionCard(
                      icon: Icons.support_agent_outlined,
                      title: 'Help'.tr(context),
                      subtitle: 'Support inbox'.tr(context),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                SupportInboxScreen(appState: appState),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text('Language'.tr(context)),
                    subtitle: Text(_languageLabel(_localeCode(locale))),
                    onTap: () async {
                      final selected = await Navigator.of(context).push<Locale>(
                        MaterialPageRoute(
                          builder: (_) =>
                              LanguageSelectionScreen(currentLocale: locale),
                        ),
                      );
                      if (selected != null) {
                        onLocaleChanged(selected);
                        onStateChanged();
                      }
                    },
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.developer_mode_outlined),
                    title: Text('Demo mode'.tr(context)),
                    subtitle: Text(
                      isDemo
                          ? 'Using local seeded customers, menu and orders'.tr(
                              context,
                            )
                          : 'Using live API data'.tr(context),
                    ),
                    value: isDemo,
                    onChanged: (value) {
                      appState.switchMode(value ? AppMode.demo : AppMode.live);
                      onStateChanged();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                                ? 'Switched to Demo mode.'.tr(context)
                                : 'Switched to Live mode.'.tr(context),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF2563EB),
            ),
            title: Text('Data health'.tr(context)),
            subtitle: Text(
              'Meals: ${health.meals} • Orders: ${health.orders} • Food places: ${health.partners}',
            ),
            trailing:
                health.meals > 0 && health.orders > 0 && health.partners > 0
                ? const Icon(Icons.check_circle, color: Color(0xFF1A8F46))
                : const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFD97706),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text('Manage addresses'.tr(context)),
            subtitle: Text(
              '${appState.cachedAddresses.length} saved address(es)',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddressesScreen(appState: appState),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_outlined),
            title: Text('Support inbox'.tr(context)),
            subtitle: Text(
              '${appState.cachedSupportThreads.length} threads • ${appState.cachedSupportIssues.length} issues',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SupportInboxScreen(appState: appState),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text('Catalog size'.tr(context)),
            subtitle: Text('${MockData.meals.length} demo meals loaded'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CatalogScreen(appState: appState),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text('Orders available'.tr(context)),
            subtitle: Text('${MockData.demoOrders.length} demo orders loaded'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => OrdersScreen(appState: appState),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(FoodilyRadii.md),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(FoodilyRadii.md),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _localeCode(Locale locale) {
  final language = locale.languageCode.trim();
  if (language.isNotEmpty) {
    return language.toLowerCase();
  }
  final country = locale.countryCode?.trim();
  if (country != null && country.isNotEmpty) {
    return country.toLowerCase();
  }
  return 'en';
}

String _languageLabel(String code) {
  switch (code) {
    case 'hi':
      return 'हिंदी';
    case 'bn':
      return 'বাংলা';
    case 'te':
      return 'తెలుగు';
    case 'mr':
      return 'मराठी';
    case 'ta':
      return 'தமிழ்';
    case 'ur':
      return 'اردو';
    case 'gu':
      return 'ગુજરાતી';
    case 'kn':
      return 'ಕನ್ನಡ';
    case 'ml':
      return 'മലയാളം';
    case 'or':
      return 'ଓଡ଼ିଆ';
    case 'pa':
      return 'ਪੰਜਾਬੀ';
    case 'as':
      return 'অসমীয়া';
    case 'ne':
      return 'नेपाली';
    case 'sd':
      return 'سنڌي';
    case 'ks':
      return 'कॉशुर / كٲشُر';
    case 'kok':
      return 'कोंकणी';
    case 'mai':
      return 'मैथिली';
    case 'sa':
      return 'संस्कृतम्';
    case 'mni':
      return 'মৈতৈলোন';
    case 'brx':
      return 'बरʼ';
    case 'sat':
      return 'ᱥᱟᱱᱛᱟᱲᱤ';
    case 'doi':
      return 'डोगरी';
    default:
      return 'English';
  }
}
