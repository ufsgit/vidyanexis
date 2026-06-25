import sys
path = r"d:\vidyanexis\lib\presentation\pages\reports\lead_check_in_report_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("const Text('Check-in Reports'", "Text('Check-in Reports'")
content = content.replace("const DropdownMenuItem<int>(", "DropdownMenuItem<int>(")
content = content.replace("child: const Row(", "child: Row(")
content = content.replace("const Text('All'", "Text('All'")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
