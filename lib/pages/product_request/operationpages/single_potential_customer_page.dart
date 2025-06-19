import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SinglePotentialCustomerPage extends StatefulWidget {
  final Map<String, dynamic> commodity;

  const SinglePotentialCustomerPage({super.key, required this.commodity});

  @override
  _SinglePotentialCustomerPageState createState() =>
      _SinglePotentialCustomerPageState();
}

class _SinglePotentialCustomerPageState
    extends State<SinglePotentialCustomerPage> {
  int? _expandedIndex;

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

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openWhatsApp(String phone) async {
    // Remove the first digit if it's 0 and add +265
    String formattedPhone =
        phone.startsWith('0') ? '+265${phone.substring(1)}' : phone;
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: formattedPhone,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    final customers = widget.commodity['customers'];

    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        title: Text('Potential Customers for ${widget.commodity['name']}'),
      ),
      body: ListView.builder(
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return Slidable(
            key: ValueKey(customer['phone']),
            startActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) => _makePhoneCall(customer['phone']),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  icon: Icons.call,
                  label: 'Call',
                ),
              ],
            ),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) =>
                      _showDialog(context, 'Poked Time', customer['poked']),
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  icon: Icons.access_time,
                  label: 'Poked Time',
                ),
                SlidableAction(
                  onPressed: (context) => _openWhatsApp(customer['phone']),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  icon: Icons.chat_rounded,
                  label: 'Chat',
                ),
                SlidableAction(
                  onPressed: (context) => _showDialog(
                      context, 'Unit Price', widget.commodity['unit_price']),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  icon: Icons.attach_money,
                  label: 'Unit Price',
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(customer['name'][0]),
              ),
              title: Text(customer['name']),
              subtitle: Text(
                _obfuscatePhoneNumber(customer['phone']),
                style: TextStyle(fontSize: 13.0),
              ),
              trailing: IconButton(
                icon: Icon(Icons.call),
                onPressed: () => _makePhoneCall(customer['phone']),
              ),
            ),
          );
        },
      ),
    );
  }
}
