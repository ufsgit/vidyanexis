import os
import re

dir_path = r'd:\vidyanexis\lib\presentation\pages\reports'

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # This pattern targets: return Center( child: Column( ... Icon(Icons.search_off_outlined ...) ... Text('No ...') ... ));
    # It handles both `return Center` and `Center` inside a ternary or similar.
    # It stops matching at the end of the Center block which corresponds to the closing `)` of the `Center(`.
    # Since regex balancing is hard, we'll do a simpler approach:
    # Find `Icon(Icons.search_off_outlined`
    # Walk backward to find `Center(`
    # Walk forward to find `Text('...')`
    # Replace that chunk.

    # Simpler regex since most are identical:
    pattern = re.compile(
        r'(?:return\s+)?Center\(\s*child:\s*Column\(\s*(?:mainAxisAlignment:\s*MainAxisAlignment\.center,\s*)?children:\s*\[\s*(?:const\s+)?Icon\(Icons\.search_off_outlined[^\)]*\)\s*,\s*(?:const\s+)?SizedBox\(height:\s*\d+\),\s*(?:const\s+)?Text\(\s*\'([^\']+)\'[^\)]+\)\s*,?\s*\]\s*,\s*\)\s*,?\s*\)',
        re.MULTILINE | re.DOTALL
    )

    def replace_match(m):
        msg = m.group(1)
        # If it started with return, we preserve it. Let's check by looking at the match text.
        text = m.group(0)
        prefix = 'return ' if text.startswith('return') else ''
        return f"{prefix}const CommonEmptyState(message: '{msg}')"

    content = pattern.sub(replace_match, content)

    # Some might use Icons.assignment_return_outlined or others that I missed
    pattern2 = re.compile(
        r'(?:return\s+)?Center\(\s*child:\s*Padding\(\s*padding:[^\)]+\),\s*child:\s*Column\(\s*children:\s*\[\s*(?:const\s+)?Icon\([^\]]+\]\s*,\s*\)\s*,\s*\)\s*,?\s*\)',
        re.MULTILINE | re.DOTALL
    )
    # The previous regex in replace_inventory_empty_states missed some, but we only have Icons.search_off_outlined remaining.

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
