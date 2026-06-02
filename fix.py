import sys

file_path = 'd:/dev/vidyanexis/lib/presentation/pages/home/task_page.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

new_content = content.replace("\\'", "'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(new_content)
print("Fixed backslashes")
