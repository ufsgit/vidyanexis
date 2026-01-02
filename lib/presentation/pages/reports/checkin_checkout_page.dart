import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/check_in_out_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/add_check_in_out.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  _CheckInOutScreenState createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<CheckInOutProvider>(context, listen: false);
      DateTime now = DateTime.now();
      DateTime fromDate = DateTime(now.year, now.month, 1);
      DateTime toDate = DateTime(now.year, now.month + 1, 0);
      reportsProvider.setFromDate(fromDate);
      reportsProvider.setToDate(toDate);
      String fromDateString = reportsProvider.formattedFromDate;
      String toDateString = reportsProvider.formattedToDate;
      reportsProvider.setTaskSearchCriteria(
          '', fromDateString, toDateString, '', '', '');
      reportsProvider.getSearchTaskReport(context);

      // final provider = Provider.of<DropDownProvider>(context, listen: false);
      // provider.getAMCStatus(context);
      // provider.getUserDetails(context);
      // provider.getTaskType(context);

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
    final reportsProvider = Provider.of<CheckInOutProvider>(context);
    // final provider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Attendance',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppStyles.isWebScreen(context)
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Flexible(child: Container()),
                        // Container(
                        //   width: MediaQuery.of(context).size.width / 4,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(20),
                        //     border: Border.all(color: Colors.grey[300]!),
                        //   ),
                        //   child: TextField(
                        //     controller: searchController,
                        //     onSubmitted: (query) {
                        //       // reportsProvider.selectDateFilterOption(null);
                        //       // reportsProvider.removeStatus();
                        //       reportsProvider.setTaskSearchCriteria(
                        //         query,
                        //         reportsProvider.fromDateS,
                        //         reportsProvider.toDateS,
                        //         reportsProvider.Status,
                        //         reportsProvider.AssignedTo,
                        //         reportsProvider.TaskType,
                        //       );
                        //       reportsProvider.getSearchTaskReport(context);
                        //     },
                        //     decoration: InputDecoration(
                        //       hintText: 'Search here....',
                        //       prefixIcon: const Icon(Icons.search),
                        //       border: InputBorder.none,
                        //       contentPadding: const EdgeInsets.symmetric(
                        //         horizontal: 16,
                        //         vertical: 4,
                        //       ),
                        //       suffixIcon: Padding(
                        //         padding: const EdgeInsets.all(4.0),
                        //         child: ElevatedButton(
                        //           onPressed: () {
                        //             String query = searchController.text;
                        //             // leadProvider.selectDateFilterOption(null);
                        //             // leadProvider.removeStatus();
                        //             print(query);
                        //             if (reportsProvider.Search.isNotEmpty) {
                        //               searchController.clear();
                        //               reportsProvider.setTaskSearchCriteria(
                        //                 '',
                        //                 reportsProvider.fromDateS,
                        //                 reportsProvider.toDateS,
                        //                 reportsProvider.Status,
                        //                 reportsProvider.AssignedTo,
                        //                 reportsProvider.TaskType,
                        //               );
                        //               reportsProvider
                        //                   .getSearchTaskReport(context);
                        //             } else {
                        //               reportsProvider.setTaskSearchCriteria(
                        //                 query,
                        //                 reportsProvider.fromDateS,
                        //                 reportsProvider.toDateS,
                        //                 reportsProvider.Status,
                        //                 reportsProvider.AssignedTo,
                        //                 reportsProvider.TaskType,
                        //               );
                        //               reportsProvider
                        //                   .getSearchTaskReport(context);
                        //             }
                        //           },
                        //           style: ElevatedButton.styleFrom(
                        //             backgroundColor: AppColors.textGrey4,
                        //             foregroundColor: Colors.white,
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 16,
                        //               vertical: 12,
                        //             ),
                        //           ),
                        //           child: Text(reportsProvider.Search.isNotEmpty
                        //               ? 'Cancel'
                        //               : 'Search'),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 16),
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
                                : AppColors
                                    .primaryBlue, // Change foreground color
                            backgroundColor: reportsProvider.isFilter
                                ? const Color(0xFF5499D9)
                                : Colors.white, // Change background color
                            side: BorderSide(
                                color: reportsProvider.isFilter
                                    ? const Color(0xFF5499D9)
                                    : AppColors
                                        .primaryBlue), // Change border color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ElevatedButton.icon(
                        //   onPressed: () async {
                        //     await reportsProvider.getAttendanceDetails(
                        //         "0", context);
                        //     showDialog(
                        //       barrierDismissible: false,
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return const AddCheckInOutWidget(
                        //           editId: '0',
                        //           isEdit: false,
                        //         );
                        //       },
                        //     );
                        //   },
                        //   icon: const Icon(Icons.add),
                        //   label: const Text('Add Attendance'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.primaryBlue,
                        //     foregroundColor: Colors.white,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 12,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 16),
                        // CustomElevatedButton(
                        //   onPressed: () {
                        //     exportToExcel(
                        //       headers: ['Name', 'Date', 'Time', 'Location'],
                        //       data: reportsProvider.taskReport.map((task) {
                        //         return {
                        //           'Name': task.userDetailsName,
                        //           'Date': task.attendanceDate.isNotEmpty
                        //               ? DateFormat('dd MMM yyyy').format(
                        //                   DateTime.parse(task.attendanceDate))
                        //               : '',
                        //           'Time': task.attendanceTime,
                        //           'Location': task.location,
                        //         };
                        //       }).toList(),
                        //       fileName: 'Attendance_Report',
                        //     );
                        //   },
                        //   buttonText: 'Export to Excel',
                        //   textColor: AppColors.whiteColor,
                        //   borderColor: AppColors.appViolet,
                        //   backgroundColor: AppColors.appViolet,
                        // ),
                      ],
                    ),
                  )
                //mobile design
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          width: double.infinity,
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
                                reportsProvider.TaskType,
                              );
                              reportsProvider.getSearchTaskReport(context);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search here....',
                              prefixIcon: const Icon(Icons.search),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
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
                                        reportsProvider.TaskType,
                                      );
                                      reportsProvider
                                          .getSearchTaskReport(context);
                                    } else {
                                      reportsProvider.setTaskSearchCriteria(
                                        query,
                                        reportsProvider.fromDateS,
                                        reportsProvider.toDateS,
                                        reportsProvider.Status,
                                        reportsProvider.AssignedTo,
                                        reportsProvider.TaskType,
                                      );
                                      reportsProvider
                                          .getSearchTaskReport(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.textGrey4,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 0,
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
                        OutlinedButton.icon(
                          onPressed: () {
                            reportsProvider.toggleFilter();
                            print(reportsProvider.isFilter);
                          },
                          icon: const Icon(Icons.filter_list),
                          label: Text('Filter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: reportsProvider.isFilter
                                ? Colors.white
                                : AppColors
                                    .primaryBlue, // Change foreground color
                            backgroundColor: reportsProvider.isFilter
                                ? const Color(0xFF5499D9)
                                : Colors.white, // Change background color
                            side: BorderSide(
                                color: reportsProvider.isFilter
                                    ? const Color(0xFF5499D9)
                                    : AppColors
                                        .primaryBlue), // Change border color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // ElevatedButton.icon(
                        //   onPressed: () async {
                        //     await reportsProvider.getAttendanceDetails(
                        //         "0", context);
                        //     showDialog(
                        //       barrierDismissible: false,
                        //       context: context,
                        //       builder: (BuildContext context) {
                        //         return const AddCheckInOutWidget(
                        //           editId: '0',
                        //           isEdit: false,
                        //         );
                        //       },
                        //     );
                        //   },
                        //   icon: const Icon(Icons.add),
                        //   label: const Text('Add Attendance'),
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.primaryBlue,
                        //     foregroundColor: Colors.white,
                        //     padding: const EdgeInsets.symmetric(
                        //       horizontal: 16,
                        //       vertical: 0,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(width: 16),
                        // CustomElevatedButton(
                        //   onPressed: () {
                        //     exportToExcel(
                        //       headers: ['Name', 'Date', 'Time', 'Location'],
                        //       data: reportsProvider.taskReport.map((task) {
                        //         return {
                        //           'Name': task.userDetailsName,
                        //           'Date': task.attendanceDate.isNotEmpty
                        //               ? DateFormat('dd MMM yyyy').format(
                        //                   DateTime.parse(task.attendanceDate))
                        //               : '',
                        //           'Time': task.attendanceTime,
                        //           'Location': task.location,
                        //         };
                        //       }).toList(),
                        //       fileName: 'Attendance_Report',
                        //     );
                        //   },
                        //   buttonText: 'Export to Excel',
                        //   textColor: AppColors.whiteColor,
                        //   borderColor: AppColors.appViolet,
                        //   backgroundColor: AppColors.appViolet,
                        // ),
                      ],
                    ),
                  ),
            if (reportsProvider.isFilter)
              AppStyles.isWebScreen(context)
                  ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
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
                                    const Text('Date: All'),
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
                          const SizedBox(
                            width: 10,
                          ),
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
                          //       const Text('User Name: '),
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
                          //                 .map(
                          //                     (status) => DropdownMenuItem<int>(
                          //                           value: status.userDetailsId,
                          //                           child: ConstrainedBox(
                          //                             constraints:
                          //                                 const BoxConstraints(
                          //                                     maxWidth: 150),
                          //                             child: Text(
                          //                               status.userDetailsName ??
                          //                                   '',
                          //                               overflow: TextOverflow
                          //                                   .ellipsis, // Adds ellipsis when the text is too long
                          //                               style: const TextStyle(
                          //                                   fontSize: 14),
                          //                             ),
                          //                           ),
                          //                         ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setUserFilterStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
                          //           String status = reportsProvider
                          //               .selectedStatus
                          //               .toString();
                          //           String assignedTo =
                          //               reportsProvider.selectedUser.toString();
                          //           String fromDate =
                          //               reportsProvider.formattedFromDate;
                          //           String toDate =
                          //               reportsProvider.formattedToDate;
                          //           String taskType = reportsProvider
                          //               .selectedTaskType
                          //               .toString();
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //             reportsProvider.Search,
                          //             fromDate,
                          //             toDate,
                          //             status,
                          //             assignedTo,
                          //             taskType,
                          //           );
                          //           reportsProvider
                          //               .getSearchTaskReport(context);
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
                              (reportsProvider.selectedTaskType != null &&
                                  reportsProvider.selectedTaskType != 0) ||
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
                                  '',
                                );
                                reportsProvider.getSearchTaskReport(context);
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
                    )
                  : Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Wrap(
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (reportsProvider.fromDate == null &&
                                      reportsProvider.toDate == null)
                                    const Text('Date: All'),
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
                          const SizedBox(
                            width: 10,
                          ),
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
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       const Text('User Name: '),
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
                          //                 .map(
                          //                     (status) => DropdownMenuItem<int>(
                          //                           value: status.userDetailsId,
                          //                           child: ConstrainedBox(
                          //                             constraints:
                          //                                 const BoxConstraints(
                          //                                     maxWidth: 150),
                          //                             child: Text(
                          //                               status.userDetailsName ??
                          //                                   '',
                          //                               overflow: TextOverflow
                          //                                   .ellipsis, // Adds ellipsis when the text is too long
                          //                               style: const TextStyle(
                          //                                   fontSize: 14),
                          //                             ),
                          //                           ),
                          //                         ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setUserFilterStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
                          //           String status = reportsProvider
                          //               .selectedStatus
                          //               .toString();
                          //           String assignedTo =
                          //               reportsProvider.selectedUser.toString();
                          //           String fromDate =
                          //               reportsProvider.formattedFromDate;
                          //           String toDate =
                          //               reportsProvider.formattedToDate;
                          //           String taskType = reportsProvider
                          //               .selectedTaskType
                          //               .toString();
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //             reportsProvider.Search,
                          //             fromDate,
                          //             toDate,
                          //             status,
                          //             assignedTo,
                          //             taskType,
                          //           );
                          //           reportsProvider
                          //               .getSearchTaskReport(context);
                          //         },
                          //         underline: Container(),
                          //         isDense: true,
                          //         iconSize: 18,
                          //       ),
                          //     ],
                          //   ),
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
                              (reportsProvider.selectedTaskType != null &&
                                  reportsProvider.selectedTaskType != 0) ||
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
                                  '',
                                );
                                reportsProvider.getSearchTaskReport(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textRed,
                                side: BorderSide(color: AppColors.textRed),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                              child: const Text('Reset'),
                            ),
                        ],
                      ),
                    ),
            AppStyles.isWebScreen(context)
                ? Expanded(
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
                                        flex: 1,
                                        title: 'Name',
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Date',
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Check In Time',
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Check Out Time',
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Location',
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Photo',
                                        color: Color(0xFF607185)),
                                  ],
                                ),
                              ),
                              // Data Rows
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap:
                                      true, // To avoid scrolling issues when inside a parent widget
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: reportsProvider
                                      .taskReport.length, // Number of tasks
                                  itemBuilder: (context, index) {
                                    var task =
                                        reportsProvider.taskReport[index];
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 25.0),
                                                child:
                                                    Text((index + 1).toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        )),
                                              ),
                                            ),
                                            // TableWidget(title: task.orderNo),
                                            TableWidget(
                                              flex: 1,
                                              data: GestureDetector(
                                                // onTap: () async {
                                                //   await reportsProvider
                                                //       .getAttendanceDetails(
                                                //           task.attendanceMasterId
                                                //               .toString(),
                                                //           context);
                                                //   showDialog(
                                                //     barrierDismissible: false,
                                                //     context: context,
                                                //     builder:
                                                //         (BuildContext context) {
                                                //       return AddCheckInOutWidget(
                                                //         editId: task
                                                //             .attendanceMasterId
                                                //             .toString(),
                                                //         isEdit: true,
                                                //       );
                                                //     },
                                                //   );
                                                //   // context.push(
                                                //   //     '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                // },
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFE9EDF1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  child: Text(
                                                    task.userDetailsName,
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

                                            TableWidget(
                                                flex: 1,
                                                title: formatDate(
                                                    task.checkInDate)),
                                            TableWidget(
                                                flex: 1,
                                                title: formatTime(
                                                    task.checkInTimeOnly)),
                                            TableWidget(
                                                flex: 1,
                                                title: formatTime(
                                                    task.checkOutTimeOnly)),
                                            TableWidget(
                                                flex: 1, title: task.location),
                                            task.photo.isNotEmpty
                                                ? TableWidget(
                                                    flex: 1,
                                                    data:
                                                        CustomOutlinedSvgButton(
                                                      showIcon: false,
                                                      onPressed: () async {
                                                        showImageDialog(
                                                            context,
                                                            HttpUrls.imgBaseUrl +
                                                                task.photo);
                                                      },
                                                      svgPath:
                                                          'assets/images/Print.svg',
                                                      label: 'View Photo',
                                                      breakpoint: 860,
                                                      foregroundColor:
                                                          AppColors.primaryBlue,
                                                      backgroundColor:
                                                          Colors.white,
                                                      borderSide: BorderSide(
                                                          color: AppColors
                                                              .primaryBlue),
                                                    ),
                                                  )
                                                : TableWidget(
                                                    flex: 1,
                                                    data: Container(),
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
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: reportsProvider.taskReport.length,
                        itemBuilder: (context, index) {
                          var task = reportsProvider.taskReport[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Row 1: Serial No. and Name
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'No. ${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF607185),
                                        ),
                                      ),
                                      // GestureDetector(
                                      //   onTap: () async {
                                      //     await reportsProvider
                                      //         .getAttendanceDetails(
                                      //             task.attendanceMasterId
                                      //                 .toString(),
                                      //             context);
                                      //     showDialog(
                                      //       barrierDismissible: false,
                                      //       context: context,
                                      //       builder: (_) => AddCheckInOutWidget(
                                      //         editId: task.attendanceMasterId
                                      //             .toString(),
                                      //         isEdit: true,
                                      //       ),
                                      //     );
                                      //   },
                                      //   child: Container(
                                      //     padding: const EdgeInsets.symmetric(
                                      //         horizontal: 10, vertical: 5),
                                      //     decoration: BoxDecoration(
                                      //       color: const Color(0xFFE9EDF1),
                                      //       borderRadius:
                                      //           BorderRadius.circular(30),
                                      //     ),
                                      //     child: Text(
                                      //       task.userDetailsName,
                                      //       style: const TextStyle(
                                      //         fontWeight: FontWeight.bold,
                                      //         fontSize: 14,
                                      //       ),
                                      //       overflow: TextOverflow.ellipsis,
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  /// Row 2: Dates and Times
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _labelValue(
                                          'Date', formatDate(task.checkInDate)),
                                      _labelValue('Check-In',
                                          formatTime(task.checkInTimeOnly)),
                                      _labelValue('Check-Out',
                                          formatTime(task.checkOutTimeOnly)),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  /// Row 3: Location
                                  _labelValue('Location', task.location),

                                  /// Row 4: Photo Button
                                  if (task.photo.isNotEmpty)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: CustomOutlinedSvgButton(
                                        showIcon: false,
                                        onPressed: () {
                                          showImageDialog(context,
                                              HttpUrls.imgBaseUrl + task.photo);
                                        },
                                        svgPath: 'assets/images/Print.svg',
                                        label: 'View Photo',
                                        breakpoint: 860,
                                        foregroundColor: AppColors.primaryBlue,
                                        backgroundColor: Colors.white,
                                        borderSide: BorderSide(
                                            color: AppColors.primaryBlue),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<CheckInOutProvider>(
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
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

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows the dialog to be dismissed by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black, // Set background color to black
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // Adjust image fit
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    // Return a placeholder or error image in case of an error
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.2)),
                      child: const Icon(
                        Icons.hide_image_outlined,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white), // Close icon button
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog when button is pressed
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy')
          .format(parsedDate); // Example: Jan 15, 2025
    } catch (e) {
      return date; // In case of error, return the original string
    }
  }

  String formatTime(String time) {
    try {
      DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsedTime); // Example: 12:26 PM
    } catch (e) {
      return time; // In case of error, return the original string
    }
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
