import sys

filepath = 'd:/vidyanexis/lib/presentation/pages/home/customer_page.dart'
content = open(filepath, 'r', encoding='utf-8').read()

old_code = '''                                                        children: provider
                                                            .taskType
                                                            .where((taskType) =>
                                                                taskType
                                                                    .manualCreation ==
                                                                1)
                                                            .map((taskType) {
                                                          final users = provider
                                                              .searchUserDetails
                                                              .where((user) {
                                                            return user
                                                                    .departmentId
                                                                    .toString() ==
                                                                taskType
                                                                    .departmentIds
                                                                    .toString();
                                                          }).toList();

                                                          if (users.isEmpty) {
                                                            return const SizedBox.shrink();
                                                          }'''

new_code = '''                                                        children: provider
                                                            .taskType
                                                            .where((taskType) =>
                                                                taskType
                                                                    .manualCreation ==
                                                                1)
                                                            .where((taskType) {
                                                              final users = provider
                                                                  .searchUserDetails
                                                                  .where((user) {
                                                                return user
                                                                        .departmentId
                                                                        .toString() ==
                                                                    taskType
                                                                        .departmentIds
                                                                        .toString();
                                                              }).toList();
                                                              return users.isNotEmpty;
                                                            })
                                                            .map((taskType) {
                                                          final users = provider
                                                              .searchUserDetails
                                                              .where((user) {
                                                            return user
                                                                    .departmentId
                                                                    .toString() ==
                                                                taskType
                                                                    .departmentIds
                                                                    .toString();
                                                          }).toList();'''

content = content.replace('\r\n', '\n')
old_code = old_code.replace('\r\n', '\n')

if old_code in content:
    content = content.replace(old_code, new_code)
    open(filepath, 'w', encoding='utf-8').write(content)
    print("Success")
else:
    print("Failed to find the block")
