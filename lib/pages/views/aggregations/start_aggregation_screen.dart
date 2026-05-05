import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/provider/aggregation_provider.dart';
import 'package:provider/provider.dart';

class StartAggregationScreen extends StatefulWidget {
  const StartAggregationScreen({Key? key}) : super(key: key);

  @override
  State<StartAggregationScreen> createState() => _StartAggregationScreenState();
}

class _StartAggregationScreenState extends State<StartAggregationScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedGroupId;
  int? _selectedValueChainId;
  int? _selectedMeasureId = 1; // Default to Kg
  int? _commodityId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AggregationProvider>(context, listen: false);
      provider.fetchGroups();
      provider.fetchValueChains();
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<AggregationProvider>(context, listen: false);
      
      Map<String, dynamic> payload = {
        'group_id': _selectedGroupId,
        'value_chain_id': _selectedValueChainId,
        'measure_id': _selectedMeasureId,
        'commodity_id': _commodityId ?? 1, // Fallback
      };

      bool success = await provider.createAggregation(payload);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aggregation started successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'Failed to start aggregation'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Start Pool', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Consumer<AggregationProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Initialize a new pool',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Define which group and commodity this aggregation is for.',
                    style: TextStyle(color: Colors.blueGrey, fontSize: 15),
                  ),
                  const SizedBox(height: 32),
                  
                  if (provider.isLoadingGroups) 
                    const LinearProgressIndicator()
                  else
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration('Select Group', Icons.group),
                      value: _selectedGroupId,
                      items: provider.groups.map((g) => DropdownMenuItem(value: g['id'] as int, child: Text(g['name']))).toList(),
                      onChanged: (val) => setState(() => _selectedGroupId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  const SizedBox(height: 20),
                  
                  if (provider.isLoadingValueChains)
                    const LinearProgressIndicator()
                  else
                    DropdownButtonFormField<int>(
                      decoration: _inputDecoration('Select Commodity (Value Chain)', Icons.eco),
                      value: _selectedValueChainId,
                      items: provider.valueChains.map((v) => DropdownMenuItem(value: v['id'] as int, child: Text(v['name']))).toList(),
                      onChanged: (val) => setState(() => _selectedValueChainId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                  const SizedBox(height: 20),
                  
                  DropdownButtonFormField<int>(
                    decoration: _inputDecoration('Measurement Unit', Icons.scale),
                    value: _selectedMeasureId,
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Kilograms (Kg)')),
                      DropdownMenuItem(value: 2, child: Text('Tonnes (T)')),
                      DropdownMenuItem(value: 3, child: Text('Bags')),
                    ],
                    onChanged: (val) => setState(() => _selectedMeasureId = val),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Initialize Aggregation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kPrimaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
