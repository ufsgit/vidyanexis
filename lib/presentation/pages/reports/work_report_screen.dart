import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/work_report_provider.dart';
import 'package:techtify/presentation/pages/home/customer_details_page.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/table_cell.dart';
import 'package:techtify/utils/csv_function.dart';

class WorkReportScreen extends StatefulWidget {
  static const String route = '/workReport/';
  final String userId;
  const WorkReportScreen({
    super.key,
    required this.userId,
  });

  @override
  State<WorkReportScreen> createState() => _WorkReportScreenState();
}

class _WorkReportScreenState extends State<WorkReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<WorkReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchTaskReport(widget.userId, context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '0');

      //search
      // searchController.addListener(() {
      //   reportsProvider.selectDateFilterOption(null);
      //   reportsProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   reportsProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WorkReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // IconButton(
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  //   icon: Icon(Icons.arrow_back_rounded),
                  // ),
                  // SizedBox(
                  //   width: 10,
                  // ),
                  const Text(
                    'Work Details Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Flexible(child: Container()),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (query) {
                        // reportsProvider.selectDateFilterOption(null);
                        // reportsProvider.removeStatus();
                        reportsProvider.setTaskSearchCriteria(
                          query,
                          reportsProvider.fromDateS,
                          reportsProvider.toDateS,
                          reportsProvider.Status,
                          reportsProvider.AssignedTo,
                        );
                        reportsProvider.getSearchTaskReport(
                            widget.userId, context);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search here....',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: ElevatedButton(
                            onPressed: () {
                              String query = searchController.text;
                              // leadProvider.selectDateFilterOption(null);
                              // leadProvider.removeStatus();
                              print(query);
                              if (reportsProvider.Search.isNotEmpty) {
                                searchController.clear();
                                reportsProvider.setTaskSearchCriteria(
                                  '',
                                  reportsProvider.fromDateS,
                                  reportsProvider.toDateS,
                                  reportsProvider.Status,
                                  reportsProvider.AssignedTo,
                                );
                                reportsProvider.getSearchTaskReport(
                                    widget.userId, context);
                              } else {
                                reportsProvider.setTaskSearchCriteria(
                                  query,
                                  reportsProvider.fromDateS,
                                  reportsProvider.toDateS,
                                  reportsProvider.Status,
                                  reportsProvider.AssignedTo,
                                );
                                reportsProvider.getSearchTaskReport(
                                    widget.userId, context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textGrey4,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(reportsProvider.Search.isNotEmpty
                                ? 'Cancel'
                                : 'Search'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      reportsProvider.toggleFilter();
                      print(reportsProvider.isFilter);
                    },
                    icon: const Icon(Icons.filter_list),
                    label: Text(MediaQuery.of(context).size.width > 860
                        ? 'Filter'
                        : ''),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: reportsProvider.isFilter
                          ? Colors.white
                          : AppColors.primaryBlue, // Change foreground color
                      backgroundColor: reportsProvider.isFilter
                          ? const Color(0xFF5499D9)
                          : Colors.white, // Change background color
                      side: BorderSide(
                          color: reportsProvider.isFilter
                              ? const Color(0xFF5499D9)
                              : AppColors.primaryBlue), // Change border color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  CustomElevatedButton(
                    onPressed: () {
                      exportToExcel(
                        headers: [
                          'Customer Name',
                          'Mobile',
                          'Address',
                          'Follow Up By',
                          'Remark',
                          'Entry Date',
                          'Follow Up Date',
                          'Status'
                        ],
                        data: reportsProvider.taskReport.map((task) {
                          return {
                            'Customer Name': task.customer,
                            'Mobile': task.mobile,
                            'Address': task.address1,
                            'Follow Up By': task.followUpBy,
                            'Remark': task.remark,
                            'Entry Date': task.entryDate,
                            'Follow Up Date': task.followUp,
                            'Status': task.statusName,
                          };
                        }).toList(),
                        fileName: 'Work_Report',
                      );
                    },
                    buttonText: 'Export to Excel',
                    textColor: AppColors.whiteColor,
                    borderColor: AppColors.appViolet,
                    backgroundColor: AppColors.appViolet,
                  )
                ],
              ),
            ),
            if (reportsProvider.isFilter)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: reportsProvider.selectedStatus != null &&
                                    reportsProvider.selectedStatus != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Status: '),
                          DropdownButton<int>(
                            value: reportsProvider.selectedStatus,
                            hint: const Text('All'),
                            items: [
                                  const DropdownMenuItem<int>(
                                    value:
                                        0, // Use 0 or null to represent "All"
                                    child: Text(
                                      'All',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ] +
                                provider.followUpData
                                    .map((status) => DropdownMenuItem<int>(
                                          value: status.statusId,
                                          child: Text(
                                            status.statusName ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                reportsProvider.setStatus(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  reportsProvider.selectedStatus.toString();
                              String assignedTo =
                                  reportsProvider.selectedUser.toString();
                              String fromDate =
                                  reportsProvider.formattedFromDate;
                              String toDate = reportsProvider.formattedToDate;
                              print(
                                  'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                              reportsProvider.setTaskSearchCriteria(
                                  reportsProvider.Search,
                                  fromDate,
                                  toDate,
                                  status,
                                  assignedTo);
                              reportsProvider.getSearchTaskReport(
                                  widget.userId, context);
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    GestureDetector(
                      onTap: () {
                        onClickTopButton(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: reportsProvider.fromDate != null ||
                                      reportsProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (reportsProvider.fromDate == null &&
                                reportsProvider.toDate == null)
                              const Text('Entry Date: All'),
                            if (reportsProvider.fromDate != null &&
                                reportsProvider.toDate != null)
                              Text(
                                  'Date : ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}'),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.arrow_drop_down_outlined,
                              color: Colors.black45,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(
                    //         color: reportsProvider.selectedUser != null &&
                    //                 reportsProvider.selectedUser != 0
                    //             ? AppColors.primaryBlue
                    //             : Colors.grey[300]!),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       const Text('Assigned to: '),
                    //       DropdownButton<int>(
                    //         value: reportsProvider.selectedUser,
                    //         hint: const Text('All'),
                    //         items: [
                    //               const DropdownMenuItem<int>(
                    //                 value:
                    //                     0, // Use 0 or null to represent "All"
                    //                 child: Text(
                    //                   'All',
                    //                   style: TextStyle(fontSize: 14),
                    //                 ),
                    //               ),
                    //             ] +
                    //             provider.searchUserDetails
                    //                 .map((status) => DropdownMenuItem<int>(
                    //                       value: status.userDetailsId,
                    //                       child: ConstrainedBox(
                    //                         constraints: BoxConstraints(
                    //                             maxWidth: 150),
                    //                         child: Text(
                    //                           status.userDetailsName ?? '',
                    //                           overflow: TextOverflow
                    //                               .ellipsis, // Adds ellipsis when the text is too long
                    //                           style: const TextStyle(
                    //                               fontSize: 14),
                    //                         ),
                    //                       ),
                    //                     ))
                    //                 .toList(),
                    //         onChanged: (int? newValue) {
                    //           if (newValue != null) {
                    //             reportsProvider.setUserFilterStatus(
                    //                 newValue); // Update the status in the provider
                    //           }
                    //           String status =
                    //               reportsProvider.selectedStatus.toString();
                    //           String assignedTo =
                    //               reportsProvider.selectedUser.toString();
                    //           String fromDate =
                    //               reportsProvider.formattedFromDate;
                    //           String toDate =
                    //               reportsProvider.formattedToDate;
                    //           print(
                    //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                    //           reportsProvider.setTaskSearchCriteria(
                    //             reportsProvider.Search,
                    //             fromDate,
                    //             toDate,
                    //             status,
                    //             assignedTo,
                    //           );
                    //           reportsProvider.getSearchTaskReport(
                    //               widget.userId, context);
                    //         },
                    //         underline: Container(),
                    //         isDense: true,
                    //         iconSize: 18,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const Spacer(),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Apply the selected filters (You can use values from the provider)
                    //     String status =
                    //         reportsProvider.selectedStatus.toString();
                    //     String fromDate =
                    //         reportsProvider.formattedFromDate;
                    //     String toDate = reportsProvider.formattedToDate;
                    //     print(
                    //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                    //     reportsProvider.setSearchCriteria(
                    //       reportsProvider.search,
                    //       fromDate,
                    //       toDate,
                    //       status,
                    //     );
                    //     reportsProvider.getSearchCustomers(context);
                    //   },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: Colors.white,
                    //     foregroundColor: AppColors.primaryBlue,
                    //     side: BorderSide(color: AppColors.primaryBlue),
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 16,
                    //       vertical: 12,
                    //     ),
                    //   ),
                    //   child: const Text('Apply'),
                    // ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                    if (reportsProvider.fromDate != null ||
                        reportsProvider.toDate != null ||
                        (reportsProvider.selectedStatus != null &&
                            reportsProvider.selectedStatus != 0) ||
                        (reportsProvider.selectedUser != null &&
                            reportsProvider.selectedUser != 0) ||
                        reportsProvider.Search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          reportsProvider.selectDateFilterOption(null);
                          reportsProvider.removeStatus();
                          searchController.clear();
                          reportsProvider.setTaskSearchCriteria(
                            '',
                            '',
                            '',
                            '',
                            '',
                          );
                          reportsProvider.getSearchTaskReport(
                              widget.userId, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Header Row (Table Column Titles)
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF2F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 80,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 25.0),
                                  child: Text('No.',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              TableWidget(
                                  flex: 2,
                                  title: 'Customer Name',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Mobile',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 2,
                                  title: 'Address',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Follow Up By',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 3,
                                  title: 'Remark',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Entry Date',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Follow Up Date',
                                  color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Status',
                                  color: Color(0xFF607185)),
                            ],
                          ),
                        ),
                        // Data Rows
                        Expanded(
                          child: ListView.builder(
                            shrinkWrap:
                                true, // To avoid scrolling issues when inside a parent widget
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: reportsProvider
                                .taskReport.length, // Number of tasks
                            itemBuilder: (context, index) {
                              var task = reportsProvider.taskReport[index];
                              return GestureDetector(
                                onTap: () {
                                  // context.go(
                                  //     '${CustomerDetailsScreen.route}${task.customerId.toString()}');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: index % 2 == 0
                                        ? Colors.white
                                        : const Color(0xFFF6F7F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  // Alternate row colors
                                  child: Row(
                                    // mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       vertical: 12.0, horizontal: 25.0),
                                      //   child: Text(task.customerId.toString(),
                                      //       style: const TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //       )),
                                      // ),
                                      SizedBox(
                                        width: 80,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 25.0),
                                          child: Text((index + 1).toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ),
                                      // TableWidget(title: task.orderNo),
                                      TableWidget(
                                        flex: 2,
                                        data: InkWell(
                                          onTap: () {
                                            context.push(
                                                '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE9EDF1),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    1700
                                                ? Row(
                                                    mainAxisSize: MainAxisSize
                                                        .min, // Ensures the Row takes only as much space as needed
                                                    children: [
                                                      // Front image (before text)
                                                      Image.asset(
                                                        'assets/images/lead_profile.png', // Replace with your image asset or NetworkImage
                                                        width:
                                                            15, // You can adjust the size of the image
                                                        height:
                                                            15, // You can adjust the size of the image
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              8), // Space between the image and text
                                                      Text(
                                                        task.customer.length >
                                                                20
                                                            ? '${task.customer.substring(0, 20)}...'
                                                            : task.customer,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width:
                                                              8), // Space between the text and back image
                                                      // Back image (after text)
                                                      Image.asset(
                                                        'assets/images/forward.png', // Replace with your image asset or NetworkImage
                                                        width:
                                                            12, // Adjust the size of the image
                                                        height:
                                                            12, // Adjust the size of the image
                                                      ),
                                                    ],
                                                  )
                                                : Text(
                                                    task.customer,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      TableWidget(flex: 1, title: task.mobile),
                                      TableWidget(
                                          flex: 2, title: task.address1),
                                      TableWidget(
                                          flex: 1, title: task.followUpBy),
                                      TableWidget(flex: 3, title: task.remark),
                                      TableWidget(
                                        flex: 1,
                                        title: task.entryDate,
                                      ),
                                      TableWidget(
                                        flex: 1,
                                        title: task.followUp,
                                      ),
                                      // TableWidget(
                                      //   flex: 1,
                                      //   data: Container(
                                      //     padding:
                                      //         task.taskStatusName.isNotEmpty
                                      //             ? const EdgeInsets.symmetric(
                                      //                 horizontal: 8,
                                      //                 vertical: 2)
                                      //             : const EdgeInsets.all(0),
                                      //     decoration: BoxDecoration(
                                      //       color: StatusUtils.getTaskColor(
                                      //           task.taskStatusId),
                                      //       borderRadius:
                                      //           BorderRadius.circular(6),
                                      //       border: Border.all(
                                      //           color: Colors.black45,
                                      //           width: 0.1),
                                      //     ),
                                      //     child: Text(
                                      //       task.taskStatusName,
                                      //       overflow: TextOverflow.ellipsis,
                                      //       maxLines: 1,
                                      //       style: TextStyle(
                                      //         color:
                                      //             StatusUtils.getTaskTextColor(
                                      //                 task.taskStatusId),
                                      //         fontSize: 13,
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                      // Expanded(
                                      //   child: CustomOutlinedSvgButton(
                                      //     showIcon: false,
                                      //     onPressed: () async {
                                      //       String taskId =
                                      //           task.taskId.toString();
                                      //       String customerId =
                                      //           task.customerId.toString();
                                      //       print('Task ID: $taskId');
                                      //       customerDetailsProvider
                                      //           .getTaskDetails(
                                      //               taskId.toString(), context);

                                      //       showDialog(
                                      //         context: context,
                                      //         builder: (BuildContext context) {
                                      //           return TaskDetailsWidget(
                                      //             taskId: taskId.toString(),
                                      //             customerId:
                                      //                 customerId.toString(),
                                      //             showEdit: false,
                                      //           );
                                      //         },
                                      //       );
                                      //     },
                                      //     svgPath: 'assets/images/Print.svg',
                                      //     label: 'View Details',
                                      //     breakpoint: 860,
                                      //     foregroundColor:
                                      //         AppColors.primaryBlue,
                                      //     backgroundColor: Colors.white,
                                      //     borderSide: BorderSide(
                                      //         color: AppColors.primaryBlue),
                                      //   ),
                                      // ),
                                      TableWidget(
                                        // width: 200,
                                        flex: 1,
                                        data: Container(
                                          padding: task.statusName.isNotEmpty
                                              ? const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4)
                                              : const EdgeInsets.all(0),
                                          decoration: BoxDecoration(
                                            // color: StatusUtils.getStatusColor(
                                            //     int.parse(lead.statusId)),
                                            color: parseColor(task.colorCode)
                                                .withOpacity(0.1)
                                                .withAlpha(30),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.black45,
                                                width: 0.1),
                                          ),
                                          child: Text(
                                            task.statusName,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              color: parseColor(task.colorCode),
                                              fontWeight: FontWeight.w600,
                                              // color:
                                              //     StatusUtils.getStatusTextColor(
                                              //         int.parse(lead.statusId)),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<WorkReportProvider>(
        builder: (contextx, reportsProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              reportsProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color:
                                reportsProvider.selectedDateFilterIndex == index
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);

                          reportsProvider.formatDate();

                          print(reportsProvider.formattedFromDate);
                          print(reportsProvider.formattedToDate);

                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = reportsProvider.formattedFromDate;
                          String toDate = reportsProvider.formattedToDate;
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                              reportsProvider.Search,
                              fromDate,
                              toDate,
                              status,
                              assignedTo);
                          reportsProvider.getSearchTaskReport(
                              widget.userId, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                          String status =
                              reportsProvider.selectedStatus.toString();
                          String assignedTo =
                              reportsProvider.selectedUser.toString();
                          String fromDate = '';
                          String toDate = '';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                          );
                          reportsProvider.getSearchTaskReport(
                              widget.userId, context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
