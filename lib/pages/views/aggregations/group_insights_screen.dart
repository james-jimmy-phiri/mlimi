import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class GroupInsightsScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupInsightsScreen({Key? key, required this.groupId, required this.groupName}) : super(key: key);

  @override
  State<GroupInsightsScreen> createState() => _GroupInsightsScreenState();
}

class _GroupInsightsScreenState extends State<GroupInsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AggregationProvider>(context, listen: false).fetchDashboardStats(groupId: widget.groupId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.groupName} Insights', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.groupMetrics == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.groupMetrics == null) {
            return Center(child: Text(provider.errorMessage!));
          }
          
          final metrics = provider.groupMetrics;
          if (metrics == null) return const Center(child: Text('No data found'));

          return RefreshIndicator(
            onRefresh: () => provider.fetchDashboardStats(groupId: widget.groupId),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummarySection(metrics),
                  const SizedBox(height: 32),
                  const Text('Volume Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildVolumeBarChart(metrics),
                  const SizedBox(height: 32),
                  const Text('Aggregation Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildStatusPieChart(metrics),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummarySection(AggregationMetrics metrics) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Aggregations',
                value: '${metrics.totalAggregations}',
                icon: Icons.layers,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildMetricTile(
                title: 'Revenue',
                value: 'MWK ${metrics.totalRevenue.toStringAsFixed(0)}',
                icon: Icons.monetization_on,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMetricTile(
          title: 'Total Group Volume',
          value: '${metrics.totalVolume} kg',
          icon: Icons.scale,
          color: Colors.orange,
          isWide: true,
        ),
      ],
    );
  }

  Widget _buildMetricTile({required String title, required String value, required IconData icon, required Color color, bool isWide = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeBarChart(AggregationMetrics metrics) {
    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: metrics.totalVolume * 1.2,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0: return const Text('Aggregated');
                    case 1: return const Text('Sold');
                    case 2: return const Text('Remain');
                    default: return const Text('');
                  }
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: metrics.totalVolume, color: Colors.blue, width: 22, borderRadius: BorderRadius.circular(6))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: metrics.totalSoldVolume, color: Colors.green, width: 22, borderRadius: BorderRadius.circular(6))]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: metrics.remainingVolume, color: Colors.orange, width: 22, borderRadius: BorderRadius.circular(6))]),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(AggregationMetrics metrics) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    value: metrics.activeAggregations.toDouble(),
                    title: '${metrics.activeAggregations}',
                    color: Colors.orange,
                    radius: 50,
                    titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: metrics.completedAggregations.toDouble(),
                    title: '${metrics.completedAggregations}',
                    color: Colors.green,
                    radius: 50,
                    titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend(color: Colors.orange, text: 'Active Pools'),
              const SizedBox(height: 8),
              _buildLegend(color: Colors.green, text: 'Completed'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegend({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
