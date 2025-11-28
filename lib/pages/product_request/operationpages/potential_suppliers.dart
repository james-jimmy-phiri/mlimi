import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PotentialSuppliers extends StatefulWidget {
  const PotentialSuppliers({super.key});

  @override
  _PotentialSuppliersState createState() => _PotentialSuppliersState();
}

class _PotentialSuppliersState extends State<PotentialSuppliers> {
  List<dynamic> suppliers = [];
  String? selectedCrop = "maize";
  final List<String> crops = ["maize", "groundnuts", "cassava", "soya", "rice"];

  Future<void> fetchSuppliers(String crop) async {
    try {
      final String response = await DefaultAssetBundle.of(context)
          .loadString('assets/data/suppliers.json');
      final data = json.decode(response);
      setState(() {
        suppliers = data[crop] ?? [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load suppliers: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSuppliers(selectedCrop!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Suppliers'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Select Crop',
                border: OutlineInputBorder(),
              ),
              items: crops.map((String crop) {
                return DropdownMenuItem<String>(
                  value: crop,
                  child: Text(crop),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    selectedCrop = value;
                  });
                  fetchSuppliers(value);
                }
              },
            ),
          ),
          Expanded(
            child: suppliers.isEmpty
                ? const Center(child: Text('No suppliers found'))
                : ListView.builder(
                    itemCount: suppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = suppliers[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/images/product1.jpg',
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 100,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error, size: 100),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplier['customer_name'] ??
                                              'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(supplier['contact_number'] ??
                                            'No contact'),
                                        Text(supplier['location_name'] ??
                                            'No location'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  'Quantities: ${supplier['quantities'] ?? 'N/A'}'),
                              Text(
                                  'Preferred Selling Price: ${supplier['preferred_selling_price'] ?? 'N/A'}'),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final phone =
                                        supplier['contact_number'] ?? '';
                                    if (phone.isNotEmpty) {
                                      final url = Uri.parse('tel:$phone');
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Cannot launch phone dialer')),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text('Call'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
