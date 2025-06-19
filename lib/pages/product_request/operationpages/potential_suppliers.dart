import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_search/dropdown_search.dart';

class PotentialSuppliers extends StatefulWidget {
  @override
  _PotentialSuppliers createState() => _PotentialSuppliers();
}

class _PotentialSuppliers extends State<PotentialSuppliers> {
  List<dynamic> suppliers = [];
  String selectedCrop = "maize";

  Future<void> fetchSuppliers(String crop) async {
    final response = await http.get(Uri.parse('assets/data/suppliers.json'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        suppliers = data[crop];
      });
    } else {
      throw Exception('Failed to load suppliers');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSuppliers(selectedCrop);
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
            child: DropdownSearch<String>(
              items: ["maize", "groundnuts", "cassava", "soya", "rice"],
              selectedItem: selectedCrop,
              onChanged: (value) {
                setState(() {
                  selectedCrop = value!;
                });
                fetchSuppliers(selectedCrop);
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Card(
                  margin: EdgeInsets.all(10),
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
                            ),
                            SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  supplier['customer_name'],
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(supplier['contact_number']),
                                Text(supplier['location_name']),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text('Quantities: ${supplier['quantities']}'),
                        Text(
                            'Preferred Selling Price: ${supplier['preferred_selling_price']}'),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              // Implement call action
                            },
                            child: Text('Call'),
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
