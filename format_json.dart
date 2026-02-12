import 'dart:io';
import 'dart:convert';

void main() {
  var file = File('assets/data/farmers_data.json');
  if (!file.existsSync()) {
    print('File not found: ${file.path}');
    return;
  }

  var content = file.readAsStringSync();
  var json = jsonDecode(content);
  
  var encoder = JsonEncoder.withIndent('  ');
  var formatted = encoder.convert(json);
  
  file.writeAsStringSync(formatted);
  print('Formatted JSON written to ${file.path}');
}
