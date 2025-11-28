class LanguageService {
  static Map<String, Map<String, String>> translations = {
    'en': {
      'weather': 'Weather',
      'financialLiteracy': 'Financial Literacy',
      'viewMore': 'View more >',
      'loading': 'Loading...',
      'errorLoading': 'Error loading data',
      'noData': 'No data found',
      'tryAgain': 'Try Again',
      'menu': 'Menu',
      'settings': 'Settings',
      'myAccount': 'My Account',
      'changeLanguage': 'Sinthani chiyankhulo KuChichewa',
      'failedWeather': 'Failed to load Weather data. Please try again.',
      'failedFinancial': 'Failed to load Financial Literacy information.',
    },
    'ny': {
      'weather': 'Nyengo',
      'financialLiteracy': 'Ndalama ndi Bizinesi',
      'viewMore': 'Onani zambiri >',
      'loading': 'Kudikira...',
      'errorLoading': 'Palakwika potsitsa data',
      'noData': 'Palibe data yapezeka',
      'tryAgain': 'Yesaninso',
      'menu': 'Menyu',
      'settings': 'Makonda',
      'myAccount': 'Akaunti Yanga',
      'changeLanguage': 'Change to English',
      'failedWeather': 'Palakwika potsitsa data ya nyengo. Chonde yesesni.',
      'failedFinancial': 'Palakwika potsitsa data ya ndalama.',
    }
  };

  static String getText(String key, String language) {
    return translations[language]?[key] ?? translations['en']?[key] ?? key;
  }
}
