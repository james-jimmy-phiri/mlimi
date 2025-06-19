import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlimi/pages/advisory/advivory_all.dart';
import 'package:mlimi/pages/advisory/finacial_literancy/themes_pages.dart';
import 'package:mlimi/pages/product_request/homepage.dart';
import 'package:mlimi/pages/profile/profile.dart';
import 'package:mlimi/pages/views/categoryCard/category_card.dart';
import 'package:mlimi/pages/views/my_current_location.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';
import 'package:mlimi/pages/views/slider_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mlimi/pages/weather/current_weather_screen.dart';
import 'package:quickalert/quickalert.dart';
import 'package:mlimi/pages/views/recently/recently_cell.dart';
import 'package:mlimi/provider/location_provider.dart';
import 'package:provider/provider.dart';

class FeaturedScreen extends StatefulWidget {
  final List<Sector> sectors;
  const FeaturedScreen({super.key, required this.sectors});

  @override
  _FeaturedScreenState createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  String? currentDistrict;
  String? currentRegion;
  List<Map<String, dynamic>> trendingData = [];
  bool isLoading = true;
  bool isdisplay = true;
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    fetchData();
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    final box = GetStorage();
    setState(() {
      selectedLanguage = box.read('language') ?? 'en';
    });
  }

  Future<void> fetchData() async {
    var url = Uri.parse('${apiurl}v1/');
    try {
      var response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Log the fetched data
        print('Fetched data: $data');
        final List trending = data['location']['trending'];

        // Update location provider
        final locationProvider =
            Provider.of<LocationProvider>(context, listen: false);
        locationProvider.setLocation(
          district: data['location']['current_district'],
          region: data['location']['current_region'],
        );

        setState(() {
          currentDistrict = data['location']['current_district'];
          currentRegion = data['location']['current_region'];
          trendingData = trending.map((item) {
            return {
              "id": item['id'].toString(),
              "title": item['title'],
              "message": item['message'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Poor Server connection . failed to fetch the trending Data')),
        );
        setState(() {
          isdisplay = false;
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Internet connection. Please try again.')),
      );
      setState(() {
        isLoading = false;
        isdisplay = false;
      });
    }
  }

  void changeLanguage(String language) {
    final box = GetStorage();
    box.write('language', language);
    setState(() {
      selectedLanguage = language;
    });
    // fetchData(); // Reload data with the new language
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Bgreen,
        body: isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/icons/loading1.json', // Replace with your Lottie file path
                  width: 100,
                  height: 100,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    CustomAppBar(
                      currentDistrict: currentDistrict,
                      currentRegion: currentRegion,
                      trendingData: trendingData,
                      isDisplaying: isdisplay,
                    ),
                    Body(sectors: widget.sectors),
                  ],
                ),
              ),
        drawer: Drawer(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 175, 188, 177),
                  Colors.green.shade400
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/adbanner.jpg'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3), BlendMode.darken),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      selectedLanguage == 'en' ? 'Menu' : 'Menyu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black45,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.white),
                  title: Text(
                    selectedLanguage == 'en' ? 'Settings' : 'Makonda',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(),
                      )),
                ),
                Divider(color: Colors.white.withOpacity(0.5)),
                ListTile(
                  leading: Icon(Icons.account_circle, color: Colors.white),
                  title: Text(
                    selectedLanguage == 'en' ? 'My Account' : 'Akaunti Yanga',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Homepage(),
                      )),
                ),
                Divider(color: Colors.white.withOpacity(0.5)),
                ListTile(
                  leading: Icon(Icons.language, color: Colors.white),
                  title: Text(
                    selectedLanguage == 'en'
                        ? 'Change to Chichewa'
                        : 'Pitani ku Chizungu',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () {
                    changeLanguage(selectedLanguage == 'en' ? 'ny' : 'en');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final List<Sector> sectors;
  const Body({Key? key, required this.sectors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    return Container(
      color: Bgreen,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedLanguage == 'en'
                      ? "Quick Actions"
                      : "Zochita Mwachangu",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllAdvisory(),
                    ),
                  ),
                  child: Text(
                    selectedLanguage == 'en' ? "View All" : "Onani Zonse",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: kPrimaryColor),
                  ),
                )
              ],
            ),
          ),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 6,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.95,
              crossAxisSpacing: 20,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return CategoryCard(
                category: categoryList[index],
              );
            },
            itemCount: categoryList.length,
          ),
          //Add a tabview here
          const SizedBox(
            height: 20,
          ),
      
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(children: [
              Text(
                selectedLanguage == 'en' ? "Advisory :" : "Malangizo :",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              )
            ]),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.width * 0.8,
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 2),
              scrollDirection: Axis.horizontal,
              itemCount: sectors.length + 2, // JSON items + 2 custom tiles
              itemBuilder: (context, index) {
                // Render JSON-based tiles first
                if (index < sectors.length) {
                  var sector = sectors[index];
                  return RecentlyCell(
                      sector: sector); // Render Sector-based tiles
                }
      
                // Handle custom ListTiles for the last two indices
                if (index == sectors.length) {
                  // First custom tile
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WeatherScreen()));
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        // color: Colors.red,
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 2),
                                        blurRadius: 5)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/weathercover.jpg',
                                  width: MediaQuery.of(context).size.width *
                                      0.32,
                                  height: MediaQuery.of(context).size.width *
                                      0.45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              selectedLanguage == 'en'
                                  ? "Weather :"
                                  : "Zanyengo :",
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                  );
                } else if (index == sectors.length + 1) {
                  // Second custom tile
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ThemesPage()));
                    },
                    child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        // color: Colors.red,
                        width: MediaQuery.of(context).size.width * 0.32,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 2),
                                        blurRadius: 5)
                                  ]),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  'assets/images/financial_literacy.jpg',
                                  width: MediaQuery.of(context).size.width *
                                      0.32,
                                  height: MediaQuery.of(context).size.width *
                                      0.45,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              "Financial Literacy",
                              maxLines: 3,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )),
                  );
                }
      
                return Container(); // Fallback (should never reach here)
              },
            ),
          ),
        ],
      ),
    );
  }
}

final Map<String, IconData> iconMap = {
  'sell': Icons.monetization_on_outlined,
  'buy': Icons.shopping_cart_checkout,
  'wallet': Icons.account_balance_wallet_rounded,
  'location': Icons.location_on_outlined,
  'calculate': Icons.calculate,
  'search': Icons.search,
  // Add more icons as needed
};

IconData? getIconDataFromString(String iconName) {
  return iconMap[iconName];
}

class CustomAppBar extends StatelessWidget {
  final String? currentDistrict;
  final String? currentRegion;
  final List<Map<String, dynamic>> trendingData;
  final bool isDisplaying;
  const CustomAppBar({
    super.key,
    required this.currentDistrict,
    required this.currentRegion,
    required this.trendingData,
    required this.isDisplaying,
  });

  @override
  Widget build(BuildContext context) {
    final storage = GetStorage();
    final String? name = storage.read('name');
    final String? phone = storage.read('phone');
    final selectedLanguage = GetStorage().read('language') ?? 'en';

    return Container(
      padding: const EdgeInsets.only(top: 45, left: 20, right: 20),
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.1, 0.5],
          colors: [
            Color.fromARGB(255, 129, 199, 132),
            Color.fromARGB(255, 89, 185, 94),
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    // Action when image is clicked
                    Scaffold.of(context).openDrawer();
                  },
                  child: Image.asset(
                    'assets/images/homelogo.png',
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                ),
                if (name != null &&
                    name.isNotEmpty &&
                    phone != null &&
                    phone.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                      Text(
                        phone,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SimpleRegisterScreen(),
                              ),
                            ),
                            child: Text(
                              selectedLanguage == 'en' ? "Sign Up" : "Lembetsa",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const Text(
                            "|",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SimpleLoginScreen(),
                              ),
                            ),
                            child: Text(
                              selectedLanguage == 'en' ? "Sign In" : "Lowani",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            MyCurrentLocation(),
            SliderScreen()
          ],
        ),
      ),
    );
  }
}
