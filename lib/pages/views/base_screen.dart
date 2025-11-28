import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/icons.dart';
import 'package:mlimi/constants/size.dart';
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/pages/advisory/advivory_all.dart';
import 'package:mlimi/pages/market/market.dart';
import 'package:mlimi/pages/profile/profile.dart';
import 'package:mlimi/pages/views/featured_screen.dart';
import 'package:flutter/material.dart';
import 'package:mlimi/services/advisory_service.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key});

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 0;
  late Future<List<Sector>> _sectorsFuture;
  String selectedLanguage = 'en'; // Default language

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _sectorsFuture = DataService().loadSectorsFromJson();
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    final box = GetStorage();
    setState(() {
      selectedLanguage = box.read('language') ?? 'en';
    });
  }

  // Widgets with data passed to them
  List<Widget> _buildScreens(List<Sector> sectors) {
    return [
      FeaturedScreen(sectors: sectors), // Pass the data to FeaturedScreen
      AllAdvisory(),
      Market(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sector>>(
      future: _sectorsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error loading data')),
          );
        } else if (snapshot.hasData) {
          // Build screens with the fetched data
          return Scaffold(
            body: Center(
              child: _buildScreens(snapshot.data!).elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimaryColor,
              backgroundColor: Colors.white,
              elevation: 0,
              items: [
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    icFeatured,
                    height: kBottomNavigationBarItemSize,
                  ),
                  icon: Image.asset(
                    icFeaturedOutlined,
                    height: kBottomNavigationBarItemSize,
                  ),
                  label: selectedLanguage == 'en' ? "Home" : "Home",
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    icWishlist,
                    height: kBottomNavigationBarItemSize,
                  ),
                  icon: Image.asset(
                    icWishlistOutlined,
                    height: kBottomNavigationBarItemSize,
                  ),
                  label: selectedLanguage == 'en' ? "Advisory" : "Ulangizi",
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    icMarketOutlined,
                    height: kBottomNavigationBarItemSize,
                  ),
                  icon: Image.asset(
                    icMarket,
                    height: kBottomNavigationBarItemSize,
                  ),
                  label: selectedLanguage == 'en' ? "Markets" : "Pamsika",
                ),
                BottomNavigationBarItem(
                  activeIcon: Image.asset(
                    icSetting,
                    height: kBottomNavigationBarItemSize,
                  ),
                  icon: Image.asset(
                    icSettingOutlined,
                    height: kBottomNavigationBarItemSize,
                  ),
                  label:
                      selectedLanguage == 'en' ? "My Profile" : "Mbiri Yanga",
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          );
        } else {
          return Scaffold(
            body: Center(child: Text('No data found')),
          );
        }
      },
    );
  }
}
