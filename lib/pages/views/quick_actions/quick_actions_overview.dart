import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/category.dart';
import 'package:mlimi/models/category_icons.dart';

class QuickActionsOverviewPage extends StatefulWidget {
  const QuickActionsOverviewPage({super.key});

  @override
  State<QuickActionsOverviewPage> createState() =>
      _QuickActionsOverviewPageState();
}

class _QuickActionsOverviewPageState extends State<QuickActionsOverviewPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final selectedLanguage = GetStorage().read('language') ?? 'en';
    final categories = getCategoryList(selectedLanguage)
        .where(
          (category) => category.name.toLowerCase().contains(
                query.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          selectedLanguage == 'en' ? 'Quick Actions' : 'Zochita',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              child: _HeroPanel(language: selectedLanguage),
            ),
            const SizedBox(height: 24),
            FadeInDown(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 600),
              child: _SearchField(
                language: selectedLanguage,
                onChanged: (value) => setState(() => query = value),
              ),
            ),
            const SizedBox(height: 24),
            if (categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        selectedLanguage == 'en'
                            ? 'No actions found'
                            : 'Palibe zochita zomwe zapezeka',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              MasonryGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: 100 * index),
                    duration: const Duration(milliseconds: 500),
                    child: _ActionCard(
                      category: categories[index],
                      language: selectedLanguage,
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  final String language;
  const _HeroPanel({required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2E7D32),
            Color(0xFF66BB6A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
            offset: const Offset(0, 10),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              language == 'en' ? 'Featured' : 'Zapadera',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            language == 'en'
                ? 'Everything you need\nin one place'
                : 'Zonse zofunika\nzili pamodzi pano',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            language == 'en'
                ? 'Browse, compare and launch any action instantly.'
                : 'Yang’anani, yerekezerani ndikuyamba zochita nthawi yomweyo.',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final String language;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.language, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.poppins(fontSize: 15),
        decoration: InputDecoration(
          hintText: language == 'en'
              ? 'Search actions...'
              : 'Fufuzani zochita...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final Category_featured category;
  final String language;

  const _ActionCard({required this.category, required this.language});

  @override
  Widget build(BuildContext context) {
    final descriptions =
        language == 'en' ? _ActionDescriptions.en : _ActionDescriptions.ny;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => category.targetPage),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.06),
                offset: const Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getIconDataFromString(category.thumbnail) ?? Icons.apps,
                    color: kPrimaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  category.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  descriptions[category.thumbnail] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      language == 'en' ? 'Open' : 'Tsegulani',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: kPrimaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionDescriptions {
  static const Map<String, String> en = {
    'sell': 'Instantly post produce for sale and reach thousands of buyers.',
    'buy': 'Browse verified suppliers and negotiate deals in one tap.',
    'wallet': 'Track, save and move your farm finances securely.',
    'location': 'See weather, prices and trends customised to your district.',
    'calculate': 'Project profits using the margin calculator before you plant.',
    'search': 'Request scarce inputs and receive supply alerts.',
    'business': 'Showcase your agribusiness story with rich media profiles.',
    'geo': 'Receive location-aware tips built for your soils and climate.',
  };

  static const Map<String, String> ny = {
    'sell': 'Ikani zinthu zogulitsa kuti mupeze ogula ambiri nthawi yomweyo.',
    'buy': 'Yang’anani ogulitsa odalirika ndikukambirana mtengo mosavuta.',
    'wallet': 'Yendetsani ndalama zaulimi mosamala ndi Mlimi Wallet.',
    'location': 'Onani nyengo, mitengo ndi zinthu zina za dera lanu.',
    'calculate': 'Werengani phindu musanadzale pogwiritsa ntchito calculator.',
    'search': 'Pemphani zinthu zosowa ndikulandira zidziwitso zakapezeka.',
    'business': 'Onetsani bizinesi yanu yaulimi ndi zithunzi komanso ma vidiyo.',
    'geo': 'Landirani upangiri wochokera kumalo omwe mumalima.',
  };
}

