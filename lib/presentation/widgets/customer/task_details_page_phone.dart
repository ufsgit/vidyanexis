import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/expanded_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/tile_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

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
    final settingsprovider = Provider.of<SettingsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldColor,
        elevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.secondaryBlue,
            ),
          ),
        ),
        title: Text(
          'Task details',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textBlack),
        ),
        actions: [
          if (settingsprovider.menuIsEditMap[13] == 1 ||
              settingsprovider.menuIsDeleteMap[13] == 1)
            CustomPopMenuButtonWidget(
              showEdit: settingsprovider.menuIsEditMap[13] == 1,
              showDelete: settingsprovider.menuIsDeleteMap[13] == 1,
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
                          task: customerDetailsProvider.taskDetails[0],
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
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                width: 5,
                                color: customerDetailsProvider
                                            .taskDetails[0].taskStatusName ==
                                        "Completed"
                                    ? Colors.green
                                    : customerDetailsProvider.taskDetails[0]
                                                .taskStatusName ==
                                            "In Progress"
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: Image.asset(
                                              customerDetailsProvider
                                                          .taskDetails[0]
                                                          .taskTypeId ==
                                                      1
                                                  ? 'assets/images/icon_site.png'
                                                  : customerDetailsProvider
                                                              .taskDetails[0]
                                                              .taskTypeId ==
                                                          2
                                                      ? 'assets/images/icon_installation.png'
                                                      : customerDetailsProvider
                                                                  .taskDetails[
                                                                      0]
                                                                  .taskTypeId ==
                                                              3
                                                          ? 'assets/images/icon_service.png'
                                                          : 'assets/images/icon_amc.png',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              customerDetailsProvider
                                                  .taskDetails[0].taskTypeName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textBlack,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: (customerDetailsProvider
                                                              .taskDetails[0]
                                                              .taskStatusName ==
                                                          "Completed"
                                                      ? Colors.green
                                                      : customerDetailsProvider
                                                                  .taskDetails[
                                                                      0]
                                                                  .taskStatusName ==
                                                              "In Progress"
                                                          ? Colors.orange
                                                          : Colors.red)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              customerDetailsProvider
                                                  .taskDetails[0]
                                                  .taskStatusName,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: customerDetailsProvider
                                                            .taskDetails[0]
                                                            .taskStatusName ==
                                                        "Completed"
                                                    ? Colors.green
                                                    : customerDetailsProvider
                                                                .taskDetails[0]
                                                                .taskStatusName ==
                                                            "In Progress"
                                                        ? Colors.orange
                                                        : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      if (dropDownProvider
                                          .getEnquiryForNameById(
                                              customerDetailsProvider
                                                      .taskDetails[0]
                                                      .enquiryForId ??
                                                  0,
                                              customerDetailsProvider
                                                  .taskDetails[0]
                                                  .enquiryForName)
                                          .isNotEmpty) ...[
                                        Text(
                                          dropDownProvider
                                              .getEnquiryForNameById(
                                                  customerDetailsProvider
                                                          .taskDetails[0]
                                                          .enquiryForId ??
                                                      0,
                                                  customerDetailsProvider
                                                      .taskDetails[0]
                                                      .enquiryForName),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.appViolet,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      Text(
                                        customerDetailsProvider
                                            .taskDetails[0].description,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          height: 1.4,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Divider(color: Color(0xFFF1F5F9)),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 14,
                                            color: AppColors.textGrey3,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${customerDetailsProvider.taskDetails[0].taskDate.toMonthDayYearFormat()} • ${customerDetailsProvider.taskDetails[0].taskTime}',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textBlack,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 14,
                                            color: AppColors.textGrey3,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              'Created on ${customerDetailsProvider.taskDetails[0].entryDate.toMonthDayYearFormat()}',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textGrey3,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.assignment_ind_outlined,
                          size: 18,
                          color: AppColors.secondaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Task logs',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${customerDetailsProvider.taskDetails[0].taskDocuments.length} assignees',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final taskUser = customerDetailsProvider
                          .taskDetails[0].taskDocuments[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TileWidget(
                            showDivider: false,
                            titleWidget: Text(
                              taskUser.userDetailsName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textBlack,
                              ),
                            ),
                            tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            contentPadding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: getAvatarColor(taskUser.userDetailsName)
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  taskUser.userDetailsName.isNotEmpty
                                      ? taskUser.userDetailsName
                                          .substring(0, 1)
                                          .toUpperCase()
                                      : '?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: getAvatarColor(
                                        taskUser.userDetailsName),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (taskUser.documents.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Row(
                                        children: [
                                          const Icon(
                                              Icons.insert_drive_file_outlined,
                                              size: 14,
                                              color: AppColors.textGrey2),
                                          const SizedBox(width: 6),
                                          Text(
                                            'No documents uploaded',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textGrey4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: SizedBox(
                                        height: 76,
                                        child: ListView.separated(
                                          scrollDirection: Axis.horizontal,
                                          physics:
                                              const BouncingScrollPhysics(),
                                          separatorBuilder: (context, index) =>
                                              const SizedBox(width: 8),
                                          itemCount: taskUser.documents.length,
                                          itemBuilder: (context, docIndex) {
                                            final doc =
                                                taskUser.documents[docIndex];
                                            if (doc.filePath.isEmpty) {
                                              return Row(
                                                children: [
                                                  const Icon(
                                                      Icons
                                                          .insert_drive_file_outlined,
                                                      size: 14,
                                                      color:
                                                          AppColors.textGrey2),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'No documents uploaded',
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          AppColors.textGrey4,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return Center(
                                              child: InkWell(
                                                onTap: () {
                                                  // Image click viewer logic
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    border: Border.all(
                                                        color: const Color(
                                                            0xFFF1F5F9)),
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: Image.network(
                                                      HttpUrls.imgBaseUrl +
                                                          doc.filePath,
                                                      width: 64,
                                                      height: 64,
                                                      fit: BoxFit.cover,
                                                      loadingBuilder: (context,
                                                          child, progress) {
                                                        if (progress == null) {
                                                          return child;
                                                        }
                                                        return Container(
                                                          width: 64,
                                                          height: 64,
                                                          color:
                                                              Colors.grey[100],
                                                          child: const Center(
                                                            child: SizedBox(
                                                              width: 16,
                                                              height: 16,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                strokeWidth: 2,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      errorBuilder: (context,
                                                          error, stack) {
                                                        return Container(
                                                          width: 64,
                                                          height: 64,
                                                          color:
                                                              Colors.grey[100],
                                                          child: const Icon(
                                                            Icons
                                                                .hide_image_outlined,
                                                            color: Colors.grey,
                                                            size: 20,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
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
                                          top: 8, bottom: 4),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: const Color(0xFFF1F5F9)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.notes_rounded,
                                                  size: 14,
                                                  color:
                                                      AppColors.secondaryBlue,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Task Note',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w700,
                                                    color:
                                                        AppColors.secondaryBlue,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            ExpandableText(
                                              maxLines: 2,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                height: 1.4,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textBlack,
                                              ),
                                              text: taskUser
                                                  .documents[0].taskNote,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ],
                          ),
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
