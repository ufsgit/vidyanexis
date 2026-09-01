import sys

filepath = 'd:/vidyanexis/lib/presentation/pages/home/lead_page.dart'
content = open(filepath, 'r', encoding='utf-8').read()

old_code = '''                                                                 children: provider
                                                                     .taskType
                                                                     .where((taskType) =>
                                                                         taskType.manualCreation ==
                                                                         1)
                                                                     .map((taskType) {
                                                                   // Find users for this task type based on department
                                                                   final users = provider
                                                                       .searchUserDetails
                                                                       .where((user) {
                                                                     return user.departmentId.toString() ==
                                                                         taskType.departmentIds.toString();
                                                                   }).toList();

                                                                   if (users.isEmpty) {
                                                                     return MenuItemButton(
                                                                       onPressed: null,
                                                                       child: Text(taskType.taskTypeName),
                                                                     );
                                                                   }'''

new_code = '''                                                                 children: provider
                                                                     .taskType
                                                                     .where((taskType) =>
                                                                         taskType.manualCreation ==
                                                                         1)
                                                                     .where((taskType) {
                                                                       final users = provider
                                                                           .searchUserDetails
                                                                           .where((user) {
                                                                         return user.departmentId.toString() ==
                                                                             taskType.departmentIds.toString();
                                                                       }).toList();
                                                                       return users.isNotEmpty;
                                                                     })
                                                                     .map((taskType) {
                                                                   // Find users for this task type based on department
                                                                   final users = provider
                                                                       .searchUserDetails
                                                                       .where((user) {
                                                                     return user.departmentId.toString() ==
                                                                         taskType.departmentIds.toString();
                                                                   }).toList();'''

content = content.replace('\r\n', '\n')
old_code = old_code.replace('\r\n', '\n')

if old_code in content:
    content = content.replace(old_code, new_code)
    open(filepath, 'w', encoding='utf-8').write(content)
    print("Success empty tasks filter")
else:
    print("Failed to find empty tasks block")

old_icon_button = '''                                                        return IconButton(
                                                          onPressed: () {
                                                            if (controller.isOpen) {
                                                              controller.close();
                                                            } else {
                                                              controller.open();
                                                            }
                                                          },
                                                          icon: const Icon(
                                                            Icons.keyboard_arrow_down,
                                                            size: 20,
                                                            color: Colors.grey,
                                                          ),
                                                          padding: EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        );'''

new_inkwell = '''                                                        return InkWell(
                                                          onTap: () {
                                                            if (controller.isOpen) {
                                                              controller.close();
                                                            } else {
                                                              controller.open();
                                                            }
                                                          },
                                                          child: const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                                                            child: Icon(
                                                              Icons.keyboard_arrow_down,
                                                              size: 20,
                                                              color: Colors.grey,
                                                            ),
                                                          ),
                                                        );'''

old_icon_button = old_icon_button.replace('\r\n', '\n')
if old_icon_button in content:
    content = content.replace(old_icon_button, new_inkwell)
    open(filepath, 'w', encoding='utf-8').write(content)
    print("Success icon button replacement")
else:
    print("Failed icon button replacement")
