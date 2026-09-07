import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/models/inventory_models.dart';
import 'package:mlimi/services/inventory_service.dart';
import 'package:mlimi/utils/error_utils.dart';
import 'package:intl/intl.dart';

import 'product_list_page.dart';
import 'stock_movement_page.dart';

class InventoryDashboardPage extends StatefulWidget {
  final BusinessProfile profile;

  const InventoryDashboardPage({super.key, required this.profile});

  @override
  State<InventoryDashboardPage> createState() => _InventoryDashboardPageState();
}

class _InventoryDashboardPageState extends State<InventoryDashboardPage> {
  final _inventoryService = InventoryService();
  final _language = GetStorage().read('language') ?? 'en';
  final _currencyFormat = NumberFormat.currency(symbol: 'MK ', decimalDigits: 2);

  bool _isLoading = true;
  String? _errorMessage;
  InventoryDashboardStats? _stats;
  List<InventoryStockMove> _recentMoves = [];
  List<InventoryProduct> _lowStockProducts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _inventoryService.getDashboard(widget.profile.id!);
      setState(() {
        _stats = data['stats'];
        _recentMoves = data['recentMoves'];
        _lowStockProducts = data['lowStockProducts'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorUtils.getFriendlyErrorMessage(e, _language);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          'StockFlow Pro',
          style: GoogleFonts.inter(
            color: const Color(0xFF003EC7),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.9),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: GoogleFonts.inter(color: Colors.grey[700])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.profile.businessName,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back. Here\'s your stock overview for today.',
              style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF434656)),
            ),
            const SizedBox(height: 24),

            // Metrics Grid
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    'Total Products',
                    _stats?.totalProducts.toString() ?? '0',
                    Icons.inventory_2,
                    const Color(0xFF003EC7),
                    const Color(0xFFDDE1FF),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard(
                    'Value (MK)',
                    _formatCompact(_stats?.totalStockValue ?? 0),
                    Icons.account_balance_wallet,
                    const Color(0xFF3F4F65),
                    const Color(0xFFD3E4FE),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSalesCard(),

            const SizedBox(height: 32),
            _buildQuickActions(),

            if (_lowStockProducts.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text(
                'Low Stock Alerts',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
              ),
              const SizedBox(height: 16),
              ..._lowStockProducts.map((p) => _buildLowStockItem(p)),
            ],

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Movements',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StockMovementPage(profile: widget.profile)),
                    );
                  },
                  child: Text('View All', style: GoogleFonts.inter(color: const Color(0xFF003EC7))),
                )
              ],
            ),
            const SizedBox(height: 16),
            ..._recentMoves.map((m) => _buildMovementItem(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color iconColor, Color iconBg) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC3C5D9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5C647A)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC3C5D9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SALES TODAY',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5C647A)),
              ),
              const SizedBox(height: 4),
              Text(
                _currencyFormat.format(_stats?.todaySalesValue ?? 0),
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
              ),
            ],
          ),
          // Simple mock bar chart graphic
          SizedBox(
            height: 40,
            width: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBar(0.4, false),
                _buildBar(0.6, false),
                _buildBar(0.5, false),
                _buildBar(0.8, false),
                _buildBar(1.0, true),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, bool isPrimary) {
    return Container(
      width: 8,
      height: 40 * heightFactor,
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF003EC7) : const Color(0xFFDDE1FF),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionItem('Products', Icons.inventory, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ProductListPage(profile: widget.profile)),
          );
        }),
        _buildActionItem('Movements', Icons.sync_alt, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => StockMovementPage(profile: widget.profile)),
          );
        }),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC3C5D9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Icon(icon, color: const Color(0xFF003EC7)),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(InventoryProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFDAD6)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFBA1A1A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFBA1A1A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'SKU: ${product.sku ?? 'N/A'}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.currentStock} ${product.unit}',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFFBA1A1A)),
              ),
              Text(
                'Min: ${product.lowStockThreshold ?? 0}',
                style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFFBA1A1A)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMovementItem(InventoryStockMove move) {
    bool isIn = move.type == 'received' || move.type == 'returned';
    Color bgColor = isIn ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6);
    Color iconColor = isIn ? const Color(0xFF137333) : const Color(0xFFC5221F);
    IconData icon = isIn ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC3C5D9)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  move.product?.name ?? 'Unknown Product',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${move.type.toUpperCase()} • ${move.movedAt != null ? DateFormat('MMM d, h:mm a').format(DateTime.parse(move.movedAt!).toLocal()) : ''}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${isIn ? '+' : '-'}${move.quantity}',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: iconColor),
          ),
        ],
      ),
    );
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }
}
