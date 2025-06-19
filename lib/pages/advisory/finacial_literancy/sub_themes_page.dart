import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import '../../../models/finacial_literacy_model.dart';
import 'key_messages_page.dart';

class SubThemesPage extends StatelessWidget {
  final List<SubTheme> subThemes;

  SubThemesPage({required this.subThemes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(title: Text("Sub-Themes")),
      body: subThemes.isEmpty
          ? Center(child: Text("No sub-themes available"))
          : ListView.builder(
              itemCount: subThemes.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      subThemes[index].name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    trailing: Icon(Icons.navigate_next, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KeyMessagesPage(messages: subThemes[index].keyMessages),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
