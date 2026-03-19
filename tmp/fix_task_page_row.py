import sys
import os
import re

path = r"d:\dev\vidyanexis\lib\presentation\pages\home\task_page.dart"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# Find the TableWidget for taskTypeName and add one for enquiryForName
# Line 1435 is where it starts.

target = """                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message:
                                                      task.taskTypeName ?? '',
                                                  child: Text(
                                                    task.taskTypeName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF334155),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),"""

replacement = """                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message:
                                                      task.taskTypeName ?? '',
                                                  child: Text(
                                                    task.taskTypeName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF334155),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message:
                                                      task.enquiryForName ?? '',
                                                  child: Text(
                                                    task.enquiryForName ?? '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF334155),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),"""

# Using flags=re.S to match across multiple lines and ignoring leading space differences
# Wait, I'll use a more robust regex.

pattern = re.escape(target).replace(r"\ ", r"\s+")
new_content = re.sub(pattern, replacement, content, flags=re.S)

if content == new_content:
    print("Regex failed. Trying different approach.")
    # Fallback to searching for task.taskTypeName ?? '' and adding after its parent TableWidget
    # This might be tricky. Let's try matching the whole block more loosely.
    pattern = r"TableWidget\(\s+flex: 2,\s+padding:\s+const EdgeInsets\.symmetric\(.*?task\.taskTypeName\s+\?\?\s+''.*?\),\s+\),"
    new_content = re.sub(pattern, replacement, content, flags=re.S)

if content == new_content:
    print("STILL failed.")
else:
    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("File updated successfully.")
