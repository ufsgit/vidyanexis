import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/expanded_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_card_mobile_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class TaskDetailsPagePhone extends StatefulWidget {
  static String route = '/taskdetailsPage/';
  final String taskMasterId;
  final String taskId;

  final String customerId;

  const TaskDetailsPagePhone(
      {super.key,
      required this.taskMasterId,
      required this.customerId,
      required this.taskId});

  @override
  State<TaskDetailsPagePhone> createState() => _TaskDetailsPagePhoneState();
}

class _TaskDetailsPagePhoneState extends State<TaskDetailsPagePhone> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.taskDetails.clear();
      customerDetailsProvider.getTaskDetails(
          widget.taskMasterId.toString(), context);
    });
  }

  Color getAvatarColor(String name) {
    final colors = [
      Colors.blue.withOpacity(.75),
      Colors.purple.withOpacity(.75),
      Colors.orange.withOpacity(.75),
      Colors.teal.withOpacity(.75),
      Colors.pink.withOpacity(.75),
      Colors.indigo.withOpacity(.75),
      Colors.green.withOpacity(.75),
      Colors.deepOrange.withOpacity(.75),
      Colors.cyan.withOpacity(.75),
      Colors.brown.withOpacity(.75),
    ];
    final nameHash = name.hashCode.abs();
    return colors[nameHash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: Text(
          'Task details',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textBlack),
        ),
        actions: [
          CustomPopMenuButtonWidget(
            onOptionSelected: (PopupMenuOptions option) async {
              switch (option) {
                case PopupMenuOptions.edit:
                  if (customerDetailsProvider.taskDetails.isEmpty) break;

                  customerDetailsProvider.customerId = customerDetailsProvider
                      .taskDetails[0].customerId
                      .toString();
                  await customerDetailsProvider.getTaskUsers(
                      customerDetailsProvider.taskDetails[0].taskMasterId);
                  customerDetailsProvider.setTaskEditDropDown(
                      customerDetailsProvider.taskDetails[0].taskTypeId,
                      customerDetailsProvider.taskDetails[0].taskTypeName,
                      customerDetailsProvider.taskDetails[0].toUserId,
                      customerDetailsProvider.taskDetails[0].toUserName,
                      customerDetailsProvider.taskDetails[0].taskStatusId,
                      customerDetailsProvider.taskDetails[0].taskStatusName);
                  customerDetailsProvider.taskDescriptionController.text =
                      customerDetailsProvider.taskDetails[0].description
                          .toString();
                  customerDetailsProvider.taskChoosedateController.text =
                      customerDetailsProvider.taskDetails[0].taskDate
                                      .toString() !=
                                  'null' &&
                              customerDetailsProvider.taskDetails[0].taskDate
                                  .toString()
                                  .isNotEmpty
                          ? DateFormat('dd MMM yyyy').format(DateTime.parse(
                              customerDetailsProvider.taskDetails[0].taskDate
                                  .toString()))
                          : '';
                  customerDetailsProvider.taskChoosetimeController.text =
                      customerDetailsProvider.taskDetails[0].taskTime
                          .toString();
                  customerDetailsProvider.taskTypeController.text =
                      customerDetailsProvider.taskDetails[0].taskTypeName;
                  customerDetailsProvider.amcStatusNameController.text =
                      customerDetailsProvider.taskDetails[0].taskStatusName;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return AddTaskMobile(
                        isEdit: true,
                        taskId: customerDetailsProvider
                            .taskDetails[0].taskMasterId
                            .toString(),
                      );
                    },
                  ));
                  break;
                case PopupMenuOptions.delete:
                  showConfirmationDialog(
                    isLoading: customerDetailsProvider.isDeleteLoading,
                    context: context,
                    title: 'Confirm Deletion',
                    content: 'Are you sure you want to delete this task?',
                    onCancel: () {
                      Navigator.of(context).pop();
                    },
                    onConfirm: () async {
                      await customerDetailsProvider.deleteTask(
                          widget.taskId, widget.customerId, context);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                    confirmButtonText: 'Delete',
                    confirmButtonColor: Colors.red,
                  );

                  break;
              }
            },
          ),
        ],
      ),
      body: customerDetailsProvider.isLoadingDetails ||
              customerDetailsProvider.taskDetails.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: TaskCardMobileWidget(
                    taskTypeName:
                        customerDetailsProvider.taskDetails[0].taskTypeName,
                    taskStatusName:
                        customerDetailsProvider.taskDetails[0].taskStatusName,
                    description:
                        customerDetailsProvider.taskDetails[0].description,
                    taskDate: customerDetailsProvider.taskDetails[0].taskDate
                        .toMonthDayYearFormat(),
                    taskTime: customerDetailsProvider.taskDetails[0].taskTime,
                    entryDate: customerDetailsProvider.taskDetails[0].entryDate
                        .toMonthDayYearFormat(),
                    statusColor:
                        customerDetailsProvider.taskDetails[0].taskStatusName ==
                                "Completed"
                            ? Colors.green
                            : customerDetailsProvider
                                        .taskDetails[0].taskStatusName ==
                                    "In Progress"
                                ? Colors.orange
                                : Colors.red,
                    textBlack: AppColors.textBlack,
                    textGrey3: AppColors.textGrey3,
                    taskTypeIcon: Image.asset(
                      customerDetailsProvider.taskDetails[0].taskTypeId == 1
                          ? 'assets/images/icon_site.png'
                          : customerDetailsProvider.taskDetails[0].taskTypeId ==
                                  2
                              ? 'assets/images/icon_installation.png'
                              : customerDetailsProvider
                                          .taskDetails[0].taskTypeId ==
                                      3
                                  ? 'assets/images/icon_service.png'
                                  : 'assets/images/icon_amc.png',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(
                      color: Color(0xFFEEEEEE),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Task logs ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack,
                            ),
                          ),
                          TextSpan(
                            text:
                                '(${customerDetailsProvider.taskDetails[0].taskDocuments.length} assignees)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final taskUser = customerDetailsProvider
                          .taskDetails[0].taskDocuments[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TileWidget(
                          titleWidget: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${taskUser.userDetailsName} ',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          tilePadding: const EdgeInsets.all(0),
                          // subtitle: (taskUser.documents.isNotEmpty)
                          //     ? '${taskUser.documents[0].startDateTime.isNotEmpty ? taskUser.documents[0].startDateTime.toMonthDayYearFormat() : '--,-- '} to ${taskUser.documents[0].completionDateTime.isNotEmpty ? taskUser.documents[0].completionDateTime.toMonthDayYearFormat() : '--,--'}'
                          //     : '--,-- to --,--',
                          leading: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: getAvatarColor(taskUser.userDetailsName),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text(
                                taskUser.userDetailsName.isNotEmpty
                                    ? taskUser.userDetailsName
                                        .substring(0, 1)
                                        .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (customerDetailsProvider
                                    .taskDetails[0].taskDocuments.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Center(
                                      child: Text(
                                        'No task logs found.',
                                        style:
                                            TextStyle(color: Colors.grey[500]),
                                      ),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(left: 26),
                                    child: SizedBox(
                                      height: 100,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        physics: const BouncingScrollPhysics(),
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 8),
                                        itemCount: taskUser.documents.length,
                                        itemBuilder: (context, docIndex) {
                                          final doc =
                                              taskUser.documents[docIndex];
                                          return Center(
                                            child: Column(
                                              children: [
                                                doc.filePath.isNotEmpty
                                                    ? InkWell(
                                                        onTap: () {
                                                          // Add image view logic if needed
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          child: Image.network(
                                                            HttpUrls.imgBaseUrl +
                                                                doc.filePath,
                                                            width: 70,
                                                            height: 70,
                                                            fit: BoxFit.cover,
                                                            loadingBuilder:
                                                                (context, child,
                                                                    progress) {
                                                              if (progress ==
                                                                  null) {
                                                                return child;
                                                              }
                                                              return Container(
                                                                width: 70,
                                                                height: 70,
                                                                color: Colors
                                                                    .grey[200],
                                                                child:
                                                                    const Center(
                                                                  child:
                                                                      SizedBox(
                                                                    width: 20,
                                                                    height: 20,
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      strokeWidth:
                                                                          2,
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            errorBuilder:
                                                                (context, error,
                                                                    stack) {
                                                              return Container(
                                                                width: 70,
                                                                height: 70,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .grey[
                                                                      200],
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child:
                                                                    const Icon(
                                                                  Icons
                                                                      .hide_image_outlined,
                                                                  color: Colors
                                                                      .grey,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox(
                                                        height: 100,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'No Documents',
                                                              style: TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                if (taskUser.documents.isNotEmpty &&
                                    taskUser.documents[0].taskNote.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 26, top: 8, bottom: 8),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: ExpandableText(
                                        maxLines: 2,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textBlack,
                                        ),
                                        text: taskUser.documents[0].taskNote,
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: customerDetailsProvider
                        .taskDetails[0].taskDocuments.length,
                  ),
                ),
              ],
            ),
    );
  }
}
