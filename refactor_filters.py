import os, re

dir_path = r'd:\vidyanexis\lib\presentation\pages\reports'
count = 0

for filename in os.listdir(dir_path):
    if not filename.endswith('.dart'):
        continue
    filepath = os.path.join(dir_path, filename)
    with open(filepath, 'r', encoding='utf-8') as f:
        original_content = f.read()

    content = original_content

    # 1. Update dropdown padding
    # From 'padding: const EdgeInsets.symmetric(horizontal: 20),'
    # To 'padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),'
    content = re.sub(
        r'padding:\s*(const\s+)?EdgeInsets\.symmetric\(horizontal:\s*(20\.0|20)\),',
        r'padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),',
        content
    )

    # 2. Update search input contentPadding
    # contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10) -> (horizontal: 16, vertical: 8)
    content = re.sub(
        r'contentPadding:\s*(const\s+)?EdgeInsets\.symmetric\(horizontal:\s*16\.0?,\s*vertical:\s*10\.0?\)',
        r'contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)',
        content
    )

    # 3. Update top-level filter container padding
    # Usually it's 'padding: const EdgeInsets.all(10.0)' or similar, but replacing all `all(10)` is risky.
    # We will target specifically ones with margin: const EdgeInsets.symmetric(horizontal: 16.0) above them.
    content = re.sub(
        r'(margin:\s*const\s*EdgeInsets\.symmetric\(horizontal:\s*16\.0?\),\s*)padding:\s*(const\s+)?EdgeInsets\.all\([0-9.]+\),',
        r'\g<1>padding: const EdgeInsets.all(12.0),',
        content
    )

    # 4. Standardize text styles (like GoogleFonts.plusJakartaSans) if needed, but that's harder without breaking non-text widgets.

    # 5. Fix common reset button padding manually if it matches
    content = re.sub(
        r'padding:\s*const EdgeInsets\.symmetric\(\s*horizontal:\s*16,\s*vertical:\s*12,?\s*\),',
        r'padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),',
        content
    )

    if content != original_content and len(content) > 100:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        count += 1

print(f'Successfully updated {count} files.')
