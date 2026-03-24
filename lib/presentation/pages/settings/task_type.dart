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
    final isWeb = AppStyles.isWebScreen(context);
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: isWeb
                ? (constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth)
                : constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Page Title
                Text(
                  'Task Type',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textBlue800,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search and New Button
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: TextField(
                          controller: settingsProvider.searchTaskTypeController,
                          onChanged: (query) {
                            settingsProvider.searchTaskType(query, context);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (settingsProvider.menuIsSaveMap[41] == 1)
                      SizedBox(
                        height: 48,
                        child: CustomOutlinedSvgButton(
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
                          label: 'New',
                          breakpoint: 400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryBlue,
                          borderSide: BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // The List
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: settingsProvider.taskType.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey[50]!,
                    ),
                    itemBuilder: (context, index) {
                      final task = settingsProvider.taskType[index];
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildTaskTypeBadge(task.taskTypeName),
                                  if (task.departmentName != null && task.departmentName!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8, left: 4),
                                      child: Text(
                                        task.departmentName!,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _buildActionButtons(context, settingsProvider, index),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );



  }

  Widget _buildTaskTypeBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, SettingsProvider settingsProvider, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (settingsProvider.menuIsEditMap[41] == 1)
          IconButton(
            onPressed: () {
              showDialog(
                barrierDismissible: false,
                context: context,
                builder: (BuildContext context) {
                  return AddTaskType(
                    editId: settingsProvider.taskType[index].taskTypeId.toString(),
                    status: settingsProvider.taskType[index].taskTypeName,
                    isEdit: true,
                    taskType: settingsProvider.taskType[index],
                  );
                },
              );
            },
            icon: Icon(Icons.edit_outlined, color: AppColors.primaryBlue, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Edit',
          ),
        const SizedBox(width: 8),
        if (settingsProvider.menuIsDeleteMap[41] == 1)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          settingsProvider.deleteTaskType(
                            context,
                            settingsProvider.taskType[index].taskTypeId,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon: Icon(Icons.delete_outline, color: AppColors.textRed, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Delete',
          ),
      ],
    );
  }

  Future<dynamic> assignStatusDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ManageStatusWidget();
      },
    );
  }
}
