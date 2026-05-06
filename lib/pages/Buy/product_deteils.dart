import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mlimi/features/buy_sell/models/commodity_models.dart';
import 'package:mlimi/features/buy_sell/repositories/commodity_repository.dart';
import 'package:mlimi/features/buy_sell/views/edit_commodity_screen.dart';
import 'package:mlimi/features/buy_sell/views/quick_sell_screen.dart';
import 'package:mlimi/pages/views/aggregations/aggregation_details_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mlimi/models/products_model.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final Function(int) onPoke;

  const ProductDetailPage({required this.product, required this.onPoke, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _repo = CommodityRepository();
  bool _loading = true;
  CommodityDetails? _details;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final details = await _repo.getCommodityDetails(widget.product.id);
      if (!mounted) return;
      setState(() => _details = details);
    } catch (e) {
      debugPrint("Error loading details: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _markNotSold() async {
    if (_details == null) return;
    final c = _details!.commodity;
    await _repo.toggleCommodityStatus(
      commodityId: c.id,
      availabilityStatus: 'available',
    );
    await _load();
  }

  void _callPhone(String phone) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine whether to use full details or fallback basic details
    final hasFullDetails = _details != null;
    
    // Map basic product details to a dummy commodity so we can render immediately if loading
    final c = hasFullDetails ? _details!.commodity : Commodity(
      id: widget.product.id,
      valueChainId: 0,
      name: widget.product.name,
      image: widget.product.imageUrl,
      price: double.tryParse(widget.product.unitPrice),
      measure: widget.product.measure,
      quantity: double.tryParse(widget.product.quantity),
      quantityRemaining: double.tryParse(widget.product.quantity),
      availabilityStatus: widget.product.active ? 'available' : 'unavailable',
      location: widget.product.location,
      description: widget.product.description,
      type: widget.product.type,
      ownPost: false, // We don't know this from basic Product accurately enough to show owner controls
      lowStockAlert: false,
      lowStockThreshold: 0,
      isAggregation: widget.product.isAggregation,
      clientName: widget.product.client.name,
      clientPhone: widget.product.client.phone,
      views: widget.product.views,
      date: widget.product.created,
      active: widget.product.active,
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: hasFullDetails ? _buildBottomBar(c) : null,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(c, hasFullDetails),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading && !hasFullDetails)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Center(child: LinearProgressIndicator()),
                    ),
                  if (c.isAggregation) _buildAggregationBanner(c),
                  if (c.isAggregation && hasFullDetails) _buildAggregationSummary(c),
                  if (!c.isAggregation) _buildOwnerCard(c),
                  const SizedBox(height: 16),
                  _buildMetricsGrid(c),
                  const SizedBox(height: 16),
                  if (hasFullDetails) _buildPotentialInterestCard(c),
                  const SizedBox(height: 16),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    c.description ?? 'No description provided.',
                    style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (hasFullDetails) _buildSalesSection(),
                  const SizedBox(height: 40), // Padding for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Commodity c, bool hasFullDetails) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.green[700],
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (hasFullDetails && c.ownPost)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'edit') {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => EditCommodityScreen(commodity: c)),
                );
                if (updated == true) _load();
              } else if (value == 'toggle_status') {
                if ((c.availabilityStatus ?? 'available') == 'sold') {
                  await _markNotSold();
                } else {
                  final created = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuickSellScreen(
                        commodity: c,
                        initialQuantitySold: c.quantityRemaining,
                      ),
                    ),
                  );
                  if (created == true) _load();
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Colors.black54),
                    SizedBox(width: 8),
                    Text('Edit Commodity'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'toggle_status',
                child: Row(
                  children: [
                    Icon((c.availabilityStatus ?? 'available') == 'sold' ? Icons.check_circle_outline : Icons.check_circle, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text((c.availabilityStatus ?? 'available') == 'sold' ? 'Mark Available' : 'Mark Sold (All)'),
                  ],
                ),
              ),
            ],
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          c.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            c.image != null && c.image!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: c.image!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.green[100],
      child: Icon(Icons.grass, size: 80, color: Colors.green[300]),
    );
  }

  Widget _buildAggregationBanner(Commodity c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.groups, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Group Aggregate Product',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This product is a collective contribution from ${c.clientName ?? 'Group'} members.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregationSummary(Commodity c) {
    double progress = 0;
    if ((c.quantity ?? 0) > 0) {
      progress = (c.quantityRemaining ?? 0) / (c.quantity ?? 1);
    }
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Color(0xFF4F46E5)),
                SizedBox(width: 8),
                Text('Aggregation Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Total Quantity', '${c.quantity ?? 0} ${c.measure ?? ''}'),
            const SizedBox(height: 8),
            _buildInfoRow('Collected From', c.clientName ?? '-'),
            const SizedBox(height: 16),
            const Text(
              'Buyers are assured of high-quality aggregated stock from registered group members.',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Remaining Stock', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                Text('${(progress * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progress > 0.3 ? Colors.green : Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerCard(Commodity c) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green[100],
              child: Icon(Icons.person, color: Colors.green[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.clientName ?? 'Unknown Producer',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Text('Owner / Producer', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            if (c.clientPhone != null)
              IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => _callPhone(c.clientPhone!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotentialInterestCard(Commodity c) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.amber, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Potential Interest', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    (c.customersCount ?? 0) > 0 
                      ? '${c.customersCount} potential customers are interested.'
                      : 'No customers yet.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (!c.ownPost) ...[
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: c.poked ? null : () async {
                        try {
                          final role = (c.type ?? '').toLowerCase() == 'supply' ? 'supplier' : 'customer';
                          await _repo.pokeSeller(c.id, role);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully poked the seller')));
                            _load();
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to poke seller: $e')));
                          }
                        }
                      },
                      icon: Icon(c.poked ? Icons.check : Icons.handshake, size: 18),
                      label: Text(c.poked ? 'Poked' : 'Poke Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Commodity c) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.2,
      children: [
        _buildMetricTile(Icons.attach_money, 'Price', 'MWK ${c.price ?? 0} / ${c.measure ?? ''}', Colors.green),
        _buildMetricTile(Icons.inventory_2, 'Remaining', '${c.quantityRemaining ?? 0} ${c.measure ?? ''}', Colors.blue),
        _buildMetricTile(Icons.location_on, 'Location', c.location ?? 'N/A', Colors.red),
        _buildMetricTile(Icons.remove_red_eye, 'Views', '${c.views ?? 0} Views', Colors.purple),
        _buildMetricTile(Icons.date_range, 'Posted', c.date ?? '-', Colors.teal),
        _buildMetricTile(
          c.active ? Icons.check_circle : Icons.cancel, 
          'Status', 
          c.active ? 'ACTIVE' : 'INACTIVE', 
          c.active ? Colors.green : Colors.grey
        ),
      ],
    );
  }

  Widget _buildMetricTile(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  value, 
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildSalesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.point_of_sale, color: Colors.green),
            SizedBox(width: 8),
            Text('Recent Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        if (_details!.sales.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Text('No sales recorded yet.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          )
        else
          ..._details!.sales.map((s) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.shopping_cart, color: Colors.white, size: 18)),
              title: Text('${s.quantitySold} x MWK ${s.unitPrice}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Buyer: ${s.buyerName ?? '-'} • ${s.saleDate ?? '-'}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('MWK ${s.totalAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text(s.paymentStatus.toUpperCase(), style: TextStyle(fontSize: 10, color: s.paymentStatus == 'paid' ? Colors.green : Colors.orange)),
                ],
              ),
            ),
          )),
      ],
    );
  }

  Widget? _buildBottomBar(Commodity c) {
    if (!c.ownPost) return null;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: Row(
          children: [
            if (c.isAggregation && c.aggregationId != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AggregationDetailsScreen(aggregationId: c.aggregationId!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('MANAGE AGGREGATION'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(color: Color(0xFF4F46E5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            if (c.isAggregation && c.aggregationId != null) const SizedBox(width: 12),
            if ((c.quantityRemaining ?? 0) > 0)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final created = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => QuickSellScreen(commodity: c)),
                    );
                    if (created == true) _load();
                  },
                  icon: const Icon(Icons.shopping_bag),
                  label: const Text('QUICK SELL'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
