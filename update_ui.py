import os
import re

files_to_update = [
    r'lib\presentation\pages\home\task_page.dart',
    r'lib\presentation\pages\home\lead_page.dart',
    r'lib\presentation\pages\home\customer_page.dart'
]

def update_background(content):
    # Match the decoration or color of the row container
    # case 1: just color
    content = re.sub(
        r'color:\s*index\s*%\s*2\s*==\s*0\s*\?\s*Colors\.white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\),',
        r'margin: const EdgeInsets.symmetric(vertical: 4.0),\n                                                                decoration: BoxDecoration(\n                                                                    color: index % 2 != 0 ? Colors.white : Colors.transparent,\n                                                                    borderRadius: BorderRadius.circular(8.0),\n                                                                ),',
        content
    )
    # case 2: decoration already present but without border radius
    content = re.sub(
        r'decoration:\s*BoxDecoration\(\s*color:\s*index\s*%\s*2\s*==\s*0\s*\?\s*Colors\.white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\),',
        r'margin: const EdgeInsets.symmetric(vertical: 4.0),\n                                                                decoration: BoxDecoration(\n                                                                    color: index % 2 != 0 ? Colors.white : Colors.transparent,\n                                                                    borderRadius: BorderRadius.circular(8.0),',
        content
    )
    
    # case 3: hovered row index logic
    content = re.sub(
        r'color:\s*index\s*==\s*_hoveredRowIndex\s*\?\s*const\s*Color\(\s*0xFFF1F5F9\s*\)\s*:\s*\(index\s*%\s*2\s*==\s*0\s*\?\s*Colors\.white\s*:\s*const\s*Color\(\s*0xFFF6F7F9\s*\)\),',
        r'color: index == _hoveredRowIndex ? const Color(0xFFF1F5F9) : (index % 2 != 0 ? Colors.white : Colors.transparent),\n                                                                borderRadius: BorderRadius.circular(8.0),',
        content
    )

    # Let's fix the font: GoogleFonts.montserrat is a good choice for the font.
    # We can inject GoogleFonts by replacing TextStyle( with GoogleFonts.montserrat(
    # but maybe it's safer to just change the app-wide font in main.dart?
    return content

for file in files_to_update:
    path = os.path.join(r'd:\dev\vidyanexis', file)
    if os.path.exists(path):
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = update_background(content)
        
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated {file}")
    else:
        print(f"File not found: {file}")

