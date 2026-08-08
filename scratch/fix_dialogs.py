import os
import re

lib_dir = r'd:\dev\vidyanexis\lib'

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Pattern to find the exact block we want to modify.
    # We look for: builder: (BuildContext context) { ... return AlertDialog( ... actions: [ ... onPressed: () => Navigator.pop(context) ... onPressed: () async { <provider_call>; Navigator.pop(context); } ... ]
    
    # Let's try to match the `builder: (BuildContext context) {` up to `showDialog` end.
    # A simpler way is to replace chunk by chunk.
    
    # Find all occurrences of builder: (BuildContext context)
    # followed by an AlertDialog that has a Confirm Delete
    
    # We will use re.sub with a callback
    
    # Regex to capture the whole builder block.
    # This is tricky due to nested braces. We can use a simpler approach:
    # Just look for the specific lines.
    
    lines = content.split('\n')
    modified = False
    
    for i, line in enumerate(lines):
        if 'builder: (BuildContext context)' in line:
            # Look ahead to see if this is a Confirm Delete dialog
            is_confirm_delete = False
            for j in range(i, min(i+15, len(lines))):
                if 'Confirm Delete' in lines[j] or 'Are you sure you want to delete' in lines[j]:
                    is_confirm_delete = True
                    break
            
            if is_confirm_delete:
                # We found a target.
                # Change builder context to dialogContext
                lines[i] = lines[i].replace('builder: (BuildContext context)', 'builder: (BuildContext dialogContext)')
                
                # Now go forward and replace Navigator.pop(context) and fix the async block
                in_delete_button = False
                for j in range(i+1, min(i+50, len(lines))):
                    if 'Navigator.pop(context)' in lines[j] and 'Cancel' in lines[j] or '=> Navigator.pop(context)' in lines[j]:
                        lines[j] = lines[j].replace('Navigator.pop(context)', 'Navigator.pop(dialogContext)')
                    
                    if 'TextButton(' in lines[j]:
                        pass
                    
                    if 'onPressed: () async {' in lines[j] or 'onPressed: () {' in lines[j]:
                        # Look ahead for Delete text
                        is_delete_btn = False
                        for k in range(j, min(j+15, len(lines))):
                            if "'Delete'" in lines[k] or '"Delete"' in lines[k]:
                                is_delete_btn = True
                                break
                        
                        if is_delete_btn:
                            # We are in the Delete button's onPressed.
                            # Change to synchronous, insert Navigator.pop(dialogContext) FIRST.
                            # Then find the original Navigator.pop(context) and remove it.
                            if 'onPressed: () async {' in lines[j]:
                                lines[j] = lines[j].replace('onPressed: () async {', 'onPressed: () {')
                            
                            # Insert Navigator.pop(dialogContext); right after the {
                            lines[j] = lines[j] + '\n' + ' ' * (len(lines[j]) - len(lines[j].lstrip())) + '  Navigator.pop(dialogContext);'
                            
                            # Now remove the old Navigator.pop(context) in this block
                            for k in range(j+1, min(j+15, len(lines))):
                                if 'Navigator.pop(context);' in lines[k]:
                                    lines[k] = lines[k].replace('Navigator.pop(context);', '')
                                    modified = True
                                    break

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write('\n'.join(lines))
        print(f'Fixed {filepath}')

for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            process_file(os.path.join(root, f))

print('Done')
