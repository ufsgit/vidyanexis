import os
import re

directories = [
    r'd:\vidyanexis\lib\presentation\pages\reports',
    r'd:\vidyanexis\lib\presentation\pages\dashboard',
    r'd:\vidyanexis\lib\presentation\pages\home',
    r'd:\vidyanexis\lib\presentation\widgets'
]

# Match Center(child: Column(...)) with any contents that end with Text('No ... found') or similar
pattern1 = re.compile(r'Center\(\s*child:\s*Column\(\s*[^\[]*\[\s*.*?(?:Icon\([^)]+\)|Image\.[^)]+\)).*?Text\(\s*[\'"]([^\'"]*No[^\'"]*(?:found|available|data)[^\'"]*)[\'"][^\)]*\)\s*,?\s*\]\s*,\s*\)\s*,?\s*\)', re.MULTILINE | re.DOTALL | re.IGNORECASE)

for dir_path in directories:
    for root, _, files in os.walk(dir_path):
        for f in files:
            if f.endswith('.dart'):
                filepath = os.path.join(root, f)
                with open(filepath, 'r', encoding='utf-8') as file:
                    content = file.read()
                
                original_content = content
                
                def replace_func(match):
                    msg = match.group(1)
                    return f"const CommonEmptyState(message: '{msg}')"
                
                content = pattern1.sub(replace_func, content)
                
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
                    print(f'Updated pass 2 {f}')
