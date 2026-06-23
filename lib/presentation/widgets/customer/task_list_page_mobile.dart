import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart' hide StatusUtils;
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:vidyanexis/utils/status_utils.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool isLoadingMore = false;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    // _scrollController.addListener(_scrollListener); // uncomment for pagination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.taskListPageIndex = 1;
      hasMoreData = true;
      customerDetailsProvider.getTaskList(widget.customerId, context);
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMoreData) {
      loadMoreTasks();
    }
  }

  Future<void> loadMoreTasks() async {
    final provider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    setState(() {
      isLoadingMore = true;
    });

    provider.taskListPageIndex++;

    bool isEmpty = await provider.getTaskList(widget.customerId, context,
        isLoadMore: true);
    if (isEmpty) {
      hasMoreData = false;
    }

    setState(() {
      isLoadingMore = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tasks',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (Provider.of<SettingsProvider>(context,
                                    listen: false)
                                .menuIsSaveMap[13] ==
                            1)
                          GestureDetector(
                            onTap: () {
                              final customerDetailsProvider =
                                  Provider.of<CustomerDetailsProvider>(context,
                                      listen: false);
                              customerDetailsProvider.customerId =
                                  widget.customerId;
                              customerDetailsProvider.clearTaskDetails();
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return AddTaskMobile(
                                    isEdit: false,
                                    taskId: '0',
                                  );
                                },
                              ));
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBlue,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryBlue
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: customerDetailsProvider.taskList.isEmpty
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
                            controller: _scrollController,
                            child: Column(
                              children: [
                                ListView.separated(
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      height: 2,
                                      color: AppColors.grey,
                                    );
                                  },
                                  itemCount:
                                      customerDetailsProvider.taskList.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final task =
                                        customerDetailsProvider.taskList[index];

                                    Color statusColor = task.taskStatusName ==
                                            "Completed"
                                        ? Colors.green
                                        : task.taskStatusName == "In Progress"
                                            ? Colors.orange
                                            : Colors.red;
                                    return InkWell(
                                      onTap: () {
                                        // context.push(
                                        //     '${TaskDetailsPagePhone.route}${task.taskMasterId}/${task.taskId}');

                                        Navigator.push(context,
                                            MaterialPageRoute(
                                          builder: (context) {
                                            return TaskDetailsPagePhone(
                                                taskId: task.taskId.toString(),
                                                taskMasterId: task.taskMasterId
                                                    .toString(),
                                                customerId: widget.customerId
                                                    .toString());
                                          },
                                        ));
                                      },
                                      child: Container(
                                        width: MediaQuery.sizeOf(context).width,
                                        decoration: BoxDecoration(
                                            color: AppColors.whiteColor),
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
                                                              BorderRadius
                                                                  .circular(
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
                                                            : task.taskTypeId ==
                                                                    2
                                                                ? 'assets/images/icon_installation.png'
                                                                : task.taskTypeId ==
                                                                        3
                                                                    ? 'assets/images/icon_service.png'
                                                                    : 'assets/images/icon_amc.png',
                                                      )),
                                                  const SizedBox(
                                                    width: 4,
                                                  ),
                                                  Text(
                                                    task.taskTypeName,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: AppColors
                                                                .textBlack),
                                                  ),
                                                  const Spacer(),
                                                  Container(
                                                      height: 22,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color: statusColor
                                                            .withOpacity(.1),
                                                      ),
                                                      child: Center(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 2),
                                                          child: Text(
                                                            StatusUtils
                                                                .getDisplayStatus(
                                                                    task.taskStatusName),
                                                            style: GoogleFonts
                                                                .plusJakartaSans(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    color:
                                                                        statusColor),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: AppColors
                                                              .textGrey3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ));
  }
}
