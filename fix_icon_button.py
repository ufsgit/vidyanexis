import sys
content = open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'r', encoding='utf-8').read()

old_icon_button = '''                                                                              return IconButton(
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

new_inkwell = '''                                                                              return InkWell(
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

content = content.replace('\r\n', '\n')
old_icon_button = old_icon_button.replace('\r\n', '\n')

if old_icon_button in content:
    content = content.replace(old_icon_button, new_inkwell)
    open('d:/vidyanexis/lib/presentation/pages/home/task_page.dart', 'w', encoding='utf-8').write(content)
    print("Success task")
else:
    print("Failed task")

