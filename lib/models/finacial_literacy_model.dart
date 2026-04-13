class FinancialTheme {
  final int id;
  final String name;
  final List<SubTheme> subThemes;

  FinancialTheme(
      {required this.id, required this.name, required this.subThemes});

  factory FinancialTheme.fromJson(Map<String, dynamic> json) {
    return FinancialTheme(
      id: json['id'],
      name: json['name'],
      subThemes: (json['sub_themes'] as List)
          .map((subTheme) => SubTheme.fromJson(subTheme))
          .toList(),
    );
  }
}


class SubTheme {
  final int id;
  final String name;
  final List<KeyMessage> keyMessages;

  SubTheme({required this.id, required this.name, required this.keyMessages});

  factory SubTheme.fromJson(Map<String, dynamic> json) {
    return SubTheme(
      id: json['id'],
      name: json['name'],
      keyMessages: (json['key_messages'] as List)
          .map((msg) => KeyMessage.fromJson(msg))
          .toList(),
    );
  }
}

class KeyMessage {
  final String title;
  final List<String> contents;

  KeyMessage({required this.title, required this.contents});

  factory KeyMessage.fromJson(Map<String, dynamic> json) {
    return KeyMessage(
      title: json['title'],
      contents: List<String>.from(json['contents']),
    );
  }
}
