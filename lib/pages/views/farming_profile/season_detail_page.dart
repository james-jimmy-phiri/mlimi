import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/pages/views/farming_profile/add_edit_season_page.dart';
import 'package:mlimi/pages/views/farming_profile/add_activity_page.dart';
import 'package:mlimi/pages/views/farming_profile/add_expenditure_page.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class SeasonDetailPage extends StatefulWidget {
  final int seasonId;
  const SeasonDetailPage({Key? key, required this.seasonId}) : super(key: key);

  @override
  State<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends State<SeasonDetailPage>
    with SingleTickerProviderStateMixin {
  final FarmingProfileService _service = FarmingProfileService();
  final String _lang = GetStorage().read('language') ?? 'en';

  late TabController _tabController;
  FarmingSeason? _season;
  SeasonSalesSummary? _salesSummary;
  List<SeasonSale> _sales = [];
  List<SeasonExpenditure> _expenditures = [];
  bool _isLoading = true;
  String? _error;

  final _currencyFmt = NumberFormat('#,##0', 'en');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final details = await _service.getSeasonDetails(widget.seasonId);
      setState(() {
        _season = details['season'] as FarmingSeason;
        _salesSummary = details['summary'] as SeasonSalesSummary?;
        _sales = details['sales'] as List<SeasonSale>;
        _expenditures = details['expenditures'] as List<SeasonExpenditure>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  SeasonFinancialSummary get _financialSummary {
    final revenue = _salesSummary?.totalRevenue ?? 0.0;
    final expenses =
        _expenditures.fold<double>(0, (sum, e) => sum + e.amount);
    return SeasonFinancialSummary(
      totalRevenue: revenue,
      totalExpenses: expenses,
      salesCount: _salesSummary?.salesCount ?? 0,
      expenditureCount: _expenditures.length,
    );
  }

  void _navigateToAdd(String type) async {
    if (_season == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) =>
              AddActivityPage(seasonId: _season!.id, activityType: type)),
    );
    if (result == true) _loadAll();
  }

  void _navigateToAddExpenditure() async {
    if (_season == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddExpenditurePage(seasonId: _season!.id)),
    );
    if (result == true) _loadAll();
  }

  void _navigateToEdit() async {
    if (_season == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditSeasonPage(season: _season)),
    );
    if (result == true) _loadAll();
  }

  Future<void> _deleteItem(String type, int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _lang == 'en' ? 'Delete?' : 'Chotsani?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          _lang == 'en' ? 'This cannot be undone.' : 'Izi sizingabwezereke.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(_lang == 'en' ? 'Cancel' : 'Siyani',
                style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(_lang == 'en' ? 'Delete' : 'Chotsani',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      if (type == 'crop') await _service.deleteCrop(id);
      else if (type == 'livestock') await _service.deleteLivestock(id);
      else if (type == 'honey') await _service.deleteHoney(id);
      else if (type == 'expenditure') await _service.deleteExpenditure(id);
      _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      expandedHeight: 210,
                      pinned: true,
                      backgroundColor: kPrimaryColor,
                      iconTheme: const IconThemeData(color: Colors.white),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildHeroHeader(),
                      ),
                      title: Text(
                        _season?.name ?? '',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      actions: [
                        if (_season?.status != 'Completed')
                          IconButton(
                            icon: const Icon(Icons.edit_outlined,
                                color: Colors.white),
                            onPressed: _navigateToEdit,
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          onPressed: _loadAll,
                        ),
                      ],
                      bottom: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        isScrollable: true,
                        labelStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600, fontSize: 12),
                        tabs: [
                          Tab(text: _lang == 'en' ? 'Crops' : 'Mbewu'),
                          Tab(
                              text: _lang == 'en'
                                  ? 'Livestock'
                                  : 'Ziweto'),
                          Tab(text: _lang == 'en' ? 'Honey' : 'Uchi'),
                          Tab(
                              text: _lang == 'en'
                                  ? 'Expenses'
                                  : 'Ndalama'),
                          Tab(
                              text: _lang == 'en'
                                  ? 'Sales'
                                  : 'Malonda'),
                        ],
                      ),
                    ),
                  ],
                  body: Column(
                    children: [
                      _buildFinancialDashboard(),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCropsTab(),
                            _buildLivestockTab(),
                            _buildHoneyTab(),
                            _buildExpendituresTab(),
                            _buildSalesTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeroHeader() {
    final df = DateFormat('MMM dd, yyyy');
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kPrimaryColor, Color(0xFF1B5E20)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 60),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _season?.status ?? '',
                    style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _season?.type ?? '',
                  style:
                      GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  _lang == 'en'
                      ? 'Started: ${df.format(_season!.startDate)}'
                      : 'Yayamba: ${df.format(_season!.startDate)}',
                  style:
                      GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _heroStat('${_season?.crops.length ?? 0}',
                  _lang == 'en' ? 'Crops' : 'Mbewu'),
              const SizedBox(height: 8),
              _heroStat('${_season?.livestock.length ?? 0}',
                  _lang == 'en' ? 'Livestock' : 'Ziweto'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18)),
          Text(label,
              style:
                  GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFinancialDashboard() {
    final fs = _financialSummary;
    final profitColor =
        fs.isProfitable ? const Color(0xFF2E7D32) : Colors.red[700]!;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          _finCard(
            _lang == 'en' ? 'Revenue' : 'Phindu',
            'MWK ${_currencyFmt.format(fs.totalRevenue)}',
            const Color(0xFF1565C0),
            Icons.trending_up,
          ),
          const SizedBox(width: 8),
          _finCard(
            _lang == 'en' ? 'Expenses' : 'Ndalama',
            'MWK ${_currencyFmt.format(fs.totalExpenses)}',
            Colors.orange[800]!,
            Icons.arrow_downward,
          ),
          const SizedBox(width: 8),
          _finCard(
            fs.isProfitable
                ? (_lang == 'en' ? 'Profit' : 'Phindu')
                : (_lang == 'en' ? 'Loss' : 'Malephero'),
            'MWK ${_currencyFmt.format(fs.netProfit.abs())}',
            profitColor,
            fs.isProfitable
                ? Icons.emoji_events_outlined
                : Icons.warning_amber_outlined,
          ),
        ],
      ),
    );
  }

  Widget _finCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label,
                style: GoogleFonts.poppins(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            Text(value,
                style: GoogleFonts.poppins(
                    color: color, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TABS
  // ---------------------------------------------------------------------------

  Widget _buildCropsTab() {
    return _tabScaffold(
      items: _season?.crops ?? [],
      emptyLabel: _lang == 'en'
          ? 'No crops added yet'
          : 'Palibe mbewu yowonjezedwa',
      onAdd: _season?.status != 'Completed'
          ? () => _navigateToAdd('crop')
          : null,
      addLabel: _lang == 'en' ? 'Add Crop' : 'Onjeza Mbewu',
      builder: (i) {
        final crop = _season!.crops[i];
        return _dismissibleCard(
          key: 'crop-${crop.id}',
          onDelete: () => _deleteItem('crop', crop.id),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFE8F5E9),
            child: Icon(Icons.grass, color: Color(0xFF2E7D32)),
          ),
          title: crop.valueChain?.name ??
              (_lang == 'en' ? 'Unknown Crop' : 'Mbewu Zosadziwika'),
          subtitle:
              '${crop.areaCultivated} ${_lang == 'en' ? 'acres' : 'maekala'}'
              '${crop.totalExpectedHarvestQuantity != null ? ' • ${_lang == 'en' ? 'Expected' : 'Yokyekwa'}: ${crop.totalExpectedHarvestQuantity} ${crop.unitOfMeasurement ?? 'kg'}' : ''}',
          trailing: crop.productionMethod,
        );
      },
    );
  }

  Widget _buildLivestockTab() {
    return _tabScaffold(
      items: _season?.livestock ?? [],
      emptyLabel: _lang == 'en'
          ? 'No livestock added yet'
          : 'Palibe ziweto zowonjezedwa',
      onAdd: _season?.status != 'Completed'
          ? () => _navigateToAdd('livestock')
          : null,
      addLabel: _lang == 'en' ? 'Add Livestock' : 'Onjeza Chiweto',
      builder: (i) {
        final ls = _season!.livestock[i];
        return _dismissibleCard(
          key: 'ls-${ls.id}',
          onDelete: () => _deleteItem('livestock', ls.id),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFFFF3E0),
            child: Icon(Icons.pets, color: Color(0xFFEF6C00)),
          ),
          title: ls.valueChain?.name ??
              (_lang == 'en' ? 'Unknown Animal' : 'Chiweto Chosadziwika'),
          subtitle:
              '${_lang == 'en' ? 'Quantity' : 'Chiwerengero'}: ${ls.numberOfAnimals}'
              '${ls.animalVariety != null ? ' • ${ls.animalVariety}' : ''}',
        );
      },
    );
  }

  Widget _buildHoneyTab() {
    return _tabScaffold(
      items: _season?.honey ?? [],
      emptyLabel: _lang == 'en'
          ? 'No honey production added'
          : 'Palibe uchi wowonjezedwa',
      onAdd: _season?.status != 'Completed'
          ? () => _navigateToAdd('honey')
          : null,
      addLabel: _lang == 'en' ? 'Add Honey' : 'Onjeza Uchi',
      builder: (i) {
        final h = _season!.honey[i];
        return _dismissibleCard(
          key: 'honey-${h.id}',
          onDelete: () => _deleteItem('honey', h.id),
          leading: const CircleAvatar(
            backgroundColor: Color(0xFFFFF8E1),
            child: Icon(Icons.hive, color: Color(0xFFF57F17)),
          ),
          title: h.valueChain?.name ?? (_lang == 'en' ? 'Honey' : 'Uchi'),
          subtitle:
              '${h.numberOfBeehives} ${_lang == 'en' ? 'hives' : 'ming\'oma'} • ${_lang == 'en' ? 'Expected' : 'Yokyekwa'}: ${h.expectedProductionKg} kg',
        );
      },
    );
  }

  Widget _buildExpendituresTab() {
    final total =
        _expenditures.fold<double>(0, (s, e) => s + e.amount);
    return _tabScaffold(
      items: _expenditures,
      emptyLabel: _lang == 'en'
          ? 'No expenses recorded yet\nTap + to record your first expense'
          : 'Palibe ndalama zolemba\nDotani + kuzilembera',
      onAdd: _season?.status != 'Completed'
          ? _navigateToAddExpenditure
          : null,
      addLabel: _lang == 'en' ? 'Record Expense' : 'Lemba Ndalama',
      showTotal: _expenditures.isNotEmpty
          ? '${_lang == 'en' ? 'Total' : 'Kapiringanizo'}: MWK ${_currencyFmt.format(total)}'
          : null,
      builder: (i) {
        final exp = _expenditures[i];
        return _dismissibleCard(
          key: 'exp-${exp.id}',
          onDelete: () => _deleteItem('expenditure', exp.id),
          leading: CircleAvatar(
            backgroundColor: Colors.red[50],
            child:
                Icon(Icons.receipt_long_outlined, color: Colors.red[700]),
          ),
          title: exp.category,
          subtitle: exp.description.isNotEmpty
              ? exp.description
              : DateFormat('MMM dd, yyyy').format(exp.date),
          trailing: 'MWK ${_currencyFmt.format(exp.amount)}',
          trailingColor: Colors.red[700],
        );
      },
    );
  }

  Widget _buildSalesTab() {
    final totalRevenue =
        _sales.fold<double>(0, (s, sale) => s + sale.totalAmount);
    return _tabScaffold(
      items: _sales,
      emptyLabel: _lang == 'en'
          ? 'No sales recorded yet\nSales are recorded via the Commodity module'
          : 'Palibe malonda olemba\nMalonda amayambitsidwa kudzera pa Zinthu',
      onAdd: null, // Sales are not created from here; they come from commodities
      addLabel: '',
      showTotal: _sales.isNotEmpty
          ? '${_lang == 'en' ? 'Total Revenue' : 'Ndalama Yonse'}: MWK ${_currencyFmt.format(totalRevenue)}'
          : null,
      builder: (i) {
        final sale = _sales[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 1,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.green[50],
              child: Icon(Icons.sell_outlined, color: Colors.green[700]),
            ),
            title: Text(
              sale.valueChainName ??
                  (_lang == 'en' ? 'Sale' : 'Malonda'),
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Text(
              '${DateFormat('MMM dd, yyyy').format(sale.saleDate)}'
              '${sale.buyerName != null ? ' • ${sale.buyerName}' : ''}',
              style:
                  GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'MWK ${_currencyFmt.format(sale.totalAmount)}',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                      fontSize: 13),
                ),
                Text(
                  '${sale.quantitySold} kg @ ${_currencyFmt.format(sale.unitPrice)}',
                  style: GoogleFonts.poppins(
                      fontSize: 10, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabScaffold<T>({
    required List<T> items,
    required String emptyLabel,
    required VoidCallback? onAdd,
    required String addLabel,
    required Widget Function(int) builder,
    String? showTotal,
  }) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (showTotal != null)
                    Flexible(
                      child: Text(
                        showTotal,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: Colors.green[700],
                            fontSize: 13),
                      ),
                    )
                  else
                    Text(
                      '${items.length} ${_lang == 'en' ? 'record(s)' : 'rekodi'}',
                      style: GoogleFonts.poppins(
                          color: Colors.grey[600], fontSize: 13),
                    ),
                  if (onAdd != null && addLabel.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(addLabel,
                          style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        elevation: 0,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text(
                      emptyLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => builder(i),
                  childCount: items.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dismissibleCard({
    required String key,
    required VoidCallback onDelete,
    required Widget leading,
    required String title,
    required String subtitle,
    String? trailing,
    Color? trailingColor,
  }) {
    return Dismissible(
      key: Key(key),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            Text('Delete', style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 1,
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          leading: leading,
          title: Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(subtitle,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: Colors.grey[600])),
          trailing: trailing != null
              ? Text(
                  trailing,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: trailingColor ?? kPrimaryColor,
                      fontSize: 13),
                )
              : const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadAll,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              child: Text(
                _lang == 'en' ? 'Retry' : 'Yesaninso',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
