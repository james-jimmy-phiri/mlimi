import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import 'package:mlimi/services/advisory_service.dart';
import '../../../models/finacial_literacy_model.dart';

import 'sub_themes_page.dart';

class ThemesPage extends StatefulWidget {
  @override
  _ThemesPageState createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage> {
  late Future<List<FinancialTheme>> _themesFuture;

  @override
  void initState() {
    super.initState();
    _themesFuture = DataService.loadFinancialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(title: Text("Financial Themes")),
      body: FutureBuilder<List<FinancialTheme>>(
        future: _themesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(
                child: Text("Failed to load data or no themes available."));
          }

          List<FinancialTheme> themes = snapshot.data!;

          return ListView.builder(
            itemCount: themes.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    themes[index].name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SubThemesPage(subThemes: themes[index].subThemes),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
