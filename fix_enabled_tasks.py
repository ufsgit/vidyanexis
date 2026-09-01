import sys
import re

def fix_file(filepath):
    try:
        content = open(filepath, 'r', encoding='utf-8').read()
        new_content = re.sub(r'taskType\.manualCreation\s*==\s*1', r'taskType.manualCreation == 1 && taskType.isEnabled', content)
        if new_content != content:
            open(filepath, 'w', encoding='utf-8').write(new_content)
            print(f"Success {filepath}")
        else:
            print(f"Failed {filepath}")
    except Exception as e:
        print(f"Error {filepath}: {e}")

fix_file('d:/vidyanexis/lib/presentation/pages/home/lead_page.dart')
fix_file('d:/vidyanexis/lib/presentation/pages/home/customer_page.dart')
fix_file('d:/vidyanexis/lib/presentation/pages/home/task_page.dart')
