import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/service_report_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';

import '../../widgets/customer/service_details_widget.dart';

class ServicePageReport extends StatefulWidget {
  final bool fromDashBoard;

  const ServicePageReport({super.key, this.fromDashBoard = false});

  @override
  State<ServicePageReport> createState() => _ServicesPageReportState();
}

class _ServicesPageReportState extends State<ServicePageReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<ServiceReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchServiceReport(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);

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
    final reportsProvider = Provider.of<ServiceReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              title: Text(
                'Complaint Report',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
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
                        if (widget.fromDashBoard &&
                            AppStyles.isWebScreen(context))
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Image.asset(
                              'assets/images/ArrowRight.png',
                              width: 24,
                              height: 24,
                            ),
                          ),
                        if (widget.fromDashBoard &&
                            AppStyles.isWebScreen(context))
                          SizedBox(
                            width: 8,
                          ),
                        const Text(
                          'Complaint Report',
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
                              reportsProvider.getSearchServiceReport(context);
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
                                      reportsProvider
                                          .getSearchServiceReport(context);
                                    } else {
                                      reportsProvider.setTaskSearchCriteria(
                                        query,
                                        reportsProvider.fromDateS,
                                        reportsProvider.toDateS,
                                        reportsProvider.Status,
                                        reportsProvider.AssignedTo,
                                      );
                                      reportsProvider
                                          .getSearchServiceReport(context);
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
                        CustomElevatedButton(
                          onPressed: () {
                            exportToExcel(
                              headers: [
                                'Customer Name',
                                'Complaint Type',
                                'Complaint Name',
                                'Complaint Description',
                                'Added Date',
                                'Amount',
                                'Status'
                              ],
                              data: reportsProvider.serviceReport.map((task) {
                                return {
                                  'Customer Name': task.customerName,
                                  'Complaint Type': task.serviceTypeName,
                                  'Complaint Name': task.serviceName,
                                  'Complaint Description': task.description,
                                  'Added Date': task.createDate.isNotEmpty
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(task.createDate))
                                      : '',
                                  'Amount': task.amount.toString(),
                                  'Status': task.serviceStatusName,
                                };
                              }).toList(),
                              fileName: 'Complaint_Report',
                            );
                          },
                          buttonText: 'Export to Excel',
                          textColor: AppColors.whiteColor,
                          borderColor: AppColors.appViolet,
                          backgroundColor: AppColors.appViolet,
                        )
                      ],
                    ),
                  )
                //mobile
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: searchController,
                                  onSubmitted: (query) {
                                    reportsProvider.setTaskSearchCriteria(
                                      query,
                                      reportsProvider.fromDateS,
                                      reportsProvider.toDateS,
                                      reportsProvider.Status,
                                      reportsProvider.AssignedTo,
                                    );
                                    reportsProvider
                                        .getSearchServiceReport(context);
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
                                          if (reportsProvider
                                              .Search.isNotEmpty) {
                                            searchController.clear();
                                            reportsProvider
                                                .setTaskSearchCriteria(
                                              '',
                                              reportsProvider.fromDateS,
                                              reportsProvider.toDateS,
                                              reportsProvider.Status,
                                              reportsProvider.AssignedTo,
                                            );
                                            reportsProvider
                                                .getSearchServiceReport(
                                                    context);
                                          } else {
                                            reportsProvider
                                                .setTaskSearchCriteria(
                                              query,
                                              reportsProvider.fromDateS,
                                              reportsProvider.toDateS,
                                              reportsProvider.Status,
                                              reportsProvider.AssignedTo,
                                            );
                                            reportsProvider
                                                .getSearchServiceReport(
                                                    context);
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
                                        child: Text(
                                            reportsProvider.Search.isNotEmpty
                                                ? 'Cancel'
                                                : 'Search'),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                reportsProvider.toggleFilter();
                                print(reportsProvider.isFilter);
                              },
                              icon: const Icon(Icons.filter_list),
                              label: Text(
                                  MediaQuery.of(context).size.width > 860
                                      ? 'Filter'
                                      : ''), // Show only if width > 860px
                              style: OutlinedButton.styleFrom(
                                foregroundColor: reportsProvider.isFilter
                                    ? Colors.white
                                    : AppColors.primaryBlue,
                                backgroundColor: reportsProvider.isFilter
                                    ? const Color(0xFF5499D9)
                                    : Colors.white,
                                side: BorderSide(
                                  color: reportsProvider.isFilter
                                      ? const Color(0xFF5499D9)
                                      : AppColors.primaryBlue,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            CustomElevatedButton(
                              onPressed: () {
                                exportToExcel(
                                  headers: [
                                    'Customer Name',
                                    'Complaint Type',
                                    'Complaint Name',
                                    'Complaint Description',
                                    'Added Date',
                                    'Amount',
                                    'Status'
                                  ],
                                  data:
                                      reportsProvider.serviceReport.map((task) {
                                    return {
                                      'Customer Name': task.customerName,
                                      'Complaint Type': task.serviceTypeName,
                                      'Complaint Name': task.serviceName,
                                      'Complaint Description': task.description,
                                      'Added Date': task.createDate.isNotEmpty
                                          ? DateFormat('dd MMM yyyy').format(
                                              DateTime.parse(task.createDate))
                                          : '',
                                      'Amount': task.amount.toString(),
                                      'Status': task.serviceStatusName,
                                    };
                                  }).toList(),
                                  fileName: 'Complaint_Report',
                                );
                              },
                              buttonText: 'Export to Excel',
                              textColor: AppColors.whiteColor,
                              borderColor: AppColors.appViolet,
                              backgroundColor: AppColors.appViolet,
                            )
                          ],
                        ),
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedStatus !=
                                              null &&
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
                                      const [
                                        DropdownMenuItem<int>(
                                          value: 1,
                                          child: Text(
                                            'Pending',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        DropdownMenuItem<int>(
                                          value: 2,
                                          child: Text(
                                            'Completed',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                        reportsProvider.Search,
                                        fromDate,
                                        toDate,
                                        status,
                                        assignedTo);
                                    reportsProvider
                                        .getSearchServiceReport(context);
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
                                    const Text('Added Date: All'),
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
                          //         color: reportsProvider.selectedUser != null
                          //             ? AppColors.primaryBlue
                          //             : Colors.grey[300]!),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       const Text('Assigned Staff: '),
                          //       DropdownButton<int>(
                          //         value: reportsProvider.selectedUser,
                          //         hint: const Text('All'),
                          //         items: provider.searchUserDetails
                          //             .map((user) => DropdownMenuItem<int>(
                          //                   value: user.userDetailsId!,
                          //                   child: ConstrainedBox(
                          //                     constraints:
                          //                         BoxConstraints(maxWidth: 150),
                          //                     child: Text(
                          //                       user.userDetailsName ?? '',
                          //                       style:
                          //                           const TextStyle(fontSize: 14),
                          //                       overflow: TextOverflow.ellipsis,
                          //                     ),
                          //                   ),
                          //                 ))
                          //             .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setUserFilterStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
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
                          //     String fromDate = reportsProvider.formattedFromDate;
                          //     String toDate = reportsProvider.formattedToDate;
                          //     print(
                          //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //     reportsProvider.getSearchServiceReport(
                          //         '', fromDate, toDate, status, context);
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
                                reportsProvider.getSearchServiceReport(context);
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
                  //mobile
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedStatus !=
                                              null &&
                                          reportsProvider.selectedStatus != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
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
                                      const [
                                        DropdownMenuItem<int>(
                                          value: 1,
                                          child: Text(
                                            'Pending',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                        DropdownMenuItem<int>(
                                          value: 2,
                                          child: Text(
                                            'Completed',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setStatus(
                                          newValue); // Update the status in the provider
                                    }
                                    String status = reportsProvider
                                        .selectedStatus
                                        .toString();
                                    String assignedTo =
                                        reportsProvider.selectedUser.toString();
                                    String fromDate =
                                        reportsProvider.formattedFromDate;
                                    String toDate =
                                        reportsProvider.formattedToDate;
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    reportsProvider.setTaskSearchCriteria(
                                        reportsProvider.Search,
                                        fromDate,
                                        toDate,
                                        status,
                                        assignedTo);
                                    reportsProvider
                                        .getSearchServiceReport(context);
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (reportsProvider.fromDate == null &&
                                      reportsProvider.toDate == null)
                                    const Text('Added Date: All'),
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
                          //         color: reportsProvider.selectedUser != null
                          //             ? AppColors.primaryBlue
                          //             : Colors.grey[300]!),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       const Text('Assigned Staff: '),
                          //       DropdownButton<int>(
                          //         value: reportsProvider.selectedUser,
                          //         hint: const Text('All'),
                          //         items: provider.searchUserDetails
                          //             .map((user) => DropdownMenuItem<int>(
                          //                   value: user.userDetailsId!,
                          //                   child: ConstrainedBox(
                          //                     constraints:
                          //                         BoxConstraints(maxWidth: 150),
                          //                     child: Text(
                          //                       user.userDetailsName ?? '',
                          //                       style:
                          //                           const TextStyle(fontSize: 14),
                          //                       overflow: TextOverflow.ellipsis,
                          //                     ),
                          //                   ),
                          //                 ))
                          //             .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setUserFilterStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
                          //         },
                          //         underline: Container(),
                          //         isDense: true,
                          //         iconSize: 18,
                          //       ),
                          //     ],
                          //   ),
                          // ),

                          // ElevatedButton(
                          //   onPressed: () {
                          //     // Apply the selected filters (You can use values from the provider)
                          //     String status =
                          //         reportsProvider.selectedStatus.toString();
                          //     String fromDate = reportsProvider.formattedFromDate;
                          //     String toDate = reportsProvider.formattedToDate;
                          //     print(
                          //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //     reportsProvider.getSearchServiceReport(
                          //         '', fromDate, toDate, status, context);
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
                                reportsProvider.getSearchServiceReport(context);
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
                                                fontSize: 14,
                                                color: Color(0xFF607185))),
                                      ),
                                    ),
                                    TableWidget(
                                        flex: 2,
                                        title: 'Customer Name',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    // TableWidget(
                                    //     flex: 1,
                                    //     title: 'Mobile',
                                    //     color: Color(0xFF607185)),
                                    // TableWidget(
                                    //     flex: 2,
                                    //     title: 'Address',
                                    //     color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Complaint Type',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Complaint Name',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 2,
                                        title: 'Complaint Description',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Added Date',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Amount',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'Status',
                                        fontSize: 14,
                                        color: Color(0xFF607185)),
                                    TableWidget(
                                        flex: 1,
                                        title: 'View Details',
                                        fontSize: 14,
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
                                  itemCount: reportsProvider.serviceReport
                                      .length, // Number of Services
                                  itemBuilder: (context, index) {
                                    var Service =
                                        reportsProvider.serviceReport[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // context.go(
                                        //     '${CustomerDetailsScreen.route}${Service.customerId.toString()}');
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
                                            //   child: Text(Service.customerId.toString(),
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
                                                          fontSize: 12,
                                                        )),
                                              ),
                                            ),
                                            // TableWidget(title: Service.orderNo),
                                            TableWidget(
                                              flex: 2,
                                              data: InkWell(
                                                onTap: () {
                                                  context.push(
                                                      '${CustomerDetailsScreen.route}${Service.customerId.toString()}/${'true'}');
                                                },
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
                                                              Service.customerName
                                                                          .length >
                                                                      20
                                                                  ? '${Service.customerName.substring(0, 20)}...'
                                                                  : Service
                                                                      .customerName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
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
                                                          Service.customerName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                ),
                                              ),
                                            ),
                                            // TableWidget(
                                            //     flex: 1, title: Service.mobile),
                                            // TableWidget(
                                            //     flex: 2,
                                            //     title: Service.address1),
                                            TableWidget(
                                                flex: 1,
                                                fontSize: 12,
                                                title: Service.serviceTypeName),
                                            TableWidget(
                                                flex: 1,
                                                fontSize: 12,
                                                title: Service.serviceName
                                                    .toString()),
                                            TableWidget(
                                                flex: 2,
                                                fontSize: 12,
                                                title: Service.description),
                                            TableWidget(
                                                flex: 1,
                                                fontSize: 12,
                                                title: (Service
                                                        .createDate.isNotEmpty)
                                                    ? DateFormat('dd MMM yyyy')
                                                        .format(DateTime.parse(
                                                            Service.createDate))
                                                    : ''),
                                            TableWidget(
                                                flex: 1,
                                                fontSize: 12,
                                                title:
                                                    "₹${double.parse(Service.amount).toStringAsFixed(1)}"),
                                            TableWidget(
                                              flex: 1,
                                              data: Container(
                                                padding: Service
                                                        .serviceStatusName
                                                        .isNotEmpty
                                                    ? const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2)
                                                    : const EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: StatusUtils
                                                      .getStatusColor(Service
                                                          .serviceStatusId),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: Colors.black45,
                                                      width: 0.1),
                                                ),
                                                child: Text(
                                                  Service.serviceStatusName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: StatusUtils
                                                        .getStatusTextColor(
                                                            Service
                                                                .serviceStatusId),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: CustomOutlinedSvgButton(
                                                showIcon: false,
                                                onPressed: () async {
                                                  String ServiceId = Service
                                                      .serviceId
                                                      .toString();
                                                  String customerId = Service
                                                      .customerId
                                                      .toString();
                                                  print(
                                                      'Service ID: $ServiceId');
                                                  customerDetailsProvider
                                                      .getServiceDetails(
                                                          ServiceId.toString(),
                                                          context);

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ServiceDetailsWidget(
                                                          serviceId: ServiceId
                                                              .toString(),
                                                          customerId: customerId
                                                              .toString(),
                                                          showEdit: false);
                                                    },
                                                  );
                                                },
                                                svgPath:
                                                    'assets/images/Print.svg',
                                                label: 'View Details',
                                                breakpoint: 860,
                                                foregroundColor:
                                                    AppColors.primaryBlue,
                                                backgroundColor: Colors.white,
                                                borderSide: BorderSide(
                                                    color:
                                                        AppColors.primaryBlue),
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
                : Expanded(
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
                              // Data Rows
                              Expanded(
                                child: ListView.builder(
                                  shrinkWrap:
                                      true, // To avoid scrolling issues when inside a parent widget
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: reportsProvider.serviceReport
                                      .length, // Number of Services
                                  itemBuilder: (context, index) {
                                    var Service =
                                        reportsProvider.serviceReport[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // context.go(
                                        //     '${CustomerDetailsScreen.route}${Service.customerId.toString()}');
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
                                        child: Wrap(
                                          // mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            // Padding(
                                            //   padding: const EdgeInsets.symmetric(
                                            //       vertical: 12.0, horizontal: 25.0),
                                            //   child: Text(Service.customerId.toString(),
                                            //       style: const TextStyle(
                                            //         fontWeight: FontWeight.bold,
                                            //       )),
                                            // ),

                                            // TableWidget(title: Service.orderNo),
                                            TableWidget(
                                              width: 150,
                                              data: InkWell(
                                                onTap: () {
                                                  context.push(
                                                      '${CustomerDetailsScreen.route}${Service.customerId.toString()}/${'true'}');
                                                },
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
                                                              Service.customerName
                                                                          .length >
                                                                      20
                                                                  ? '${Service.customerName.substring(0, 20)}...'
                                                                  : Service
                                                                      .customerName,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
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
                                                          Service.customerName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
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
                                                width: 150,
                                                title: Service.serviceTypeName),
                                            TableWidget(
                                                width: 150,
                                                title: Service.serviceName
                                                    .toString()),
                                            TableWidget(
                                                width: 180,
                                                title: Service.description),
                                            TableWidget(
                                                width: 150,
                                                title: (Service
                                                        .createDate.isNotEmpty)
                                                    ? DateFormat('dd MMM yyyy')
                                                        .format(DateTime.parse(
                                                            Service.createDate))
                                                    : ''),
                                            TableWidget(
                                                width: 150,
                                                title:
                                                    "₹${double.parse(Service.amount).toStringAsFixed(1)}"),
                                            TableWidget(
                                              width: 150,
                                              data: Container(
                                                padding: Service
                                                        .serviceStatusName
                                                        .isNotEmpty
                                                    ? const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 8,
                                                        vertical: 2)
                                                    : const EdgeInsets.all(0),
                                                decoration: BoxDecoration(
                                                  color: StatusUtils
                                                      .getStatusColor(Service
                                                          .serviceStatusId),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                      color: Colors.black45,
                                                      width: 0.1),
                                                ),
                                                child: Text(
                                                  Service.serviceStatusName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: StatusUtils
                                                        .getStatusTextColor(
                                                            Service
                                                                .serviceStatusId),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: CustomOutlinedSvgButton(
                                                showIcon: false,
                                                onPressed: () async {
                                                  String ServiceId = Service
                                                      .serviceId
                                                      .toString();
                                                  String customerId = Service
                                                      .customerId
                                                      .toString();
                                                  print(
                                                      'Service ID: $ServiceId');
                                                  customerDetailsProvider
                                                      .getServiceDetails(
                                                          ServiceId.toString(),
                                                          context);

                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return ServiceDetailsWidget(
                                                          serviceId: ServiceId
                                                              .toString(),
                                                          customerId: customerId
                                                              .toString(),
                                                          showEdit: false);
                                                    },
                                                  );
                                                },
                                                svgPath:
                                                    'assets/images/Print.svg',
                                                label: 'View Details',
                                                breakpoint: 860,
                                                foregroundColor:
                                                    AppColors.primaryBlue,
                                                backgroundColor: Colors.white,
                                                borderSide: BorderSide(
                                                    color:
                                                        AppColors.primaryBlue),
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
      builder: (contextx) => Consumer<ServiceReportProvider>(
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
                          reportsProvider.getSearchServiceReport(context);
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
                          reportsProvider.getSearchServiceReport(context);
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
}
