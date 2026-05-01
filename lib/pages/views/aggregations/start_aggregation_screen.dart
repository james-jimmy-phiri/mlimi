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

  String? _groupId;
  String? _commodityId;
  String? _valueChainId;
  String? _measureId;

  // Assuming you will hook these up to a real endpoints for dropdowns. 
  // Currently using text fields for numeric IDs to satisfy the backend DB until dropdowns are wired.

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final provider = Provider.of<AggregationProvider>(context, listen: false);
      
      // We pass commodity_id to satisfy Controller validation, 
      // and measure_id + value_chain_id to satisfy Service logic.
      Map<String, dynamic> payload = {
        'group_id': int.parse(_groupId!),
        'commodity_id': int.parse(_commodityId ?? '1'), // Fallback if user doesn't know
        'value_chain_id': int.parse(_valueChainId!),
        'measure_id': int.parse(_measureId!),
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
        title: const Text('Start Aggregation', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Provide the required identifiers to setup the aggregation ledger.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  
                  // Group ID text field (can later be transformed to Dropdown calling getGroups())
                  _buildTextField(
                    label: 'Group ID (Client ID)',
                    icon: Icons.group,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _groupId = value,
                  ),
                  const SizedBox(height: 16),
                  
                  // Value Chain ID mapping for creating the commodity market pool
                  _buildTextField(
                    label: 'Value Chain ID',
                    icon: Icons.eco,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _valueChainId = value,
                  ),
                  const SizedBox(height: 16),
                  
                  // Measure ID for determining the scale (Kgs, Tonnes etc)
                  _buildTextField(
                    label: 'Measure ID (e.g. 1 for Kg)',
                    icon: Icons.scale,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _measureId = value,
                  ),
                  const SizedBox(height: 16),
                  
                  // The commodity validation bypass fix for backend controller
                  _buildTextField(
                    label: 'Linked Commodity ID (If existing)',
                    icon: Icons.link,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _commodityId = value,
                    isOptional: true, // we can default to 1 if needed
                  ),
                  
                  const SizedBox(height: 48),
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: provider.isActionLoading ? null : _submit,
                    child: provider.isActionLoading
                        ? const CircularProgressIndicator(color: Colors.white)
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

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required FormFieldSetter<String> onSaved,
    bool isOptional = false,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.black45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
