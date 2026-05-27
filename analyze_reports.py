import os
import glob
import re

reports_dir = r"d:\dev\vidyanexis\lib\presentation\pages\reports"
dart_files = glob.glob(os.path.join(reports_dir, "*.dart"))

has_search = 0
has_elevated_button_suffix = 0
has_custom_elevated_button = 0
has_elevated_button_export = 0

for file in dart_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
        
        if "hintText: 'Search here....'" in content:
            has_search += 1
            
        if "suffixIcon: Padding(" in content and "ElevatedButton(" in content:
            has_elevated_button_suffix += 1
            
        if "CustomElevatedButton(" in content:
            has_custom_elevated_button += 1
            
        if "ElevatedButton.icon(" in content and "Export" in content:
            has_elevated_button_export += 1

print(f"Total dart files: {len(dart_files)}")
print(f"Files with search bar: {has_search}")
print(f"Files with Elevated Button as search suffix (Search/Cancel): {has_elevated_button_suffix}")
print(f"Files with CustomElevatedButton: {has_custom_elevated_button}")
print(f"Files with ElevatedButton.icon (Export): {has_elevated_button_export}")
