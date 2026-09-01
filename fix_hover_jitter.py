import sys
content = open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'r', encoding='utf-8').read()

content = content.replace('(onHover) => MenuItemButton(', '(onHover) => MenuItemButton(onHover: onHover, ')

open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'w', encoding='utf-8').write(content)
print("Success")
