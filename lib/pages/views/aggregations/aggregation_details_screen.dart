import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'bottom_sheets.dart';
import 'broadcast_config_modal.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/services/language_service.dart';

class AggregationDetailsScreen extends StatefulWidget {
  final int aggregationId;

  const AggregationDetailsScreen({Key? key, required this.aggregationId}) : super(key: key);

  @override
  State<AggregationDetailsScreen> createState() => _AggregationDetailsScreenState();
}

class _AggregationDetailsScreenState extends State<AggregationDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AggregationProvider>(context, listen: false).fetchAggregationDetails(widget.aggregationId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = GetStorage().read('language') ?? 'en';
    return Consumer<AggregationProvider>(
      builder: (context, provider, child) {
        final agg = provider.currentAggregation;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: provider.isLoading && agg == null
              ? const Center(child: CircularProgressIndicator())
              : agg == null
                  ? Center(child: Text(provider.errorMessage ?? LanguageService.getText('noData', language)))
                  : CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(agg, language),
                        SliverToBoxAdapter(child: _buildMainStats(agg, language)),
                        // Product details section (description, date, image)
                        if (_hasProductDetails(agg))
                          SliverToBoxAdapter(child: _buildProductDetails(agg, language)),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverTabDelegate(
                            TabBar(
                              controller: _tabController,
                              labelColor: kPrimaryColor,
                              unselectedLabelColor: Colors.grey[400],
                              indicatorColor: kPrimaryColor,
                              indicatorWeight: 3,
                              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
                              unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
                              tabs: [
                                Tab(text: LanguageService.getText('contributions', language)),
                                Tab(text: LanguageService.getText('salesHistory', language)),
                                Tab(text: LanguageService.getText('earnings', language)),
                              ],
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContributionsTab(agg, language),
                              _buildSalesTab(agg, language),
                              _buildEarningsTab(agg, language),
                            ],
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: agg != null ? _buildBottomActions(agg, language) : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(agg, String language) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: () => Provider.of<AggregationProvider>(context, listen: false).fetchAggregationDetails(widget.aggregationId),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
          onPressed: () => _confirmDelete(context, language),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (agg.commodity?.imageUrl != null)
              Image.network(agg.commodity!.imageUrl!, fit: BoxFit.cover)
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.85)],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.75)],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(agg.status).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      agg.status.toUpperCase(),
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    agg.commodity?.valueChainName ?? 'Aggregation Pool',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    agg.group?.name ?? 'Farmer Group',
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(agg, String language) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickStat(LanguageService.getText('stock', language), '${agg.remainingQuantity}', 'kg', Colors.orange),
            _buildDivider(),
            _buildQuickStat(LanguageService.getText('total', language), '${agg.totalQuantity}', 'kg', Colors.blue),
            _buildDivider(),
            _buildQuickStat(LanguageService.getText('price', language), '${agg.commodity?.unitPrice ?? 0}', 'MWK', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              children: [
                TextSpan(text: value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextSpan(text: ' $unit', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 28, width: 1, color: Colors.grey[200]);

  bool _hasProductDetails(agg) {
    return (agg.description != null && agg.description!.isNotEmpty) ||
        agg.expectedSupplyDate != null ||
        (agg.unitPrice != null && agg.unitPrice! > 0);
  }

  Widget _buildProductDetails(agg, String language) {
    final isNy = language == 'ny';
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 16, color: kPrimaryColor),
              const SizedBox(width: 8),
              Text(
                isNy ? 'Zambiri za Zokolola' : 'Product Details',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (agg.description != null && agg.description!.isNotEmpty) ...[
            _buildDetailRow(
              icon: Icons.description_outlined,
              label: isNy ? 'Mfotokozero' : 'Description',
              value: agg.description!,
              isMultiLine: true,
            ),
            const SizedBox(height: 10),
          ],
          if (agg.expectedSupplyDate != null) ...[
            _buildDetailRow(
              icon: Icons.calendar_today_rounded,
              label: isNy ? 'Tsiku la Kuperekedwa' : 'Expected Supply Date',
              value: _formatDate(agg.expectedSupplyDate!),
            ),
            const SizedBox(height: 10),
          ],
          if (agg.unitPrice != null && agg.unitPrice! > 0)
            _buildDetailRow(
              icon: Icons.payments_outlined,
              label: isNy ? 'Mtengo pa Yuniti' : 'Unit Price',
              value: 'MWK ${agg.unitPrice!.toStringAsFixed(2)} / kg',
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: kPrimaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: kPrimaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w500, letterSpacing: 0.3)),
              Text(value, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw);
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Widget _buildContributionsTab(agg, String language) {
    if (agg.contributions.isEmpty) {
      return _buildEmptyState(LanguageService.getText('noContributions', language), Icons.people_outline);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.contributions.length,
      itemBuilder: (context, index) {
        final c = agg.contributions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: kPrimaryColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.groupMember?.name ?? 'Unknown Member', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(c.createdAt ?? '', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${c.quantity} kg', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                  if (agg.status == 'open')
                    GestureDetector(
                      onTap: () => showEditContributionSheet(context, agg, c),
                      child: Text(LanguageService.getText('edit', language), style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesTab(agg, String language) {
    if (agg.sales.isEmpty) {
      return _buildEmptyState(LanguageService.getText('noSales', language), Icons.shopping_cart_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.sales.length,
      itemBuilder: (context, index) {
        final s = agg.sales[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.monetization_on_rounded, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.buyer?.name ?? 'Generic Buyer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${s.quantitySold} kg @ MWK ${s.pricePerUnit}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                    if (s.dateSold != null)
                      Text(s.dateSold!, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
              ),
              Text(
                'MWK ${s.totalAmount}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEarningsTab(agg, String language) {
    if (agg.memberEarningsBreakdown.isEmpty) {
      return _buildEmptyState(LanguageService.getText('noEarnings', language), Icons.account_balance_wallet_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.memberEarningsBreakdown.length,
      itemBuilder: (context, index) {
        final e = agg.memberEarningsBreakdown[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.memberName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('${e.contributionQuantity} kg (${e.sharePercentage}%)', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              const Spacer(),
              Text(
                'MWK ${e.earnedAmount}',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomActions(agg, String language) {
    final String status = agg.status as String;
    final bool isOpen = status == 'open';
    final bool isCompleted = status == 'completed';
    final bool isAlreadyBroadcast = agg.publishedAt != null;

    final bool canBroadcast = isOpen && agg.remainingQuantity > 0 && !isAlreadyBroadcast;
    final bool canAdd = isOpen;
    final bool canSell = !isCompleted && agg.remainingQuantity > 0;

    if (!canBroadcast && !canAdd && !canSell) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isAlreadyBroadcast ? Icons.campaign_rounded : Icons.check_circle_rounded,
                color: isAlreadyBroadcast ? kPrimaryColor : Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              isAlreadyBroadcast ? LanguageService.getText('broadcastSent', language) : LanguageService.getText('poolCompleted', language),
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (canBroadcast)
                  Expanded(
                    flex: canAdd || canSell ? 3 : 1,
                    child: ElevatedButton.icon(
                      onPressed: () => showBroadcastConfigModal(context, agg),
                      icon: const Icon(Icons.broadcast_on_personal_rounded, size: 18),
                      label: Text(
                        LanguageService.getText('finalizeBroadcast', language),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                    ),
                  ),
                if (canBroadcast && (canAdd || canSell)) const SizedBox(width: 10),
                if (canAdd)
                  Expanded(
                    flex: 2,
                    child: _actionButton(
                      icon: Icons.add_circle_outline_rounded,
                      label: LanguageService.getText('add', language),
                      color: kPrimaryColor,
                      onTap: () => showAddContributionSheet(context, agg),
                    ),
                  ),
                if (canAdd && canSell) const SizedBox(width: 8),
                if (canSell)
                  Expanded(
                    flex: 2,
                    child: _actionButton(
                      icon: Icons.sell_outlined,
                      label: LanguageService.getText('sell', language),
                      color: Colors.green,
                      onTap: () => showRecordSaleSheet(context, agg),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open': return Colors.green;
      case 'partial_sold': return Colors.orange;
      case 'completed': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _confirmDelete(BuildContext context, String language) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(LanguageService.getText('deletePool', language), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(LanguageService.getText('deleteConfirm', language), style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(LanguageService.getText('cancel', language), style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<AggregationProvider>(context, listen: false).deleteAggregation(widget.aggregationId);
              if (success && mounted) Navigator.pop(context);
            },
            child: Text(LanguageService.getText('delete', language), style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: const Color(0xFFF8F9FD), child: tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) => false;
}

