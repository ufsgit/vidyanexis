import os
import re

dir_path = r'd:\vidyanexis\lib\presentation\pages\inventory'

# Match the inventory empty state pattern more flexibly
pattern = re.compile(r'Widget _buildEmptyState\(\) \{\s*return Padding\(\s*padding:[^)]+\),\s*child:\s*Center\(\s*child:\s*Column\(\s*mainAxisSize:\s*MainAxisSize\.min,\s*children:\s*\[\s*Icon\([^)]+\),\s*const SizedBox\(height:\s*\d+\),\s*Text\(\s*\'([^\']+)\',.*?\),\s*\],\s*\),\s*\),\s*\);\s*\}', re.MULTILINE | re.DOTALL)

for root, _, files in os.walk(dir_path):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
            
            original_content = content
            
            def replace_func(match):
                msg = match.group(1)
                return f"Widget _buildEmptyState() {{\n    return const CommonEmptyState(message: '{msg}');\n  }}"
            
            content = pattern.sub(replace_func, content)
            
            if content != original_content:
                if 'CommonEmptyState' in content and 'common_empty_state.dart' not in content:
                    import_str = "import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';\n"
                    last_import = content.rfind('import ')
                    if last_import != -1:
                        end_of_last_import = content.find('\n', last_import) + 1
                        content = content[:end_of_last_import] + import_str + content[end_of_last_import:]
                    else:
                        content = import_str + content

                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(content)
                print(f'Updated {f}')
