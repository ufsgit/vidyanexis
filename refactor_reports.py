import os
import glob
import re

reports_dir = r"d:\dev\vidyanexis\lib\presentation\pages\reports"
dart_files = glob.glob(os.path.join(reports_dir, "*.dart"))

for file in dart_files:
    with open(file, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    
    # 1. Update BorderRadius, Border, and add BoxShadow for the Search Container
    content = re.sub(
        r'borderRadius:\s*BorderRadius\.circular\(\d+\),\s*border:\s*Border\.all\(color:\s*Colors\.grey\[\d+\]!\),',
        r'borderRadius: BorderRadius.circular(10),\n                            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),\n                            boxShadow: [\n                              BoxShadow(\n                                color: Colors.black.withOpacity(0.02),\n                                blurRadius: 4,\n                                offset: const Offset(0, 2),\n                              ),\n                            ],',
        content
    )
    
    # 2. Update Hint text color and Icon styling in TextField
    content = re.sub(
        r"hintText:\s*'Search here\.\.\.\.',\s*prefixIcon:\s*const Icon\(Icons\.search\),",
        r"hintText: 'Search here....',\n                              hintStyle: const TextStyle(\n                                color: Color(0xFF94A3B8),\n                                fontSize: 13,\n                              ),\n                              prefixIcon: const Icon(\n                                Icons.search,\n                                color: Color(0xFF64748B),\n                                size: 18,\n                              ),",
        content
    )
    
    # 3. Update the Suffix Button (Search / Cancel) style
    content = re.sub(
        r'style:\s*ElevatedButton\.styleFrom\(\s*backgroundColor:\s*AppColors\.textGrey4,\s*foregroundColor:\s*Colors\.white,\s*padding:\s*const EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*\d+,\s*\),\s*\)',
        r'style: ElevatedButton.styleFrom(\n                                      backgroundColor: AppColors.primaryBlue,\n                                      foregroundColor: Colors.white,\n                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\n                                      shape: RoundedRectangleBorder(\n                                        borderRadius: BorderRadius.circular(10),\n                                      ),\n                                    )',
        content
    )
    
    # 4. Update CustomElevatedButton export/action buttons (Change Violet to Blue and add radius 10)
    # Be careful not to match multiple times incorrectly.
    content = re.sub(
        r'borderColor:\s*AppColors\.appViolet,\s*backgroundColor:\s*AppColors\.appViolet,',
        r'borderColor: AppColors.primaryBlue,\n                          backgroundColor: AppColors.primaryBlue,\n                          radius: 10,',
        content
    )
    
    # 5. Update ElevatedButton.icon style for Add buttons (like Add Attendance)
    content = re.sub(
        r'style:\s*ElevatedButton\.styleFrom\(\s*backgroundColor:\s*AppColors\.primaryBlue,\s*foregroundColor:\s*Colors\.white,\s*padding:\s*const EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*\d+,\s*\),\s*\)',
        r'style: ElevatedButton.styleFrom(\n                              backgroundColor: AppColors.primaryBlue,\n                              foregroundColor: Colors.white,\n                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),\n                              shape: RoundedRectangleBorder(\n                                borderRadius: BorderRadius.circular(10),\n                              ),\n                            )',
        content
    )
    
    if content != original_content:
        with open(file, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {os.path.basename(file)}")

print("Done refactoring.")
