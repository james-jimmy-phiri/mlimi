import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/models/inventory_models.dart';
import 'package:mlimi/services/inventory_service.dart';
import 'package:mlimi/utils/error_utils.dart';

class StockMovementPage extends StatefulWidget {
  final BusinessProfile profile;

  const StockMovementPage({super.key, required this.profile});

  @override
  State<StockMovementPage> createState() => _StockMovementPageState();
}

class _StockMovementPageState extends State<StockMovementPage> {
  final _inventoryService = InventoryService();
  final _language = GetStorage().read('language') ?? 'en';
  final _dateFormat = DateFormat('MMM d, yyyy h:mm a');

  bool _isLoading = true;
  String? _errorMessage;
  List<InventoryStockMove> _movements = [];

  @override
  void initState() {
    super.initState();
    _loadMovements();
  }

  Future<void> _loadMovements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final moves = await _inventoryService.getStockMoves(widget.profile.id!);
      setState(() {
        _movements = moves;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = ErrorUtils.getFriendlyErrorMessage(e, _language);
      });
    }
  }

  Future<void> _showRecordMovementSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _RecordMovementSheet(
        profile: widget.profile,
        inventoryService: _inventoryService,
      ),
    );
    if (result == true) {
      _loadMovements();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          'Stock Movements',
          style: GoogleFonts.inter(
            color: const Color(0xFF191C1E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecordMovementSheet,
        backgroundColor: const Color(0xFF003EC7),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Record Movement',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
              onPressed: _loadMovements,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF003EC7)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFDDE1FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sync_alt, size: 48, color: Color(0xFF003EC7)),
            ),
            const SizedBox(height: 24),
            Text(
              'No stock movements yet',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Record stock received, sold, or adjusted.',
              style: GoogleFonts.inter(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showRecordMovementSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003EC7),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Record Movement', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMovements,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _movements.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildMovementCard(_movements[index]),
      ),
    );
  }

  Widget _buildMovementCard(InventoryStockMove move) {
    final isIn = move.type == 'received' || move.type == 'returned' || move.type == 'adjusted_in';
    final color = isIn ? const Color(0xFF137333) : const Color(0xFFC5221F);
    final bgColor = isIn ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6);
    final icon = isIn ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    final sign = isIn ? '+' : '-';

    String formattedDate = '';
    if (move.movedAt != null) {
      try {
        formattedDate = _dateFormat.format(DateTime.parse(move.movedAt!).toLocal());
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC3C5D9).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        move.product?.name ?? 'Unknown Product',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '$sign${move.quantity} ${move.product?.unit ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        move.type.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                    if (move.reference != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '# ${move.reference}',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ]
                  ],
                ),
                if (formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
                if (move.notes != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    move.notes!,
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM SHEET: Record a new stock movement
// ---------------------------------------------------------------------------

class _RecordMovementSheet extends StatefulWidget {
  final BusinessProfile profile;
  final InventoryService inventoryService;

  const _RecordMovementSheet({required this.profile, required this.inventoryService});

  @override
  State<_RecordMovementSheet> createState() => _RecordMovementSheetState();
}

class _RecordMovementSheetState extends State<_RecordMovementSheet> {
  final _formKey = GlobalKey<FormState>();
  final _language = GetStorage().read('language') ?? 'en';
  final _quantityController = TextEditingController();
  final _referenceController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'received';
  int? _selectedProductId;
  bool _isLoading = false;
  bool _loadingProducts = true;
  List<InventoryProduct> _products = [];

  static const _movementTypes = [
    {'value': 'received', 'label': 'Received (Stock In)'},
    {'value': 'sold', 'label': 'Sold (Stock Out)'},
    {'value': 'adjusted_in', 'label': 'Adjustment In'},
    {'value': 'adjusted_out', 'label': 'Adjustment Out'},
    {'value': 'returned', 'label': 'Returned'},
    {'value': 'damaged', 'label': 'Damaged / Lost'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await widget.inventoryService.getProducts(widget.profile.id!);
      if (mounted) {
        setState(() {
          _products = products;
          _loadingProducts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProducts = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a product')));
      return;
    }
    setState(() => _isLoading = true);

    final data = <String, dynamic>{
      'product_id': _selectedProductId,
      'type': _selectedType,
      'quantity': double.tryParse(_quantityController.text) ?? 0,
      if (_referenceController.text.isNotEmpty) 'reference': _referenceController.text.trim(),
      if (_notesController.text.isNotEmpty) 'notes': _notesController.text.trim(),
    };

    try {
      await widget.inventoryService.recordStockMove(widget.profile.id!, data);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Stock movement recorded successfully'),
            backgroundColor: Color(0xFF137333),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorUtils.getFriendlyErrorMessage(e, _language)),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Record Stock Movement',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Product picker
            if (_loadingProducts)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<int>(
                value: _selectedProductId,
                hint: const Text('Select Product'),
                items: _products.map((p) => DropdownMenuItem<int>(value: p.id, child: Text(p.name))).toList(),
                onChanged: (v) => setState(() => _selectedProductId = v),
                validator: (v) => v == null ? 'Select a product' : null,
                decoration: _inputDecoration('Product *'),
              ),

            const SizedBox(height: 16),

            // Movement type
            DropdownButtonFormField<String>(
              value: _selectedType,
              items: _movementTypes
                  .map((t) => DropdownMenuItem<String>(value: t['value'], child: Text(t['label']!)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedType = v!),
              decoration: _inputDecoration('Movement Type'),
            ),
            const SizedBox(height: 16),

            // Quantity
            TextFormField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Quantity is required';
                if ((double.tryParse(v) ?? 0) <= 0) return 'Must be greater than 0';
                return null;
              },
              decoration: _inputDecoration('Quantity *'),
            ),
            const SizedBox(height: 16),

            // Reference
            TextFormField(
              controller: _referenceController,
              decoration: _inputDecoration('Reference / Invoice # (optional)'),
            ),
            const SizedBox(height: 16),

            // Notes
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: _inputDecoration('Notes (optional)'),
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003EC7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        'Record Movement',
                        style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC3C5D9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFC3C5D9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF003EC7), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF7F9FB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}
