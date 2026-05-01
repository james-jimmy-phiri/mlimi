import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';
import 'package:mlimi/models/aggregation_models.dart';

void showRecordSaleSheet(BuildContext context, Aggregation aggregation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RecordSaleSheet(aggregation: aggregation),
  );
}

void showAddContributionSheet(BuildContext context, Aggregation aggregation) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddContributionSheet(aggregation: aggregation),
  );
}

class _RecordSaleSheet extends StatefulWidget {
  final Aggregation aggregation;

  const _RecordSaleSheet({Key? key, required this.aggregation}) : super(key: key);

  @override
  State<_RecordSaleSheet> createState() => _RecordSaleSheetState();
}

class _RecordSaleSheetState extends State<_RecordSaleSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _buyerName;
  String? _buyerPhone;
  String? _quantitySold;
  String? _pricePerUnit;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      
      Map<String, dynamic> payload = {
        'buyer_name': _buyerName,
        'buyer_phone': _buyerPhone,
        'quantity_sold': double.parse(_quantitySold!),
        'price_per_unit': double.parse(_pricePerUnit!),
      };

      bool success = await provider.recordSale(widget.aggregation.id!, payload);
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale recorded successfully!'), backgroundColor: Colors.green));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error recording sale'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Record Sale', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Available Stock: ${widget.aggregation.remainingQuantity} kg', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              
              TextFormField(
                decoration: InputDecoration(labelText: 'Buyer Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _buyerName = val,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Buyer Phone (Optional)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                onSaved: (val) => _buyerPhone = val,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Quantity Sold (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  double? parsed = double.tryParse(val);
                  if (parsed == null) return 'Invalid number';
                  if (parsed > widget.aggregation.remainingQuantity) return 'Cannot sell more than available';
                  return null;
                },
                onSaved: (val) => _quantitySold = val,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price Per Unit (MWK)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _pricePerUnit = val,
              ),
              const SizedBox(height: 24),

              Consumer<AggregationProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirm Sale', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AddContributionSheet extends StatefulWidget {
  final Aggregation aggregation;

  const _AddContributionSheet({Key? key, required this.aggregation}) : super(key: key);

  @override
  State<_AddContributionSheet> createState() => _AddContributionSheetState();
}

class _AddContributionSheetState extends State<_AddContributionSheet> {
  bool _isNewMember = false;
  final _formKey = GlobalKey<FormState>();

  String? _memberId;
  String? _name;
  String? _gender;
  String? _ageRange;
  String? _quantity;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<AggregationProvider>(context, listen: false);

      bool success;
      if (_isNewMember) {
        Map<String, dynamic> payload = {
          'name': _name,
          'gender': _gender,
          'age_range': _ageRange,
          'quantity': double.parse(_quantity!),
          'value_chains': [widget.aggregation.commodity?.valueChainId ?? 1] // Fallback
        };
        success = await provider.addNewMemberContribution(widget.aggregation.id!, payload);
      } else {
        Map<String, dynamic> payload = {
          'group_member_id': int.parse(_memberId!),
          'quantity': double.parse(_quantity!),
        };
        success = await provider.addContribution(widget.aggregation.id!, payload);
      }

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contribution added successfully!'), backgroundColor: Colors.green));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage ?? 'Error adding contribution'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add Contribution', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Existing Member'),
                    selectedColor: kPrimaryColor.withOpacity(0.2),
                    selected: !_isNewMember,
                    onSelected: (val) => setState(() => _isNewMember = false),
                  ),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('New Member'),
                    selectedColor: kPrimaryColor.withOpacity(0.2),
                    selected: _isNewMember,
                    onSelected: (val) => setState(() => _isNewMember = true),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isNewMember)
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Member ID', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _memberId = val,
                )
              else ...[
                TextFormField(
                  decoration: InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => _gender = val,
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Age Range', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: ['18-35', '36-50', '51+'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => _ageRange = val,
                  validator: (val) => val == null ? 'Required' : null,
                ),
              ],
              
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Quantity Contributed (kg)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _quantity = val,
              ),
              const SizedBox(height: 24),

              Consumer<AggregationProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Contribution', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}
