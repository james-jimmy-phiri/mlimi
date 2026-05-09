import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'start_aggregation_screen.dart';
import 'aggregation_details_screen.dart';
import 'group_insights_screen.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:google_fonts/google_fonts.dart';

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
        title: Text('Group Aggregation', style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
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
                          Text(
                            'System Overview',
                            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[700], letterSpacing: 0.5),
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
                    child: Text(
                      'Aggregations Ledgers',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey[700], letterSpacing: 0.5),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final aggregation = provider.aggregations[index];
                      return _buildAggregationCard(context, aggregation, provider);
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

  Widget _buildAggregationCard(BuildContext context, Aggregation aggregation, AggregationProvider provider) {
    final statusColor = _getStatusColor(aggregation.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AggregationDetailsScreen(aggregationId: aggregation.id!))),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(Icons.inventory_2_outlined, color: kPrimaryColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          aggregation.commodity?.valueChainName ?? 'Commodity Pool',
                          style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          aggregation.group?.name ?? 'Unknown Group',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                              child: Text(aggregation.status.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor)),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.scale_outlined, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 4),
                            Text('${aggregation.remainingQuantity} kg available', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black12),
                ],
              ),
            ),
          ),
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
}
