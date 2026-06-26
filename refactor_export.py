import os
import re

def get_matching_brace(s, start_idx, open_char='{', close_char='}'):
    count = 1
    idx = start_idx
    while count > 0 and idx < len(s):
        if s[idx] == open_char:
            count += 1
        elif s[idx] == close_char:
            count -= 1
        idx += 1
    return idx

def refactor_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Find CustomElevatedButton export
    pattern_custom = r'CustomElevatedButton\s*\('
    matches = list(re.finditer(pattern_custom, content))
    for match in reversed(matches):
        start_idx = match.end()
        end_idx = get_matching_brace(content, start_idx, '(', ')')
        button_code = content[match.start():end_idx]
        
        if 'Export' in button_code or 'exportToExcel' in button_code or 'exportToPDF' in button_code:
            # Extract onPressed
            on_pressed_match = re.search(r'onPressed:\s*(\([^)]*\)\s*(?:async\s*)?{)', button_code)
            if not on_pressed_match:
                # maybe onPressed: () => ...
                on_pressed_match = re.search(r'onPressed:\s*(\([^)]*\)\s*(?:async\s*)?=>[^\n,]*),?', button_code)
            
            if on_pressed_match:
                op_start = on_pressed_match.end(1) - 1 # '{' or '='
                if button_code[op_start] == '{':
                    op_end = get_matching_brace(button_code, op_start + 1, '{', '}')
                    on_pressed_code = button_code[on_pressed_match.start():op_end]
                else:
                    on_pressed_code = on_pressed_match.group(0).strip().rstrip(',')
                
                label = 'Export'
                if 'Export to PDF' in button_code:
                    label = 'Export to PDF'
                elif 'Export to Excel' in button_code:
                    label = 'Export to Excel'
                elif 'buttonText:' in button_code:
                    lbl_match = re.search(r'buttonText:\s*\'([^\']+)\'', button_code)
                    if lbl_match: label = lbl_match.group(1)
                
                new_button = f'''CommonReportExportButton(
                      {on_pressed_code},
                      label: '{label}',
                    )'''
                content = content[:match.start()] + new_button + content[end_idx:]

    # Find ElevatedButton.icon export
    pattern_elevated = r'ElevatedButton\.icon\s*\('
    matches = list(re.finditer(pattern_elevated, content))
    for match in reversed(matches):
        start_idx = match.end()
        end_idx = get_matching_brace(content, start_idx, '(', ')')
        button_code = content[match.start():end_idx]
        
        if 'Export' in button_code or 'exportToExcel' in button_code:
            # Extract onPressed
            on_pressed_match = re.search(r'onPressed:\s*(\([^)]*\)\s*(?:async\s*)?{)', button_code)
            if not on_pressed_match:
                # maybe onPressed: () => ...
                on_pressed_match = re.search(r'onPressed:\s*(\([^)]*\)\s*(?:async\s*)?=>[^\n,]*),?', button_code)
            
            if on_pressed_match:
                op_start = on_pressed_match.end(1) - 1 # '{'
                if button_code[op_start] == '{':
                    op_end = get_matching_brace(button_code, op_start + 1, '{', '}')
                    on_pressed_code = button_code[on_pressed_match.start():op_end]
                else:
                    on_pressed_code = on_pressed_match.group(0).strip().rstrip(',')
                
                label = 'Export'
                if 'Export to Excel' in button_code:
                    label = 'Export to Excel'
                
                new_button = f'''CommonReportExportButton(
                      {on_pressed_code},
                      label: '{label}',
                    )'''
                content = content[:match.start()] + new_button + content[end_idx:]

    if content != original_content:
        # Add import if missing
        import_stmt = "import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';"
        if import_stmt not in content:
            # find last import
            last_import = content.rfind("import '")
            if last_import != -1:
                end_import = content.find('\n', last_import)
                content = content[:end_import] + '\n' + import_stmt + content[end_import:]
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Refactored {os.path.basename(filepath)}')

dir_path = r'd:\vidyanexis\lib\presentation\pages\reports'
for filename in os.listdir(dir_path):
    if filename.endswith('.dart'):
        refactor_file(os.path.join(dir_path, filename))
