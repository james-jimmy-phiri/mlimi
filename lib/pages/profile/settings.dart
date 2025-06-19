import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/pages/views/signup/pin_reset.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'en'; // Default language

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _language = storage.read('language') ?? 'en'; // Read language preference
  }

  String _localizedText(String en, String ny) {
    return _language == 'ny' ? ny : en;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        backgroundColor: Bgreen,
        elevation: 1,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: ListView(
          children: [
            Text(
              _localizedText("Settings", "Zokonda"),
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  _localizedText("Account", "Akaunti"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 15, thickness: 2),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SimpleResetScreen()),
                );
              },
              child: Text(
                _localizedText("Change password", "Sinthani Chinsinsi"),
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
            buildAccountOptionRow(context, _localizedText("Social", "Zanema")),
            buildAccountOptionRow(
                context, _localizedText("Language", "Chilankhulo")),
            buildAccountOptionRow(
                context, _localizedText("Security", "Chitetezo")),
            SizedBox(height: 40),
            Row(
              children: [
                Icon(Icons.volume_up_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  _localizedText("Notifications", "Zidziwitso"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 15, thickness: 2),
            SizedBox(height: 10),
            buildNotificationOptionRow(
                _localizedText("New for you", "Zatsopano kwa inu"), true),
            buildNotificationOptionRow(
                _localizedText("Account activity", "Zochitika pa akaunti"),
                true),
            buildNotificationOptionRow(
                _localizedText("Opportunity", "Mwayi"), false),
            const SizedBox(height: 50),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // Your sign-out logic
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  "SIGN OUT",
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 2.2,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildNotificationOptionRow(String title, bool isActive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: isActive,
            onChanged: (bool val) {
              // Your switch logic
            },
          ),
        ),
      ],
    );
  }

  GestureDetector buildAccountOptionRow(BuildContext context, String title) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => () {},
                    child: Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 10),
                        Text('EmailTo:info@farmradiomw.org'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => () {},
                    child: Row(
                      children: [
                        Icon(Icons.open_in_browser_sharp),
                        SizedBox(width: 10),
                        Text('Website'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => () {},
                    child: Row(
                      children: [
                        Icon(Icons.facebook),
                        SizedBox(width: 10),
                        Text('Facebook'),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(_localizedText("Close", "Tsekani")),
                ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
