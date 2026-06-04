import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/inovoice_report_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class InvoiceReportsScreen extends StatefulWidget {
  const InvoiceReportsScreen({super.key});

  @override
  State<InvoiceReportsScreen> createState() => _InvoiceReportsScreen();
}

class _InvoiceReportsScreen extends State<InvoiceReportsScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<InvoiceReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1); // 1 is 'Today' index
      reportsProvider.getSearchTaskReport(context);
      dropDownProvider.getEnquirySource(context);
      dropDownProvider.getEnquiryFor(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<InvoiceReportProvider>(context);

    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: AppStyles.isWebScreen(context)
          ? null
          : CustomAppBar(
              title: 'Invoice Report',
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                    query,
                    reportsProvider.fromDateS,
                    reportsProvider.toDateS,
                    reportsProvider.Status,
                    reportsProvider.AssignedTo,
                    reportsProvider.enquiryFor,
                    reportsProvider.enquirySource);
                reportsProvider.getSearchTaskReport(context);
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
                        const Text(
                          'Invoice Report',
                          style: TextStyle(
                            fontSize: 24,
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
                                  reportsProvider.enquiryFor,
                                  reportsProvider.enquirySource);
                              reportsProvider.getSearchTaskReport(context);
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
                                  reportsProvider.enquiryFor,
                                  reportsProvider.enquirySource);
                              reportsProvider.getSearchTaskReport(context);
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
                        const SizedBox(width: 8),
                        CustomElevatedButton(
                          radius: 4,
                          onPressed: () {
                            exportToExcel(
                              headers: [
                                'Customer Name',
                                'Mobile',
                                'Address',
                                'Invoice No',
                                'Invoice Date',
                                'Invoice Amount',
                                'Receipt Amount',
                                'Balance Amount',
                                'Registered Date'
                              ],
                              data: reportsProvider.taskReport.map((task) {
                                return {
                                  'Customer Name': task.customerName,
                                  'Mobile': task.contactNumber,
                                  'Address': task.address1,
                                  'Invoice No': task.invoiceNo,
                                  'Invoice Date': task.invoiceDate.isNotEmpty
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(task.invoiceDate))
                                      : '',
                                  'Invoice Amount': task.invoiceAmount,
                                  'Receipt Amount': task.recieptAmount,
                                  'Balance Amount': task.balanceAmount,
                                  'Registered Date': task
                                          .registeredDate.isNotEmpty
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(task.registeredDate))
                                      : '',
                                };
                              }).toList(),
                              fileName: 'Invoice_Report',
                            );
                          },
                          buttonText: 'Export to Excel',
                          textColor: AppColors.whiteColor,
                          borderColor: const Color(0xFFEBB12B),
                          backgroundColor: const Color(0xFFEBB12B),
                        ),
                      ],
                    ),
                  )
                //mobile
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
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
                                      reportsProvider.enquiryFor,
                                      reportsProvider.enquirySource);
                                  reportsProvider.getSearchTaskReport(context);
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
                                      reportsProvider.enquiryFor,
                                      reportsProvider.enquirySource);
                                  reportsProvider.getSearchTaskReport(context);
                                },
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
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
                                        'Mobile',
                                        'Address',
                                        'Invoice No',
                                        'Invoice Date',
                                        'Invoice Amount',
                                        'Receipt Amount',
                                        'Balance Amount',
                                        'Registered Date',
                                      ],
                                      data: reportsProvider.taskReport
                                          .map((task) {
                                        return {
                                          'Customer Name': task.customerName,
                                          'Mobile': task.contactNumber,
                                          'Address': task.address1,
                                          'Invoice No': task.invoiceNo,
                                          'Invoice Date':
                                              task.invoiceDate.isNotEmpty
                                                  ? DateFormat('dd MMM yyyy')
                                                      .format(DateTime.parse(
                                                          task.invoiceDate))
                                                  : '',
                                          'Invoice Amount':
                                              task.invoiceAmount.toString(),
                                          'Receipt Amount':
                                              task.recieptAmount.toString(),
                                          'Balance Amount':
                                              task.balanceAmount.toString(),
                                          'Registered Date':
                                              task.registeredDate.isNotEmpty
                                                  ? DateFormat('dd MMM yyyy')
                                                      .format(DateTime.parse(
                                                          task.registeredDate))
                                                  : '',
                                        };
                                      }).toList(),
                                      fileName: 'Invoice_Report',
                                    );
                                  },
                                  icon: const Icon(Icons.download, size: 18),
                                  label: const Text('Export',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                              ],
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
                      child: Wrap(
                        spacing: 10, // horizontal spacing between items
                        runSpacing: 10, // vertical spacing between rows
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(4),
                          //     border: Border.all(
                          //         color: reportsProvider.selectedStatus != null &&
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
                          //                 .map((status) => DropdownMenuItem<int>(
                          //                       value: status.amcStatusId,
                          //                       child: Text(
                          //                         status.amcStatusName ?? '',
                          //                         style:
                          //                             const TextStyle(fontSize: 14),
                          //                       ),
                          //                     ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
                          //           String status =
                          //               reportsProvider.selectedStatus.toString();
                          //           String assignedTo =
                          //               reportsProvider.selectedUser.toString();
                          //           String fromDate =
                          //               reportsProvider.formattedFromDate;
                          //           String toDate = reportsProvider.formattedToDate;
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //               reportsProvider.Search,
                          //               fromDate,
                          //               toDate,
                          //               status,
                          //               assignedTo);
                          //           reportsProvider.getSearchTaskReport(context);
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
                          CommonReportDateFilter(
                            fromDate: reportsProvider.fromDate?.toString(),
                            toDate: reportsProvider.toDate?.toString(),
                            formattedFromDate:
                                reportsProvider.formattedFromDate,
                            formattedToDate: reportsProvider.formattedToDate,
                            onTap: () => onClickTopButton(context),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: reportsProvider.fromDate != null ||
                                          reportsProvider.toDate != null
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Make Row take minimum required width
                              children: [
                                const Text("Show Outstanding"),
                                const SizedBox(
                                  width: 10,
                                ),
                                Checkbox(
                                  value: reportsProvider.isChecked,
                                  onChanged: (value) {
                                    reportsProvider.toggleCheckbox();
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                  activeColor: AppColors.primaryBlue,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: dropDownProvider
                                                  .selectedEnquirySourceId !=
                                              null &&
                                          dropDownProvider
                                                  .selectedEnquirySourceId !=
                                              0
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Enquiry Source: '),
                                DropdownButton<int>(
                                  value:
                                      dropDownProvider.selectedEnquirySourceId,
                                  hint: const Text('All'),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text(
                                            'All',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ] +
                                      dropDownProvider.enquiryData
                                          .map((source) =>
                                              DropdownMenuItem<int>(
                                                value: source.enquirySourceId,
                                                child: ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxWidth: 150),
                                                  child: Text(
                                                    source.enquirySourceName ??
                                                        '',
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ),
                                              ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      dropDownProvider
                                          .setSelectedEnquirySourceId(newValue);
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
                                        assignedTo,
                                        reportsProvider.enquiryFor,
                                        dropDownProvider.selectedEnquirySourceId
                                            .toString());
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: leadProvider.selectedEnquiryFor !=
                                              null &&
                                          leadProvider.selectedEnquiryFor != 0
                                      ? AppColors.primaryBlue
                                      : AppColors.primaryBlue),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Make Row take minimum required width
                              children: [
                                const Text('Enquiry For: '),
                                DropdownButton<int>(
                                  value: leadProvider.selectedEnquiryFor,
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
                                      dropDownProvider.enquiryForList
                                          .map((user) => DropdownMenuItem<int>(
                                                value: user.enquiryForId,
                                                child: Text(
                                                  user.enquiryForName,
                                                  style: const TextStyle(
                                                      fontSize: 14),
                                                ),
                                              ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      leadProvider
                                          .setEnquiryForFilter(newValue);
                                      final selectedEnquiryFor =
                                          dropDownProvider.enquiryForList
                                              .firstWhere(
                                                  (task) =>
                                                      task.enquiryForId ==
                                                      newValue);
                                      dropDownProvider.updateEnquiryForName(
                                          newValue,
                                          selectedEnquiryFor.enquiryForName);
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
                                        assignedTo,
                                        dropDownProvider.selectedEnquiryForId
                                            .toString(),
                                        reportsProvider.enquirySource
                                            .toString());
                                    reportsProvider
                                        .getSearchTaskReport(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 18,
                                ),
                              ],
                            ),
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
                          //                         constraints:
                          //                             BoxConstraints(maxWidth: 150),
                          //                         child: Text(
                          //                           status.userDetailsName ?? '',
                          //                           overflow: TextOverflow
                          //                               .ellipsis, // Adds ellipsis when the text is too long
                          //                           style:
                          //                               const TextStyle(fontSize: 14),
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
                          //           String toDate = reportsProvider.formattedToDate;
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //             reportsProvider.Search,
                          //             fromDate,
                          //             toDate,
                          //             status,
                          //             assignedTo,
                          //           );
                          //           reportsProvider.getSearchTaskReport(context);
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
                              reportsProvider.Search.isNotEmpty ||
                              (dropDownProvider.selectedEnquirySourceId !=
                                      null &&
                                  dropDownProvider.selectedEnquirySourceId !=
                                      0) ||
                              (dropDownProvider.selectedEnquiryForId != null &&
                                  dropDownProvider.selectedEnquirySourceId !=
                                      0))
                            CommonReportResetButton(
                              onReset: () {
                                reportsProvider.selectDateFilterOption(null);
                                reportsProvider.removeStatus();
                                searchController.clear();
                                dropDownProvider.setSelectedEnquirySourceId(0);
                                leadProvider.setEnquiryForFilter(0);
                                reportsProvider.setTaskSearchCriteria(
                                    '', '', '', '', '', '', '');
                                reportsProvider.getSearchTaskReport(context);
                              },
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
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 10,
                        children: [
                          // Container(
                          //   padding: const EdgeInsets.symmetric(horizontal: 20),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     borderRadius: BorderRadius.circular(4),
                          //     border: Border.all(
                          //         color: reportsProvider.selectedStatus != null &&
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
                          //                 .map((status) => DropdownMenuItem<int>(
                          //                       value: status.amcStatusId,
                          //                       child: Text(
                          //                         status.amcStatusName ?? '',
                          //                         style:
                          //                             const TextStyle(fontSize: 14),
                          //                       ),
                          //                     ))
                          //                 .toList(),
                          //         onChanged: (int? newValue) {
                          //           if (newValue != null) {
                          //             reportsProvider.setStatus(
                          //                 newValue); // Update the status in the provider
                          //           }
                          //           String status =
                          //               reportsProvider.selectedStatus.toString();
                          //           String assignedTo =
                          //               reportsProvider.selectedUser.toString();
                          //           String fromDate =
                          //               reportsProvider.formattedFromDate;
                          //           String toDate = reportsProvider.formattedToDate;
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //               reportsProvider.Search,
                          //               fromDate,
                          //               toDate,
                          //               status,
                          //               assignedTo);
                          //           reportsProvider.getSearchTaskReport(context);
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
                          CommonReportDateFilter(
                            fromDate: reportsProvider.fromDate?.toString(),
                            toDate: reportsProvider.toDate?.toString(),
                            formattedFromDate:
                                reportsProvider.formattedFromDate,
                            formattedToDate: reportsProvider.formattedToDate,
                            onTap: () => onClickTopButton(context),
                          ),
                          // const SizedBox(
                          //   width: 10,
                          // ),
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
                          //                         constraints:
                          //                             BoxConstraints(maxWidth: 150),
                          //                         child: Text(
                          //                           status.userDetailsName ?? '',
                          //                           overflow: TextOverflow
                          //                               .ellipsis, // Adds ellipsis when the text is too long
                          //                           style:
                          //                               const TextStyle(fontSize: 14),
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
                          //           String toDate = reportsProvider.formattedToDate;
                          //           print(
                          //               'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          //           reportsProvider.setTaskSearchCriteria(
                          //             reportsProvider.Search,
                          //             fromDate,
                          //             toDate,
                          //             status,
                          //             assignedTo,
                          //           );
                          //           reportsProvider.getSearchTaskReport(context);
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
                                dropDownProvider.setSelectedEnquirySourceId(0);
                                leadProvider.setEnquiryForFilter(0);
                                reportsProvider.setTaskSearchCriteria(
                                    '', '', '', '', '', '', '');
                                reportsProvider.getSearchTaskReport(context);
                              },
                            ),
                        ],
                      ),
                    ),
            if (reportsProvider.taskReport.isEmpty)
              Expanded(
                child: const CommonEmptyState(message: 'No invoice reports found'),
              )
            else ...[
              AppStyles.isWebScreen(context)
                  ? Expanded(
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          title: 'Invoice No',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Invoice Date',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Invoice Amount',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Receipt Amount',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Balance Amount',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Registered Date',
                                          color: Color(0xFF607185)),
                                    ],
                                  ),
                                ),
                                // Data Rows
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        reportsProvider.taskReport.length,
                                    itemBuilder: (context, index) {
                                      var invoice =
                                          reportsProvider.taskReport[index];
                                      return GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF6F7F9),
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                                  child: Text(
                                                      (index + 1).toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                data: InkWell(
                                                  onTap: () {
                                                    context.push(
                                                        '${CustomerDetailsScreen.route}${invoice.customerId.toString()}/${'true'}');
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
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1700
                                                            ? Row(
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
                                                                      width: 8),
                                                                  Text(
                                                                    invoice.customerName.length >
                                                                            20
                                                                        ? '${invoice.customerName.substring(0, 20)}...'
                                                                        : invoice
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
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  const Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: 12,
                                                                    color: Color(
                                                                        0xFF152D70),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                invoice
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
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title: invoice.contactNumber),
                                              TableWidget(
                                                flex: 2,
                                                data: Tooltip(
                                                  message: invoice.address1,
                                                  child: Text(
                                                    invoice.address1,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title: invoice.invoiceNo
                                                      .toString()),
                                              TableWidget(
                                                flex: 1,
                                                title: (invoice.invoiceDate
                                                            .toString()
                                                            .isNotEmpty &&
                                                        invoice.invoiceDate
                                                                .toString() !=
                                                            'null')
                                                    ? DateFormat('dd MMM yyyy')
                                                        .format(DateTime.parse(
                                                            invoice.invoiceDate
                                                                .toString()))
                                                    : '',
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title: invoice.invoiceAmount
                                                      .toString()),
                                              TableWidget(
                                                  flex: 1,
                                                  title: invoice.recieptAmount
                                                      .toString()),
                                              TableWidget(
                                                  flex: 1,
                                                  title: invoice.balanceAmount
                                                      .toString()),
                                              TableWidget(
                                                  flex: 1,
                                                  title: (invoice.registeredDate
                                                          .toString()
                                                          .isNotEmpty)
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(invoice
                                                                  .registeredDate
                                                                  .toString()))
                                                      : ''),
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
                                Expanded(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount:
                                        reportsProvider.taskReport.length,
                                    itemBuilder: (context, index) {
                                      var invoice =
                                          reportsProvider.taskReport[index];
                                      return GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF6F7F9),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Wrap(
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            runSpacing: 10,
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
                                                  child: Text(
                                                      (index + 1).toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                              ),
                                              TableWidget(
                                                width: 150,
                                                data: InkWell(
                                                  onTap: () {
                                                    context.push(
                                                        '${CustomerDetailsScreen.route}${invoice.customerId.toString()}/${'true'}');
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
                                                          BorderRadius.circular(
                                                              50),
                                                    ),
                                                    child:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                1700
                                                            ? Row(
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
                                                                      width: 8),
                                                                  Text(
                                                                    invoice.customerName.length >
                                                                            20
                                                                        ? '${invoice.customerName.substring(0, 20)}...'
                                                                        : invoice
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
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 8),
                                                                  const Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: 12,
                                                                    color: Color(
                                                                        0xFF152D70),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                invoice
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
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  width: 150,
                                                  title: invoice.invoiceNo
                                                      .toString()),
                                              TableWidget(
                                                width: 150,
                                                title: (invoice.invoiceDate
                                                            .toString()
                                                            .isNotEmpty &&
                                                        invoice.invoiceDate
                                                                .toString() !=
                                                            'null')
                                                    ? DateFormat('dd MMM yyyy')
                                                        .format(DateTime.parse(
                                                            invoice.invoiceDate
                                                                .toString()))
                                                    : '',
                                              ),
                                              TableWidget(
                                                  width: 150,
                                                  title: invoice.invoiceAmount
                                                      .toString()),
                                              TableWidget(
                                                  width: 150,
                                                  title: invoice.recieptAmount
                                                      .toString()),
                                              TableWidget(
                                                  width: 150,
                                                  title: invoice.balanceAmount
                                                      .toString()),
                                              TableWidget(
                                                  width: 150,
                                                  title: (invoice.registeredDate
                                                          .toString()
                                                          .isNotEmpty)
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(invoice
                                                                  .registeredDate
                                                                  .toString()))
                                                      : ''),
                                              TableWidget(
                                                  width: 150,
                                                  title: invoice.contactNumber
                                                      .toString()),
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
              AppStyles.isWebScreen(context)
                  ? Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(width: 80, child: Text('')),
                              Expanded(flex: 2, child: Text('')),
                              Expanded(flex: 1, child: Text('')),
                              Expanded(flex: 1, child: Text('')),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 16, left: 16),
                                  child: Text('Total Invoice Amount',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 16, left: 16),
                                  child: Text('Total Receipt Amount',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 10, right: 16, left: 16),
                                  child: Text('Total Balance Amount',
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF607185))),
                                ),
                              ),
                              Expanded(flex: 1, child: Text('')),
                              Expanded(flex: 1, child: Text('')),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: 80, child: Text('')),
                              const TableWidget(
                                  flex: 2, title: '', color: Color(0xFF607185)),
                              const TableWidget(
                                  flex: 1, title: '', color: Color(0xFF607185)),
                              const TableWidget(
                                  flex: 1, title: '', color: Color(0xFF607185)),
                              TableWidget(
                                  flex: 1,
                                  title: 'Rs ${reportsProvider.invoiceTotal}',
                                  color: Colors.black),
                              TableWidget(
                                  flex: 1,
                                  title: 'Rs ${reportsProvider.recieptTotal}',
                                  color: Colors.black),
                              TableWidget(
                                  flex: 1,
                                  title: 'Rs ${reportsProvider.balanceTotal}',
                                  color: Colors.black),
                              const TableWidget(
                                  flex: 1, title: '', color: Color(0xFF607185)),
                              const TableWidget(
                                  flex: 1, title: '', color: Color(0xFF607185)),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF2F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total Invoice Amount: Rs ${reportsProvider.invoiceTotal}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF607185),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Receipt Amount: Rs ${reportsProvider.recieptTotal}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF607185),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total Balance Amount: Rs ${reportsProvider.balanceTotal}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF607185),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
            ]
          ],
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<InvoiceReportProvider>(
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
                              assignedTo,
                              reportsProvider.enquiryFor,
                              reportsProvider.enquirySource);
                          reportsProvider.getSearchTaskReport(context);
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
                              reportsProvider.enquiryFor,
                              reportsProvider.enquirySource);
                          reportsProvider.getSearchTaskReport(context);
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
