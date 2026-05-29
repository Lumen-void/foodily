import 'package:flutter/material.dart';
import 'package:flutter_core/flutter_core.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key, required this.currentLocale});

  final Locale currentLocale;

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final _searchController = TextEditingController();

  static const _languages = [
    _LanguageOption(
      locale: Locale('en'),
      englishName: 'English',
      nativeName: 'English',
    ),
    _LanguageOption(
      locale: Locale('hi'),
      englishName: 'Hindi',
      nativeName: 'हिंदी',
    ),
    _LanguageOption(
      locale: Locale('bn'),
      englishName: 'Bengali',
      nativeName: 'বাংলা',
    ),
    _LanguageOption(
      locale: Locale('te'),
      englishName: 'Telugu',
      nativeName: 'తెలుగు',
    ),
    _LanguageOption(
      locale: Locale('mr'),
      englishName: 'Marathi',
      nativeName: 'मराठी',
    ),
    _LanguageOption(
      locale: Locale('ta'),
      englishName: 'Tamil',
      nativeName: 'தமிழ்',
    ),
    _LanguageOption(
      locale: Locale('ur'),
      englishName: 'Urdu',
      nativeName: 'اردو',
    ),
    _LanguageOption(
      locale: Locale('gu'),
      englishName: 'Gujarati',
      nativeName: 'ગુજરાતી',
    ),
    _LanguageOption(
      locale: Locale('kn'),
      englishName: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
    ),
    _LanguageOption(
      locale: Locale('ml'),
      englishName: 'Malayalam',
      nativeName: 'മലയാളം',
    ),
    _LanguageOption(
      locale: Locale('or'),
      englishName: 'Odia',
      nativeName: 'ଓଡ଼ିଆ',
    ),
    _LanguageOption(
      locale: Locale('pa'),
      englishName: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
    ),
    _LanguageOption(
      locale: Locale('as'),
      englishName: 'Assamese',
      nativeName: 'অসমীয়া',
    ),
    _LanguageOption(
      locale: Locale('ne'),
      englishName: 'Nepali',
      nativeName: 'नेपाली',
    ),
    _LanguageOption(
      locale: Locale('sd'),
      englishName: 'Sindhi',
      nativeName: 'سنڌي',
    ),
    _LanguageOption(
      locale: Locale('ks'),
      englishName: 'Kashmiri',
      nativeName: 'कॉशुर / كٲشُر',
    ),
    _LanguageOption(
      locale: Locale('kok'),
      englishName: 'Konkani',
      nativeName: 'कोंकणी',
    ),
    _LanguageOption(
      locale: Locale('mai'),
      englishName: 'Maithili',
      nativeName: 'मैथिली',
    ),
    _LanguageOption(
      locale: Locale('sa'),
      englishName: 'Sanskrit',
      nativeName: 'संस्कृतम्',
    ),
    _LanguageOption(
      locale: Locale('mni'),
      englishName: 'Manipuri',
      nativeName: 'মৈতৈলোন / মণিপুরী',
    ),
    _LanguageOption(
      locale: Locale('brx'),
      englishName: 'Bodo',
      nativeName: 'बरʼ',
    ),
    _LanguageOption(
      locale: Locale('sat'),
      englishName: 'Santali',
      nativeName: 'ᱥᱟᱱᱛᱟᱲᱤ',
    ),
    _LanguageOption(
      locale: Locale('doi'),
      englishName: 'Dogri',
      nativeName: 'डोगरी',
    ),
  ];

  String _effectiveCode(Locale locale) {
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = _languages
        .where((option) {
          if (query.isEmpty) return true;
          return option.englishName.toLowerCase().contains(query) ||
              option.nativeName.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: Text('Select Language'.tr(context))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search language'.tr(context),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              itemCount: filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final language = filtered[index];
                final selected =
                    _effectiveCode(language.locale) ==
                    _effectiveCode(widget.currentLocale);
                return Card(
                  child: ListTile(
                    title: Text(
                      language.nativeName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(language.englishName),
                    trailing: selected
                        ? const Icon(
                            Icons.check_circle,
                            color: Color(0xFF2563EB),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(language.locale),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.englishName,
    required this.nativeName,
  });

  final Locale locale;
  final String englishName;
  final String nativeName;
}
