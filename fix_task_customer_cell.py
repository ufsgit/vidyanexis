with open(r'd:\vidyanexis\lib\presentation\pages\home\task_page.dart', 'r', encoding='utf-8') as f:
    content = f.read()

lines = content.split('\n')

pad = '                                                  '
q = "'"
replacement = [
    pad + 'data: Column(',
    pad + '  crossAxisAlignment: CrossAxisAlignment.start,',
    pad + '  mainAxisSize: MainAxisSize.min,',
    pad + '  children: [',
    pad + '    Row(',
    pad + '      children: [',
    pad + '        Expanded(',
    pad + '          child: Container(',
    pad + '            decoration: BoxDecoration(',
    pad + '              color: const Color(0xFFEBF5FF),',
    pad + '              borderRadius: BorderRadius.circular(5),',
    pad + '            ),',
    pad + '            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),',
    pad + '            child: InkWell(',
    pad + '              onTap: () {',
    pad + '                context.push(',
    pad + '                  ' + q + '${CustomerDetailsScreen.route}${task.customerId.toString()}/${' + q + 'true' + q + '});',
    pad + '              },',
    pad + '              child: Text(',
    pad + '                task.customerName ?? ' + q + 'Unknown' + q + ',',
    pad + '                overflow: TextOverflow.ellipsis,',
    pad + '                maxLines: 1,',
    pad + '                style: const TextStyle(',
    pad + '                  color: Colors.blue,',
    pad + '                  fontWeight: FontWeight.w500,',
    pad + '                  fontSize: 13,',
    pad + '                ),',
    pad + '              ),',
    pad + '            ),',
    pad + '          ),',
    pad + '        ),',
    pad + '      ],',
    pad + '    ),',
    pad + '    if (task.mobile.isNotEmpty)',
    pad + '      Padding(',
    pad + '        padding: const EdgeInsets.only(top: 2, left: 2),',
    pad + '        child: Text(',
    pad + '          task.mobile,',
    pad + '          overflow: TextOverflow.ellipsis,',
    pad + '          maxLines: 1,',
    pad + '          style: const TextStyle(',
    pad + '            color: Color(0xFF475569),',
    pad + '            fontSize: 11,',
    pad + '            fontWeight: FontWeight.w400,',
    pad + '          ),',
    pad + '        ),',
    pad + '      ),',
    pad + '  ],',
    pad + '),',
]

new_lines = lines[:1593] + replacement + lines[1666:]
new_content = '\n'.join(new_lines)

with open(r'd:\vidyanexis\lib\presentation\pages\home\task_page.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)

print('Done. New line count:', len(new_lines))
