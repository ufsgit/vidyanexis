import os
import re

files_to_update = [
    r'lib\presentation\pages\home\task_page.dart',
    r'lib\presentation\pages\home\lead_page.dart',
    r'lib\presentation\pages\home\customer_page.dart'
]

def update_background(content):
    # Let's find child: Container( \n height: rowHeight, \n color: index % 2 == 0 ...
    # And replace with margin and decoration
    
    pattern1 = r'(child:\s*Container\(\s*height:\s*rowHeight,\s*)color:\s*index\s*%\s*2\s*==\s*0\s*\?\s*Colors\s*\.\s*white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\),'
    replacement1 = r'\1margin: const EdgeInsets.symmetric(vertical: 4.0),\n                                                                decoration: BoxDecoration(\n                                                                    color: index % 2 != 0 ? Colors.white : Colors.transparent,\n                                                                    borderRadius: BorderRadius.circular(8.0),\n                                                                ),'
    
    content, count1 = re.subn(pattern1, replacement1, content)
    
    pattern2 = r'(decoration:\s*BoxDecoration\(\s*)color:\s*index\s*%\s*2\s*==\s*0\s*\?\s*Colors\s*\.\s*white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\),'
    replacement2 = r'\1color: index % 2 != 0 ? Colors.white : Colors.transparent,\n                                                                    borderRadius: BorderRadius.circular(8.0),'
    
    content, count2 = re.subn(pattern2, replacement2, content)
    
    pattern3 = r'color:\s*index\s*==\s*_hoveredRowIndex\s*\?\s*const\s*Color\(\s*0xFFF1F5F9\s*\)\s*:\s*\(index\s*%\s*2\s*==\s*0\s*\?\s*Colors\s*\.\s*white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\)\),'
    replacement3 = r'color: index == _hoveredRowIndex ? const Color(0xFFF1F5F9) : (index % 2 != 0 ? Colors.white : Colors.transparent),\n                                                                borderRadius: BorderRadius.circular(8.0),'
    
    content, count3 = re.subn(pattern3, replacement3, content)

    print(f"Replacements made: P1={count1}, P2={count2}, P3={count3}")

    return content

for file in files_to_update:
    path = os.path.join(r'd:\dev\vidyanexis', file)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = update_background(content)
        
        if new_content != content:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated {file}")
        else:
            print(f"No changes for {file}")
    else:
        print(f"File not found: {file}")

