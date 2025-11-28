import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mlimi/constants/color.dart';
import 'package:get_storage/get_storage.dart';

class HomeAppBarWithDrawer extends StatefulWidget {
  final Widget Function() profileScreenBuilder;
  final Widget Function() homepageBuilder;
  final Widget? body;

  const HomeAppBarWithDrawer({
    Key? key,
    required this.profileScreenBuilder,
    required this.homepageBuilder,
    this.body,
  }) : super(key: key);

  @override
  State<HomeAppBarWithDrawer> createState() => _HomeAppBarWithDrawerState();
}

class _HomeAppBarWithDrawerState extends State<HomeAppBarWithDrawer> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final storage = GetStorage();
  late String _language;

  @override
  void initState() {
    super.initState();
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    setState(() {
      _language = storage.read('language') ?? 'en';
    });
  }

  void _handleLanguageChange(String newLanguage) async {
    await storage.write('language', newLanguage);
    setState(() {
      _language = newLanguage;
    });
  }

  String _localizedText(String enText, String nyText) {
    return _language == 'ny' ? nyText : enText;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Bgreen,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset("assets/icons/menu.svg"),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: _localizedText("All ", "Zonse "),
                style: const TextStyle(color: ksecondaryColor),
              ),
              TextSpan(
                text: _localizedText("Advisory", "Malangizo"),
                style: const TextStyle(color: kPrimaryColor),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: SvgPicture.asset("assets/icons/notification.svg"),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 175, 188, 177),
                Colors.green.shade400
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/adbanner.jpg'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3), BlendMode.darken),
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    _localizedText('Menu', 'Menyu'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black45,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.white),
                title: Text(
                  _localizedText('Settings', 'Makonda'),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.profileScreenBuilder(),
                    )),
              ),
              Divider(color: Colors.white.withOpacity(0.5)),
              ListTile(
                leading: Icon(Icons.account_circle, color: Colors.white),
                title: Text(
                  _localizedText('My Account', 'Akaunti Yanga'),
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => widget.homepageBuilder(),
                    )),
              ),
              Divider(color: Colors.white.withOpacity(0.5)),
              ListTile(
                leading: Icon(Icons.language, color: Colors.white),
                title: Text(
                  _language == 'en'
                      ? 'Sinthani chiyankhulo KuChichewa'
                      : 'Change to English',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                onTap: () {
                  _handleLanguageChange(_language == 'en' ? 'ny' : 'en');
                },
              ),
            ],
          ),
        ),
      ),
      body: widget.body ?? Container(),
    );
  }
}
