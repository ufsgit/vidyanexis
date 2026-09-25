import os

path = r'd:\dev\vidyanexis\lib\presentation\pages\home\lead_page.dart'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the broken syntax
bad_syntax = '''                                                    decoration: BoxDecoration(
                                                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                                                                decoration: BoxDecoration(
                                                                    color: index % 2 != 0 ? Colors.white : Colors.transparent,
                                                                    borderRadius: BorderRadius.circular(8.0),
                                                                ),'''

good_syntax = '''                                                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                                                    decoration: BoxDecoration(
                                                        color: index % 2 != 0 ? Colors.white : Colors.transparent,
                                                        borderRadius: BorderRadius.circular(8.0),
                                                    ),'''

content = content.replace(bad_syntax, good_syntax)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Fixed lead_page.dart')
