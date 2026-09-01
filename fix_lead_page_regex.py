import sys
import re

filepath = 'd:/vidyanexis/lib/presentation/pages/home/lead_page.dart'
content = open(filepath, 'r', encoding='utf-8').read()

pattern = r'''\s*\.map\(\(taskType\)\s*\{\s*//\s*Find\s*users\s*for\s*this\s*task\s*type\s*based\s*on\s*department\s*final\s*users\s*=\s*provider\s*\.searchUserDetails\s*\.where\(\(user\)\s*\{\s*return\s*user\.departmentId\.toString\(\)\s*==\s*taskType\.departmentIds\.toString\(\);\s*\}\)\.toList\(\);\s*if\s*\(users\s*\.isEmpty\)\s*\{\s*return\s*MenuItemButton\(\s*onPressed:\s*null,\s*child:\s*Text\(taskType\.taskTypeName\),\s*\);\s*\}'''

new_code = '''
                                                                            .where((taskType) {
                                                                              final users = provider
                                                                                  .searchUserDetails
                                                                                  .where((user) {
                                                                                return user.departmentId.toString() ==
                                                                                    taskType.departmentIds.toString();
                                                                              }).toList();
                                                                              return users.isNotEmpty;
                                                                            })
                                                                            .map((taskType) {
                                                                          // Find users for this task type based on department
                                                                          final users = provider
                                                                              .searchUserDetails
                                                                              .where((user) {
                                                                            return user.departmentId.toString() ==
                                                                                taskType.departmentIds.toString();
                                                                          }).toList();'''

match = re.search(pattern, content)
if match:
    content = content[:match.start()] + new_code + content[match.end():]
    open(filepath, 'w', encoding='utf-8').write(content)
    print("Success empty tasks filter")
else:
    print("Failed to find empty tasks block regex")

