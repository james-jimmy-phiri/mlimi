import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'bottom_sheets.dart';
import 'broadcast_config_modal.dart';
import 'dart:ui';

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
    return Consumer<AggregationProvider>(
      builder: (context, provider, child) {
        final agg = provider.currentAggregation;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: provider.isLoading && agg == null
              ? const Center(child: CircularProgressIndicator())
              : agg == null
                  ? Center(child: Text(provider.errorMessage ?? 'Not found'))
                  : CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(agg),
                        SliverToBoxAdapter(child: _buildMainStats(agg)),
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
                              tabs: const [
                                Tab(text: 'Contributions'),
                                Tab(text: 'Sales History'),
                                Tab(text: 'Earnings'),
                              ],
                            ),
                          ),
                        ),
                        SliverFillRemaining(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildContributionsTab(agg),
                              _buildSalesTab(agg),
                              _buildEarningsTab(agg),
                            ],
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: agg != null ? _buildBottomActions(agg) : null,
        );
      },
    );
  }

  Widget _buildSliverAppBar(agg) {
    final bool isPublished = agg.status != 'open' && agg.status != 'closed'; // Simplified check

    return SliverAppBar(
      expandedHeight: 220,
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
          onPressed: () => _confirmDelete(context),
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
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 8),
                  Text(
                    agg.commodity?.valueChainName ?? 'Aggregation Pool',
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    agg.group?.name ?? 'Farmer Group',
                    style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainStats(agg) {
    return Container(
      transform: Matrix4.translationValues(0, -30, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            _buildQuickStat('Stock', '${agg.remainingQuantity}', 'kg', Colors.orange),
            _buildDivider(),
            _buildQuickStat('Total', '${agg.totalQuantity}', 'kg', Colors.blue),
            _buildDivider(),
            _buildQuickStat('Price', '${agg.commodity?.unitPrice ?? 0}', 'MWK', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: value, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextSpan(text: ' $unit', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: Colors.grey[200]);

  Widget _buildContributionsTab(agg) {
    if (agg.contributions.isEmpty) {
      return _buildEmptyState('No contributions yet', Icons.people_outline);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.contributions.length,
      itemBuilder: (context, index) {
        final c = agg.contributions[index];
        return Container(
          margin: const EdgeInsets.bottom(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: kPrimaryColor.withOpacity(0.1),
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
                      child: Text('Edit', style: GoogleFonts.poppins(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesTab(agg) {
    if (agg.sales.isEmpty) {
      return _buildEmptyState('No sales recorded', Icons.shopping_cart_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.sales.length,
      itemBuilder: (context, index) {
        final s = agg.sales[index];
        return Container(
          margin: const EdgeInsets.bottom(12),
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
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.monetization_on_rounded, color: Colors.green, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.buyer?.name ?? 'Generic Buyer', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('${s.quantitySold} kg @ MWK ${s.pricePerUnit}', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
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

  Widget _buildEarningsTab(agg) {
    if (agg.memberEarningsBreakdown.isEmpty) {
      return _buildEmptyState('No earnings data available', Icons.account_balance_wallet_outlined);
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: agg.memberEarningsBreakdown.length,
      itemBuilder: (context, index) {
        final e = agg.memberEarningsBreakdown[index];
        return Container(
          margin: const EdgeInsets.bottom(12),
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

  Widget _buildBottomActions(agg) {
    final bool canBroadcast = agg.status == 'open' && agg.remainingQuantity > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (canBroadcast)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => showBroadcastConfigModal(context, agg),
                icon: const Icon(Icons.broadcast_on_personal_rounded, size: 20),
                label: Text('Finalize & Broadcast', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          if (canBroadcast) const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.add_circle_outline_rounded,
                    label: 'Add',
                    color: kPrimaryColor,
                    onTap: () => showAddContributionSheet(context, agg),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    icon: Icons.sell_outlined,
                    label: 'Sell',
                    color: Colors.green,
                    onTap: () => showRecordSaleSheet(context, agg),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            Text(label, style: GoogleFonts.poppins(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Pool', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure? This will delete all contributions and sales data.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<AggregationProvider>(context, listen: false).deleteAggregation(widget.aggregationId);
              if (success && mounted) Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
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

