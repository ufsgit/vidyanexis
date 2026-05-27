import os
import glob
import re

reports_dir = r"d:\dev\vidyanexis\lib\presentation\pages\reports"
dart_files = glob.glob(os.path.join(reports_dir, "*.dart"))

def replace_radius(match):
    val = int(match.group(1))
    # We want to change radii that are between 5 and 30 to 4. 
    # Things larger like 50 or 100 are likely circular avatars.
    if 5 <= val <= 30:
        return "BorderRadius.circular(4)"
    return match.group(0)

for file in dart_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Replace BorderRadius.circular
    content = re.sub(r'BorderRadius\.circular\((\d+)\)', replace_radius, content)
    
    # Replace CustomElevatedButton radius if it was previously set to 10 or 16
    content = re.sub(r'radius:\s*10,', 'radius: 4,', content)
    content = re.sub(r'radius:\s*16,', 'radius: 4,', content)
    
    if content != original_content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {os.path.basename(file)}")

print("Radius update complete.")
