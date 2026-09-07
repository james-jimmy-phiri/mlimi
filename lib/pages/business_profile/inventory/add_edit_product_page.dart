import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mlimi/models/business_profile.dart';
import 'package:mlimi/models/inventory_models.dart';
import 'package:mlimi/services/inventory_service.dart';
import 'package:mlimi/utils/error_utils.dart';
import 'package:get_storage/get_storage.dart';

class AddEditProductPage extends StatefulWidget {
  final BusinessProfile profile;
  final InventoryProduct? product; // null = create mode

  const AddEditProductPage({super.key, required this.profile, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _inventoryService = InventoryService();
  final _language = GetStorage().read('language') ?? 'en';

  // Form controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _currentStockController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedUnit = 'units';
  bool _isActive = true;
  bool _isSaving = false;
  List<InventorySupplier> _suppliers = [];
  int? _selectedSupplierId;
  bool _loadingSuppliers = true;

  bool get _isEditMode => widget.product != null;

  static const _units = ['units', 'kg', 'g', 'litre', 'ml', 'bags', 'boxes', 'pcs', 'dozen'];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    if (_isEditMode) {
      _populateFields(widget.product!);
    }
  }

  void _populateFields(InventoryProduct p) {
    _nameController.text = p.name;
    _skuController.text = p.sku ?? '';
    _barcodeController.text = p.barcode ?? '';
    _categoryController.text = p.category ?? '';
    _buyingPriceController.text = p.buyingPrice?.toStringAsFixed(2) ?? '';
    _sellingPriceController.text = p.sellingPrice?.toStringAsFixed(2) ?? '';
    _currentStockController.text = p.currentStock.toStringAsFixed(2);
    _lowStockController.text = p.lowStockThreshold?.toStringAsFixed(2) ?? '';
    _notesController.text = p.notes ?? '';
    _selectedUnit = p.unit;
    _isActive = p.isActive;
    _selectedSupplierId = p.supplierId;
  }

  Future<void> _loadSuppliers() async {
    try {
      final suppliers = await _inventoryService.getSuppliers(widget.profile.id!);
      if (mounted) {
        setState(() {
          _suppliers = suppliers;
          _loadingSuppliers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSuppliers = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'unit': _selectedUnit,
      'is_active': _isActive ? 1 : 0,
      if (_skuController.text.isNotEmpty) 'sku': _skuController.text.trim(),
      if (_barcodeController.text.isNotEmpty) 'barcode': _barcodeController.text.trim(),
      if (_categoryController.text.isNotEmpty) 'category': _categoryController.text.trim(),
      if (_buyingPriceController.text.isNotEmpty) 'buying_price': double.tryParse(_buyingPriceController.text),
      if (_sellingPriceController.text.isNotEmpty) 'selling_price': double.tryParse(_sellingPriceController.text),
      if (_currentStockController.text.isNotEmpty) 'current_stock': double.tryParse(_currentStockController.text),
      if (_lowStockController.text.isNotEmpty) 'low_stock_threshold': double.tryParse(_lowStockController.text),
      if (_notesController.text.isNotEmpty) 'notes': _notesController.text.trim(),
      if (_selectedSupplierId != null) 'supplier_id': _selectedSupplierId,
    };

    try {
      await _inventoryService.saveProduct(
        widget.profile.id!,
        data,
        productId: _isEditMode ? widget.product!.id : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Product updated successfully' : 'Product added successfully'),
            backgroundColor: const Color(0xFF137333),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorUtils.getFriendlyErrorMessage(e, _language)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _categoryController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _currentStockController.dispose();
    _lowStockController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Product' : 'Add Product',
          style: GoogleFonts.inter(
            color: const Color(0xFF191C1E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: Text(
                'Save',
                style: GoogleFonts.inter(
                  color: const Color(0xFF003EC7),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection(
              'Basic Information',
              Icons.info_outline,
              [
                _buildTextFormField(
                  controller: _nameController,
                  label: 'Product Name *',
                  hint: 'e.g. Maize Flour 2kg',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _skuController,
                        label: 'SKU',
                        hint: 'e.g. MF-001',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _barcodeController,
                        label: 'Barcode',
                        hint: '1234567890',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTextFormField(
                  controller: _categoryController,
                  label: 'Category',
                  hint: 'e.g. Grains, Fertilizer',
                ),
                const SizedBox(height: 16),
                // Unit dropdown
                _buildDropdownField<String>(
                  label: 'Unit of Measure',
                  value: _selectedUnit,
                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setState(() => _selectedUnit = v!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSection(
              'Pricing',
              Icons.attach_money,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _buyingPriceController,
                        label: 'Buying Price (MK)',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _sellingPriceController,
                        label: 'Selling Price (MK)',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSection(
              'Stock Levels',
              Icons.inventory_2_outlined,
              [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _currentStockController,
                        label: 'Current Stock',
                        hint: '0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _lowStockController,
                        label: 'Low Stock Alert',
                        hint: 'e.g. 10',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSection(
              'Supplier',
              Icons.local_shipping_outlined,
              [
                if (_loadingSuppliers)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildDropdownField<int?>(
                    label: 'Supplier (optional)',
                    value: _selectedSupplierId,
                    items: [
                      const DropdownMenuItem<int?>(value: null, child: Text('None')),
                      ..._suppliers.map(
                        (s) => DropdownMenuItem<int?>(value: s.id, child: Text(s.name)),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedSupplierId = v),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSection(
              'Additional Info',
              Icons.notes_outlined,
              [
                _buildTextFormField(
                  controller: _notesController,
                  label: 'Notes',
                  hint: 'Any additional notes...',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Product',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    Switch(
                      value: _isActive,
                      activeColor: const Color(0xFF003EC7),
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF003EC7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        _isEditMode ? 'Update Product' : 'Add Product',
                        style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC3C5D9).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF003EC7), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF191C1E)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
        hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
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
      ),
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF191C1E)),
      decoration: InputDecoration(
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
      ),
    );
  }
}
