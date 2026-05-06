import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'bottom_sheets.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Pool Details', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<AggregationProvider>(context, listen: false).fetchAggregationDetails(widget.aggregationId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Pool'),
                  content: const Text('Are you sure you want to delete this pool? This action cannot be undone and will delete all associated data including sales and contributions.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context); // Close dialog
                        final provider = Provider.of<AggregationProvider>(context, listen: false);
                        bool success = await provider.deleteAggregation(widget.aggregationId);
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pool deleted successfully'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context); // Go back to previous screen
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(provider.errorMessage ?? 'Failed to delete pool'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.currentAggregation == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.currentAggregation == null) {
            return Center(child: Text(provider.errorMessage!));
          }
          
          final agg = provider.currentAggregation;
          if (agg == null) return const Center(child: Text('Not found'));

          double totalRevenue = agg.sales.fold(0.0, (sum, sale) => sum + sale.totalAmount);

          return Column(
            children: [
              _buildHeaderCards(agg),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: kPrimaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: kPrimaryColor,
                  tabs: const [
                    Tab(text: 'Contributions'),
                    Tab(text: 'Sales'),
                    Tab(text: 'Earnings'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildContributionsTab(agg),
                    _buildSalesTab(agg),
                    _buildEarningsTab(agg, totalRevenue),
                  ],
                ),
              )
            ],
          );
        },
      ),
      floatingActionButton: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.extended(
                heroTag: 'fab_sale',
                backgroundColor: Colors.green,
                onPressed: () {
                  if (provider.currentAggregation != null) {
                    showRecordSaleSheet(context, provider.currentAggregation!);
                  }
                },
                icon: const Icon(Icons.sell, color: Colors.white),
                label: const Text('Record Sale', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'fab_contrib',
                backgroundColor: kPrimaryColor,
                onPressed: () {
                  if (provider.currentAggregation != null) {
                    showAddContributionSheet(context, provider.currentAggregation!);
                  }
                },
                icon: const Icon(Icons.add_circle, color: Colors.white),
                label: const Text('Add Contribution', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildHeaderCards(agg) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            agg.group?.name ?? 'Unknown Group',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Available Stock',
                  value: '${agg.remainingQuantity} kg',
                  color: Colors.orange,
                  icon: Icons.inventory_2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Total Aggregated',
                  value: '${agg.totalQuantity} kg',
                  color: Colors.blue,
                  icon: Icons.scale,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard({required String title, required String value, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildContributionsTab(agg) {
    if (agg.contributions.isEmpty) {
      return const Center(child: Text('No contributions yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: agg.contributions.length,
      separatorBuilder: (c, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contrib = agg.contributions[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: kPrimaryColor.withOpacity(0.2),
            child: Icon(Icons.person, color: kPrimaryColor),
          ),
          title: Text(contrib.groupMember?.name ?? 'Unknown Member', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(contrib.createdAt ?? 'Unknown date'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${contrib.quantity} kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (agg.status == 'open') ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () => showEditContributionSheet(context, agg, contrib),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSalesTab(agg) {
    if (agg.sales.isEmpty) {
      return const Center(child: Text('No sales yet.', style: TextStyle(color: Colors.grey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 120),
      itemCount: agg.sales.length,
      separatorBuilder: (c, i) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final sale = agg.sales[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.2),
            child: const Icon(Icons.monetization_on, color: Colors.green),
          ),
          title: Text(sale.buyer?.name ?? 'Unknown Buyer', style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('${sale.quantitySold} kg @ MWK ${sale.pricePerUnit}'),
          trailing: Text('MWK ${sale.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
        );
      },
    );
  }

  Widget _buildEarningsTab(agg, double totalRevenue) {
    if (agg.memberEarningsBreakdown.isEmpty) {
      if (agg.sales.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No revenue generated yet.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text('Record a sale to see earnings.', style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120, top: 8),
      itemCount: agg.memberEarningsBreakdown.length,
      itemBuilder: (context, index) {
        final earnings = agg.memberEarningsBreakdown[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.account_balance_wallet, color: Colors.green, size: 20),
            ),
            title: Text(earnings.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Contributed: ${earnings.contributionQuantity} kg (${earnings.sharePercentage.toStringAsFixed(1)}%)', 
                     style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            trailing: Text(
              'MWK ${earnings.earnedAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
            ),
          ),
        );
      },
    );
  }
}
