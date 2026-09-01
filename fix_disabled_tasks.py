import sys

filepath = 'd:/vidyanexis/lib/presentation/pages/home/customer_page.dart'
content = open(filepath, 'r', encoding='utf-8').read()

old_code = '''                                                          if (users.isEmpty) {
                                                            return MenuItemButton(
                                                              onPressed: null,
                                                              child: Text(taskType
                                                                  .taskTypeName),
                                                            );
                                                          }'''
new_code = '''                                                          if (users.isEmpty) {
                                                            return const SizedBox.shrink();
                                                          }'''

content = content.replace('\r\n', '\n')
old_code = old_code.replace('\r\n', '\n')

if old_code in content:
    content = content.replace(old_code, new_code)
    open(filepath, 'w', encoding='utf-8').write(content)
    print("Success")
else:
    print("Failed to find the block")
