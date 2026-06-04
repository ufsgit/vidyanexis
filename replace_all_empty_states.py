import os
import re

dir_path = r'd:\vidyanexis\lib\presentation'

# Pattern 1: Standard _buildEmptyState with Column > Icon > Text
pattern1 = re.compile(
    r'(Widget\s+_build(?:EmptyState|ContentBody|NoDataFound|Empty)[^\(]*\([^\)]*\)\s*\{[^}]*?)'
    r'(?:return|child:)\s*(?:Center|Padding|Container)\(\s*(?:padding:[^\)]+\),\s*)?'
    r'(?:child:\s*)?(?:Center|Padding)\(\s*(?:padding:[^\)]+\),\s*)?'
    r'child:\s*Column\(\s*mainAxisAlignment:\s*MainAxisAlignment\.center,\s*children:\s*\['
    r'\s*(?:const\s+)?Icon\([^\]]+\]\s*,\s*\)\s*,\s*\)\s*(?:;|,)?',
    re.MULTILINE | re.DOTALL
)

# A more robust regex that finds any block that looks like:
# Icon(..., size: ...),
# SizedBox(height: ...),
# Text('No ... found', ...)
pattern_universal = re.compile(
    r'(return|child:)\s*(?:const\s+)?(?:Center|Padding|Container|SizedBox)\([\s\S]*?'
    r'Icon\([a-zA-Z0-9_.]+(?:,\s*size:\s*\d+(?:\.\d+)?)?(?:,\s*color:\s*[^)]+)?\),?'
    r'\s*(?:const\s+)?SizedBox\(height:\s*\d+(?:\.\d+)?\),?'
    r'\s*(?:const\s+)?Text\(\s*\'([^\']+)\'[\s\S]*?;\s*\}',
    re.MULTILINE
)

# Wait, regex is too brittle. Let's do a simpler python parser:
def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original_content = content

    # Find "No ... found" or "No data available" inside Text widgets that are accompanied by an Icon
    # We will search for `Widget _buildEmptyState` or similar methods
    method_pattern = re.compile(r'(Widget\s+_[a-zA-Z0-9]+(?:Empty|NoData|NotFound)[a-zA-Z0-9]*\s*\([^\)]*\)\s*\{)(.*?)(^\s*\})', re.MULTILINE | re.DOTALL)
    
    def replace_method(match):
        method_sig = match.group(1)
        body = match.group(2)
        end_brace = match.group(3)
        
        # Check if this body contains an Icon and a Text saying 'No ...'
        text_match = re.search(r'Text\(\s*\'(No[^\']+)\'', body, re.IGNORECASE)
        icon_match = re.search(r'Icon\(', body)
        
        if text_match and icon_match:
            msg = text_match.group(1)
            # Replace the entire body with returning CommonEmptyState
            return f"{method_sig}\n    return const CommonEmptyState(message: '{msg}');\n  }}"
        return match.group(0)

    content = method_pattern.sub(replace_method, content)
    
    # Check for direct 'No data' Center widgets not in a dedicated method
    # e.g., child: _expenseList.isEmpty ? Center(child: Column(... Text('No expenses found') ...)) : ListView...
    inline_pattern = re.compile(r'(?:return|child:)\s*(?:const\s+)?Center\(\s*child:\s*Column\(\s*mainAxisAlignment:\s*MainAxisAlignment\.center,\s*children:\s*\[\s*(?:const\s+)?Icon\([^]]+Text\(\s*\'(No[^\']+)\'[^\]]+\]\s*,\s*\)\s*,\s*\)', re.MULTILINE | re.DOTALL)
    
    def replace_inline(match):
        msg = match.group(1)
        prefix = match.group(0)[:match.group(0).find('Center')]
        return f"{prefix}const CommonEmptyState(message: '{msg}')"
        
    content = inline_pattern.sub(replace_inline, content)

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
