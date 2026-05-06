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

void showEditContributionSheet(BuildContext context, Aggregation aggregation, AggregationContribution contribution) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditContributionSheet(aggregation: aggregation, contribution: contribution),
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
  bool _isNewBuyer = false;
  int? _selectedBuyerId;
  String? _buyerName;
  String? _buyerPhone;
  String? _buyerLocation;
  String? _quantitySold;
  String? _pricePerUnit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AggregationProvider>(context, listen: false).fetchBuyers();
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      
      Map<String, dynamic> payload = {
        'quantity_sold': double.parse(_quantitySold!),
        'price_per_unit': double.parse(_pricePerUnit!),
      };

      if (_isNewBuyer) {
        payload['buyer_name'] = _buyerName;
        payload['buyer_phone'] = _buyerPhone;
        payload['buyer_location'] = _buyerLocation;
      } else {
        payload['buyer_id'] = _selectedBuyerId;
      }

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
              Text('Available Stock: ${widget.aggregation.remainingQuantity} kg', 
                   style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Existing Buyer')),
                      selected: !_isNewBuyer,
                      selectedColor: Colors.green.withOpacity(0.2),
                      onSelected: (val) => setState(() => _isNewBuyer = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('New Buyer')),
                      selected: _isNewBuyer,
                      selectedColor: Colors.green.withOpacity(0.2),
                      onSelected: (val) => setState(() => _isNewBuyer = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isNewBuyer)
                Consumer<AggregationProvider>(
                  builder: (ctx, provider, child) {
                    if (provider.isLoadingBuyers) return const LinearProgressIndicator();
                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Buyer',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedBuyerId,
                      items: provider.buyers.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                      onChanged: (val) => setState(() => _selectedBuyerId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    );
                  },
                )
              else ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Buyer Name',
                    prefixIcon: const Icon(Icons.person_add),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _buyerName = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Buyer Phone',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _buyerPhone = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Buyer Location',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (val) => _buyerLocation = val,
                ),
              ],
              
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Quantity (kg)',
                        suffixText: 'kg',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        double? parsed = double.tryParse(val);
                        if (parsed == null) return 'Invalid';
                        if (parsed > widget.aggregation.remainingQuantity) return 'Over limit';
                        return null;
                      },
                      onSaved: (val) => _quantitySold = val,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Price/Unit',
                        prefixText: 'MWK ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _pricePerUnit = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Consumer<AggregationProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Confirm Sale', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  int? _selectedMemberId;
  String? _name;
  String? _gender;
  String? _ageRange;
  String? _phone;
  String? _quantity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.aggregation.groupId != null) {
        Provider.of<AggregationProvider>(context, listen: false).fetchGroupMembers(widget.aggregation.groupId!);
      }
    });
  }

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
          'phone': _phone,
          'quantity': double.parse(_quantity!),
          'value_chains': [widget.aggregation.commodity?.valueChainId ?? 1] // In a real app, this might be a multi-select
        };
        success = await provider.addNewMemberContribution(widget.aggregation.id!, payload);
      } else {
        Map<String, dynamic> payload = {
          'group_member_id': _selectedMemberId,
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
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Existing Member')),
                      selectedColor: kPrimaryColor.withOpacity(0.2),
                      selected: !_isNewMember,
                      onSelected: (val) => setState(() => _isNewMember = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('New Member')),
                      selectedColor: kPrimaryColor.withOpacity(0.2),
                      selected: _isNewMember,
                      onSelected: (val) => setState(() => _isNewMember = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isNewMember)
                Consumer<AggregationProvider>(
                  builder: (ctx, provider, child) {
                    if (provider.isLoadingMembers) return const LinearProgressIndicator();
                    if (provider.groupMembers.isEmpty) return const Text('No members found in this group.', style: TextStyle(color: Colors.red));
                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Member',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: _selectedMemberId,
                      items: provider.groupMembers.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
                      onChanged: (val) => setState(() => _selectedMemberId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    );
                  }
                )
              else ...[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_add),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  onSaved: (val) => _name = val,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSaved: (val) => _phone = val,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Gender', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        items: ['Male', 'Female'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => _gender = val,
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Age Range', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        items: ['18-35', '36-50', '51+'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (val) => _ageRange = val,
                        validator: (val) => val == null ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 24),
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity Contributed (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid';
                  return null;
                },
                onSaved: (val) => _quantity = val,
              ),
              const SizedBox(height: 32),

              Consumer<AggregationProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text('Submit Contribution', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

class _EditContributionSheet extends StatefulWidget {
  final Aggregation aggregation;
  final AggregationContribution contribution;

  const _EditContributionSheet({Key? key, required this.aggregation, required this.contribution}) : super(key: key);

  @override
  State<_EditContributionSheet> createState() => _EditContributionSheetState();
}

class _EditContributionSheetState extends State<_EditContributionSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.contribution.quantity.toString();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final provider = Provider.of<AggregationProvider>(context, listen: false);

      Map<String, dynamic> payload = {
        'quantity': double.parse(_quantity),
        'group_member_id': widget.contribution.groupMemberId,
      };

      bool success = await provider.updateContribution(
        widget.aggregation.id!,
        widget.contribution.id!,
        payload,
      );

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Contribution updated successfully!'),
          backgroundColor: Colors.green,
        ));
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(provider.errorMessage ?? 'Error updating contribution'),
          backgroundColor: Colors.red,
        ));
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
              const Text('Update Contribution', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Text(
                'Member: ${widget.contribution.groupMember?.name ?? "Unknown"}',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                initialValue: _quantity,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity Contributed (kg)',
                  suffixText: 'kg',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid number';
                  return null;
                },
                onSaved: (val) => _quantity = val!,
              ),
              const SizedBox(height: 32),
              Consumer<AggregationProvider>(
                builder: (ctx, provider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Update Contribution',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
