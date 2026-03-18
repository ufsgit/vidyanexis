import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:vidyanexis/utils/extensions.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/amc_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/periodic_service_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class AmcReportScreen extends StatefulWidget {
  final bool fromDashBoard;

  const AmcReportScreen({super.key, this.fromDashBoard = false});

  @override
  State<AmcReportScreen> createState() => _AmcReportScreen();
}

class _AmcReportScreen extends State<AmcReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<AMCReportProvider>(context, listen: false);

      // Set default filter to "Today"
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1); // Index 1 is 'Today'
      reportsProvider.formatDate();

      reportsProvider.setTaskSearchCriteria(
        '',
        reportsProvider.formattedFromDate,
        reportsProvider.formattedToDate,
        '',
        '',
      );

      reportsProvider.getSearchAmcReport(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('dd MMM yyyy').format(date);
    }
    if (date is String && date.isNotEmpty) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
      } catch (e) {
        return date; // fallback to raw string if not parsable
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AMCReportProvider>(context);
    // final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: AppColors.textGrey4,
                ),
              ),
              title: Text(
                'Periodic Service Report',
                style: const TextStyle(
                  fontSize: 18,
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
                        // Header
                        if (widget.fromDashBoard)
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: Color(0xFF152D70),
                            ),
                          ),
                        if (widget.fromDashBoard)
                          SizedBox(
                            width: 8,
                          ),
                        const Text(
                          'Periodic Service',
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
                              reportsProvider.getSearchAmcReport(context);
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
                                          .getSearchAmcReport(context);
                                    } else {
                                      reportsProvider.setTaskSearchCriteria(
                                        query,
                                        reportsProvider.fromDateS,
                                        reportsProvider.toDateS,
                                        reportsProvider.Status,
                                        reportsProvider.AssignedTo,
                                      );
                                      reportsProvider
                                          .getSearchAmcReport(context);
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
                                'Address',
                                'Phone',
                                'Description',
                                'AMC Date',
                                'From Date',
                                'To Date',
                                'Product Name',
                                'Category',
                                'Amount',
                                'Status',
                                'Service'
                              ],
                              data: reportsProvider.amcReport.map((task) {
                                return {
                                  'Customer Name': task.customerName,
                                  'Address': task.address1,
                                  'Phone': task.mobile,
                                  'Description': task.description,
                                  'AMC Date': task.intervalDate,
                                  'From Date': formatDate(task.fromDate),
                                  'To Date': formatDate(task.toDate),
                                  'Product Name': task.productName,
                                  'Category': task.categoryName.isNotEmpty
                                      ? task.categoryName
                                      : 'AMC',
                                  'Amount': task.amount.toString(),
                                  'Status': task.displayStatus,
                                  'Service': task.serviceName,
                                };
                              }).toList(),
                              fileName: 'Periodic_Service_Report',
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
                //Mobile
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(
                        //   height: 10,
                        // ),
                        Column(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
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
                                  reportsProvider.getSearchAmcReport(context);
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
                                          );
                                          reportsProvider
                                              .getSearchAmcReport(context);
                                        } else {
                                          reportsProvider.setTaskSearchCriteria(
                                            query,
                                            reportsProvider.fromDateS,
                                            reportsProvider.toDateS,
                                            reportsProvider.Status,
                                            reportsProvider.AssignedTo,
                                          );
                                          reportsProvider
                                              .getSearchAmcReport(context);
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
                                  vertical: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            CustomElevatedButton(
                              onPressed: () {
                                exportToExcel(
                                  headers: [
                                    'Customer Name',
                                    'Address',
                                    'Phone',
                                    'Description',
                                    'AMC Date',
                                    'From Date',
                                    'To Date',
                                    'Product Name',
                                    'Category',
                                    'Amount',
                                    'Status',
                                    'Service'
                                  ],
                                  data: reportsProvider.amcReport.map((task) {
                                    return {
                                      'Customer Name': task.customerName,
                                      'Address': task.address1,
                                      'Phone': task.mobile,
                                      'Description': task.description,
                                      'AMC Date': task.intervalDate,
                                      'From Date':
                                          task.fromDate.toString().isNotEmpty
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(DateTime.parse(
                                                      task.fromDate.toString()))
                                              : '',
                                      'To Date':
                                          task.toDate.toString().isNotEmpty
                                              ? DateFormat('dd MMM yyyy')
                                                  .format(DateTime.parse(
                                                      task.toDate.toString()))
                                              : '',
                                      'Product Name': task.productName,
                                      'Category': task.categoryName.isNotEmpty
                                          ? task.categoryName
                                          : 'AMC',
                                      'Amount': task.amount.toString(),
                                      'Status': task.displayStatus,
                                      'Service': task.serviceName,
                                    };
                                  }).toList(),
                                  fileName: 'Periodic_Service_Report',
                                );
                              },
                              buttonText: 'Export to Excel',
                              textColor: AppColors.whiteColor,
                              borderColor: AppColors.appViolet,
                              backgroundColor: AppColors.appViolet,
                            )
                          ],
                        ),
                        const SizedBox(width: 16),
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
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(
                          //         color: reportsProvider.selectedStatus !=
                          //                     null &&
                          //                 reportsProvider.selectedStatus != 0
                          //             ? AppColors.primaryBlue
                          //             : Colors.grey[300]!),
                          //   ),
                          //   child: Row(
                          //     children: [
                          //       const Text('Status: '),
                          //       DropdownButton<int>(
                          //         value: reportsProvider.selectedStatus,
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
                          //             provider.amcStatus
                          //                 .map(
                          //                     (status) => DropdownMenuItem<int>(
                          //                           value: status.amcStatusId,
                          //                           child: Text(
                          //                             status.displayStatus,
                          //                             style: const TextStyle(
                          //                                 fontSize: 14),
                          //                           ),
                          //                         ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setStatus(
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
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //               reportsProvider.Search,
                          //               fromDate,
                          //               toDate,
                          //               status,
                          //               assignedTo);
                          //           reportsProvider.getSearchAmcReport(context);
                          //         },
                          //         underline: Container(),
                          //         isDense: true,
                          //         iconSize: 18,
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
                          //           reportsProvider.getSearchAmcReport(context);
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
                          //         reportsProvider.selectedAMCStatus.toString();
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
                                reportsProvider.getSearchAmcReport(context);
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
                  //Mobile
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
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(20),
                          //     border: Border.all(
                          //         color: reportsProvider.selectedStatus !=
                          //                     null &&
                          //                 reportsProvider.selectedStatus != 0
                          //             ? AppColors.primaryBlue
                          //             : Colors.grey[300]!),
                          //   ),
                          //   child: Row(
                          //     mainAxisSize: MainAxisSize.min,
                          //     children: [
                          //       const Text('Status: '),
                          //       DropdownButton<int>(
                          //         value: reportsProvider.selectedStatus,
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
                          //             provider.amcStatus
                          //                 .map(
                          //                     (status) => DropdownMenuItem<int>(
                          //                           value: status.amcStatusId,
                          //                           child: Text(
                          //                             status.displayStatus,
                          //                             style: const TextStyle(
                          //                                 fontSize: 14),
                          //                           ),
                          //                         ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setStatus(
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
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //               reportsProvider.Search,
                          //               fromDate,
                          //               toDate,
                          //               status,
                          //               assignedTo);
                          //           reportsProvider.getSearchAmcReport(context);
                          //         },
                          //         underline: Container(),
                          //         isDense: true,
                          //         iconSize: 18,
                          //       ),
                          //     ],
                          //   ),
                          // ),
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
                          //           reportsProvider.getSearchAmcReport(context);
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
                          //         reportsProvider.selectedAMCStatus.toString();
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
                                reportsProvider.getSearchAmcReport(context);
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
            Expanded(
              child: AppStyles.isWebScreen(context)
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width < 1500
                            ? 1500
                            : MediaQuery.of(context).size.width,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 25.0),
                                            child: Text('No.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                    color: Color(0xFF607185))),
                                          ),
                                        ),
                                        TableWidget(
                                            flex: 3,
                                            title: 'Customer Name',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 4,
                                            title: 'Address',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 3,
                                            title: 'Phone',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'Description',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'AMC Date',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'From Date',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'To Date',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 3,
                                            title: 'Product Name',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'Amount',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'Status',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'Service',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'View Details',
                                            fontSize: 14,
                                            color: Color(0xFF607185)),
                                      ],
                                    ),
                                  ),
                                  // Data Rows
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap: false,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          reportsProvider.amcReport.length,
                                      itemBuilder: (context, index) {
                                        final task =
                                            reportsProvider.amcReport[index];
                                        return InkWell(
                                          onTap: () {
                                            // Handle redirection
                                          },
                                          child: Container(
                                            decoration: const BoxDecoration(
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Color(0xFFEFF2F5),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 80,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 25.0),
                                                    child: Text('${index + 1}'),
                                                  ),
                                                ),
                                                TableWidget(
                                                  flex: 3,
                                                  data: InkWell(
                                                    onTap: () {
                                                      context.push(
                                                          '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFE9EDF1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      child: Text(
                                                        task.customerName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Color(
                                                                0xFF607185),
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                    flex: 4,
                                                    title: task.address1,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 3,
                                                    title: task.mobile,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title: task.description,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title: task.intervalDate,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title: formatDate(
                                                        task.fromDate),
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title:
                                                        formatDate(task.toDate),
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 3,
                                                    title: task.productName,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title:
                                                        task.amount.toString(),
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                    flex: 2,
                                                    title: task.displayStatus,
                                                    color: StatusUtils
                                                        .getTaskColor(
                                                            task.amcStatusId)),
                                                TableWidget(
                                                    flex: 2,
                                                    title: task.serviceName,
                                                    color: const Color(
                                                        0xFF607185)),
                                                TableWidget(
                                                  flex: 2,
                                                  data: Center(
                                                    child: IconButton(
                                                      onPressed: () {
                                                        // Redirection to detail screen
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              PeriodicServiceDetailsPage(
                                                            customerId: task
                                                                .customerId
                                                                .toString(),
                                                            amcReportModeld:
                                                                task,
                                                            showEdit: false,
                                                          ),
                                                        );
                                                      },
                                                      icon: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 16,
                                                          color: AppColors
                                                              .primaryBlue),
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
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width < 2200
                            ? 2200
                            : MediaQuery.of(context).size.width,
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
                                  // Table Header
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F4F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      children: [
                                        TableWidget(
                                            width: 60,
                                            title: 'No.',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 250,
                                            title: 'Customer Name',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 350,
                                            title: 'Address',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 180,
                                            title: 'Phone',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 150,
                                            title: 'Description',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 140,
                                            title: 'AMC Date',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 140,
                                            title: 'From Date',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 140,
                                            title: 'To Date',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 200,
                                            title: 'Product Name',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 130,
                                            title: 'Amount',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 150,
                                            title: 'Category',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 150,
                                            title: 'Status',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 130,
                                            title: 'Service',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 180,
                                            title: 'View Details',
                                            fontSize: 13,
                                            color: Color(0xFF607185)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Data Rows
                                  Expanded(
                                    child: ListView.builder(
                                      shrinkWrap:
                                          false, // To avoid scrolling issues when inside a parent widget
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount:
                                          reportsProvider.amcReport.length,
                                      itemBuilder: (context, index) {
                                        var task =
                                            reportsProvider.amcReport[index];
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
                                              children: [
                                                SizedBox(
                                                  width: 60,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 12.0,
                                                        horizontal: 16.0),
                                                    child: Text(
                                                        (index + 1).toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        )),
                                                  ),
                                                ),
                                                TableWidget(
                                                  width: 250,
                                                  data: InkWell(
                                                    onTap: () {
                                                      context.push(
                                                          '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFE9EDF1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50),
                                                      ),
                                                      child: Text(
                                                        task.customerName
                                                                    .length >
                                                                30
                                                            ? '${task.customerName.substring(0, 30)}...'
                                                            : task.customerName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                    width: 350,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 4),
                                                    title: task.address1),
                                                TableWidget(
                                                    width: 180,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 4),
                                                    title: task.mobile),
                                                TableWidget(
                                                    width: 150,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 4),
                                                    title: task.description),
                                                TableWidget(
                                                    width: 140,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 4),
                                                    title: task.intervalDate),
                                                TableWidget(
                                                    width: 140,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    title: (task.fromDate
                                                            .toString()
                                                            .isNotEmpty)
                                                        ? task.fromDate
                                                            .toString()
                                                            .toDDMMYYYY()
                                                        : ''),
                                                TableWidget(
                                                    width: 140,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    title: (task.toDate
                                                            .toString()
                                                            .isNotEmpty)
                                                        ? task.toDate
                                                            .toString()
                                                            .toDDMMYYYY()
                                                        : ''),
                                                TableWidget(
                                                    width: 180,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    title: task.productName
                                                        .toString()),
                                                TableWidget(
                                                    width: 130,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    title:
                                                        "₹${double.parse(task.amount).toStringAsFixed(1)}"),
                                                TableWidget(
                                                    width: 150,
                                                    fontSize: 13,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 16,
                                                        horizontal: 8),
                                                    title: task.categoryName
                                                            .isNotEmpty
                                                        ? task.categoryName
                                                        : 'AMC'),
                                                TableWidget(
                                                  width: 150,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 16,
                                                      horizontal: 8),
                                                  data: Container(
                                                    padding: task.amcStatusName
                                                            .isNotEmpty
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 2)
                                                        : const EdgeInsets.all(
                                                            0),
                                                    decoration: BoxDecoration(
                                                      color: StatusUtils
                                                          .getTaskColor(
                                                              task.amcStatusId),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: Colors.black45,
                                                          width: 0.1),
                                                    ),
                                                    child: Text(
                                                      task.displayStatus,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        color: StatusUtils
                                                            .getTaskTextColor(
                                                                task.amcStatusId),
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                    width: 130,
                                                    fontSize: 13,
                                                    title: task.serviceName
                                                        .toString()),
                                                TableWidget(
                                                  width: 180,
                                                  data: CustomOutlinedSvgButton(
                                                    showIcon: false,
                                                    onPressed: () async {
                                                      String customerId = task
                                                          .customerId
                                                          .toString();
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return PeriodicServiceDetailsPage(
                                                              amcReportModeld:
                                                                  task,
                                                              customerId:
                                                                  customerId
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
                                                    backgroundColor:
                                                        Colors.white,
                                                    borderSide: BorderSide(
                                                        color: AppColors
                                                            .primaryBlue),
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
                      ),
                    ),
            ), // end Expanded
          ],
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<AMCReportProvider>(
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
                          reportsProvider.getSearchAmcReport(context);
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
                          reportsProvider.getSearchAmcReport(context);
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
