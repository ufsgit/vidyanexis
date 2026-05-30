import os
import re

reports_dir = r'd:\dev\vidyanexis\lib\presentation\pages\reports'
files_to_fix = [
    'attendance_report.dart',
    'commission_report_mobile.dart',
    'customer_outstanding_report_mobile.dart',
    'employee_summary_report_screen.dart',
    'enquiry_for_summary_report_screen.dart',
    'enquiry_source_summary_report_screen.dart',
    'lead_check_in_report_mobile.dart',
    'out_of_warrenty_report_screen.dart',
    'periodic_service_report_page_mobile.dart',
    'sub_contract_report_mobile.dart',
    'task_summary_report_screen.dart',
    'total_outstanding_report_page.dart',
    'upcoming_warrenty_report_screen.dart',
    'work_report_screen_phone.dart',
    'work_summary_screen_phone.dart'
]

for file in files_to_fix:
    filepath = os.path.join(reports_dir, file)
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    fab_idx = content.find('floatingActionButton:')
    if fab_idx != -1:
        before_fab = content[:fab_idx]
        fab_content = content[fab_idx:]
        
        # We need to make sure we don't insert it again if the script is run multiple times
        if 'Provider.of<SidebarProvider>(context, listen: false).stopSearch();' not in fab_content:
            new_fab_content = re.sub(
                r'(\.toggleFilter\(\);)', 
                r'\1\n                    Provider.of<SidebarProvider>(context, listen: false).stopSearch();', 
                fab_content, 
                count=1
            )
            
            if 'package:vidyanexis/controller/side_bar_provider.dart' not in before_fab:
                before_fab = "import 'package:vidyanexis/controller/side_bar_provider.dart';\n" + before_fab
                
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(before_fab + new_fab_content)
            print(f'Fixed {file}')
        else:
            print(f'Already fixed {file}')
