import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_task_type.dart';
import 'package:vidyanexis/presentation/widgets/settings/manage_status_widget.dart';

class TaskTypeContent extends StatefulWidget {
  const TaskTypeContent({super.key});

  @override
  State<TaskTypeContent> createState() => _TaskTypeContentState();
}

class _TaskTypeContentState extends State<TaskTypeContent> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchTaskType('', context);
      settingsProvider.searchTaskTypeController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: AppStyles.isWebScreen(context)
                ? constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth
                : MediaQuery.of(context).size.width - 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    children: [
                      Text(
                        'Task Type',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlue800),
                      ),
                      const Spacer(),
                      Container(
                        width: MediaQuery.of(context).size.width / 3.5,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: settingsProvider.searchTaskTypeController,
                          onChanged: (query) {
                            print(query);
                            settingsProvider.searchTaskType(query, context);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search here....',
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // if (settingsProvider.menuIsSaveMap[22] == 1)
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const AddTaskType(
                                editId: '0',
                                isEdit: false,
                                status: '',
                              );
                            },
                          );
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'New Task Type',
                        breakpoint: 860,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 12,
                          );
                        },
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: settingsProvider.taskType.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        height: 22,
                                        decoration: BoxDecoration(
                                            color: AppColors.surfaceGrey,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            settingsProvider
                                                .taskType[index].taskTypeName,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      settingsProvider
                                              .taskType[index].departmentName ??
                                          '',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),

                                  // ActionChip(
                                  //     shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.only(
                                  //           bottomLeft: Radius.circular(15),
                                  //           topRight: Radius.circular(15),
                                  //         ),
                                  //         side: BorderSide(
                                  //             color: Colors.transparent)),
                                  //     color: WidgetStateProperty.all(
                                  //         Colors.blue[50]),
                                  //     onPressed: () => assignStatusDialog(
                                  //           context,
                                  //         ),
                                  //     avatar: CircleAvatar(
                                  //       radius: 16,
                                  //       child: Icon(Icons.person_add_outlined,
                                  //           size: 12, color: Colors.grey),
                                  //     ),
                                  //     label: Text(
                                  //       'Manage Status',
                                  //       style: GoogleFonts.plusJakartaSans(
                                  //           fontWeight: FontWeight.w400),
                                  //     )),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  // if (settingsProvider.menuIsEditMap[22] == 1)
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AddTaskType(
                                                editId: settingsProvider
                                                    .taskType[index].taskTypeId
                                                    .toString(),
                                                status: settingsProvider
                                                    .taskType[index]
                                                    .taskTypeName,
                                                isEdit: true,
                                                taskType: settingsProvider
                                                    .taskType[index]);
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryBlue),
                                      )),
                                  // if (settingsProvider.menuIsDeleteMap[22] == 1)
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    settingsProvider
                                                        .deleteTaskType(
                                                            context,
                                                            settingsProvider
                                                                .taskType[index]
                                                                .taskTypeId);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text(
                                                    'Delete',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textRed),
                                      ))
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  assignStatusDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ManageStatusWidget();
      },
    );
  }
}
