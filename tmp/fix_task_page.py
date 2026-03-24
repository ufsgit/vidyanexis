import sys
import os
import re

path = r"d:\dev\vidyanexis\lib\presentation\pages\home\task_page.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Using a very flexible regex for whitespace
pattern = r"exportToExcel\(\s+'Customer',\s+'Task',\s+'Enquiry for',\s+'Assigned To',\s+'Description',\s+'Date',\s+'Status'\s+\],"
replacement = r"""exportToExcel(
                                                        headers: [
                                                          'Customer',
                                                          'Task',
                                                          'Enquiry for',
                                                          'Assigned To',
                                                          'Description',
                                                          'Date',
                                                          'Status'
                                                        ],"""

new_content = re.sub(pattern, replacement, content, flags=re.MULTILINE)

if content == new_content:
    print("Regex failed to match. Trying even MORE flexible pattern.")
    # Match any positional arguments in exportToExcel() followed by a ],
    pattern = r"exportToExcel\(\s+'Customer',.*?'Status'\s+\],"
    new_content = re.sub(pattern, replacement, content, flags=re.DOTALL)

if content == new_content:
    print("STILL failed.")
else:
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("File updated successfully.")
