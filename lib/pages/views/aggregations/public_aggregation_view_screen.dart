import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/aggregation_models.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'bottom_sheets.dart';
import 'aggregation_details_screen.dart';

class PublicAggregationViewScreen extends StatefulWidget {
  final int aggregationId;

  const PublicAggregationViewScreen({super.key, required this.aggregationId});

  @override
  State<PublicAggregationViewScreen> createState() => _PublicAggregationViewScreenState();
}

class _PublicAggregationViewScreenState extends State<PublicAggregationViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String get _language => GetStorage().read('language') ?? 'en';

  int? get _myClientId {
    final raw = GetStorage().read('client_id');
    if (raw == null) return null;
    return raw is int ? raw : int.tryParse(raw.toString());
  }

  bool _isOwner(Aggregation agg) {
    final myId = _myClientId;
    if (myId == null) return false;
    return myId == agg.groupId ||
        myId == agg.createdBy ||
        myId == agg.group?.id;
  }

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AggregationProvider>(context, listen: false)
          .fetchAggregationDetails(widget.aggregationId)
          .then((_) => _slideController.forward());
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNy = _language == 'ny';

    return Consumer<AggregationProvider>(
      builder: (context, provider, child) {
        final agg = provider.currentAggregation;

        return Scaffold(
          backgroundColor: const Color(0xFFF0F4FA),
          body: provider.isLoading && agg == null
              ? _buildLoadingState()
              : agg == null
                  ? _buildErrorState(provider.errorMessage, isNy)
                  : CustomScrollView(
                      slivers: [
                        _buildSliverAppBar(agg, isNy),
                        SliverToBoxAdapter(
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: FadeTransition(
                              opacity: _slideController,
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStockProgressCard(agg, isNy),
                                    const SizedBox(height: 14),
                                    _buildPricingAndStockRow(agg, isNy),
                                    const SizedBox(height: 14),
                                    _buildGroupInformationCard(agg, isNy),
                                    const SizedBox(height: 14),
                                    _buildKeyDetailsCard(agg, isNy),
                                    const SizedBox(height: 14),
                                    _buildDescriptionCard(agg, isNy),
                                    const SizedBox(height: 100),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: agg != null ? _buildBottomActionBar(agg, isNy) : null,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F4FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String? message, bool isNy) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded, size: 52, color: Colors.orange),
            ),
            const SizedBox(height: 16),
            Text(
              isNy ? 'Zinakukira Cholakwika' : 'Could not load pool',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? (isNy ? 'Yesani kachiwiri' : 'Please try again'),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<AggregationProvider>(context, listen: false)
                    .fetchAggregationDetails(widget.aggregationId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(isNy ? 'Yesaninso' : 'Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Aggregation agg, bool isNy) {
    final cropName = agg.commodity?.valueChainName ?? (isNy ? 'Gulu la Katundu' : 'Aggregation Pool');
    final groupName = agg.group?.name ?? (isNy ? 'Gulu la Alimi' : 'Farmer Group');

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      elevation: 0,
      backgroundColor: kPrimaryColor,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
            onPressed: () {
              Provider.of<AggregationProvider>(context, listen: false)
                  .fetchAggregationDetails(widget.aggregationId);
            },
          ),
        ),
        // Manage button in header (visible to owners only)
        Consumer<AggregationProvider>(
          builder: (ctx, provider, _) {
            final agg = provider.currentAggregation;
            if (agg == null || !_isOwner(agg)) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 20),
                tooltip: _language == 'ny' ? 'Samalani Zosonkhanitsa' : 'Manage Aggregation',
                onPressed: () {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => AggregationDetailsScreen(aggregationId: agg.id!),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            if (agg.commodity?.imageUrl != null)
              Image.network(
                agg.commodity!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [const Color(0xFF1B5E20), kPrimaryColor],
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [const Color(0xFF1B5E20), kPrimaryColor, const Color(0xFF4CAF50)],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            // Dark gradient overlay for readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
            // Bottom hero info
            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildHeroBadge(_statusLabel(agg.status, isNy), _getStatusColor(agg.status)),
                      if (agg.publishedAt != null)
                        _buildHeroBadge(
                          isNy ? '📡 YAFALITSIDWA' : '📡 BROADCASTED',
                          Colors.purple,
                        ),
                      if (agg.commodity?.measureName != null)
                        _buildHeroBadge(agg.commodity!.measureName!, Colors.indigo),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cropName,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 8)],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.groups_2_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          groupName,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4)],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6),
      ),
    );
  }

  Widget _buildStockProgressCard(Aggregation agg, bool isNy) {
    final total = agg.totalQuantity;
    final remaining = agg.remainingQuantity;
    final sold = total - remaining;
    final double percent = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;
    final Color barColor = percent > 0.5 ? kPrimaryColor : percent > 0.2 ? Colors.orange : Colors.red;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isNy ? '📦 Kuchuluka kwa Katundu' : '📦 Stock Availability',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: barColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${(percent * 100).toStringAsFixed(0)}% ${isNy ? 'yatsala' : 'left'}',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: barColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: percent),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (ctx, val, _) => LinearProgressIndicator(
                value: val,
                minHeight: 12,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockStat(
                isNy ? 'Yotsala' : 'Remaining',
                '${remaining.toStringAsFixed(0)} kg',
                barColor,
              ),
              _buildStockStat(
                isNy ? 'Yogulitsidwa' : 'Sold',
                '${sold.toStringAsFixed(0)} kg',
                Colors.grey[600]!,
              ),
              _buildStockStat(
                isNy ? 'Zonse' : 'Total',
                '${total.toStringAsFixed(0)} kg',
                Colors.black87,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
        Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  Widget _buildPricingAndStockRow(Aggregation agg, bool isNy) {
    final price = agg.commodity?.unitPrice ?? 0;
    final contributions = agg.contributions.length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.sell_outlined,
            label: isNy ? 'Mtengo / kg' : 'Unit Price',
            value: 'MWK ${price.toStringAsFixed(0)}',
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_alt_outlined,
            label: isNy ? 'Alimi' : 'Farmers',
            value: contributions > 0 ? '$contributions' : '—',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupInformationCard(Aggregation agg, bool isNy) {
    final group = agg.group;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNy ? '👥 Gulu Lopanga Zosonkhanitsa' : '👥 Producer Group',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor.withValues(alpha: 0.2), kPrimaryColor.withValues(alpha: 0.05)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.groups_2_rounded, color: kPrimaryColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group?.name ?? 'Mlimi Farmer Cooperative',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isNy ? 'Gulu la Alimi Olembetsedwa pa Mlimi' : 'Registered Mlimi Farmer Cluster',
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_rounded, color: kPrimaryColor, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyDetailsCard(Aggregation agg, bool isNy) {
    final createdAt = agg.createdAt != null
        ? _formatDate(agg.createdAt!)
        : (isNy ? 'Sichidziwika' : 'Unknown');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNy ? '📋 Zambiri Zazikuluzikulu' : '📋 Key Details',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 14),
          _buildDetailRow(
            icon: Icons.calendar_today_outlined,
            label: isNy ? 'Tsiku Lopanganidwa' : 'Date Created',
            value: createdAt,
          ),
          const Divider(height: 20, thickness: 0.5),
          _buildDetailRow(
            icon: Icons.inventory_2_outlined,
            label: isNy ? 'Njira ya Kutsimikizitsa' : 'Status',
            value: _statusLabel(agg.status, isNy),
            valueColor: _getStatusColor(agg.status),
          ),
          if (agg.publishedAt != null) ...[
            const Divider(height: 20, thickness: 0.5),
            _buildDetailRow(
              icon: Icons.campaign_outlined,
              label: isNy ? 'Yatumizidwa pa' : 'Broadcasted On',
              value: _formatDate(agg.publishedAt!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String label, required String value, Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FA),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(Aggregation agg, bool isNy) {
    final description = agg.commodity?.description;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isNy ? '📝 Nkhani Yokhudza Gulu' : '📝 About This Pool',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 10),
          Text(
            (description != null && description.isNotEmpty)
                ? description
                : (isNy
                    ? 'Zosonkhanitsa izi zakonzedwa m\'gulu la alimi kuti zithandize kupeza mitengo yabwino pa msika waukulu. Alimi amayika katundu wawo pamodzi kuti apeze mtengo wabwino.'
                    : 'This produce pool is aggregated by a registered farmer cluster to access premium bulk market prices. Farmers pool their produce together to negotiate better rates with verified buyers.'),
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700], height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(Aggregation agg, bool isNy) {
    final isSoldOut = agg.remainingQuantity <= 0;
    final isCompleted = agg.status.toLowerCase() == 'completed';
    final canOrder = !isSoldOut && !isCompleted;
    final isOwner = _isOwner(agg);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Manage Aggregation button (owner only)
            if (isOwner) ...
            [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AggregationDetailsScreen(aggregationId: agg.id!),
                    ),
                  ),
                  icon: const Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 20),
                  label: Text(
                    isNy ? 'Samalani Zosonkhanitsa' : 'Manage Aggregation',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                // Share button
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FA),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.black54, size: 20),
                    onPressed: () {
                      final cropName = agg.commodity?.valueChainName ?? 'Crop Pool';
                      final price = agg.commodity?.unitPrice ?? 0;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isNy
                                ? 'Gawidanani: $cropName pa MWK ${price.toStringAsFixed(0)}/kg'
                                : 'Share: $cropName at MWK ${price.toStringAsFixed(0)}/kg',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: kPrimaryColor,
                        ),
                      );
                    },
                  ),
                ),
                // Order / Contact button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: canOrder ? () => showRecordSaleSheet(context, agg) : null,
                    icon: Icon(
                      isSoldOut || isCompleted ? Icons.inventory_2_outlined : Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      isSoldOut
                          ? (isNy ? 'Ndalama Zonse Zagulitsidwa' : 'Sold Out')
                          : isCompleted
                              ? (isNy ? 'Gulu Lazatha' : 'Pool Completed')
                              : (isNy ? 'Gulani pa Gulu' : 'Order From Pool'),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canOrder ? kPrimaryColor : Colors.grey,
                      disabledBackgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: canOrder ? 2 : 0,
                      shadowColor: kPrimaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))
      ],
    );
  }

  String _statusLabel(String status, bool isNy) {
    switch (status.toLowerCase()) {
      case 'open':
        return isNy ? 'YOTSEGUKA' : 'OPEN';
      case 'partial_sold':
        return isNy ? 'YODULA' : 'PARTIAL';
      case 'completed':
        return isNy ? 'YATHA' : 'COMPLETED';
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }
}
