import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class TaskListPageMobile extends StatefulWidget {
  final String customerId;

  const TaskListPageMobile({
    super.key,
    required this.customerId,
  });

  @override
  State<TaskListPageMobile> createState() => _TaskListPageMobileState();
}

class _TaskListPageMobileState extends State<TaskListPageMobile> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getTaskList(widget.customerId, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: customerDetailsProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : customerDetailsProvider.taskList.isEmpty
                ? Center(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 80,
                        ),
                        Text(
                          'No tasks found.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlack),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          'Start by creating a new task.',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textGrey3),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 2,
                              color: AppColors.grey,
                            );
                          },
                          itemCount: customerDetailsProvider.taskList.length,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final task =
                                customerDetailsProvider.taskList[index];

                            Color statusColor =
                                task.taskStatusName == "Completed"
                                    ? Colors.green
                                    : task.taskStatusName == "In Progress"
                                        ? Colors.orange
                                        : Colors.red;
                            return InkWell(
                              onTap: () {
                                // context.push(
                                //     '${TaskDetailsPagePhone.route}${task.taskMasterId}/${task.taskId}');

                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return TaskDetailsPagePhone(
                                        taskId: task.taskId.toString(),
                                        taskMasterId:
                                            task.taskMasterId.toString(),
                                        customerId:
                                            widget.customerId.toString());
                                  },
                                ));
                              },
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration:
                                    BoxDecoration(color: AppColors.whiteColor),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                              height: 22,
                                              width: 3,
                                              decoration: BoxDecoration(
                                                  color: statusColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16))),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: Image.asset(
                                                task.taskTypeId == 1
                                                    ? 'assets/images/icon_site.png'
                                                    : task.taskTypeId == 2
                                                        ? 'assets/images/icon_installation.png'
                                                        : task.taskTypeId == 3
                                                            ? 'assets/images/icon_service.png'
                                                            : 'assets/images/icon_amc.png',
                                              )),
                                          const SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            task.taskTypeName,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textBlack),
                                          ),
                                          const Spacer(),
                                          Container(
                                              height: 22,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color:
                                                    statusColor.withOpacity(.1),
                                              ),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 2),
                                                  child: Text(
                                                    task.taskStatusName,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: statusColor),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          task.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.textGrey3),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 22,
                                            decoration: BoxDecoration(
                                                color: AppColors.scaffoldColor,
                                                border: Border.all(
                                                    color: AppColors.grey),
                                                borderRadius:
                                                    BorderRadius.circular(6)),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .calendar_month_outlined,
                                                    size: 16,
                                                    color: AppColors.textGrey3,
                                                  ),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    task.taskDate
                                                        .toString()
                                                        .toFormattedDate(),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .textGrey3),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.symmetric(horizontal: 5),
                                          //   child: Text(
                                          //     '•',
                                          //     style: GoogleFonts.plusJakartaSans(
                                          //         fontSize: 10,
                                          //         fontWeight: FontWeight.w500,
                                          //         color: AppColors.textGrey3),
                                          //   ),
                                          // ),
                                          // Container(
                                          //   height: 20,
                                          //   width: 20,
                                          //   decoration: BoxDecoration(
                                          //       borderRadius: BorderRadius.circular(100),
                                          //       color: AppColors.textRed),
                                          // ),
                                          // const SizedBox(width: 4),
                                          // Text(
                                          //   'David',
                                          //   style: GoogleFonts.plusJakartaSans(
                                          //       fontSize: 14,
                                          //       fontWeight: FontWeight.w500,
                                          //       color: AppColors.textGrey3),
                                          // ),
                                          const Spacer(),
                                          Text(
                                            task.entryDate
                                                .toString()
                                                .toTimeAgo(),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textGrey3),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Create task',
          onPressed: () {
            final customerDetailsProvider =
                Provider.of<CustomerDetailsProvider>(context, listen: false);
            customerDetailsProvider.customerId = widget.customerId;
            customerDetailsProvider.clearTaskDetails();
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AddTaskMobile(
                  isEdit: false,
                  taskId: '0',
                );
              },
            ));
            // showModalBottomSheet(
            //   context: context,
            //   isScrollControlled: true,
            //   showDragHandle: false,
            //   isDismissible: false,
            //   backgroundColor: Colors.transparent,
            //   builder: (BuildContext context) {
            //     return Padding(
            //       padding: EdgeInsets.only(
            //           bottom: MediaQuery.of(context).viewInsets.bottom),
            //       child: Wrap(
            //         children: [
            //           AddTaskMobile(
            //             isEdit: false,
            //             taskId: '0',
            //           ),
            //         ],
            //       ),
            //     );
            //   },
            // );
          },
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
