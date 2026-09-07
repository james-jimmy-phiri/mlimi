import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/models/farming_profile_models.dart';
import 'package:mlimi/services/farming_profile_service.dart';

class AddExpenditurePage extends StatefulWidget {
  final int seasonId;
  const AddExpenditurePage({Key? key, required this.seasonId}) : super(key: key);

  @override
  State<AddExpenditurePage> createState() => _AddExpenditurePageState();
}

class _AddExpenditurePageState extends State<AddExpenditurePage> {
  final _formKey = GlobalKey<FormState>();
  final _service = FarmingProfileService();
  final _lang = GetStorage().read('language') ?? 'en';

  bool _isLoading = false;
  String _category = SeasonExpenditure.categories.first;
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _date = DateTime.now();

  static const Map<String, IconData> _categoryIcons = {
    'Seeds': Icons.grass,
    'Fertilizer': Icons.science_outlined,
    'Pesticides/Herbicides': Icons.bug_report_outlined,
    'Labor': Icons.people_outline,
    'Equipment/Machinery': Icons.agriculture,
    'Transport': Icons.local_shipping_outlined,
    'Irrigation': Icons.water_drop_outlined,
    'Land Rent': Icons.map_outlined,
    'Other': Icons.receipt_long_outlined,
  };

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _service.addExpenditure(widget.seasonId, {
        'category': _category,
        'description': _descController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'date': DateFormat('yyyy-MM-dd').format(_date),
      });

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(_lang == 'en' ? 'Expense recorded successfully' : 'Ndalama zasungidwa bwino'),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString().replaceAll('Exception: ', '')),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _lang == 'en' ? 'Record Expense' : 'Lemba Ndalama Zotuluka',
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category selector grid
                    Text(
                      _lang == 'en' ? 'Expense Category' : 'Mtundu wa Ndalama',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: SeasonExpenditure.categories.length,
                      itemBuilder: (context, i) {
                        final cat = SeasonExpenditure.categories[i];
                        final isSelected = _category == cat;
                        return GestureDetector(
                          onTap: () => setState(() => _category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? kPrimaryColor.withValues(alpha: 0.1) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? kPrimaryColor : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _categoryIcons[cat] ?? Icons.receipt_long_outlined,
                                  color: isSelected ? kPrimaryColor : Colors.grey[600],
                                  size: 26,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cat,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? kPrimaryColor : Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Description
                    TextFormField(
                      controller: _descController,
                      decoration: InputDecoration(
                        labelText: _lang == 'en' ? 'Description' : 'Mfotokozedwe',
                        hintText: _lang == 'en' ? 'e.g., 50kg bag of Urea fertilizer' : 'mwachitsanzo, katundu wa mbewu',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? (_lang == 'en' ? 'Required' : 'Chofunikira') : null,
                    ),

                    const SizedBox(height: 20),

                    // Amount
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: _lang == 'en' ? 'Amount (MWK)' : 'Khauli (MWK)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                        ),
                        prefixIcon: const Icon(Icons.payments_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return _lang == 'en' ? 'Required' : 'Chofunikira';
                        if (double.tryParse(v) == null) return _lang == 'en' ? 'Enter a valid number' : 'Lowetsani nambala yolondola';
                        if (double.parse(v) <= 0) return _lang == 'en' ? 'Amount must be greater than 0' : 'Khauli iyenera kukhala yoposa 0';
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Date
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _lang == 'en' ? 'Date of Expense' : 'Tsiku la Ndalama',
                                  style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                                ),
                                Text(
                                  DateFormat('MMMM dd, yyyy').format(_date),
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: Text(
                          _lang == 'en' ? 'Save Expense' : 'Sungani Ndalama',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}
