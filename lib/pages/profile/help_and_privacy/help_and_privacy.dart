import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mlimi/constants/color.dart';
import 'package:get_storage/get_storage.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  _HelpSupportPageState createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  late String _language;

  @override
  void initState() {
    super.initState();
    final storage = GetStorage();
    _language = storage.read<String>('language') ?? 'en'; // Default to English
  }

  String _localizedText(String enText, String chText) {
    return _language == 'en' ? enText : chText;
  }

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://www.farmradiomw.org');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }

  void _launchDial(String number) async {
    final url = 'tel:$number';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _launchEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _launchMap(String query) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$query';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(
        backgroundColor: Bgreen,
        elevation: 1,
        title: Text(
          _localizedText('Help & Support', 'Thandizo ndi Chithandizo'),
        ),
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
            Row(
              children: [
                Icon(Icons.person, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  _localizedText('Need Assistance', 'Mukufuna Thandizo'),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 15, thickness: 2),
            SizedBox(height: 10),
            Text(
              _localizedText(
                'If you need help or more information to guide you, or if you want to speak to a support agent, feel free to call our call center hotline below.',
                'Ngati mukufuna thandizo kapena zambiri zothandizira, kapena mukufuna kuyankhula ndi wothandizira, chonde imbani foni pa manambala omwe ali pansipa.',
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              _localizedText(
                'Select Your Network below to speak with mlimi hotline agents for an assistance',
                'Sankhani netiweki yomwe mumagwiritsa ntchito pansipa kuti muyankhule ndi othandizira a Mlimi Hotline kuti akuthandizeni.',
              ),
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton(
                  onPressed: () => _launchDial('8111'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "AIRTEL",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.2,
                      color: Colors.black,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () => _launchDial('7111'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    "TNM",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 2.2,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Icon(Icons.volume_up_outlined, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  _localizedText(
                    'Contact Details',
                    'Zambiri Zolankhulana',
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(height: 15, thickness: 2),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchMap(
                  'Plot number 862, Area 47 Sector 4, Off Msokela Road'),
              child: Row(
                children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _localizedText(
                        'Plot number 862, Area 47 Sector 4, Off Msokela Road',
                        'Chiwerengero cha plot 862, Area 47 Sector 4, Off Msokela Road',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchDial('+265993449245'),
              child: Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 10),
                  Text('+265 993 449 245'),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => _launchEmail('info@farmradiomw.org'),
              child: Row(
                children: [
                  Icon(Icons.email),
                  SizedBox(width: 10),
                  Text('info@farmradiomw.org'),
                ],
              ),
            ),
            SizedBox(height: 50),
            Center(
              child: OutlinedButton(
                onPressed: _launchWebsite,
                child: Text(
                  _localizedText('VISIT WEBSITE', 'PITANI KU WEBUSAITI'),
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
}
