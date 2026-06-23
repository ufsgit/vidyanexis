import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  int buttonCount = 0;
  for (final file in files) {
    final content = file.readAsStringSync();
    if (content.contains('Icons.filter_list') ||
        content.contains('Icons.filter_alt')) {
      print(file.path);
      buttonCount++;
    }
  }
  print('Total files with filter icon: $buttonCount');
}
