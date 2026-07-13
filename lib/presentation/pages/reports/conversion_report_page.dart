import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/customer/conversion_details_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/controller/conversion_report_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';

import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/pdf_function.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class ConversionReportPage extends StatefulWidget {
  final bool fromDashBoard;

  const ConversionReportPage({super.key, this.fromDashBoard = false});

  @override
  State<ConversionReportPage> createState() => _ConversionReportPage();
}

class _ConversionReportPage extends State<ConversionReportPage> {
  ScrollController scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();
  TextEditingController leadIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<ConversionReportProvider>(context, listen: false);
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1); // 1 is 'Today' index
      reportsProvider.getSearchConversionReport(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getEnquiryFor(context);
      provider.getEnquirySource(context);
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
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: !AppStyles.isWebScreen(context)
          ? CustomAppBar(
              title: 'Conversion Report',
              onSearchTap: () {
                Provider.of<SidebarProvider>(context, listen: false)
                    .startSearch();
                reportsProvider.toggleFilter();
              },
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                Provider.of<SidebarProvider>(context, listen: false)
                    .stopSearch();
                if (reportsProvider.isFilter) reportsProvider.toggleFilter();
                reportsProvider.setTaskSearchCriteria(
                  '',
                  '',
                  '',
                  '',
                  '',
                );
                reportsProvider.getSearchConversionReport(context);
              },
              onSearch: (query) {
                reportsProvider.setTaskSearchCriteria(
                  query,
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                );
                reportsProvider.getSearchConversionReport(context);
                if (reportsProvider.isFilter) reportsProvider.toggleFilter();
              },
              onExcelTap: () {
                exportToExcel(
                  headers: _exportHeaders,
                  data: _prepareExportData(reportsProvider),
                  fileName: 'Conversion_Report',
                );
              },
              onPdfTap: () {
                exportToPDF(
                  headers: _exportHeaders,
                  data: _prepareExportData(reportsProvider),
                  fileName: 'Conversion_Report',
                );
              },
              showExcel: true,
              showPdf: true,
              searchController: searchController,
            )
          : null,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (WEB ONLY)
            if (AppStyles.isWebScreen(context))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
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
                      const SizedBox(width: 8),
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
                      'Conversion Report',
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
                        border: Border.all(
                            color: const Color(0xFFCBD5E1), width: 1.0),
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
                                searchController.selection.extentOffset ==
                                    searchController.text.length) {
                              searchController.selection =
                                  TextSelection.collapsed(
                                      offset: searchController.text.length);
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
                          reportsProvider.getSearchConversionReport(context);
                          if (reportsProvider.isFilter) {
                            reportsProvider.toggleFilter();
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search here....',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF94A3B8),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              reportsProvider.setTaskSearchCriteria(
                                searchController.text,
                                reportsProvider.fromDateS,
                                reportsProvider.toDateS,
                                reportsProvider.Status,
                                reportsProvider.AssignedTo,
                              );
                              reportsProvider
                                  .getSearchConversionReport(context);
                              if (reportsProvider.isFilter) {
                                reportsProvider.toggleFilter();
                              }
                            },
                            child: const Icon(Icons.search,
                                color: Color(0xFF64748B), size: 18),
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
                    CommonReportExportButton(
                      onPressed: () {
                        exportToExcel(
                          headers: _exportHeaders,
                          data: _prepareExportData(reportsProvider),
                          fileName: 'Conversion_Report',
                        );
                      },
                      label: 'Export to Excel',
                    ),
                    const SizedBox(width: 8),
                    CommonReportExportButton(
                      onPressed: () {
                        exportToPDF(
                          headers: _exportHeaders,
                          data: _prepareExportData(reportsProvider),
                          fileName: 'Conversion_Report',
                        );
                      },
                      label: 'Export to PDF',
                    ),
                  ],
                ),
              ),

            // Expanded Filter Bar (Web Only)
            if (reportsProvider.isFilter && AppStyles.isWebScreen(context))
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Enquiry For
                        Container(
                          height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (reportsProvider.selectedStatus != null &&
                                      reportsProvider.selectedStatus != 0)
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Enquiry For: ',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              DropdownButton<int>(
                                value: reportsProvider.selectedStatus ?? 0,
                                hint: const Text('All',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                items: [
                                      const DropdownMenuItem<int>(
                                        value: 0,
                                        child: Text('All',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ] +
                                    provider.enquiryForList
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.enquiryForId,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: Text(
                                                  status.enquiryForName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    reportsProvider.setStatus(newValue);
                                  }

                                  String status = (newValue ?? 0).toString();
                                  String assignedTo =
                                      (reportsProvider.selectedToUserId ?? 0)
                                          .toString();
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
                                  );
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                                underline: Container(),
                                isDense: true,
                                iconSize: 18,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Enquiry Source
                        Container(
                          height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: (reportsProvider.selectedEnquirySourceId !=
                                          null &&
                                      reportsProvider.selectedEnquirySourceId !=
                                          0)
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Enquiry Source: ',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              DropdownButton<int>(
                                value:
                                    reportsProvider.selectedEnquirySourceId ??
                                        0,
                                hint: const Text('All',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                items: [
                                      const DropdownMenuItem<int>(
                                        value: 0,
                                        child: Text('All',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ] +
                                    provider.enquiryData
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.enquirySourceId,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: Text(
                                                  status.enquirySourceName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    reportsProvider.setEnquirySource(newValue);
                                  }

                                  String status =
                                      (reportsProvider.selectedStatus ?? 0)
                                          .toString();
                                  String assignedTo =
                                      (reportsProvider.selectedToUserId ?? 0)
                                          .toString();
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
                                  );
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                                underline: Container(),
                                isDense: true,
                                iconSize: 18,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Date Filter
                        CommonReportDateFilter(
                          fromDate: reportsProvider.fromDate?.toString(),
                          toDate: reportsProvider.toDate?.toString(),
                          formattedFromDate: reportsProvider.formattedFromDate,
                          formattedToDate: reportsProvider.formattedToDate,
                          onTap: () => onClickTopButton(context),
                        ),

                        // By User
                        Container(
                          height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  (reportsProvider.selectedByUserId != null &&
                                          reportsProvider.selectedByUserId != 0)
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('By User: ',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              DropdownButton<int>(
                                value: reportsProvider.selectedByUserId ?? 0,
                                hint: const Text('All',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                items: [
                                      const DropdownMenuItem<int>(
                                        value: 0,
                                        child: Text('All',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ] +
                                    provider.searchUserDetails
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.userDetailsId,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: Text(
                                                  status.userDetailsName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    reportsProvider
                                        .setByUserFilterStatus(newValue);
                                  }

                                  String status =
                                      (reportsProvider.selectedStatus ?? 0)
                                          .toString();
                                  String assignedTo =
                                      (reportsProvider.selectedToUserId ?? 0)
                                          .toString();
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
                                  );
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                                underline: Container(),
                                isDense: true,
                                iconSize: 18,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Assigned Staff
                        Container(
                          height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  (reportsProvider.selectedToUserId != null &&
                                          reportsProvider.selectedToUserId != 0)
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Assigned Staff: ',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              DropdownButton<int>(
                                value: reportsProvider.selectedToUserId ?? 0,
                                hint: const Text('All',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                items: [
                                      const DropdownMenuItem<int>(
                                        value: 0,
                                        child: Text('All',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ] +
                                    provider.searchUserDetails
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.userDetailsId,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: Text(
                                                  status.userDetailsName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                onChanged: (int? newValue) {
                                  if (newValue != null) {
                                    reportsProvider
                                        .setToUserFilterStatus(newValue);
                                  }

                                  String status =
                                      (reportsProvider.selectedStatus ?? 0)
                                          .toString();
                                  String assignedTo =
                                      (newValue ?? 0).toString();
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
                                  );
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                                underline: Container(),
                                isDense: true,
                                iconSize: 18,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Status
                        Container(
                          height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color:
                                  (reportsProvider.selectedFollowUpStatusId !=
                                              null &&
                                          reportsProvider
                                                  .selectedFollowUpStatusId !=
                                              0)
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Status: ',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 13)),
                              DropdownButton<int>(
                                value:
                                    reportsProvider.selectedFollowUpStatusId ??
                                        0,
                                hint: const Text('All',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                items: [
                                      const DropdownMenuItem<int>(
                                        value: 0,
                                        child: Text('All',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13)),
                                      ),
                                    ] +
                                    provider.followUpStatusList
                                        .map((status) => DropdownMenuItem<int>(
                                              value: status.statusId,
                                              child: ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        maxWidth: 150),
                                                child: Text(
                                                  status.statusName ?? '',
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13),
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
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ],
                          ),
                        ),

                        // Reset All Filters
                        if (reportsProvider.fromDate != null ||
                            reportsProvider.toDate != null ||
                            (reportsProvider.selectedStatus != null &&
                                reportsProvider.selectedStatus != 0) ||
                            (reportsProvider.selectedByUserId != null &&
                                reportsProvider.selectedByUserId != 0) ||
                            (reportsProvider.selectedToUserId != null &&
                                reportsProvider.selectedToUserId != 0) ||
                            (reportsProvider.selectedEnquirySourceId != null &&
                                reportsProvider.selectedEnquirySourceId != 0) ||
                            (reportsProvider.selectedFollowUpStatusId != null &&
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

            // MOBILE FILTER PANEL (Fills body cleanly without cramming)
            if (reportsProvider.isFilter && !AppStyles.isWebScreen(context))
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      CustomText('Lead ID',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      TextField(
                        controller: leadIdController,
                        decoration: InputDecoration(
                          hintText: 'Enter Lead ID',
                          hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: Colors.grey),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(color: AppColors.grey),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSubmitted: (value) {
                          reportsProvider.setLeadId(value);
                          reportsProvider.setTaskSearchCriteria(
                            searchController.text,
                            reportsProvider.fromDateS,
                            reportsProvider.toDateS,
                            reportsProvider.Status,
                            reportsProvider.AssignedTo,
                            leadId: value,
                          );
                          reportsProvider.getSearchConversionReport(context);
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomText('Enquiry For',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.selectedStatus == 0 ||
                                reportsProvider.selectedStatus == null,
                            onTap: () {
                              reportsProvider.setStatus(0);
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                          ),
                          ...provider.enquiryForList
                              .map((e) => FilterChipWidget(
                                    label: e.enquiryForName,
                                    isSelected:
                                        reportsProvider.selectedStatus ==
                                            e.enquiryForId,
                                    onTap: () {
                                      reportsProvider.setStatus(e.enquiryForId);
                                      reportsProvider
                                          .getSearchConversionReport(context);
                                    },
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Enquiry Source',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                reportsProvider.selectedEnquirySourceId == 0 ||
                                    reportsProvider.selectedEnquirySourceId ==
                                        null,
                            onTap: () {
                              reportsProvider.setEnquirySource(0);
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                          ),
                          ...provider.enquiryData.map((e) => FilterChipWidget(
                                label: e.enquirySourceName,
                                isSelected:
                                    reportsProvider.selectedEnquirySourceId ==
                                        e.enquirySourceId,
                                onTap: () {
                                  reportsProvider
                                      .setEnquirySource(e.enquirySourceId);
                                  reportsProvider
                                      .getSearchConversionReport(context);
                                },
                              )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Conversion Date',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      CommonReportDateFilter(
                        fromDate: reportsProvider.fromDate?.toString(),
                        toDate: reportsProvider.toDate?.toString(),
                        formattedFromDate: reportsProvider.formattedFromDate,
                        formattedToDate: reportsProvider.formattedToDate,
                        onTap: () => onClickTopButton(context),
                      ),
                      const SizedBox(height: 16),
                      CustomText('By User',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.selectedByUserId == 0 ||
                                reportsProvider.selectedByUserId == null,
                            onTap: () {
                              reportsProvider.setByUserFilterStatus(0);
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                          ),
                          ...provider.searchUserDetails
                              .map((u) => FilterChipWidget(
                                    label: u.userDetailsName ?? 'Unknown',
                                    isSelected:
                                        reportsProvider.selectedByUserId ==
                                            u.userDetailsId,
                                    onTap: () {
                                      reportsProvider.setByUserFilterStatus(
                                          u.userDetailsId);
                                      reportsProvider
                                          .getSearchConversionReport(context);
                                    },
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Assigned Staff',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected: reportsProvider.selectedToUserId == 0 ||
                                reportsProvider.selectedToUserId == null,
                            onTap: () {
                              reportsProvider.setToUserFilterStatus(0);
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                          ),
                          ...provider.searchUserDetails
                              .map((u) => FilterChipWidget(
                                    label: u.userDetailsName ?? 'Unknown',
                                    isSelected:
                                        reportsProvider.selectedToUserId ==
                                            u.userDetailsId,
                                    onTap: () {
                                      reportsProvider.setToUserFilterStatus(
                                          u.userDetailsId);
                                      reportsProvider
                                          .getSearchConversionReport(context);
                                    },
                                  )),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomText('Status',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          FilterChipWidget(
                            label: 'All',
                            isSelected:
                                reportsProvider.selectedFollowUpStatusId == 0 ||
                                    reportsProvider.selectedFollowUpStatusId ==
                                        null,
                            onTap: () {
                              reportsProvider.selectedFollowUpStatusId = 0;
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                          ),
                          ...provider.followUpStatusList
                              .map((s) => FilterChipWidget(
                                    label: s.statusName ?? 'Unknown',
                                    isSelected: reportsProvider
                                            .selectedFollowUpStatusId ==
                                        s.statusId,
                                    onTap: () {
                                      reportsProvider.selectedFollowUpStatusId =
                                          s.statusId;
                                      reportsProvider
                                          .getSearchConversionReport(context);
                                    },
                                  )),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (reportsProvider.fromDate != null ||
                          reportsProvider.toDate != null ||
                          (reportsProvider.selectedStatus != null &&
                              reportsProvider.selectedStatus != 0) ||
                          (reportsProvider.selectedByUserId != null &&
                              reportsProvider.selectedByUserId != 0) ||
                          (reportsProvider.selectedToUserId != null &&
                              reportsProvider.selectedToUserId != 0) ||
                          (reportsProvider.selectedEnquirySourceId != null &&
                              reportsProvider.selectedEnquirySourceId != 0) ||
                          (reportsProvider.selectedFollowUpStatusId != null &&
                              reportsProvider.selectedFollowUpStatusId != 0) ||
                          reportsProvider.Search.isNotEmpty ||
                          reportsProvider.leadId != '0')
                        SizedBox(
                          width: double.infinity,
                          child: CommonReportResetButton(
                            label: 'Reset All Filters',
                            onReset: () {
                              reportsProvider.selectDateFilterOption(null);
                              reportsProvider.removeStatus();
                              searchController.clear();
                              leadIdController.clear();
                              reportsProvider.setTaskSearchCriteria(
                                  '', '', '', '', '',
                                  leadId: '0');
                              reportsProvider
                                  .getSearchConversionReport(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            // List/Table View (Hidden when filtering in Mobile, displaying nicely when not)
            if (AppStyles.isWebScreen(context) || !reportsProvider.isFilter)
              AppStyles.isWebScreen(context)
                  ? Expanded(
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width < 1700
                                ? 1700
                                : MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  bottom: 16.0,
                                  top: 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                      width: 1.0),
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
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF2F5),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 12.0),
                                                child: Center(
                                                  child: Text('No.',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(
                                                              0xFF607185))),
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
                                                title: 'Conversion Date',
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
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: reportsProvider
                                                .conversionReport.isEmpty
                                            ? const CommonEmptyState(
                                                message:
                                                    'No conversion reports found')
                                            : ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const AlwaysScrollableScrollPhysics(),
                                                itemCount: reportsProvider
                                                    .conversionReport.length,
                                                itemBuilder: (context, index) {
                                                  var conversion =
                                                      reportsProvider
                                                              .conversionReport[
                                                          index];
                                                  return GestureDetector(
                                                    onTap: () {},
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: index % 2 == 0
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFFF6F7F9),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Row(
                                                        children: [
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
                                                                    fontSize:
                                                                        12,
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
                                                                padding: const EdgeInsets
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
                                                                              4),
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
                                                                        width:
                                                                            6),
                                                                    Flexible(
                                                                      child:
                                                                          Text(
                                                                        conversion
                                                                            .customerName,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                        style:
                                                                            const TextStyle(
                                                                          color:
                                                                              Colors.black,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              12,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            4),
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
                                                                      .registeredDate)),
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
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          CommonReportSummaryBar(
                            totalLabel: 'Total Records',
                            totalCount: reportsProvider.conversionReport.length,
                            showingLabel: 'Showing',
                            showingCount:
                                reportsProvider.conversionReport.length,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Consumer<ConversionReportProvider>(
                                builder: (context, reportsProvider, child) {
                                  if (reportsProvider
                                      .conversionReport.isEmpty) {
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

                                  return ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        Divider(
                                            height: 2, color: AppColors.grey),
                                    itemCount:
                                        reportsProvider.conversionReport.length,
                                    itemBuilder: (context, index) {
                                      final item = reportsProvider
                                          .conversionReport[index];

                                      return ReportListItem(
                                        title: item.customerName,
                                        subtitle: '${item.mobile} >',
                                        onSubtitleTap: () {
                                          context.push(
                                              '${CustomerDetailsScreen.route}${item.customerId.toString()}/${'true'}');
                                        },
                                        status: item.statusName,
                                        statusColor: AppColors.parseColor(
                                            item.colorCode),
                                        description: item.remark.isEmpty
                                            ? 'No remark provided'
                                            : item.remark,
                                        bottomLeftIcon: Icons.person_outline,
                                        bottomLeftText: item.registerdBy,
                                        bottomRightText: item.creationDate
                                            .toString()
                                            .toDayMonthYearFormat(),
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return ConversionDetailsPage(
                                                conversionModel: item,
                                                customerId:
                                                    item.customerId.toString(),
                                                showEdit: false,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: (!AppStyles.isWebScreen(context) && reportsProvider.isFilter)
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_conversion_report_filter_fab',
                  onPressed: () {
                    reportsProvider.setLeadId(leadIdController.text);
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.fromDateS,
                      reportsProvider.toDateS,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      leadId: leadIdController.text,
                    );
                    reportsProvider.getSearchConversionReport(context);
                    reportsProvider.toggleFilter();
                    Provider.of<SidebarProvider>(context, listen: false)
                        .stopSearch();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : null,
      ),
    );
  }
}

void onClickTopButton(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (contextx) => Consumer<ConversionReportProvider>(
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
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        List<Widget>.generate(dateButtonTitles.length, (index) {
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                        reportsProvider.getSearchConversionReport(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        reportsProvider.getSearchConversionReport(context);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        backgroundColor: AppColors.textRed.withOpacity(0.1),
                        foregroundColor: AppColors.textRed,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

final List<String> _exportHeaders = [
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
  'Conversion Date',
  'Created Date',
  'Next Follow-up',
  'Remark'
];

List<Map<String, dynamic>> _prepareExportData(
    ConversionReportProvider reportsProvider) {
  return reportsProvider.conversionReport.asMap().entries.map((entry) {
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
      'Conversion Date': _formatDateSafely(task.registeredDate),
      'Created Date': _formatDateSafely(task.creationDate),
      'Next Follow-up': _formatDateSafely(task.nextFollowUpDate),
      'Remark': task.remark,
    };
  }).toList();
}

String _formatDateSafely(DateTime? date) {
  if (date == null) return '';
  try {
    return DateFormat('dd MMM yyyy').format(date);
  } catch (_) {
    return '';
  }
}
