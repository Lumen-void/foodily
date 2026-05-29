import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  // Keep framework delegates on locales that Material/Cupertino fully support.
  static const supportedLocales = [Locale('en'), Locale('hi')];

  static AppStrings of(Locale locale) => AppStrings(locale);

  static String localeCodeOf(Locale locale) {
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

  static const _en = {
    'appName': 'Foodily',
    'otpTitle': 'Sign in with phone',
    'sendOtp': 'Send OTP',
    'sameDay': 'Same-Day Menu',
    'weeklyMenu': 'Weekly Subscription Menu',
    'orderNow': 'Order now',
    'orderFullWeek': 'Order Full Week',
    'subscribeNow': 'Subscribe now',
    'cart': 'Cart',
    'checkout': 'Checkout',
    'wallet': 'Wallet',
    'tracking': 'Order Tracking',
  };

  static const _hi = {
    'appName': 'फूडीली',
    'otpTitle': 'फ़ोन से साइन इन करें',
    'sendOtp': 'ओटीपी भेजें',
    'sameDay': 'आज का मेनू',
    'weeklyMenu': 'साप्ताहिक सब्सक्रिप्शन मेनू',
    'orderNow': 'अभी ऑर्डर करें',
    'orderFullWeek': 'पूरा सप्ताह ऑर्डर करें',
    'subscribeNow': 'सब्सक्राइब करें',
    'cart': 'कार्ट',
    'checkout': 'चेकआउट',
    'wallet': 'वॉलेट',
    'tracking': 'ऑर्डर ट्रैकिंग',
  };

  static const _uiHi = {
    'Home': 'होम',
    'Meals': 'मील्स',
    'Profile': 'प्रोफाइल',
    'Synced': 'सिंक',
    'Select Language': 'भाषा चुनें',
    'Search language': 'भाषा खोजें',
    'Search restaurants or cuisines': 'रेस्टोरेंट या क्यूज़ीन खोजें',
    'Search restaurants, meals, plans': 'रेस्टोरेंट, मील्स और प्लान खोजें',
    'Search meals': 'मील्स खोजें',
    'All': 'सभी',
    'Favorites': 'फेवरेट',
    'Fast Delivery': 'फास्ट डिलीवरी',
    'Under ₹120': '₹120 से कम',
    'Veg': 'शाकाहारी',
    'High Protein': 'हाई प्रोटीन',
    'Auto pick for now': 'अभी के लिए ऑटो चयन',
    'Apply': 'लागू करें',
    'Restaurants near you': 'आपके पास के रेस्टोरेंट',
    'places open now': 'स्थान अभी खुले हैं',
    'No restaurants found for this filter.':
        'इस फ़िल्टर के लिए कोई रेस्टोरेंट नहीं मिला।',
    'Reorder in 1 tap': '1 टैप में दोबारा ऑर्डर',
    'Reorder': 'फिर से ऑर्डर',
    'Reordered from': 'फिर से ऑर्डर किया गया',
    'Top meals from': 'लोकप्रिय मील्स -',
    'Quick add to cart': 'कार्ट में जल्दी जोड़ें',
    'No meals available right now.': 'अभी कोई मील उपलब्ध नहीं है।',
    'View menu': 'मेनू देखें',
    'Favorite': 'पसंदीदा',
    'Restaurant': 'रेस्टोरेंट',
    'Dhaba': 'ढाबा',
    'Rasoi': 'रसोई',
    'Cloud kitchen': 'क्लाउड किचन',
    'Tiffin / Rasoi': 'टिफिन / रसोई',
    'Cloud Kitchen': 'क्लाउड किचन',
    'Breakfast': 'नाश्ता',
    'Lunch': 'लंच',
    'Dinner': 'डिनर',
    'Add': 'जोड़ें',
    'Meal presets': 'मील प्रीसेट',
    'Weekly Veg': 'साप्ताहिक वेज',
    'Monthly Family': 'मासिक फैमिली',
    'Custom': 'कस्टम',
    'Weekly': 'साप्ताहिक',
    'Monthly': 'मासिक',
    'Auto': 'ऑटो',
    'Choose Restaurant': 'रेस्टोरेंट चुनें',
    'No restaurants found for this search.':
        'इस खोज के लिए कोई रेस्टोरेंट नहीं मिला।',
    'From': 'से शुरू',
    'Plan Type': 'प्लान प्रकार',
    'Start': 'शुरुआत',
    'Next Monday': 'अगला सोमवार',
    'Tomorrow': 'कल',
    'Next Week': 'अगला सप्ताह',
    'Plan Pricing': 'प्लान कीमत',
    'Selected': 'चयनित',
    'Starts': 'शुरू',
    'Menu Items & Prices': 'मेनू आइटम और कीमतें',
    'No meals available for this place right now.':
        'इस स्थान के लिए अभी कोई मील उपलब्ध नहीं है।',
    'Available': 'उपलब्ध',
    'Customization notes': 'कस्टमाइजेशन नोट्स',
    'Include custom preferences': 'कस्टम पसंद शामिल करें',
    'Auto-renew plan': 'ऑटो-रिन्यू प्लान',
    'Save': 'सेव करें',
    'plan': 'प्लान',
    'Custom basket': 'कस्टम बास्केट',
    'My Orders': 'मेरे ऑर्डर',
    'Order history': 'ऑर्डर इतिहास',
    'Addresses': 'पते',
    'Saved places': 'सेव किए गए स्थान',
    'Payment': 'पेमेंट',
    'Wallet & offers': 'वॉलेट और ऑफर',
    'Help': 'मदद',
    'Support inbox': 'सपोर्ट इनबॉक्स',
    'Threads': 'थ्रेड्स',
    'Issues': 'समस्याएँ',
    'Unable to load support data': 'सपोर्ट डेटा लोड नहीं हो सका',
    'Order-linked live chats': 'ऑर्डर से जुड़े लाइव चैट',
    'No open support threads.': 'कोई खुला सपोर्ट थ्रेड नहीं है।',
    'No messages yet': 'अभी कोई संदेश नहीं',
    'Escalations and resolution tracking': 'एस्केलेशन और समाधान ट्रैकिंग',
    'No active support issues.': 'कोई सक्रिय सपोर्ट समस्या नहीं है।',
    'Language': 'भाषा',
    'Demo mode': 'डेमो मोड',
    'Using local seeded customers, menu and orders':
        'लोकल डेमो ग्राहक, मेनू और ऑर्डर उपयोग हो रहे हैं',
    'Using live API data': 'लाइव API डेटा उपयोग हो रहा है',
    'Switched to Demo mode.': 'डेमो मोड पर स्विच किया गया।',
    'Switched to Live mode.': 'लाइव मोड पर स्विच किया गया।',
    'Data health': 'डेटा स्वास्थ्य',
    'Manage addresses': 'पते प्रबंधित करें',
    'Catalog size': 'कैटलॉग आकार',
    'Orders available': 'उपलब्ध ऑर्डर',
    'Edit profile': 'प्रोफाइल संपादित करें',
    'Wallet & Offers': 'वॉलेट और ऑफर',
    'Available balance': 'उपलब्ध बैलेंस',
    'Wallet for': 'वॉलेट -',
    'Offers loading...': 'ऑफर लोड हो रहे हैं...',
    'Eligible savings': 'योग्य बचत',
    'Checking first-order, streak and surge-safe rules':
        'पहला ऑर्डर, स्ट्रीक और सर्ज नियम जाँचे जा रहे हैं',
    'No applicable offers right now': 'अभी कोई लागू ऑफर नहीं है',
    'Referral code': 'रेफरल कोड',
    'Share and earn ₹100 per successful signup': 'हर सफल साइनअप पर ₹100 कमाएं',
    'Copy': 'कॉपी',
    'Apply referral code': 'रेफरल कोड लागू करें',
    'Recent wallet activity': 'हाल की वॉलेट गतिविधि',
    'No wallet transactions yet': 'अभी कोई वॉलेट ट्रांजैक्शन नहीं है',
    'Referred customers (demo)': 'रेफर किए गए ग्राहक (डेमो)',
    'orders': 'ऑर्डर',
    'Unable to load addresses': 'पते लोड नहीं हो सके',
    'Retry': 'फिर कोशिश करें',
    'No addresses available for this customer.':
        'इस ग्राहक के लिए कोई पता उपलब्ध नहीं है।',
    'Serviceable': 'सर्विस उपलब्ध',
    'Not serviceable': 'सर्विस उपलब्ध नहीं',
    'Unable to load orders': 'ऑर्डर लोड नहीं हो सके',
    'No orders available yet.': 'अभी कोई ऑर्डर उपलब्ध नहीं है।',
    'Cart Drawer': 'कार्ट',
    'No items in cart': 'कार्ट में कोई आइटम नहीं है',
    'Add meals from home to continue checkout.':
        'चेकआउट जारी रखने के लिए होम से मील्स जोड़ें।',
    'Qty': 'मात्रा',
    'Total payable': 'कुल भुगतान',
    'Proceed to Checkout': 'चेकआउट पर जाएं',
    'Checkout': 'चेकआउट',
    'Order type': 'ऑर्डर प्रकार',
    'One-time': 'एक बार',
    'Weekly Subscription': 'साप्ताहिक सब्सक्रिप्शन',
    'Monthly Subscription': 'मासिक सब्सक्रिप्शन',
    'Preferred delivery window': 'पसंदीदा डिलीवरी समय',
    'Payment mode': 'पेमेंट मोड',
    'Cash on delivery': 'कैश ऑन डिलीवरी',
    'No addresses available for this account.':
        'इस खाते के लिए कोई पता उपलब्ध नहीं है।',
    'Delivery address': 'डिलीवरी पता',
    'Auto-apply wallet credits': 'वॉलेट क्रेडिट ऑटो लागू करें',
    'Use wallet balance within cap on checkout':
        'चेकआउट पर सीमा के भीतर वॉलेट बैलेंस उपयोग करें',
    'Delivery confirmation': 'डिलीवरी पुष्टि',
    'Order will be delivered to': 'ऑर्डर पहुंचाया जाएगा',
    'in slot': 'समय स्लॉट में',
    'Pay with Razorpay (Sandbox)': 'Razorpay से भुगतान करें (सैंडबॉक्स)',
    'One-tap checkout preferences saved.':
        'वन-टैप चेकआउट प्राथमिकताएं सेव हो गईं।',
    'Save as one-tap defaults': 'वन-टैप डिफ़ॉल्ट के रूप में सेव करें',
    'Address unavailable': 'पता उपलब्ध नहीं',
    'Add a serviceable address in profile.':
        'प्रोफाइल में सर्विस योग्य पता जोड़ें।',
    'Order Tracking': 'ऑर्डर ट्रैकिंग',
    'Realtime ETA': 'रियलटाइम ETA',
    'Delay prediction': 'देरी का अनुमान',
    'Report delay': 'देरी रिपोर्ट करें',
    'Delay signal sent to operations.': 'देरी की सूचना ऑपरेशंस को भेज दी गई।',
    'and added to cart.': 'और कार्ट में जोड़ दिया गया।',
    'Issue': 'समस्या',
    'created.': 'बनाई गई।',
    'Support thread': 'सपोर्ट थ्रेड',
    'started.': 'शुरू हुआ।',
    'Active': 'सक्रिय',
    'Completed': 'पूर्ण',
    'No orders found for this filter.':
        'इस फ़िल्टर के लिए कोई ऑर्डर नहीं मिला।',
    'Track ETA': 'ETA ट्रैक करें',
    'Support': 'सपोर्ट',
    'Created': 'बनाया गया',
    'Confirmed': 'पुष्टि',
    'Preparing': 'तैयारी',
    'Out for delivery': 'डिलीवरी के लिए निकला',
    'Delivered': 'डिलीवर',
    'Cancelled': 'रद्द',
    'Top dishes': 'टॉप डिशेज',
    'Full menu': 'पूरा मेनू',
    'No dishes available right now.': 'अभी कोई डिश उपलब्ध नहीं है।',
    'No meals match this filter.': 'इस फ़िल्टर से कोई मील मेल नहीं खाता।',
    'View cart': 'कार्ट देखें',
    'item': 'आइटम',
    'items': 'आइटम',
    'Select meals to continue': 'जारी रखने के लिए मील्स चुनें',
    'Add at least one meal to continue.':
        'जारी रखने के लिए कम से कम एक मील जोड़ें।',
    'FINAL PRICE, BEST OFFER APPLIED': 'अंतिम कीमत, सर्वोत्तम ऑफर लागू',
    'RESTAURANTS DELIVERING TO YOU': 'रेस्टोरेंट आपके लिए डिलीवर कर रहे हैं',
    'EXPLORE MORE': 'और खोजें',
    'Voice search is coming soon': 'वॉइस सर्च जल्द आ रहा है',
    'Applied budget meals filter': 'बजट मील्स फ़िल्टर लागू किया गया',
    'Offers opened': 'ऑफर खोले गए',
    'Collections opened': 'कलेक्शन खोले गए',
    'Recommended for you': 'आपके लिए सुझाव',
  };

  String text(String key) {
    final map = localeCodeOf(locale) == 'hi' ? _hi : _en;
    return map[key] ?? key;
  }

  String ui(String value) {
    final code = localeCodeOf(locale);
    if (code == 'en') {
      return value;
    }
    if (code == 'hi') {
      return _uiHi[value] ?? value;
    }
    return value;
  }
}

extension AppLocalizedString on String {
  String tr(BuildContext context) {
    final locale = AppLiveTranslator.instance.activeLocale;
    final seed = AppStrings.of(locale).ui(this);
    return AppLiveTranslator.instance.translate(seed, locale);
  }
}

class AppLiveTranslator extends ChangeNotifier {
  AppLiveTranslator._();

  static final AppLiveTranslator instance = AppLiveTranslator._();

  final GoogleTranslator _translator = GoogleTranslator();
  final Map<String, String> _cache = {};
  final Set<String> _inFlight = {};
  Locale _activeLocale = const Locale('en');
  Locale get activeLocale => _activeLocale;

  void updateLocale(Locale locale) {
    if (AppStrings.localeCodeOf(_activeLocale) ==
        AppStrings.localeCodeOf(locale)) {
      return;
    }
    _activeLocale = locale;
    notifyListeners();
  }

  String translate(String source, Locale locale) {
    if (source.isEmpty) return source;
    final localeCode = AppStrings.localeCodeOf(locale);
    if (localeCode == 'en') {
      return source;
    }
    if (localeCode == 'hi' && _looksLocalized(source)) {
      return source;
    }

    final to = _mapToGoogleCode(localeCode);
    final key = '$to|$source';
    final cached = _cache[key];
    if (cached != null && cached.isNotEmpty) return cached;

    if (_inFlight.add(key)) {
      _translateAsync(key: key, source: source, to: to);
    }

    return source;
  }

  Future<void> _translateAsync({
    required String key,
    required String source,
    required String to,
  }) async {
    try {
      final output = await _translator.translate(source, to: to);
      final translated = output.text.trim();
      _cache[key] = translated.isEmpty ? source : translated;
    } catch (_) {
      if (to != 'hi') {
        try {
          final fallback = await _translator.translate(source, to: 'hi');
          final translated = fallback.text.trim();
          _cache[key] = translated.isEmpty ? source : translated;
          return;
        } catch (_) {
          // Fall through to source text.
        }
      }
      // Avoid repeated calls for keys that fail in this session.
      _cache[key] = source;
    } finally {
      _inFlight.remove(key);
      notifyListeners();
    }
  }

  String _mapToGoogleCode(String languageCode) {
    return switch (languageCode) {
      // Codes commonly unsupported by the package endpoint; use nearest Indian fallback.
      'kok' || 'mni' || 'brx' || 'mai' || 'sat' || 'doi' => 'hi',
      'ks' => 'ur',
      _ => languageCode,
    };
  }

  bool _looksLocalized(String text) {
    return RegExp(r'[\u0900-\u0D7F\u1780-\u17FF\u1E00-\u1EFF]').hasMatch(text);
  }
}
