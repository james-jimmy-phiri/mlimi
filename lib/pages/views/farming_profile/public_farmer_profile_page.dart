import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/services/farming_profile_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicFarmerProfilePage extends StatefulWidget {
  final PublicFarmerProfile farmer;
  const PublicFarmerProfilePage({Key? key, required this.farmer})
      : super(key: key);

  @override
  State<PublicFarmerProfilePage> createState() =>
      _PublicFarmerProfilePageState();
}

class _PublicFarmerProfilePageState extends State<PublicFarmerProfilePage> {
  final FarmingProfileService _service = FarmingProfileService();
  final String _lang = GetStorage().read('language') ?? 'en';

  List<FarmingSeason> _seasons = [];
  bool _isLoadingSeasons = true;
  String? _seasonsError;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    setState(() {
      _isLoadingSeasons = true;
      _seasonsError = null;
    });
    try {
      final seasons = await _service.getPublicFarmerSeasons(widget.farmer.id);
      setState(() {
        _seasons = seasons;
        _isLoadingSeasons = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSeasons = false;
        _seasonsError = e.toString();
      });
    }
  }

  Future<void> _callFarmer() async {
    if (widget.farmer.phone == null) return;
    final phone = widget.farmer.phone!.replaceAll(' ', '');
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _whatsappFarmer() async {
    if (widget.farmer.phone == null) return;
    final phone =
        widget.farmer.phone!.replaceAll(RegExp(r'[^0-9]'), '');
    final intlPhone =
        phone.startsWith('0') ? '265${phone.substring(1)}' : phone;
    final uri = Uri.parse('https://wa.me/$intlPhone');
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = widget.farmer;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          // --- Hero header -------------------------------------------------
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: kPrimaryColor,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, Color(0xFF1B5E20)],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor:
                            Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          farmer.name.isNotEmpty
                              ? farmer.name[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.poppins(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        farmer.name,
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                      if (farmer.district != null || farmer.region != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                [farmer.district, farmer.region]
                                    .where((e) => e != null)
                                    .join(', '),
                                style: GoogleFonts.poppins(
                                    color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 6),
                      // Active badge
                      if (farmer.activeSeasonCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _lang == 'en'
                                ? '🌱 Active Farmer'
                                : '🌱 Mlimi Wogwira',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            title: Text(
              farmer.name,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            ),
          ),

          // --- Stats bar ---------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(
                    '${farmer.seasonCount}',
                    _lang == 'en' ? 'Total\nSeasons' : 'Nyengo\nZonse',
                    Icons.calendar_month_outlined,
                  ),
                  _divider(),
                  _statItem(
                    '${farmer.activeSeasonCount}',
                    _lang == 'en' ? 'Active\nSeasons' : 'Nyengo\nZogwira',
                    Icons.agriculture,
                  ),
                  _divider(),
                  _statItem(
                    '${farmer.primaryCrops.length}',
                    _lang == 'en' ? 'Crop\nTypes' : 'Mitundu\nya Mbewu',
                    Icons.grass,
                  ),
                ],
              ),
            ),
          ),

          // --- Contact buttons ---------------------------------------------
          if (farmer.phone != null)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _callFarmer,
                        icon: const Icon(Icons.call_outlined, size: 18),
                        label: Text(
                          _lang == 'en' ? 'Call Farmer' : 'Imbani Mlimi',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kPrimaryColor,
                          side: const BorderSide(color: kPrimaryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _whatsappFarmer,
                        icon: const Icon(Icons.chat_outlined, size: 18),
                        label: Text(
                          'WhatsApp',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding:
                              const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // --- Crops & Livestock section -----------------------------------
          if (farmer.primaryCrops.isNotEmpty ||
              farmer.primaryLivestock.isNotEmpty)
            SliverToBoxAdapter(
              child: _sectionCard(
                title: _lang == 'en'
                    ? 'What This Farmer Grows'
                    : 'Zimene Mlimi Amakula',
                icon: Icons.eco_outlined,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...farmer.primaryCrops
                        .map((c) => _chip(c, Icons.grass, Colors.green)),
                    ...farmer.primaryLivestock
                        .map((l) => _chip(l, Icons.pets, Colors.orange)),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // --- Seasons section header --------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _lang == 'en' ? 'Farming Seasons' : 'Nyengo za Ulimi',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  if (_isLoadingSeasons)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh,
                          size: 20, color: kPrimaryColor),
                      onPressed: _loadSeasons,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // --- Seasons list -----------------------------------------------
          if (_isLoadingSeasons)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_seasonsError != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                child: Center(
                  child: Text(
                    _lang == 'en'
                        ? 'Could not load seasons. Tap refresh above.'
                        : 'Sitinatha kutsegula nyengo. Dotani nchipsinjo chakumutha.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              ),
            )
          else if (_seasons.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 24),
                child: Center(
                  child: Text(
                    _lang == 'en'
                        ? 'No public seasons available for this farmer yet.'
                        : 'Palibe nyengo zogawana kwa mlimi uyu panopa.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 13),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildPublicSeasonCard(_seasons[i]),
                  childCount: _seasons.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPublicSeasonCard(FarmingSeason season) {
    final df = DateFormat('MMM yyyy');
    final statusColor = season.status == 'Active'
        ? kPrimaryColor
        : season.status == 'Harvesting'
            ? Colors.orange[700]!
            : const Color(0xFF1565C0);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    season.name,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    season.status,
                    style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${df.format(season.startDate)} • ${season.type}',
              style:
                  GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),
            if (season.description != null &&
                season.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                season.description!,
                style: GoogleFonts.poppins(
                    color: Colors.grey[700], fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (season.crops.isNotEmpty || season.livestock.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  // FIX: Correct operator precedence with explicit parentheses
                  ...season.crops.take(3).map((c) => _chip(
                        c.valueChain?.name ??
                            (_lang == 'en' ? 'Crop' : 'Mbewu'),
                        Icons.grass,
                        Colors.green,
                      )),
                  ...season.livestock.take(2).map((l) => _chip(
                        l.valueChain?.name ??
                            (_lang == 'en' ? 'Livestock' : 'Chiweto'),
                        Icons.pets,
                        Colors.orange,
                      )),
                  ...season.honey.take(1).map((h) => _chip(
                        h.valueChain?.name ??
                            (_lang == 'en' ? 'Honey' : 'Uchi'),
                        Icons.hive_outlined,
                        Colors.amber,
                      )),
                ],
              ),
            ],
            // NOTE: Financial data (expenses, prices, profits) is intentionally
            // hidden from public view to protect farmer privacy.
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color[800]),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: kPrimaryColor, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: kPrimaryColor),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style:
              GoogleFonts.poppins(color: Colors.grey[600], fontSize: 11),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(height: 40, width: 1, color: Colors.grey[200]);
}
