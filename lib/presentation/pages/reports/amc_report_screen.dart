import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/amc_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/periodic_service_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';


import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';

class AmcReportScreen extends StatefulWidget {
  final bool fromDashBoard;

  const AmcReportScreen({super.key, this.fromDashBoard = false});

  @override
  State<AmcReportScreen> createState() => _AmcReportScreen();
}

class _AmcReportScreen extends State<AmcReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

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
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: AppStyles.isWebScreen(context)
          ? null
          : CustomAppBar(
              title: 'Periodic Service Report',
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchAmcReport(context);
              },
              onSearchTap: () => reportsProvider.toggleFilter(),
              onFilterTap: () => reportsProvider.toggleFilter(),
              searchController: searchController,
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
                        // Header
                        if (widget.fromDashBoard) ...[
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: Color(0xFF152D70),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ] else ...[
                          Builder(
                            builder: (context) => IconButton(
                              onPressed: () {
                                ScaffoldState? parent;
                                context.visitAncestorElements((element) {
                                  if (element is StatefulElement &&
                                      element.state is ScaffoldState) {
                                    ScaffoldState scaffold =
                                        element.state as ScaffoldState;
                                    if (scaffold.hasDrawer) {
                                      parent = scaffold;
                                      return false;
                                    }
                                  }
                                  return true;
                                });
                                parent?.openDrawer();
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondaryBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.sort,
                                  size: 20,
                                  color: AppColors.secondaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        const Text(
                          'Periodic Service',
                          style: TextStyle(
                            fontSize: 24,
                            color: Color(0xFF152D70),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Flexible(child: Container()),
                        Container(
  width: 280,
  height: 38,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: searchController,
    focusNode: searchFocusNodeWeb,
    textAlignVertical: TextAlignVertical.center,
    onTap: () {
      Future.microtask(() {
        if (searchController.text.isNotEmpty &&
            searchController.selection.baseOffset == 0 &&
            searchController.selection.extentOffset == searchController.text.length) {
          searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
        }
      });
    },
    onSubmitted: (query) {
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
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      suffixIcon: GestureDetector(
        onTap: () {
                              reportsProvider.setTaskSearchCriteria(
                                searchController.text,
                                reportsProvider.fromDateS,
                                reportsProvider.toDateS,
                                reportsProvider.Status,
                                reportsProvider.AssignedTo,
                              );
                              reportsProvider.getSearchAmcReport(context);
                            },
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
),
                        const SizedBox(width: 16),
                        CustomFilterButton(
                          onPressed: () {
                            reportsProvider.toggleFilter();
                          },
                          isFilter: reportsProvider.isFilter,
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
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
                          icon: const Icon(Icons.download, size: 18),
                          label: const Text('Export',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
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
  width: double.infinity,
  height: 38,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: searchController,
    focusNode: searchFocusNodeMobile,
    textAlignVertical: TextAlignVertical.center,
    onTap: () {
      Future.microtask(() {
        if (searchController.text.isNotEmpty &&
            searchController.selection.baseOffset == 0 &&
            searchController.selection.extentOffset == searchController.text.length) {
          searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
        }
      });
    },
    onSubmitted: (query) {
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
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      suffixIcon: GestureDetector(
        onTap: () {
                                  reportsProvider.setTaskSearchCriteria(
                                    searchController.text,
                                    reportsProvider.fromDateS,
                                    reportsProvider.toDateS,
                                    reportsProvider.Status,
                                    reportsProvider.AssignedTo,
                                  );
                                  reportsProvider.getSearchAmcReport(context);
                                },
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CustomFilterButton(
                              onPressed: () {
                                reportsProvider.toggleFilter();
                              },
                              isFilter: reportsProvider.isFilter,
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
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
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
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
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
                      child: Row(
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(4),
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
                          CommonReportDateFilter(
                            fromDate: reportsProvider.fromDate?.toString(),
                            toDate: reportsProvider.toDate?.toString(),
                            formattedFromDate:
                                reportsProvider.formattedFromDate,
                            formattedToDate: reportsProvider.formattedToDate,
                            onTap: () => onClickTopButton(context),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(4),
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
                          //   style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
                            CommonReportResetButton(
                              onReset: () {
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
                                elevation: 0,
                                side: BorderSide(color: AppColors.textRed),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            CustomText('Date Range',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textBlack),
                            const SizedBox(height: 8),
                            CommonReportDateFilter(
                              fromDate: reportsProvider.fromDate?.toString(),
                              toDate: reportsProvider.toDate?.toString(),
                              formattedFromDate:
                                  reportsProvider.formattedFromDate,
                              formattedToDate: reportsProvider.formattedToDate,
                              onTap: () => onClickTopButton(context),
                            ),
                            const SizedBox(height: 24),
                            if (reportsProvider.fromDate != null ||
                                reportsProvider.toDate != null ||
                                (reportsProvider.selectedStatus != null &&
                                    reportsProvider.selectedStatus != 0) ||
                                (reportsProvider.selectedUser != null &&
                                    reportsProvider.selectedUser != 0) ||
                                reportsProvider.Search.isNotEmpty)
                              SizedBox(
                                width: double.infinity,
                                child: CommonReportResetButton(
                                  label: 'Reset All Filters',
                                  onReset: () {
                                    reportsProvider
                                        .selectDateFilterOption(null);
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
                                    elevation: 0,
                                    side: BorderSide(color: AppColors.textRed),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                  ),
                                ),
                              ),
                          ],
                        ),
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
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  // Header Row (Table Column Titles)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF2F5),
                                      borderRadius: BorderRadius.circular(4),
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
                                            flex: 2,
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
                                                  flex: 2,
                                                  data: Tooltip(
                                                    message: task.address1,
                                                    child: Text(
                                                      task.address1,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color:
                                                            Color(0xFF607185),
                                                      ),
                                                    ),
                                                  ),
                                                ),
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
                  : Column(
                      children: [
                        if (!reportsProvider.isFilter &&
                            reportsProvider.amcReport.isNotEmpty)
                          CommonReportSummaryBar(
                            totalLabel: 'Total AMC',
                            totalCount: reportsProvider.amcReport.length,
                            showingLabel: 'Showing',
                            showingCount: reportsProvider.amcReport.length,
                          ),
                        Expanded(
                          child: reportsProvider.amcReport.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.search_off_outlined,
                                          size: 80, color: Colors.grey[300]),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No reports found',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: reportsProvider.amcReport.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final task =
                                        reportsProvider.amcReport[index];
                                    return ReportListItem(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) =>
                                              PeriodicServiceDetailsPage(
                                            customerId:
                                                task.customerId.toString(),
                                            amcReportModeld: task,
                                            showEdit: false,
                                          ),
                                        );
                                      },
                                      title: task.customerName,
                                      subtitle: task.mobile,
                                      description:
                                          '${task.productName} - ${task.description}',
                                      status: task.displayStatus,
                                      statusColor: StatusUtils.getTaskColor(
                                          task.amcStatusId),
                                      bottomLeftIcon:
                                          Icons.calendar_today_outlined,
                                      bottomLeftText: task.intervalDate,
                                      bottomRightText: task.serviceName,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),

            ),
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
              borderRadius: BorderRadius.circular(4),
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
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
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
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
