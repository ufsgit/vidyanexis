import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    while (true) {
      int iconIndex = content.indexOf('Icons.filter_list');
      if (iconIndex == -1) iconIndex = content.indexOf('Icons.filter_alt');
      if (iconIndex == -1) break;

      // Check if it's commented out
      int lineStart = content.lastIndexOf('\n', iconIndex);
      if (lineStart != -1) {
        String linePrefix = content.substring(lineStart, iconIndex);
        if (linePrefix.contains('//')) {
          content = content.replaceFirst(
              'Icons.filter', 'Icons.REPLACED_FILTER', iconIndex);
          continue;
        }
      }

      // Find the start of the button
      int startIdx = content.lastIndexOf('ElevatedButton.icon', iconIndex);
      int startIdx2 = content.lastIndexOf('OutlinedButton.icon', iconIndex);

      int buttonStart = startIdx > startIdx2 ? startIdx : startIdx2;

      if (buttonStart == -1 || (iconIndex - buttonStart > 800)) {
        content = content.replaceFirst(
            'Icons.filter', 'Icons.REPLACED_FILTER', iconIndex);
        continue;
      }

      // Find matching closing parenthesis
      int balance = 0;
      int endIndex = -1;
      bool started = false;
      for (int i = buttonStart; i < content.length; i++) {
        if (content[i] == '(') {
          balance++;
          started = true;
        } else if (content[i] == ')') {
          balance--;
        }
        if (started && balance == 0) {
          endIndex = i;
          break;
        }
      }

      if (endIndex == -1) {
        content = content.replaceFirst(
            'Icons.filter', 'Icons.REPLACED_FILTER', iconIndex);
        continue;
      }

      String buttonCode = content.substring(buttonStart, endIndex + 1);

      int onPressedStart = buttonCode.indexOf('onPressed:');
      if (onPressedStart == -1) {
        content = content.replaceFirst(
            'Icons.filter', 'Icons.REPLACED_FILTER', iconIndex);
        continue;
      }

      int nextParamStart =
          buttonCode.length - 1; // End right before the closing ')'
      List<String> otherParams = ['icon:', 'label:', 'style:'];
      for (String param in otherParams) {
        int idx = buttonCode.indexOf(param);
        if (idx > onPressedStart && idx < nextParamStart) {
          nextParamStart = idx;
        }
      }

      String onPressedCode =
          buttonCode.substring(onPressedStart + 10, nextParamStart).trim();
      if (onPressedCode.endsWith(',')) {
        onPressedCode =
            onPressedCode.substring(0, onPressedCode.length - 1).trim();
      }

      // Extract provider.isFilter
      String isFilterCode = 'false';
      RegExp exp = RegExp(r'([a-zA-Z0-9_]+\.isFilter)');
      var match = exp.firstMatch(buttonCode);
      if (match != null) {
        isFilterCode = match.group(1)!;
      }

      String replacement = '''CustomFilterButton(
  onPressed: $onPressedCode,
  isFilter: $isFilterCode,
)''';

      content = content.replaceRange(buttonStart, endIndex + 1, replacement);
      changed = true;
    }

    content = content.replaceAll('Icons.REPLACED_FILTER', 'Icons.filter');

    if (changed) {
      String importStr =
          "import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';\n";
      if (!content.contains('custom_filter_button.dart')) {
        int importIdx = content.indexOf('import ');
        if (importIdx != -1) {
          content = content.substring(0, importIdx) +
              importStr +
              content.substring(importIdx);
        } else {
          content = importStr + content;
        }
      }
      file.writeAsStringSync(content);
      print('Updated: \${file.path}');
    }
  }
}
