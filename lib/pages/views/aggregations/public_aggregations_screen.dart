import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'public_aggregation_view_screen.dart';
import 'aggregation_details_screen.dart';
import 'start_aggregation_screen.dart';

class PublicAggregationsScreen extends StatefulWidget {
  const PublicAggregationsScreen({super.key});

  @override
  State<PublicAggregationsScreen> createState() => _PublicAggregationsScreenState();
}

class _PublicAggregationsScreenState extends State<PublicAggregationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  String _searchQuery = '';

  // Filter modal state
  int? _filterValueChainId;    // null = show all
  String? _filterSector;       // null = show all sectors

  String get _language => GetStorage().read('language') ?? 'en';

  bool _showMyAggregations = false;

  int? get _myClientId {
    final raw = GetStorage().read('client_id');
    if (raw == null) return null;
    return raw is int ? raw : int.tryParse(raw.toString());
  }

  bool _isOwnerOf(Aggregation agg) {
    final myId = _myClientId;
    if (myId == null) return false;
    return myId == agg.groupId || myId == agg.createdBy || myId == agg.group?.id;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      provider.fetchAggregations();
      if (provider.valueChains.isEmpty) provider.fetchValueChains();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _statusOptions => [
        {'key': 'All', 'ny': 'Zonse', 'en': 'All'},
        {'key': 'Open', 'ny': 'tsegulani', 'en': 'Open'},
        {'key': 'Partial Sold', 'ny': 'zogulitsidwako', 'en': 'Partial'},
        {'key': 'Completed', 'ny': 'Zatsiliza', 'en': 'Done'},
      ];

  bool get _hasActiveFilters => _filterValueChainId != null || _filterSector != null;

  void _clearFilters() {
    setState(() {
      _filterValueChainId = null;
      _filterSector = null;
    });
  }

  void _showFilterModal() {
    final provider = Provider.of<AggregationProvider>(context, listen: false);
    final isNy = _language == 'ny';

    // Temporary state inside modal
    int? tempVcId = _filterValueChainId;
    String? tempSector = _filterSector;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final groups = provider.valueChainsBySector;
          final sectorOrder = ['crops', 'livestock', 'honey'];
          final sectorEmoji = {'crops': '🌾', 'livestock': '🐄', 'honey': '🍯'};
          final sectorLabel = {
            'crops': isNy ? 'Mbewu' : 'Crops',
            'livestock': isNy ? 'Ziweto' : 'Livestock',
            'honey': isNy ? 'Uchi' : 'Honey',
          };

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle + title
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isNy ? 'Sefa Zosonkhanitsa' : 'Filter Aggregations',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (tempVcId != null || tempSector != null)
                            TextButton(
                              onPressed: () => setModal(() { tempVcId = null; tempSector = null; }),
                              child: Text(isNy ? 'Chotsani' : 'Clear All', style: GoogleFonts.poppins(color: kPrimaryColor, fontSize: 13)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // ── Sector Quick-Filter Chips ─────────────────────────
                      Text(
                        isNy ? 'Msewu wa Mtengo' : 'Sector / Type',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // "All sectors" chip
                          _FilterChip(
                            label: isNy ? 'Zonse' : 'All',
                            selected: tempSector == null && tempVcId == null,
                            onTap: () => setModal(() { tempSector = null; tempVcId = null; }),
                          ),
                          ...sectorOrder.map((sector) {
                            final hasItems = (groups[sector] ?? []).isNotEmpty;
                            return _FilterChip(
                              label: '${sectorEmoji[sector] ?? ''} ${sectorLabel[sector] ?? sector}',
                              selected: tempSector == sector && tempVcId == null,
                              onTap: hasItems
                                  ? () => setModal(() { tempSector = sector; tempVcId = null; })
                                  : null,
                              disabled: !hasItems,
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Individual Value Chain ────────────────────────────
                      Text(
                        isNy ? 'Zokolola Zenizeni' : 'Specific Commodity',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 10),
                      if (provider.isLoadingValueChains)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      else if (provider.valueChains.isEmpty)
                        Text(
                          isNy ? 'Palibe mtengo wopezeka' : 'No value chains found',
                          style: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 13),
                        )
                      else
                        ...sectorOrder.map((sector) {
                          final vcs = groups[sector] ?? [];
                          if (vcs.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 12, bottom: 6),
                                child: Text(
                                  '${sectorEmoji[sector] ?? ''} ${sectorLabel[sector] ?? sector}',
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimaryColor),
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: vcs.map((vc) => _FilterChip(
                                  label: vc.name,
                                  selected: tempVcId == vc.id,
                                  onTap: () => setModal(() {
                                    tempVcId = vc.id;
                                    tempSector = sector;
                                  }),
                                )).toList(),
                              ),
                            ],
                          );
                        }),

                      // Include any extra sectors not in predefined list
                      ...groups.keys
                          .where((s) => !sectorOrder.contains(s))
                          .map((sector) {
                        final vcs = groups[sector]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12, bottom: 6),
                              child: Text(sector.toUpperCase(),
                                  style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: vcs.map((vc) => _FilterChip(
                                label: vc.name,
                                selected: tempVcId == vc.id,
                                onTap: () => setModal(() { tempVcId = vc.id; tempSector = sector; }),
                              )).toList(),
                            ),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                // Apply button
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _filterValueChainId = tempVcId;
                        _filterSector = tempSector;
                      });
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: Text(
                      isNy ? 'Yikani Zosankha' : 'Apply Filter',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNy = _language == 'ny';
    final title = isNy ? 'Zosonkhanitsa Zonse' : 'All Aggregations';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            Consumer<AggregationProvider>(
              builder: (ctx, provider, _) {
                final count = provider.aggregations.length;
                if (count == 0) return const SizedBox.shrink();
                return Text(
                  '$count ${isNy ? 'zosonkhanitsa' : 'aggregations'}',
                  style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
                );
              },
            ),
          ],
        ),
        actions: [
          // Filter icon with badge if filters active
          Consumer<AggregationProvider>(
            builder: (ctx, provider, _) => Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    color: _hasActiveFilters ? kPrimaryColor : Colors.black87,
                  ),
                  tooltip: isNy ? 'Sefa' : 'Filter',
                  onPressed: _showFilterModal,
                ),
                if (_hasActiveFilters)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Consumer<AggregationProvider>(
            builder: (ctx, provider, _) => IconButton(
              icon: AnimatedRotation(
                turns: provider.isLoading ? 1.0 : 0.0,
                duration: const Duration(seconds: 1),
                child: const Icon(Icons.refresh_rounded),
              ),
              onPressed: provider.isLoading
                  ? null
                  : () {
                      Provider.of<AggregationProvider>(context, listen: false).fetchAggregations();
                    },
            ),
          ),
          // 3-line options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu_rounded, color: Colors.black87),
            tooltip: isNy ? 'Zosankha Zina' : 'More Options',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'my_aggregations') {
                setState(() => _showMyAggregations = true);
              } else if (value == 'all_aggregations') {
                setState(() => _showMyAggregations = false);
              } else if (value == 'start') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StartAggregationScreen()),
                ).then((_) {
                  Provider.of<AggregationProvider>(context, listen: false).fetchAggregations();
                });
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem<String>(
                value: 'my_aggregations',
                child: Row(
                  children: [
                    Icon(Icons.account_circle_rounded,
                        color: _showMyAggregations ? kPrimaryColor : Colors.black87, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isNy ? 'Zosonkhanitsa Zanga' : 'My Aggregations',
                      style: GoogleFonts.poppins(
                        fontWeight: _showMyAggregations ? FontWeight.bold : FontWeight.normal,
                        color: _showMyAggregations ? kPrimaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'all_aggregations',
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_outlined,
                        color: !_showMyAggregations ? kPrimaryColor : Colors.black87, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isNy ? 'Zosonkhanitsa Zonse' : 'All Aggregations',
                      style: GoogleFonts.poppins(
                        fontWeight: !_showMyAggregations ? FontWeight.bold : FontWeight.normal,
                        color: !_showMyAggregations ? kPrimaryColor : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'start',
                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline_rounded, color: Colors.green, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      isNy ? 'Yambani Zosonkhanitsa' : 'Start Aggregation',
                      style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFAB(isNy),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          final myClientId = _myClientId;
          // Pre-filter to My Aggregations if active
          final sourceAggs = _showMyAggregations
              ? provider.aggregations.where((a) =>
                  myClientId != null &&
                  (a.groupId == myClientId ||
                      a.createdBy == myClientId ||
                      a.group?.id == myClientId)).toList()
              : provider.aggregations;

          final filtered = sourceAggs.where((agg) {
            // Status filter
            if (_selectedStatus != 'All') {
              if (agg.status.toLowerCase() != _selectedStatus.toLowerCase().replaceAll(' ', '_')) {
                return false;
              }
            }

            // Value chain ID filter (takes precedence over sector-only filter)
            if (_filterValueChainId != null) {
              if (agg.commodity?.valueChainId != _filterValueChainId) return false;
            } else if (_filterSector != null) {
              // Sector filter: match the sector via value chains list
              final matchingVcIds = provider.valueChainsBySector[_filterSector]?.map((vc) => vc.id).toSet() ?? {};
              if (!matchingVcIds.contains(agg.commodity?.valueChainId)) return false;
            }

            // Search filter
            if (_searchQuery.isNotEmpty) {
              final query = _searchQuery.toLowerCase();
              final cropName = (agg.commodity?.valueChainName ?? '').toLowerCase();
              final groupName = (agg.group?.name ?? '').toLowerCase();
              return cropName.contains(query) || groupName.contains(query);
            }
            return true;
          }).toList();

          debugPrint('[PublicAggregationsScreen] total=${provider.aggregations.length} filtered=${filtered.length} isLoading=${provider.isLoading} myAggs=$_showMyAggregations');

          return Column(
            children: [
              // Search & Filter bar
              _buildSearchFilterBar(isNy, provider),

              // My Aggregations banner
              if (_showMyAggregations)
                Container(
                  color: kPrimaryColor.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.account_circle_rounded, size: 16, color: kPrimaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isNy ? 'Munaona Zosonkhanitsa Zanu' : 'Showing your aggregations',
                          style: GoogleFonts.poppins(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showMyAggregations = false),
                        child: Text(
                          isNy ? 'Onani Zonse' : 'Show All',
                          style: GoogleFonts.poppins(fontSize: 11, color: kPrimaryColor, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),

              // Active filter indicator
              if (_hasActiveFilters) _buildActiveFilterBanner(isNy, provider),

              // Stats Summary Row
              if (provider.aggregations.isNotEmpty && !provider.isLoading)
                _buildSummaryRow(filtered, isNy),

              // List
              Expanded(
                child: provider.isLoading && provider.aggregations.isEmpty
                    ? _buildLoadingShimmer()
                    : filtered.isEmpty
                        ? _buildEmptyState(isNy)
                        : RefreshIndicator(
                            color: kPrimaryColor,
                            onRefresh: () async {
                              await provider.fetchAggregations();
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildAggregationCard(context, filtered[index], isNy, index);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterBanner(bool isNy, AggregationProvider provider) {
    String label;
    if (_filterValueChainId != null) {
      final vc = provider.valueChains.firstWhere(
        (v) => v.id == _filterValueChainId,
        orElse: () => ValueChainItem(id: 0, name: '?', category: '', sector: ''),
      );
      label = isNy ? 'Zoona: ${vc.name}' : 'Showing: ${vc.name}';
    } else {
      final sectorLabel = {
        'crops': isNy ? 'Mbewu' : 'Crops',
        'livestock': isNy ? 'Ziweto' : 'Livestock',
        'honey': isNy ? 'Uchi' : 'Honey',
      };
      label = isNy
          ? 'Msewu: ${sectorLabel[_filterSector] ?? _filterSector}'
          : 'Sector: ${sectorLabel[_filterSector] ?? _filterSector}';
    }

    return Container(
      color: kPrimaryColor.withValues(alpha: 0.05),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, size: 14, color: kPrimaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(isNy ? 'Chotsani' : 'Clear', style: GoogleFonts.poppins(fontSize: 11, color: kPrimaryColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilterBar(bool isNy, AggregationProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: isNy ? 'Fufuzani mbewu kapena gulu...' : 'Search commodity or farmer group...',
              hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search_rounded, color: kPrimaryColor),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF0F4FA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: kPrimaryColor.withValues(alpha: 0.4), width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusOptions.map((opt) {
                final isSelected = _selectedStatus == opt['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : const Color(0xFFF0F4FA),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSelected
                          ? [BoxShadow(color: kPrimaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                          : [],
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() => _selectedStatus = opt['key']!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(Icons.check_circle_rounded, size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isNy ? opt['ny']! : opt['en']!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(List<Aggregation> aggs, bool isNy) {
    final open = aggs.where((a) => a.status == 'open').length;
    final totalKg = aggs.fold<double>(0, (sum, a) => sum + a.remainingQuantity);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildSummaryChip(
            icon: Icons.inventory_2_outlined,
            label: '$open ${isNy ? 'Zotsegula' : 'open'}',
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _buildSummaryChip(
            icon: Icons.scale_outlined,
            label: '${totalKg.toStringAsFixed(0)} kg ${isNy ? 'yotsala' : 'available'}',
            color: Colors.blue,
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            _buildSummaryChip(
              icon: Icons.filter_alt_outlined,
              label: isNy ? 'Wasefedwa' : 'Filtered',
              color: kPrimaryColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryChip({required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, i) => Container(
        height: 110,
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: double.infinity, color: Colors.grey[200]),
                    const SizedBox(height: 8),
                    Container(height: 11, width: 140, color: Colors.grey[200]),
                    const Spacer(),
                    Container(height: 8, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isNy) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.inventory_2_outlined, size: 52, color: kPrimaryColor.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 18),
          Text(
            isNy ? 'Palibe zosonkhanitsa' : 'No aggregations found',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            isNy ? 'Yesani kusakasa mwa njira ina' : 'Try a different search or filter',
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedStatus = 'All';
                _filterValueChainId = null;
                _filterSector = null;
              });
            },
            icon: const Icon(Icons.clear_all_rounded),
            label: Text(isNy ? 'Chotsani Zosankha' : 'Clear All Filters'),
            style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregationCard(BuildContext context, Aggregation agg, bool isNy, int index) {
    final statusColor = _getStatusColor(agg.status);
    final cropName = agg.commodity?.valueChainName ?? (isNy ? 'Zokolola' : 'Commodity Pool');
    final groupName = agg.group?.name ?? (isNy ? 'Gulu la Alimi' : 'Farmer Group');
    final price = agg.commodity?.unitPrice ?? 0;
    final remaining = agg.remainingQuantity;
    final total = agg.totalQuantity;
    final stockPercent = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60).clamp(0, 400)),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              if (_showMyAggregations && _isOwnerOf(agg)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AggregationDetailsScreen(aggregationId: agg.id!)),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PublicAggregationViewScreen(aggregationId: agg.id!)),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Commodity image or gradient icon
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [kPrimaryColor.withValues(alpha: 0.15), kPrimaryColor.withValues(alpha: 0.05)],
                            ),
                          ),
                          child: agg.commodity?.imageUrl != null
                              ? Image.network(
                                  agg.commodity!.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.grass_rounded, color: kPrimaryColor, size: 30),
                                )
                              : Icon(Icons.grass_rounded, color: kPrimaryColor, size: 30),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cropName,
                                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                                  ),
                                  child: Text(
                                    _statusLabel(agg.status, isNy),
                                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 0.4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.groups_2_outlined, size: 13, color: Colors.grey[500]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    groupName,
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$remaining kg ${isNy ? 'yilipo' : 'left'}',
                                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange[800]),
                                ),
                                if (price > 0)
                                  Text(
                                    'MWK ${price.toStringAsFixed(0)}/kg',
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: kPrimaryColor),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Mini stock progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: stockPercent,
                          minHeight: 6,
                          backgroundColor: Colors.grey[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            stockPercent > 0.5 ? kPrimaryColor : stockPercent > 0.2 ? Colors.orange : Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(stockPercent * 100).toStringAsFixed(0)}% ${isNy ? 'yatsala' : 'remaining'} · ${total.toStringAsFixed(0)} kg ${isNy ? 'zonse' : 'total'}',
                        style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(String status, bool isNy) {
    switch (status.toLowerCase()) {
      case 'open':
        return isNy ? 'OTSEGUKA' : 'OPEN';
      case 'partial_sold':
        return isNy ? 'ZODULA' : 'PARTIAL';
      case 'completed':
        return isNy ? 'ZATHA' : 'DONE';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF2E7D32);
      case 'partial_sold':
        return const Color(0xFFE65100);
      case 'completed':
        return const Color(0xFF1565C0);
      default:
        return Colors.grey;
    }
  }

  /// Show Start Aggregation FAB only for group accounts.
  Widget? _buildFAB(bool isNy) {
    final rawClientType = GetStorage().read('client_type')?.toString().toLowerCase() ?? '';
    final token = GetStorage().read('token');
    final members = GetStorage().read('members');

    final isGroup = rawClientType.contains('group') || (members != null && members is List && members.isNotEmpty);

    // Only authenticated group accounts can start an aggregation
    if (token == null || !isGroup) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StartAggregationScreen()),
        ).then((_) {
          // Refresh list when returning from StartAggregationScreen
          Provider.of<AggregationProvider>(context, listen: false).fetchAggregations();
        });
      },
      backgroundColor: kPrimaryColor,
      elevation: 4,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: Text(
        isNy ? 'Yambani Zosonkhanitsa' : 'Start Aggregation',
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
      ),
    );
  }
}

// ─── Filter Chip Widget ───────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool disabled;

  const _FilterChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : (disabled ? Colors.grey[100] : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kPrimaryColor : (disabled ? Colors.grey[200]! : Colors.grey[300]!),
          ),
          boxShadow: selected
              ? [BoxShadow(color: kPrimaryColor.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected ? Colors.white : (disabled ? Colors.grey[400] : Colors.black87),
          ),
        ),
      ),
    );
  }
}
