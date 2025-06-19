import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyerDetail extends StatelessWidget {
  final Map<String, dynamic> buyer;
  final String imagePath;

  const BuyerDetail({Key? key, required this.buyer, required this.imagePath})
      : super(key: key);

  void _launchDial(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          buyer['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.person, 'Name', buyer['name']),
                    _buildDetailRow(
                        Icons.location_on, 'Location', buyer['location']),
                    _buildDetailRow(
                        Icons.agriculture, 'Value Chain', buyer['value_chain']),
                    _buildDetailRow(
                        Icons.production_quantity_limits,
                        'Recommended Starting Quantities',
                        buyer['recommended_starting_quantities']),
                    _buildDetailRow(Icons.map, 'District', buyer['district']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Contact Marketing Hotline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Click the button below to speak with Mlimi hotline agents for free and get connected with our marketing actors.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactButton('AIRTEL', '8111'),
                _buildContactButton('TNM', '7111'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(String network, String number) {
    return OutlinedButton.icon(
      onPressed: () => _launchDial(number),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide(color: Colors.blue),
      ),
      icon: Icon(Icons.phone, color: Colors.blue),
      label: Text(
        network,
        style: TextStyle(fontSize: 16, color: Colors.blue),
      ),
    );
  }
}
