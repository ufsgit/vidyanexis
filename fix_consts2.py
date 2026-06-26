import re
path = r"d:\vidyanexis\lib\presentation\pages\reports\lead_check_in_report_screen.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

content = re.sub(r"const\s+Text\(\s*'Choose Date'", "Text('Choose Date'", content)
content = re.sub(r"const\s+Text\(\s*'Pick a date'", "Text('Pick a date'", content)
content = re.sub(r"const\s+Center\(\s*child:\s*Text\(\s*'Choose Date'", "Center(child: Text('Choose Date'", content)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
