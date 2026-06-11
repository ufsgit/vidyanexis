with open(r'd:\vidyanexis\lib\presentation\pages\home\task_page.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Fix 1: line 1610 (0-indexed 1609) - broken context.push string
# Current: '                                                                     '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'});\n'
# Should be: "                                                                   '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');\n"
old_1609 = lines[1609]
print(f"Line 1610 before: {repr(old_1609)}")
lines[1609] = "                                                                   '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');\r\n"
print(f"Line 1610 after:  {repr(lines[1609])}")

# Fix 2: The _HoverMenuAnchor at line 1643 (0-indexed 1642) needs to be moved inside
# the inner Row's children list. Currently:
#   Row(children: [Expanded(blue pill)]),  <- Row closes at line 1642 (0-indexed)
#   _HoverMenuAnchor(...)                  <- this is now a sibling of Column's children
# We need to insert it as the 2nd child of the inner Row (before its closing '],' at line 1641 0-indexed)

# Line 1641 (0-indexed 1640) is '                                                     ],'  <- closes Row children
# Line 1642 (0-indexed 1641) is '                                                   ),'   <- closes Row(
# Line 1643 (0-indexed 1642) is start of _HoverMenuAnchor

# We need to:
# 1. Remove the '],' and '),' closing the inner Row temporarily (lines 1641, 1642 -> 0-indexed 1640, 1641)
# 2. Find where _HoverMenuAnchor ends
# 3. Re-insert the _HoverMenuAnchor inside the Row, then close Row

# Find line index of _HoverMenuAnchor start
hover_start = None
for i, line in enumerate(lines):
    if i >= 1641 and i <= 1645 and '_HoverMenuAnchor(' in line:
        hover_start = i
        break
print(f"_HoverMenuAnchor starts at 0-indexed: {hover_start}")

# Find where _HoverMenuAnchor ends - look for the closing of the outer Row in data
# The original outer Row was: Row(children:[Expanded(...), _HoverMenuAnchor(...)], )
# After my replacement, _HoverMenuAnchor is a sibling. 
# We need to find the closing ); of _HoverMenuAnchor
# Count brace depth
depth = 0
hover_end = None
for i in range(hover_start, hover_start + 100):
    for ch in lines[i]:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
    if depth == 0 and i > hover_start:
        hover_end = i
        break
print(f"_HoverMenuAnchor ends at 0-indexed: {hover_end}")
print(f"Line {hover_end+1}: {repr(lines[hover_end])}")

# The Row closing '],' is at index 1640, '),' is at 1641
row_close_bracket = 1640  # '],'
row_close_paren = 1641    # '),'

print(f"Row close bracket line {row_close_bracket+1}: {repr(lines[row_close_bracket])}")
print(f"Row close paren line {row_close_paren+1}: {repr(lines[row_close_paren])}")
