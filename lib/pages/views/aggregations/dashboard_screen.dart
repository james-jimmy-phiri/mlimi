import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'start_aggregation_screen.dart';
import 'aggregation_details_screen.dart';

class AggregationsDashboardScreen extends StatefulWidget {
  const AggregationsDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AggregationsDashboardScreen> createState() => _AggregationsDashboardScreenState();
}

class _AggregationsDashboardScreenState extends State<AggregationsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      provider.fetchDashboardStats();
      provider.fetchAggregations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Group Aggregation', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final provider = Provider.of<AggregationProvider>(context, listen: false);
              provider.fetchDashboardStats();
              provider.fetchAggregations();
            },
          )
        ],
      ),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.aggregations.isEmpty && provider.metrics == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.aggregations.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchDashboardStats();
              await provider.fetchAggregations();
            },
            child: CustomScrollView(
              slivers: [
                if (provider.metrics != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'System Overview',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGlassMetricCard(
                                  title: 'Total Volume',
                                  value: '${provider.metrics!.totalVolume} kg',
                                  icon: Icons.scale,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildGlassMetricCard(
                                  title: 'Remaining',
                                  value: '${provider.metrics!.remainingVolume} kg',
                                  icon: Icons.inventory_2,
                                  color: Colors.orangeAccent,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildGlassMetricCard(
                            title: 'Total Revenue',
                            value: 'MWK ${provider.metrics!.totalRevenue.toStringAsFixed(2)}',
                            icon: Icons.monetization_on,
                            color: Colors.green,
                            isWide: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                    child: const Text(
                      'Aggregations Ledgers',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.blueGrey),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final aggregation = provider.aggregations[index];
                      return _buildAggregationCard(context, aggregation);
                    },
                    childCount: provider.aggregations.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)) // Padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kPrimaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StartAggregationScreen()),
          );
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Start Aggregation', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildGlassMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text(value,
                          style: TextStyle(
                            fontSize: isWide ? 22 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAggregationCard(BuildContext context, aggregation) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AggregationDetailsScreen(aggregationId: aggregation.id!)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimaryColor.withOpacity(0.7), kPrimaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Icon(Icons.group_work, color: Colors.white, size: 30)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aggregation.group?.name ?? 'Group Aggregation',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${aggregation.status.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: aggregation.status == 'open' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Available: ${aggregation.remainingQuantity} kg',
                              style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          Text('Total: ${aggregation.totalQuantity} kg',
                              style: const TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
