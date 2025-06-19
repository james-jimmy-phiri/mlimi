import 'package:flutter/material.dart';
import 'package:mlimi/constants/color.dart';
import '../../../models/finacial_literacy_model.dart';


class KeyMessagesPage extends StatelessWidget {
  final List<KeyMessage> messages;

  KeyMessagesPage({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Bgreen,
      appBar: AppBar(title: Text("Key Messages")),
      body: messages.isEmpty
          ? Center(child: Text("No key messages available"))
          : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ExpansionTile(
                    title: Text(
                      messages[index].title,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: messages[index].contents
                        .map((content) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Text(content, style: TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                  ),
                );
              },
            ),
    );
  }
}
