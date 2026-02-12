import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/gross_margin_model.dart';
import 'package:mlimi/pages/margin_calculator/category_selection_page.dart';
import 'package:mlimi/pages/margin_calculator/saved_records_page.dart';
import 'package:mlimi/utils/app_translations.dart';

class CropSelectionPage extends StatefulWidget {
  final List<Crop> crops;

  const CropSelectionPage({required this.crops, Key? key}) : super(key: key);

  @override
  State<CropSelectionPage> createState() => _CropSelectionPageState();
}

class _CropSelectionPageState extends State<CropSelectionPage> {
  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(AppTranslations.getString('change_language')),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                await AppTranslations.changeLanguage('en');
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('English', style: TextStyle(fontSize: 16)),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await AppTranslations.changeLanguage('ny');
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Chichewa', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToSaved() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedRecordsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // First widget at the top
            FadeInUp(
              duration: const Duration(milliseconds: 1000),
              child: Container(
                height: 300,
                width: double.infinity,
                padding: const EdgeInsets.only(left: 25, right: 25, top: 60),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    colors: [
                      Color.fromARGB(255, 129, 199, 132),
                      Color.fromARGB(255, 89, 185, 94),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: IconButton(
                            icon: SvgPicture.asset("assets/icons/back.svg"),
                            iconSize: 20,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onSelected: (value) {
                              if (value == 'saved') {
                                _navigateToSaved();
                              } else if (value == 'language') {
                                _changeLanguage();
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return [
                                PopupMenuItem(
                                  value: 'saved',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.save_alt, color: Colors.black54),
                                      const SizedBox(width: 10),
                                      Text(AppTranslations.getString('saved_records')),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'language',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.language, color: Colors.black54),
                                      const SizedBox(width: 10),
                                      Text(AppTranslations.getString('change_language')),
                                    ],
                                  ),
                                ),
                              ];
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 1200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.getString('select_crop'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromRGBO(69, 71, 69, 1),
                                  ),
                                ),
                                Text(
                                  AppTranslations.getString('to_calculate'),
                                  style: const TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(69, 71, 69, 1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 1300),
                            child: Image.asset('assets/icons/calculator.png'),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            // Search bar
            Transform.translate(
              offset: const Offset(0, -35),
              child: FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.only(left: 20, top: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 30.0,
                        offset: const Offset(0, 10.0),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(5.0),
                    color: Colors.white,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 20.0,
                      ),
                      border: InputBorder.none,
                      hintText: AppTranslations.getString('search'),
                    ),
                  ),
                ),
              ),
            ),

            FadeInUp(
              duration: const Duration(milliseconds: 1300),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 3.5 / 4, // Aspect ratio for image and text
                ),
                itemCount: widget.crops.length,
                itemBuilder: (context, index) {
                  Crop crop = widget.crops[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CategorySelectionPage(crop: crop),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                              child: Image.asset(
                                'assets/images/${crop.image}.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              crop.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
