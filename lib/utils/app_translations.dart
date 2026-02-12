import 'package:get_storage/get_storage.dart';

class AppTranslations {
  static final GetStorage _box = GetStorage();
  static const String _langKey = 'language'; // Changed from 'app_language_code'

  static String get currentLanguage => _box.read(_langKey) ?? 'en';

  static Future<void> changeLanguage(String langCode) async {
    await _box.write(_langKey, langCode);
  }

  static String getString(String key) {
    final lang = currentLanguage;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']![key] ?? key;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'select_crop': 'Select Crop',
      'to_calculate': 'To Calculate',
      'search': 'Search',
      'saved_records': 'Saved Records',
      'change_language': 'Change Language',
      'gross_margin_analysis': 'Gross Margin Analysis for',
      'field_size': 'Field Size',
      'hectares': 'Hectares',
      'total_income': 'Total Income',
      'total_expenditure': 'Total Expenditure',
      'profit_margin': 'Profit Margin',
      'save_record': 'Save Record',
      'record_saved': 'Record saved successfully!',
      'variable_costs': 'Total Variable Costs',
      'close': 'Close',
      'item': 'Item',
      'input_value': 'Input Value',
      'rate_per_acre': 'Rate per Acre',
      'total': 'Total',
      'saved_margins': 'Saved Margins',
      'no_records': 'No saved records found.',
      'delete': 'Delete',
      'view_details': 'View Details',
      'summary_paragraph': 'For a field size of @size hectares of @crop, with an estimated yield of @yield kg/ha and a selling price of MWK @price, the projected outcome is shown below.',
      'expenditure': 'Expenditure',
      'income': 'Income',
      'profit': 'Profit',
      'confirm_delete': 'Confirm Delete',
      'delete_prompt': 'Are you sure you want to delete this record?',
      'cancel': 'Cancel',
      'category_of': 'Category of',
      'variety_maturity': 'variety based on maturity period',
      'search_categories': 'Search for categories...',
      'average_yield': 'Average Yield',
      'per_hec': 'per Hec',
      'maize': 'Maize',
    },
    'ny': {
      'select_crop': 'Sankhani Mbewu',
      'to_calculate': 'Kuwerengera',
      'search': 'Fufuzani',
      'saved_records': 'Mbiri Yosungidwa',
      'change_language': 'Sinthani Chiyankhulo',
      'gross_margin_analysis': 'Kuwunika kwa Phindu la',
      'field_size': 'Kukula kwa Munda',
      'hectares': 'Mahekitala',
      'total_income': 'Ndalama Zonse',
      'total_expenditure': 'Ndalama Zodyerera',
      'profit_margin': 'Phindu Lonse',
      'save_record': 'Sungani Mbiri',
      'record_saved': 'Mbiri yasungidwa bwino!',
      'variable_costs': 'Ndalama Zosiyanasiyana',
      'close': 'Tsekani',
      'item': 'Chinthu',
      'input_value': 'Mtengo Wolowetsa',
      'rate_per_acre': 'Mtengo pa Acre',
      'total': 'Jumla',
      'saved_margins': 'Phindu Losungidwa',
      'no_records': 'Palibe mbiri yosungidwa.',
      'delete': 'Fufutani',
      'view_details': 'Onani Zambiri',
      'summary_paragraph': 'Pa munda wa mahekitala @size a @crop, ndi zokolola zoyembekezeka za @yield kg/ha komanso mtengo wogulitsa wa MWK @price, zotsatira zake zikuwonestsedwa pansipa.',
      'expenditure': 'Kugwiritsa Ntchito',
      'income': 'Ndalama',
      'profit': 'Phindu',
      'confirm_delete': 'Tsimikizani Kufufuta',
      'delete_prompt': 'Mukutsimikiza kuti mukufuna kufufuta mbiriyi?',
      'cancel': 'Letsani',
      'category_of': 'Gulu la',
      'variety_maturity': 'mtundu potengera nthawi yokhwima',
      'search_categories': 'Fufuzani magulu...',
      'average_yield': 'Avareji ya Zokolola',
      'per_hec': 'pa Hekitala',
      'maize': 'Chimanga', // Fixed Maize translation
    },
  };
}
