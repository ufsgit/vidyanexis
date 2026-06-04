import os

dir_path = r'd:\vidyanexis\lib\presentation'

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content
    search_str = "Icon(Icons.search_off_outlined"

    while search_str in content:
        icon_index = content.find(search_str)
        # Find the Center( that encloses this Icon
        center_index = content.rfind("Center(", 0, icon_index)
        if center_index == -1:
            break
        
        # Find the text message
        text_start = content.find("Text(", icon_index)
        if text_start == -1:
            break
        quote_start = content.find("'", text_start)
        quote_end = content.find("'", quote_start + 1)
        if quote_start == -1 or quote_end == -1:
            break
        msg = content[quote_start+1:quote_end]
        
        # Now find the end of the Center block
        # We need to count brackets starting from center_index
        open_brackets = 0
        end_index = -1
        for i in range(center_index, len(content)):
            if content[i] == '(':
                open_brackets += 1
            elif content[i] == ')':
                open_brackets -= 1
                if open_brackets == 0:
                    end_index = i
                    break
                    
        if end_index != -1:
            # Replace the whole block
            prefix = content[:center_index]
            suffix = content[end_index+1:]
            content = prefix + f"const CommonEmptyState(message: '{msg}')" + suffix
        else:
            break

    if content != original_content:
        if 'CommonEmptyState' in content and 'common_empty_state.dart' not in content:
            import_str = "import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';\n"
            last_import = content.rfind('import ')
            if last_import != -1:
                end_of_last_import = content.find('\n', last_import) + 1
                content = content[:end_of_last_import] + import_str + content[end_of_last_import:]
            else:
                content = import_str + content
                
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk(dir_path):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))
