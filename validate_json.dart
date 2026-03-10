import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('assets/data/mlimi_chichewa.json');
  try {
    final contents = file.readAsStringSync();
    final data = jsonDecode(contents);
    print('JSON parsed successfully!');
    print(data['sectors'].length.toString() + ' sectors found.');
  } catch (e) {
    print('Failed to parse JSON: \$e');
  }
}
