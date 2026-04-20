import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/customer/conversion_details_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/conversion_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';

class ConversionReportPage extends StatefulWidget {
  final bool fromDashBoard;

  const ConversionReportPage({super.key, this.fromDashBoard = false});

  @override
  State<ConversionReportPage> createState() => _ConversionReportPage();
}

class _ConversionReportPage extends State<ConversionReportPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<ConversionReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchConversionReport(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getEnquiryFor(context);
      provider.getAllFollowUpStatus(context, "0");
      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<ConversionReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: const Text(
                'Conversion Report',
                style: TextStyle(
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
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: Color(0xFF152D70),
                            ),
                          ),
                        if (widget.fromDashBoard &&
                            AppStyles.isWebScreen(context))
                          SizedBox(
                            width: 8,
                          ),
                        if (AppStyles.isWebScreen(context))
                          const Text(
                            'Conversion Report',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        Flexible(child: Container()),
                        Container(
                          width: MediaQuery.of(context).size.width / 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextField(
                            controller: searchController,
                            textAlignVertical: TextAlignVertical.center,
                            onSubmitted: (query) {
                              reportsProvider.setTaskSearchCriteria(
                                query,
                                reportsProvider.fromDateS,
                                reportsProvider.toDateS,
                                reportsProvider.Status,
                                reportsProvider.AssignedTo,
                              );
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                            decoration: InputDecoration(
                              hintText: 'Search here....',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                color: Colors.grey[400],
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            reportsProvider.toggleFilter();
                          },
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: Text(MediaQuery.of(context).size.width > 860
                              ? 'Filter'
                              : ''),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: reportsProvider.isFilter
                                ? Colors.white
                                : AppColors.primaryBlue,
                            backgroundColor: reportsProvider.isFilter
                                ? AppColors.primaryBlue
                                : Colors.white,
                            elevation: 0,
                            side: BorderSide(color: AppColors.primaryBlue),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            exportToExcel(
                              headers: [
                                'No.',
                                'Cus. ID',
                                'Lead Name',
                                'Mobile No',
                                'Address',
                                'Enquiry For',
                                'Enquiry Source',
                                'By User',
                                'Assigned Staff',
                                'Status',
                                'Created Date',
                                'Next Follow-up',
                                'Remark'
                              ],
                              data: reportsProvider.conversionReport
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final index = entry.key;
                                final task = entry.value;
                                return {
                                  'No.': (index + 1).toString(),
                                  'Cus. ID': task.customerId.toString(),
                                  'Lead Name': task.customerName,
                                  'Mobile No': task.mobile,
                                  'Address':
                                      '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                                  'Enquiry For': task.enquiryForName.toString(),
                                  'Enquiry Source': task.enquirySourceName,
                                  'By User': task.byUserName,
                                  'Assigned Staff': task.toUserName,
                                  'Status': task.statusName,
                                  'Created Date':
                                      _formatDateSafely(task.creationDate),
                                  'Next Follow-up':
                                      _formatDateSafely(task.nextFollowUpDate),
                                  'Remark': task.remark,
                                };
                              }).toList(),
                              fileName: 'Conversion_Report',
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
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            if (AppStyles.isWebScreen(context))
                              const Text(
                                'Conversion Report',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? MediaQuery.of(context).size.width / 4
                                  : MediaQuery.of(context).size.width * 0.9,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: searchController,
                                textAlignVertical: TextAlignVertical.center,
                                onSubmitted: (query) {
                                  reportsProvider.setTaskSearchCriteria(
                                    query,
                                    reportsProvider.fromDateS,
                                    reportsProvider.toDateS,
                                    reportsProvider.Status,
                                    reportsProvider.AssignedTo,
                                  );
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search here....',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  suffixIcon: reportsProvider.Search.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
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
                                                .getSearchConversionReport(
                                                    context);
                                          },
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                reportsProvider.toggleFilter();
                              },
                              icon: const Icon(Icons.filter_list, size: 18),
                              label: Text(
                                  MediaQuery.of(context).size.width > 860
                                      ? 'Filter'
                                      : ''),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: reportsProvider.isFilter
                                    ? Colors.white
                                    : AppColors.primaryBlue,
                                backgroundColor: reportsProvider.isFilter
                                    ? AppColors.primaryBlue
                                    : Colors.white,
                                elevation: 0,
                                side: BorderSide(color: AppColors.primaryBlue),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                exportToExcel(
                                  headers: [
                                    'Customer Name',
                                    'Conversion By',
                                    'Creation Date',
                                    'Conversion Date',
                                    'Enquiry For',
                                    'Status',
                                  ],
                                  data: reportsProvider.conversionReport
                                      .map((task) {
                                    return {
                                      'ID': task.customerId,
                                      'Customer Name': task.customerName,
                                      'Contact No': task.mobile,
                                      'Address':
                                          '${task.address1}${task.address2.isNotEmpty ? ', ${task.address2}' : ''}${task.address3.isNotEmpty ? ', ${task.address3}' : ''}${task.address4.isNotEmpty ? ', ${task.address4}' : ''}',
                                      'Enquiry For': task.enquiryForName,
                                      'Enquiry Source': task.enquirySourceName,
                                      'By User': task.byUserName,
                                      'Assigned Staff': task.toUserName,
                                      'Status': task.statusName,
                                      'Created Date': DateFormat('dd MMM yyyy')
                                          .format(task.creationDate),
                                      'Next FollowUp': DateFormat('dd MMM yyyy')
                                          .format(task.nextFollowUpDate),
                                      'Remark': task.remark,
                                    };
                                  }).toList(),
                                  fileName: 'Conversion_Report',
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
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
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
                                const Text('Enquiry For: '),
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
                                      provider.enquiryForList
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.enquiryForId,
                                                    child: Text(
                                                      status.enquiryForName,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ))
                                          .toList(),
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
                                        .getSearchConversionReport(context);
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider.selectedUser != null &&
                                          reportsProvider.selectedUser != 0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Text('Conversion By: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedUser,
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
                                      provider.searchUserDetails
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.userDetailsId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.userDetailsName,
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setUserFilterStatus(
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
                                      assignedTo,
                                    );
                                    reportsProvider
                                        .getSearchConversionReport(context);
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
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: reportsProvider
                                                  .selectedFollowUpStatusId !=
                                              null &&
                                          reportsProvider
                                                  .selectedFollowUpStatusId !=
                                              0
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Text('Status: '),
                                DropdownButton<int>(
                                  value:
                                      reportsProvider.selectedFollowUpStatusId,
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
                                      provider.followUpStatusList
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.statusId,
                                                    child: ConstrainedBox(
                                                      constraints:
                                                          const BoxConstraints(
                                                              maxWidth: 150),
                                                      child: Text(
                                                        status.statusName ?? '',
                                                        overflow: TextOverflow
                                                            .ellipsis, // Adds ellipsis when the text is too long
                                                        style: const TextStyle(
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    reportsProvider.selectedFollowUpStatusId =
                                        newValue ?? 0;
                                    reportsProvider
                                        .getSearchConversionReport(context);
                                    setState(() {});
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          // ElevatedButton(
                          //   onPressed: () {
                          //     // // Apply the selected filters (You can use values from the provider)
                          //     // String status =
                          //     //     reportsProvider.selectedStatus.toString();
                          //     // String fromDate = reportsProvider.formattedFromDate;
                          //     // String toDate = reportsProvider.formattedToDate;
                          //     // print(
                          //     //     'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //     // reportsProvider.getSearchServiceReport(
                          //     //     '', fromDate, toDate, status, context);
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
                              (reportsProvider.selectedFollowUpStatusId !=
                                      null &&
                                  reportsProvider.selectedFollowUpStatusId !=
                                      0) ||
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
                                reportsProvider
                                    .getSearchConversionReport(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.textRed,
                                elevation: 0,
                                side: BorderSide(color: AppColors.textRed),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
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
                        spacing: 10.0,
                        runSpacing: 10.0,
                        alignment: WrapAlignment.start,
                        children: [
                          // Enquiry For
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: reportsProvider.selectedStatus != null &&
                                        reportsProvider.selectedStatus != 0
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Enquiry For: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedStatus,
                                  hint: const Text('All'),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text('All',
                                              style: TextStyle(fontSize: 14)),
                                        ),
                                      ] +
                                      provider.enquiryForList.map((status) {
                                        return DropdownMenuItem<int>(
                                          value: status.enquiryForId,
                                          child: Text(
                                            status.enquiryForName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider.setStatus(newValue);
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
                                    reportsProvider.setTaskSearchCriteria(
                                        reportsProvider.Search,
                                        fromDate,
                                        toDate,
                                        status,
                                        assignedTo);
                                    reportsProvider
                                        .getSearchConversionReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Conversion Date
                          CommonReportDateFilter(
                            fromDate: reportsProvider.fromDate?.toString(),
                            toDate: reportsProvider.toDate?.toString(),
                            formattedFromDate:
                                reportsProvider.formattedFromDate,
                            formattedToDate: reportsProvider.formattedToDate,
                            onTap: () => onClickTopButton(context),
                          ),

                          // Conversion By
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: reportsProvider.selectedUser != null &&
                                        reportsProvider.selectedUser != 0
                                    ? AppColors.primaryBlue
                                    : AppColors.primaryBlue,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Conversion By: '),
                                DropdownButton<int>(
                                  value: reportsProvider.selectedUser,
                                  hint: const Text('All'),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text('All',
                                              style: TextStyle(fontSize: 14)),
                                        ),
                                      ] +
                                      provider.searchUserDetails.map((status) {
                                        return DropdownMenuItem<int>(
                                          value: status.userDetailsId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              status.userDetailsName,
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      reportsProvider
                                          .setUserFilterStatus(newValue);
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
                                    reportsProvider.setTaskSearchCriteria(
                                        reportsProvider.Search,
                                        fromDate,
                                        toDate,
                                        status,
                                        assignedTo);
                                    reportsProvider
                                        .getSearchConversionReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Status
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    reportsProvider.selectedFollowUpStatusId !=
                                                null &&
                                            reportsProvider
                                                    .selectedFollowUpStatusId !=
                                                0
                                        ? AppColors.primaryBlue
                                        : AppColors.primaryBlue,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Status: '),
                                DropdownButton<int>(
                                  value:
                                      reportsProvider.selectedFollowUpStatusId,
                                  hint: const Text('All'),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text('All',
                                              style: TextStyle(fontSize: 14)),
                                        ),
                                      ] +
                                      provider.followUpStatusList.map((status) {
                                        return DropdownMenuItem<int>(
                                          value: status.statusId,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              status.statusName ?? '',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (int? newValue) {
                                    reportsProvider.selectedFollowUpStatusId =
                                        newValue ?? 0;
                                    reportsProvider
                                        .getSearchConversionReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),

                          // Reset Button
                          if (reportsProvider.fromDate != null ||
                              reportsProvider.toDate != null ||
                              (reportsProvider.selectedStatus != null &&
                                  reportsProvider.selectedStatus != 0) ||
                              (reportsProvider.selectedUser != null &&
                                  reportsProvider.selectedUser != 0) ||
                              (reportsProvider.selectedFollowUpStatusId !=
                                      null &&
                                  reportsProvider.selectedFollowUpStatusId !=
                                      0) ||
                              reportsProvider.Search.isNotEmpty)
                          CommonReportResetButton(
                            onReset: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              searchController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                  '', '', '', '', '');
                              reportsProvider
                                  .getSearchConversionReport(context);
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
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            AppStyles.isWebScreen(context)
                ? Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width < 1700
                            ? 1700
                            : MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0, top: 0.0),
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
                                          width: 50,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12.0),
                                            child: Center(
                                              child: Text('No.',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color:
                                                          Color(0xFF607185))),
                                            ),
                                          ),
                                        ),
                                        TableWidget(
                                            width: 80,
                                            title: 'Cus. ID',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 3,
                                            title: 'Lead Name',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 150,
                                            title: 'Mobile No',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 1,
                                            title: 'Enquiry For',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 1,
                                            title: 'Enquiry Source',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 1,
                                            title: 'By User',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 1,
                                            title: 'Assigned Staff',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 130,
                                            title: 'Status',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 130,
                                            title: 'Created Date',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            width: 140,
                                            title: 'Next Follow-up',
                                            color: Color(0xFF607185)),
                                        TableWidget(
                                            flex: 2,
                                            title: 'Remark',
                                            color: Color(0xFF607185)),
                                        // TableWidget(
                                        //     flex: 1,
                                        //     title: 'View Details',
                                        //     fontSize: 14,
                                        //     color: Color(0xFF607185)),
                                      ],
                                    ),
                                  ),
                                  // Data Rows
                                  Expanded(
                                    child: reportsProvider
                                            .conversionReport.isEmpty
                                        ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.search_off_outlined,
                                                    size: 80,
                                                    color: Colors.grey[300]),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No conversion reports found',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount: reportsProvider
                                                .conversionReport.length,
                                            itemBuilder: (context, index) {
                                              var conversion = reportsProvider
                                                  .conversionReport[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  // context.go(
                                                  //     '${CustomerDetailsScreen.route}${Service.customerId.toString()}');
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: index % 2 == 0
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFFF6F7F9),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
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
                                                        width: 50,
                                                        child: Center(
                                                          child: Text(
                                                              (index + 1)
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              )),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                          width: 80,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .customerId
                                                              .toString()),
                                                      TableWidget(
                                                        flex: 3,
                                                        data: InkWell(
                                                          onTap: () {
                                                            context.push(
                                                                '${CustomerDetailsScreen.route}${conversion.customerId.toString()}/${'true'}');
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFE9EDF1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(
                                                                  Icons
                                                                      .account_circle,
                                                                  size: 15,
                                                                  color: Color(
                                                                      0xFF152D70),
                                                                ),
                                                                const SizedBox(
                                                                    width: 6),
                                                                Flexible(
                                                                  child: Text(
                                                                    conversion
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
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    width: 4),
                                                                const Icon(
                                                                  Icons
                                                                      .arrow_forward_ios,
                                                                  size: 10,
                                                                  color: Color(
                                                                      0xFF152D70),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                          width: 150,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .mobile),
                                                      TableWidget(
                                                          flex: 1,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .enquiryForName
                                                              .toString()),
                                                      TableWidget(
                                                          flex: 1,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .enquirySourceName),
                                                      TableWidget(
                                                          flex: 1,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .byUserName),
                                                      TableWidget(
                                                          flex: 1,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .toUserName),
                                                      TableWidget(
                                                          width: 130,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .statusName),
                                                      TableWidget(
                                                          width: 130,
                                                          fontSize: 12,
                                                          title: _formatDateSafely(
                                                              conversion
                                                                  .creationDate)),
                                                      TableWidget(
                                                          width: 140,
                                                          fontSize: 12,
                                                          title: _formatDateSafely(
                                                              conversion
                                                                  .nextFollowUpDate)),
                                                      TableWidget(
                                                          flex: 2,
                                                          fontSize: 12,
                                                          title: conversion
                                                              .remark),
                                                      // Expanded(
                                                      //   child: CustomOutlinedSvgButton(
                                                      //     showIcon: false,
                                                      //     onPressed: () async {
                                                      //       String serviceId = conversion
                                                      //           .enquiryForName
                                                      //           .toString();
                                                      //       String customerId = conversion
                                                      //           .customerId
                                                      //           .toString();
                                                      //       print(
                                                      //           'Service ID: $serviceId');
                                                      //       // customerDetailsProvider
                                                      //       //     .getServiceDetails(
                                                      //       //         serviceId.toString(),
                                                      //       //         context);

                                                      //       showDialog(
                                                      //         context: context,
                                                      //         builder:
                                                      //             (BuildContext context) {
                                                      //           return ConversionDetailsPage(
                                                      //               conversionModel:
                                                      //                   conversion,
                                                      //               customerId: customerId
                                                      //                   .toString(),
                                                      //               showEdit: false);
                                                      //         },
                                                      //       );
                                                      //     },
                                                      //     svgPath:
                                                      //         'assets/images/Print.svg',
                                                      //     label: 'View Details',
                                                      //     breakpoint: 860,
                                                      //     foregroundColor:
                                                      //         AppColors.primaryBlue,
                                                      //     backgroundColor: Colors.white,
                                                      //     borderSide: BorderSide(
                                                      //         color:
                                                      //             AppColors.primaryBlue),
                                                      //   ),
                                                      // ),
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
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 8.0),
                      child: Consumer<ConversionReportProvider>(
                        builder: (context, reportsProvider, child) {
                          if (reportsProvider.conversionReport.isEmpty) {
                            return Center(
                              child: Column(
                                children: [
                                  const SizedBox(height: 80),
                                  Text(
                                    'No conversion reports found',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'There are no conversions to display',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: reportsProvider.conversionReport.length,
                            itemBuilder: (context, index) {
                              final conversion =
                                  reportsProvider.conversionReport[index];

                              return InkWell(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ConversionDetailsPage(
                                        conversionModel: conversion,
                                        customerId:
                                            conversion.customerId.toString(),
                                        showEdit: false,
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.only(
                                      bottom: 10, right: 5, left: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 3,
                                            height: 32,
                                            color: AppColors.parseColor(
                                                    conversion.colorCode)
                                                .withOpacity(0.4),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  conversion.customerName,
                                                  style: AppStyles
                                                      .getBoldTextStyle(
                                                          fontSize: 14),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  conversion.mobile,
                                                  style: AppStyles
                                                      .getRegularTextStyle(
                                                    fontSize: 12,
                                                    fontColor:
                                                        Color(0xff7D8B9B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.parseColor(
                                                      conversion.colorCode)
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              conversion.statusName,
                                              style: AppStyles.getBoldTextStyle(
                                                fontSize: 12,
                                                fontColor: AppColors.parseColor(
                                                    conversion.colorCode),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        conversion.address1.isEmpty
                                            ? 'No address provided'
                                            : conversion.address1,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.getRegularTextStyle(
                                          fontSize: 12,
                                          fontColor: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Conversion by: ${conversion.registerdBy}',
                                              style:
                                                  AppStyles.getRegularTextStyle(
                                                fontSize: 12,
                                                fontColor: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            conversion.creationDate
                                                .toString()
                                                .toDayMonthYearFormat(),
                                            style: AppStyles.getBoldTextStyle(
                                              fontSize: 12,
                                              fontColor: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Color(0xffF6F7F9),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              conversion.enquiryForName,
                                              style: AppStyles.getBoldTextStyle(
                                                  fontSize: 12),
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward_ios,
                                                size: 16),
                                            color: Colors.grey[500],
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                builder: (context) {
                                                  return CustomerDetailPageMobile(
                                                      fromLead: false,
                                                      customerId: conversion
                                                          .customerId);
                                                },
                                              ));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<ConversionReportProvider>(
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
                          reportsProvider.getSearchConversionReport(context);
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
                          reportsProvider.getSearchConversionReport(context);
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

  String _formatDateSafely(DateTime? date) {
    if (date == null) return '';
    try {
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return '';
    }
  }
}
