import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/advisory_model.dart';
import 'package:mlimi/pages/advisory/advisory_widgets/advisory_category.dart';
import 'package:mlimi/pages/advisory/components/discount_card.dart';
import 'package:mlimi/pages/advisory/finacial_literancy/themes_pages.dart';
import 'package:mlimi/pages/weather/current_weather_screen.dart';
import 'package:get_storage/get_storage.dart';

class AdvisorySector extends StatefulWidget {
  final List<Sector> sectors;

  const AdvisorySector({
    super.key,
    required this.sectors,
  });

  @override
  State<AdvisorySector> createState() => _AdvisorySectorState();
}

class _AdvisorySectorState extends State<AdvisorySector> {
  late String _language;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Retrieve language preference from GetStorage
    _language = storage.read<String>('language') ?? 'en';
  }

  // Method to get localized text based on language preference
  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    const int customTileCount = 2;
    final int totalItemCount = widget.sectors.length + customTileCount;

    return Column(
      children: [
        const DiscountCard(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: totalItemCount,
              itemBuilder: (context, index) {
                if (index < widget.sectors.length) {
                  final sector = widget.sectors[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdvisoryCategory(
                            sector: sector,
                            selectedLanguage: _language,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _language == 'en'
                                      ? sector.name
                                      : (sector.nameNy ?? sector.name),
                                  style: TextStyle(
                                      color: TColor.text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _localizedText(
                                      'View more >', 'Onani zambiri >'),
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xff212121)
                                        .withOpacity(0.3),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/${sector.sectorimage}.jpg',
                              width: media.width * 0.35,
                              height: media.width * 0.15 * 1.6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final customIndex = index - widget.sectors.length;
                if (customIndex == 0) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WeatherScreen(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _localizedText('Weather', 'Zanyengo'),
                                  style: TextStyle(
                                      color: TColor.text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _localizedText(
                                      'View more >', 'Onani zambiri >'),
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xff212121)
                                        .withOpacity(0.3),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/weather.jpg',
                              width: media.width * 0.35,
                              height: media.width * 0.15 * 1.6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (customIndex == 1) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemesPage(),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  _localizedText('Financial Literacy',
                                      'Maphudzilo Adzachuma'),
                                  style: TextStyle(
                                      color: TColor.text,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _localizedText(
                                      'View more >', 'Onani zambiri >'),
                                  maxLines: 2,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: const Color(0xff212121)
                                        .withOpacity(0.3),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 15),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.asset(
                              'assets/images/financialcover.jpg',
                              width: media.width * 0.35,
                              height: media.width * 0.15 * 1.6,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ],
    );
  }
}

// Update CustomPage1 and CustomPage2 to use GetStorage as well
class CustomPage1 extends StatefulWidget {
  const CustomPage1({Key? key}) : super(key: key);

  @override
  State<CustomPage1> createState() => _CustomPage1State();
}

class _CustomPage1State extends State<CustomPage1> {
  late String _language;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _language = storage.read<String>('language') ?? 'en';
  }

  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_localizedText('Weather', 'Nyengo'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _localizedText('Failed to load Weather data. Please try again.',
                  'Palakwika potsitsa data ya nyengo. Chonde yesesni.'),
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(_localizedText('Try Again', 'Yesaninso')),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomPage2 extends StatefulWidget {
  const CustomPage2({Key? key}) : super(key: key);

  @override
  State<CustomPage2> createState() => _CustomPage2State();
}

class _CustomPage2State extends State<CustomPage2> {
  late String _language;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _language = storage.read<String>('language') ?? 'en';
  }

  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
              _localizedText('Financial Literacy', 'Ndalama ndi Bizinesi'))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _localizedText('Failed to load Financial Literacy information.',
                  'Palakwika potsitsa data ya ndalama.'),
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: Text(_localizedText('Try Again', 'Yesaninso')),
            ),
          ],
        ),
      ),
    );
  }
}
