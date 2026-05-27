import os
import re

files_to_fix = [
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\conversion_report_page.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\invoice_reports_screen.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\lead_check_in_report_screen.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\lead_page_report.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\lead_report_mobile.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\lead_status_report_screen.dart",
    r"d:\dev\vidyanexis\lib\presentation\pages\reports\staff_location_report_screen.dart",
]

for file in files_to_fix:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We find CustomElevatedButton and add radius if it's missing
    # We can match CustomElevatedButton(\s*onPressed:
    # and add radius: 4, inside it
    content = re.sub(r'CustomElevatedButton\(', r'CustomElevatedButton(\n                          radius: 4,', content)
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(content)
        
    print(f"Fixed {os.path.basename(file)}")

print("Done fixing CustomElevatedButton radii.")
