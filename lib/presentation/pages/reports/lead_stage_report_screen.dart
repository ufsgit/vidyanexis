import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';
import 'package:vidyanexis/presentation/pages/reports/lead_stage_detail_report_screen.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_stage_report_provider.dart';
import 'package:vidyanexis/controller/models/lead_stage_report_model.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class LeadStageReportScreen extends StatefulWidget {
  final bool fromDashBoard;
  static const String route = '/leadStageReport';
  const LeadStageReportScreen({super.key, this.fromDashBoard = false});

  @override
  State<LeadStageReportScreen> createState() => _LeadStageReportScreenState();
}

class _LeadStageReportScreenState extends State<LeadStageReportScreen> {
  TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<LeadStageReportProvider>(context, listen: false);

      provider.fetchReportData(context);
    });
  }

  String formatDateStr(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return DateFormat('dd MMM yyyy').format(date);
    }
    if (date is String && date.isNotEmpty) {
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(date));
      } catch (e) {
        return date;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeadStageReportProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: AppStyles.isWebScreen(context) ? null : const SidebarDrawer(),
      appBar: AppStyles.isWebScreen(context)
          ? null
          : CustomAppBar(
              title: 'Stage report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onFilterTap: () => provider.toggleFilter(),
              onSearch: (query) {},
              showSearch: false,
            ),
      body: Consumer<LeadStageReportProvider>(
        builder: (context, provider, child) {
          if (AppStyles.isWebScreen(context)) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  const SizedBox(height: 24),
                  if (provider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    _buildContentBody(context, provider),
                ],
              ),
            );
          }
          return _buildMobileLayout(context, provider);
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, LeadStageReportProvider provider) {
    return Column(
      children: [
        if (provider.isFilter) _buildFilterPanel(context, provider),
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : provider.reportData.isEmpty
                  ? _buildEmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildStageGrid(provider.reportData),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterPanel(
      BuildContext context, LeadStageReportProvider provider) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Range',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: provider.fromDate?.toString(),
              toDate: provider.toDate?.toString(),
              formattedFromDate: provider.formattedFromDate,
              formattedToDate: provider.formattedToDate,
              onTap: () => onClickTopButton(context),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.fetchReportData(context);
                      provider.toggleFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    provider.removeStatus();
                    provider.fetchReportData(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const CommonEmptyState(
      message: 'No report data found',
    );
  }

  Widget _buildContentBody(
      BuildContext context, LeadStageReportProvider provider) {
    if (provider.reportData.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const CommonEmptyState(
          message: 'No data available',
        ),
      );
    }

    return Container(
      width: double.infinity,
      alignment: Alignment.topLeft,
      child: _buildStageGrid(provider.reportData),
    );
  }

  Widget _buildHeader(BuildContext context, LeadStageReportProvider provider) {
    return Column(
      children: [
        AppStyles.isWebScreen(context)
            ? Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    if (widget.fromDashBoard) ...[
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            size: 24, color: Color(0xFF152D70)),
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
                      'Stage report',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
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
                          provider.fetchReportData(context);
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
                              provider.fetchReportData(context);
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
                        provider.toggleFilter();
                      },
                      isFilter: provider.isFilter,
                    ),
                    const SizedBox(width: 16),
                    CommonReportExportButton(
                      onPressed: () {
                        exportToExcel(
                          headers: ['Stage Name', 'Lead Count'],
                          data: provider.reportData.map((item) {
                            return {
                              'Stage Name': item.stageName ?? "",
                              'Lead Count': item.leadCount.toString(),
                            };
                          }).toList(),
                          fileName: 'Stage_Report',
                        );
                      },
                      label: 'Export to Excel',
                    )
                  ],
                ),
              )
            : Container(),
        if (provider.isFilter)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                CommonReportDateFilter(
                  fromDate: provider.fromDate?.toString(),
                  toDate: provider.toDate?.toString(),
                  formattedFromDate: provider.formattedFromDate,
                  formattedToDate: provider.formattedToDate,
                  onTap: () => onClickTopButton(context),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 38,
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.fetchReportData(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                CommonReportResetButton(
                  onReset: () {
                    provider.removeStatus();
                    provider.fetchReportData(context);
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  void onClickTopButton(BuildContext context) {
    final List<String> dateButtonTitles = [
      'Yesterday',
      'Today',
      'Tomorrow',
      'This Week',
      'This Month',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Consumer<LeadStageReportProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: Center(
                child: Text(
                  'Select Date Range',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlack,
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(
                        dateButtonTitles.length,
                        (index) {
                          final title = dateButtonTitles[index];
                          final isSelected =
                              provider.selectedDateFilterIndex == index;
                          return ActionChip(
                            onPressed: () {
                              provider.setDateFilter(title);
                              provider.selectDateFilterOption(index);
                            },
                            backgroundColor: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey[100],
                            label: Text(
                              title,
                              style: GoogleFonts.plusJakartaSans(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, true),
                            decoration: InputDecoration(
                              labelText: 'From Date',
                              hintText: provider.formattedFromDate,
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => provider.selectDate(context, false),
                            decoration: InputDecoration(
                              labelText: 'To Date',
                              hintText: provider.formattedToDate,
                              suffixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    provider.fetchReportData(context);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStageGrid(List<LeadStageReportModel> data) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: data.map((item) {
        return InkWell(
          onTap: () {
            if (item.stageId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LeadStageDetailReportScreen(
                    stageId: item.stageId!,
                    stageName: item.stageName ?? 'Unknown',
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stage ID not found')),
              );
            }
          },
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  item.stageName ?? 'Unknown',
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 12),
                CustomText(
                  (item.leadCount ?? 0).toString(),
                  fontSize: 24,
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
