import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';

class SinglePotentialSupplierPage extends StatelessWidget {
  final Map<String, dynamic> commodity;

  const SinglePotentialSupplierPage({super.key, required this.commodity});

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  String _obfuscatePhoneNumber(String phoneNumber) {
    return phoneNumber.substring(0, phoneNumber.length - 4) + '****';
  }

  @override
  Widget build(BuildContext context) {
    final suppliers = commodity['suppliers'];

    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        title: Text('Potential Customers for ${commodity['name']}'),
      ),
      body: ListView.builder(
        itemCount: suppliers.length,
        itemBuilder: (context, index) {
          final customer = suppliers[index];
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  child: Text(customer['name'][0]),
                ),
                title: Text(customer['name']),
                subtitle: Text(_obfuscatePhoneNumber(customer['phone'])),
                trailing: IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () => _makePhoneCall(customer['phone']),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //Text('Preferred Price: ${commodity['unit_price']}'),
                    Text('Poked Time: ${customer['poked']}'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
