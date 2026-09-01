import sys
import os

filepath = 'd:/vidyanexis/lib/presentation/pages/home/lead_page.dart'
if os.path.exists(filepath):
    content = open(filepath, 'r', encoding='utf-8').read()
    if '(onHover) => MenuItemButton(' in content:
        content = content.replace('(onHover) => MenuItemButton(', '(onHover) => MenuItemButton(onHover: onHover, ')
        open(filepath, 'w', encoding='utf-8').write(content)
        print("Success for lead_page.dart")
    else:
        print("MenuItemButton not found in lead_page.dart")
else:
    print("lead_page.dart not found")
