import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class AttendanceReport extends StatefulWidget {
  const AttendanceReport({super.key});

  @override
  State<AttendanceReport> createState() => _AttendanceReportState();
}

class _AttendanceReportState extends State<AttendanceReport> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<AttendanceReportProvider>(context, listen: false);
      reportsProvider.setDateFilter('Today');
      reportsProvider.selectDateFilterOption(1);
      reportsProvider.getSearchTaskReport(context);

      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getUserDetails(context);

      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<AttendanceReportProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Attendance Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlack),
              showFilterIcon: false,
              searchHintText: 'Search by staff...',
              searchController: searchController,
              onSearchTap: () {
                searchProvider.startSearch();
              },
              onFilterTap: () {
                reportsProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                searchProvider.stopSearch();
                if (reportsProvider.isFilter) {
                  reportsProvider.toggleFilter();
                }
                reportsProvider.setTaskSearchCriteria(
                  '',
                  reportsProvider.fromDateS,
                  reportsProvider.toDateS,
                  reportsProvider.Status,
                  reportsProvider.AssignedTo,
                  reportsProvider.TaskType,
                );
                reportsProvider.getSearchTaskReport(context);
              },
              onSearch: (query) {
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
              onChanged: (query) {
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
            ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // ── Web Header & Filter ───────────────────────────────────────────
            if (isWeb) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
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
                    Text(
                      'Attendance Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const Spacer(),
                    // Search Bar
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
                        onSubmitted: (query) {},
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
                            onTap: () {},
                            child: const Icon(Icons.search,
                                color: Color(0xFF64748B), size: 18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    CustomFilterButton(
                      onPressed: () => reportsProvider.toggleFilter(),
                      isFilter: reportsProvider.isFilter,
                    ),
                    const SizedBox(width: 16),
                    // Export Button
                    CommonReportExportButton(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'Staff Name',
                            'Date',
                            'Check-In',
                            'Check-Out',
                            'Location',
                          ],
                          data: reportsProvider.taskReport.map((task) {
                            return {
                              'Staff Name': task.userDetailsName,
                              'Date': task.checkInDate,
                              'Check-In': task.checkInTimeOnly,
                              'Check-Out': task.checkOutTimeOnly.isEmpty
                                  ? '-'
                                  : task.checkOutTimeOnly,
                              'Location': task.location.isEmpty
                                  ? 'No Location'
                                  : task.location,
                            };
                          }).toList(),
                          fileName: 'Attendance_Report',
                        );
                      },
                      label: 'Export',
                    ),
                  ],
                ),
              ),
              if (reportsProvider.isFilter)
                _buildWebFilterBar(context, reportsProvider, provider),
            ],

            // ── Mobile Filter (Fullscreen) ──────────────────────────────────
            if (!isWeb && reportsProvider.isFilter)
              Expanded(
                child: _buildFilterPanel(context, reportsProvider, provider),
              )
            else if (!isWeb) ...[
              // ── Mobile Header & Summary ──────────────────────────────────
              if (reportsProvider.taskReport.isNotEmpty)
                CommonReportSummaryBar(
                  totalLabel: 'Total Records',
                  totalCount: reportsProvider.taskReport.length,
                  showingLabel: 'Showing',
                  showingCount: reportsProvider.taskReport.length,
                ),
              Expanded(
                child: reportsProvider.taskReport.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: reportsProvider.taskReport.length,
                        itemBuilder: (context, index) {
                          final task = reportsProvider.taskReport[index];

                          // Extract Initials for User Avatar
                          String initials = '';
                          if (task.userDetailsName.isNotEmpty) {
                            final parts =
                                task.userDetailsName.trim().split(' ');
                            if (parts.isNotEmpty) {
                              initials = parts[0][0].toUpperCase();
                              if (parts.length > 1 && parts[1].isNotEmpty) {
                                initials += parts[1][0].toUpperCase();
                              }
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey[100]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Initials Avatar
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          initials.isNotEmpty ? initials : 'ST',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            task.userDetailsName,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: const Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_month,
                                                  size: 13,
                                                  color: Colors.grey[400]),
                                              const SizedBox(width: 4),
                                              Text(
                                                task.checkInDate,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Row Number pill
                                    Container(
                                      height: 40,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '#${index + 1}',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 10,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Check-In and Check-Out Time badges
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: const Color(0xFF16A34A)
                                                .withOpacity(0.12),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CHECK-IN',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: const Color(0xFF15803D),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              task.checkInTimeOnly,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF16A34A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 10),
                                        decoration: BoxDecoration(
                                          color: task.checkOutTimeOnly.isEmpty
                                              ? const Color(0xFFFEF3C7)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: task.checkOutTimeOnly.isEmpty
                                                ? const Color(0xFFD97706)
                                                    .withOpacity(0.12)
                                                : const Color(0xFFDC2626)
                                                    .withOpacity(0.12),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'CHECK-OUT',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: task.checkOutTimeOnly
                                                        .isEmpty
                                                    ? const Color(0xFFB45309)
                                                    : const Color(0xFFB91C1C),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              task.checkOutTimeOnly.isEmpty
                                                  ? 'In Progress'
                                                  : task.checkOutTimeOnly,
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: task.checkOutTimeOnly
                                                        .isEmpty
                                                    ? const Color(0xFFD97706)
                                                    : const Color(0xFFDC2626),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (task.location.isNotEmpty) ...[
                                  const SizedBox(height: 14),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 15,
                                          color: Color(0xFF64748B),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            task.location,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: const Color(0xFF475569),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],

            // ── Table Header (Web Only) ──────────────────────────────────────
            if (isWeb) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 1, child: _tableHeader('No.')),
                    Expanded(flex: 3, child: _tableHeader('Staff Name')),
                    Expanded(flex: 2, child: _tableHeader('Date')),
                    Expanded(flex: 2, child: _tableHeader('Check-In')),
                    Expanded(flex: 2, child: _tableHeader('Check-Out')),
                    Expanded(flex: 4, child: _tableHeader('Location')),
                  ],
                ),
              ),
              Expanded(
                child: reportsProvider.taskReport.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: reportsProvider.taskReport.length,
                        itemBuilder: (context, index) {
                          final task = reportsProvider.taskReport[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Color(0xFFF3F4F6))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 1,
                                    child: Text('${index + 1}',
                                        style: _tableRowStyle())),
                                Expanded(
                                    flex: 3,
                                    child: Text(task.userDetailsName,
                                        style: _tableRowStyle())),
                                Expanded(
                                    flex: 2,
                                    child: Text(task.checkInDate,
                                        style: _tableRowStyle())),
                                Expanded(
                                    flex: 2,
                                    child: Text(task.checkInTimeOnly,
                                        style: _tableRowStyle())),
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                        task.checkOutTimeOnly.isEmpty
                                            ? '-'
                                            : task.checkOutTimeOnly,
                                        style: _tableRowStyle())),
                                Expanded(
                                    flex: 4,
                                    child: Text(
                                        task.location.isEmpty
                                            ? 'No Location'
                                            : task.location,
                                        style: _tableRowStyle(),
                                        overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (!isWeb && reportsProvider.isFilter)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_attendance_report_filter_fab',
                  onPressed: () {
                    reportsProvider.setTaskSearchCriteria(
                      searchController.text,
                      reportsProvider.formattedFromDate,
                      reportsProvider.formattedToDate,
                      reportsProvider.Status,
                      reportsProvider.AssignedTo,
                      reportsProvider.TaskType,
                    );
                    reportsProvider.getSearchTaskReport(context);
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
              ),
            )
          : null,
    );
  }

  // ── Web: horizontal inline filter bar ───────────────────────────────────
  Widget _buildWebFilterBar(
    BuildContext context,
    AttendanceReportProvider reportsProvider,
    DropDownProvider provider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                              decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.grey),
      ),
      child: Row(
        children: [
          // Date picker chip
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            label: 'Date',
            onTap: () => onClickTopButton(context),
          ),
          const SizedBox(width: 12),
          // User dropdown
          Container(
            width: 250,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: reportsProvider.AssignedTo != '0' &&
                        reportsProvider.AssignedTo != ''
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Staff: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.black54),
                ),
                Expanded(
                  child: DropdownButton<int>(
                    value: int.tryParse(reportsProvider.AssignedTo) ?? 0,
                    isExpanded: true,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      provider.searchUserDetails
                          .map((user) => DropdownMenuItem<int>(
                                value: user.userDetailsId,
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    user.userDetailsName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      reportsProvider.setUserFilterStatus(newValue);
                    }
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Apply button
          ElevatedButton(
            onPressed: () {
              reportsProvider.setTaskSearchCriteria(
                searchController.text,
                reportsProvider.formattedFromDate,
                reportsProvider.formattedToDate,
                reportsProvider.Status,
                reportsProvider.AssignedTo,
                reportsProvider.TaskType,
              );
              reportsProvider.getSearchTaskReport(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEAB308),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          // Reset button
          if (reportsProvider.fromDate != null ||
              (reportsProvider.AssignedTo != '0' &&
                  reportsProvider.AssignedTo != ''))
            CommonReportResetButton(
              label: 'Reset',
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
                  '',
                );
                reportsProvider.getSearchTaskReport(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textRed,
                elevation: 0,
                side: BorderSide(color: AppColors.textRed),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context,
      AttendanceReportProvider reportsProvider, DropDownProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          CustomText('Date Range',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack),
          const SizedBox(height: 12),
          CommonReportDateFilter(
            fromDate: reportsProvider.fromDate?.toString(),
            toDate: reportsProvider.toDate?.toString(),
            formattedFromDate: reportsProvider.formattedFromDate,
            formattedToDate: reportsProvider.formattedToDate,
            onTap: () => onClickTopButton(context),
          ),
          const SizedBox(height: 32),
          CustomText('Staff Member',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textBlack),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                onSelected: (_) {
                  reportsProvider.setUserFilterStatus(0);
                },
                selected: reportsProvider.AssignedTo == '0' ||
                    reportsProvider.AssignedTo == '',
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                label: Text(
                  'All Staff',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                selectedColor: AppColors.primaryBlue,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: reportsProvider.AssignedTo == '0' ||
                          reportsProvider.AssignedTo == ''
                      ? Colors.white
                      : const Color(0xFF475569),
                ),
                side: BorderSide(
                  color: reportsProvider.AssignedTo == '0' ||
                          reportsProvider.AssignedTo == ''
                      ? Colors.transparent
                      : Colors.grey[300]!,
                ),
              ),
              ...provider.searchUserDetails.map((user) {
                final bool isSelected =
                    reportsProvider.AssignedTo == user.userDetailsId.toString();
                return ChoiceChip(
                  onSelected: (_) {
                    reportsProvider
                        .setUserFilterStatus(user.userDetailsId ?? 0);
                  },
                  selected: isSelected,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  label: Text(
                    user.userDetailsName ?? 'Unknown',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  selectedColor: AppColors.primaryBlue,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                  side: BorderSide(
                    color: isSelected ? Colors.transparent : Colors.grey[300]!,
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 40),
          if (reportsProvider.fromDate != null ||
              (reportsProvider.AssignedTo != '0' &&
                  reportsProvider.AssignedTo != ''))
            SizedBox(
              width: double.infinity,
              child: CommonReportResetButton(
                label: 'Reset All Filters',
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
                    '',
                  );
                  reportsProvider.getSearchTaskReport(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textRed,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.textRed),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(message: 'No attendance reports found');
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<AttendanceReportProvider>(
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
                    Center(
                      child: Text(
                        'Choose Date',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        final bool isSelected =
                            reportsProvider.selectedDateFilterIndex == index;
                        return ChoiceChip(
                          onSelected: (_) {
                            reportsProvider.setDateFilter(title);
                            reportsProvider.selectDateFilterOption(index);
                          },
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          label: Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF475569),
                            ),
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Pick a custom date',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, true),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                reportsProvider.selectDate(context, false),
                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              suffixIcon:
                                  const Icon(Icons.calendar_month, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.formatDate();
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            reportsProvider.formattedFromDate,
                            reportsProvider.formattedToDate,
                            reportsProvider.Status,
                            reportsProvider.AssignedTo,
                            reportsProvider.TaskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Apply Filter',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
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

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  TextStyle _tableRowStyle() {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      color: const Color(0xFF374151),
    );
  }
}
