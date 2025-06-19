import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late String _language;

  @override
  void initState() {
    super.initState();
    // Retrieve the selected language from GetStorage
    final storage = GetStorage();
    _language = storage.read<String>('language') ?? 'en'; // Default to English
  }

  String _localizedText(String enText, String chText) {
    return _language == 'en' ? enText : chText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _localizedText('Privacy Policy', 'Ndondomeko Yachinsinsi'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _localizedText('Privacy Policy', 'Ndondomeko Yachinsinsi'),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              _localizedText(
                'This privacy policy applies to the Mlimi_app app (hereafter referred to as "Application") for mobile devices, created by Farm Radio Trust (hereafter referred to as "Service Provider") as a Free service. This service is provided "AS IS".',
                'Ndondomeko yachinsinsi iyi imagwira ntchito pa pulogalamu ya Mlimi_app yomwe idapangidwa ndi Farm Radio Trust (yomwe pambuyo pake idzatchedwa "Service Provider") ngati ntchito yaulere. Ntchitoyi imaperekedwa "MONGA ILILI".',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(_localizedText(
                '1. Information Collection and Use',
                '1. Kusonkhanitsa ndi Kugwiritsa Ntchito Zambiri')),
            Text(
              _localizedText(
                'The Application collects certain information when you download and use it. This may include:\n- IP address\n- Pages visited and time spent\n- Device operating system\n\n**User Information**: Additional personal data may include User ID, gender, phone number, and location for enhanced service and contact purposes.',
                'Pulogalamuyi imasonkhanitsa zambiri zina mukaitsitsa ndi kuigwiritsa ntchito. Izi zitha kuphatikiza:\n- Adilesi ya IP\n- Masamba omwe adayendera ndi nthawi yomwe adalipirako\n- Njira yogwiritsira ntchito chipangizo\n\n**Zambiri za Ogwiritsa Ntchito**: Zina zodzipereka zitha kuphatikiza ID ya Wogwiritsa Ntchito, jenda, nambala ya foni, ndi malo opititsa patsogolo ntchito ndi zolumikizana.',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(_localizedText(
                '2. Third Party Access', '2. Kupeza Kwa Wachitatu')),
            Text(
              _localizedText(
                'Aggregated, anonymized data may be sent to external services to enhance our Application. The Application utilizes third-party services with their own privacy policies:\n- Google Play Services\n\nThe Service Provider may disclose information under legal obligation or with trusted service providers.',
                'Zambiri zopangidwa mwachidule komanso osadziwika zitha kuperekedwa kwa ntchito zakunja kuti apititse patsogolo Pulogalamuyi. Pulogalamuyi imagwiritsa ntchito ntchito za wachitatu ndi ndondomeko zawo zachinsinsi:\n- Google Play Services\n\nWopereka Ntchito akhoza kufotokoza zambiri pansi pa udindo wazamalamulo kapena ndi ogwiritsa ntchito omwe amawakhulupirira.',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(_localizedText(
                '3. Opt-Out Rights', '3. Ufulu Wopanda Kutenga Nawo Gawo')),
            Text(
              _localizedText(
                'You can stop all collection of information by uninstalling the Application using standard device methods.',
                'Mutha kuletsa kusonkhanitsidwa kwa zambiri zonse pokhazikitsa Pulogalamuyi pogwiritsa ntchito njira zokhazikika za chipangizo.',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(_localizedText(
                '4. Data Retention Policy', '4. Ndondomeko Yosungira Zambiri')),
            Text(
              _localizedText(
                'The Service Provider retains user data while you use the Application and for a reasonable period thereafter. Contact us at info@farmradiomw.org to request deletion of your data.',
                'Wopereka Ntchito amasunga zambiri za ogwiritsa ntchito mukamagwiritsa ntchito Pulogalamuyi komanso kwanthawi yokwanira pambuyo pake. Lumikizanani nafe pa info@farmradiomw.org kuti mupemphere kuchotsedwa kwa zomwe zili nanu.',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            _buildSectionTitle(_localizedText(
                "5. Children's Privacy", "5. Zachinsinsi za Ana")),
            Text(
              _localizedText(
                'The Service Provider does not collect data from children under 13. If data from a child is discovered, it will be deleted. Contact us at info@farmradiomw.org with concerns.',
                'Wopereka Ntchito sakusonkhanitsa zambiri kuchokera kwa ana osakwana zaka 13. Ngati deta yochokera kwa mwana idzapezeka, idzachotsedwa. Lumikizanani nafe pa info@farmradiomw.org ngati mukuda nkhawa.',
              ),
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            // Additional sections follow the same pattern...
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.green.shade700,
      ),
    );
  }
}
