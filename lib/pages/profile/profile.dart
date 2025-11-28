import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/constants/profileconstant.dart';
import 'package:mlimi/constants/url.dart';
import 'package:mlimi/pages/product_request/homepage.dart';
import 'package:mlimi/pages/profile/profile_list_item.dart';
import 'package:mlimi/pages/profile/help_and_privacy/help_and_privacy.dart';
import 'package:mlimi/pages/profile/settings.dart';
import 'package:mlimi/pages/profile/privacy/privacy.dart';
import 'package:mlimi/pages/views/base_screen.dart';
import 'package:mlimi/pages/views/signup/loginscreen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _language;
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Retrieve language preference from GetStorage
    _language = storage.read<String>('language') ?? 'en';
  }

  // Method to get localized text based on language preference
  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive design
    ScreenUtil.init(context, designSize: Size(414, 896), minTextAdapt: true);

    // Fetching user details from storage
    final name = storage.read<String>('name') ?? 'Unknown';
    final phone = storage.read<String>('phone') ?? 'No phone';

    var profileInfo = Expanded(
      child: Column(
        children: <Widget>[
          Container(
            height: kSpacingUnit.w * 10,
            width: kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: kSpacingUnit.w * 5,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style:
                        kTitleTextStyle.copyWith(fontSize: kSpacingUnit.w * 5),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    height: kSpacingUnit.w * 2.5,
                    width: kSpacingUnit.w * 2.5,
                    decoration: BoxDecoration(
                      color: Colors.green[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        LineAwesomeIcons.pen_alt_solid,
                        color: kDarkPrimaryColor,
                        size: kSpacingUnit.w * 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          Text(
            name,
            style: kTitleTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            phone,
            style: kCaptionTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Homepage()),
              );
            },
            child: Container(
              height: kSpacingUnit.w * 5,
              width: kSpacingUnit.w * 22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(kSpacingUnit.w * 3),
                color: Colors.green[300],
              ),
              child: Center(
                child: Text(
                  _localizedText('My Account', 'Akaunti Yanu'),
                  style: kButtonTextStyle,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        profileInfo,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    return Scaffold(
      backgroundColor: Bgreen,
      body: Column(
        children: <Widget>[
          SizedBox(height: kSpacingUnit.w * 5),
          header,
          Expanded(
            child: ListView(
              children: <Widget>[
                ProfileListItem(
                  icon: LineAwesomeIcons.user_shield_solid,
                  text: _localizedText('Privacy', 'Zachinsinsi'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PrivacyPolicyPage()),
                    );
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.history_solid,
                  text: _localizedText(
                      'Add a New Account', 'lowani Akaunti Yatsopano'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SimpleRegisterScreen()),
                    );
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.question_circle,
                  text: _localizedText(
                      'Help & Support', 'Thandizo ndi Chithandizo'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HelpSupportPage()),
                    );
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.user_plus_solid,
                  text: _localizedText('Invite a Friend', 'Dziwisani a Bwenzi'),
                  onTap: () {
                    const applink =
                        'https://play.google.com/store/apps/details?id=com.frtholdingsmw.mlimi&pcampaignid=web_share';

                    Share.share(
                        'Check out this amazing agriculture information app! Download it here: $applink');
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.cog_solid,
                  text: _localizedText('Settings', 'Zikhazikiso'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                ProfileListItem(
                  icon: LineAwesomeIcons.sign_out_alt_solid,
                  text: _localizedText('Logout', 'Tulukani'),
                  hasNavigation: false,
                  textColor: Colors.red,
                  onTap: () async {
                    try {
                      final response = await http.post(
                        Uri.parse('${apiurl}v1/auth/logout'),
                        headers: {
                          'Authorization': 'Bearer ${storage.read('token')}',
                          'Accept': 'application/json',
                        },
                      );

                      if (response.statusCode == 200) {
                        storage.remove('phone');
                        storage.remove('name');
                        storage.remove('token');

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => BaseScreen()),
                          (route) => false,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_localizedText(
                                'Successfully logged out', 'Mutuluka bwino')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (response.statusCode == 401) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_localizedText(
                                'You are already logged out',
                                'Mwatuluka kale')),
                            backgroundColor: Colors.red,
                          ),
                        );
                        storage.remove('name');
                        storage.remove('phone');
                        storage.remove('token');
                      } else {
                        throw Exception('Failed to log out');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_localizedText('Failed to log out: $e',
                              'mwakanika Kutuluka: $e')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
