import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/time_track_report_provider.dart';
import 'package:vidyanexis/controller/models/time_track_chart_data.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeTrackReportPage extends StatefulWidget {
  const TimeTrackReportPage({super.key});

  @override
  State<TimeTrackReportPage> createState() => _TimeTrackReportPageState();
}

class _TimeTrackReportPageState extends State<TimeTrackReportPage> {
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final providerTimeTrack =
          Provider.of<TimeTrackReportProvider>(context, listen: false);

      providerTimeTrack.clearFilters();
      await providerTimeTrack.initializeWithLoggedInUser();
      providerTimeTrack.setDateFilter('Today'); // Set both from and to dates
      providerTimeTrack.selectDateFilterOption(1); // Optional: highlight "Today" chip if there's an index 1
      providerTimeTrack.getTimeTrackReport(context);

      Provider.of<DropDownProvider>(context, listen: false)
          .getUserDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerTimeTrack = Provider.of<TimeTrackReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: isWeb ? null : const SidebarDrawer(),
      appBar: isWeb
          ? null
          : CustomAppBar(
              title: 'Time Track Report',
              titleStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack),
              onFilterTap: () {
                providerTimeTrack.toggleFilter();
              },
              showSearch: false,
              onSearch: (q) {},
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Web header bar ──────────────────────────────────────────────
          if (isWeb)
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
                          borderRadius: BorderRadius.circular(12),
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
                    'Time Track Report',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const Spacer(),
                  CustomFilterButton(
                    onPressed: () => providerTimeTrack.toggleFilter(),
                    isFilter: providerTimeTrack.isFilter,
                  ),
                ],
              ),
            ),

          // ── Web filter bar ───────────────────────────────────────────────
          if (isWeb && providerTimeTrack.isFilter)
            _buildWebFilterBar(context, providerTimeTrack, dropDownProvider),

          // ── Mobile filter panel ──────────────────────────────────────────
          if (!isWeb && providerTimeTrack.isFilter)
            _buildMobileFilterPanel(
                context, providerTimeTrack, dropDownProvider),

          // ── Chart content ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer<TimeTrackReportProvider>(
                    builder: (context, chartProvider, _) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(12),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(color: AppColors.grey),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Time Tracking Summary',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlue.withAlpha(25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    (chartProvider.fromDate != null)
                                        ? chartProvider.formattedFromDate
                                        : 'Today',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (chartProvider.isLoading)
                              const SizedBox(
                                height: 300,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              )
                            else
                              SizedBox(
                                height: 300,
                                child: SfCartesianChart(
                                  margin: const EdgeInsets.all(0),
                                  primaryXAxis: CategoryAxis(
                                    majorGridLines:
                                        const MajorGridLines(width: 0),
                                    labelStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textGrey4,
                                    ),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    majorGridLines: MajorGridLines(
                                      width: 1,
                                      color: AppColors.grey.withAlpha(100),
                                      dashArray: const <double>[5, 5],
                                    ),
                                    majorTickLines:
                                        const MajorTickLines(width: 0),
                                    labelStyle: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: AppColors.textGrey4,
                                    ),
                                  ),
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    color: AppColors.textBlack,
                                    textStyle:
                                        const TextStyle(color: Colors.white),
                                  ),
                                  series: <CartesianSeries<TimeTrackChartData,
                                      String>>[
                                    SplineAreaSeries<TimeTrackChartData,
                                        String>(
                                      name: 'Activity',
                                      dataSource: chartProvider.chartData,
                                      xValueMapper:
                                          (TimeTrackChartData data, _) =>
                                              data.x,
                                      yValueMapper:
                                          (TimeTrackChartData data, _) =>
                                              data.y1,
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primaryBlue.withAlpha(100),
                                          AppColors.primaryBlue.withAlpha(0),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      borderColor: AppColors.primaryBlue,
                                      borderWidth: 2,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Web: horizontal inline filter bar ───────────────────────────────────
  Widget _buildWebFilterBar(
    BuildContext context,
    TimeTrackReportProvider provider,
    DropDownProvider dropDownProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey),
      ),
      child: Row(
        children: [
          // Date picker chip
          CommonReportDateFilter(
            fromDate: provider.fromDate?.toString(),
            toDate: provider.toDate?.toString(),
            formattedFromDate: provider.formattedFromDate,
            formattedToDate: provider.formattedToDate,
            label: 'Date',
            onTap: () => _showDateDialog(context),
          ),
          const SizedBox(width: 12),
          // User dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.selectedUser != null && provider.selectedUser != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                Text(
                  'By User: ',
                  style: GoogleFonts.plusJakartaSans(fontSize: 14),
                ),
                DropdownButton<int>(
                  value: provider.selectedUser,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child:
                              Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      dropDownProvider.searchUserDetails
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
                      provider.setUserFilter(newValue);
                    }
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Apply button
          ElevatedButton(
            onPressed: () => provider.getTimeTrackReport(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          // Reset button (shown only when filters are active)
          if (provider.fromDate != null ||
              (provider.selectedUser != null && provider.selectedUser != 0))
            CommonReportResetButton(
              label: 'Reset',
              onReset: () {
                provider.clearFilters();
                provider.getTimeTrackReport(context);
              },
            ),
        ],
      ),
    );
  }

  // ── Mobile: vertical stacked filter panel ───────────────────────────────
  Widget _buildMobileFilterPanel(
    BuildContext context,
    TimeTrackReportProvider provider,
    DropDownProvider dropDownProvider,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.grey, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText('Date Filter',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            CommonReportDateFilter(
              fromDate: provider.fromDate?.toString(),
              toDate: provider.toDate?.toString(),
              formattedFromDate: provider.formattedFromDate,
              formattedToDate: provider.formattedToDate,
              label: 'Selected Date',
              onTap: () => _showDateDialog(context),
            ),
            const SizedBox(height: 24),
            CustomText('Filter by User',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChipWidget(
                  label: 'All Users',
                  isSelected:
                      provider.selectedUser == null || provider.selectedUser == 0,
                  onTap: () {
                    provider.setUserFilter(0);
                  },
                ),
                ...dropDownProvider.searchUserDetails.map(
                  (user) => FilterChipWidget(
                    label: user.userDetailsName ?? '',
                    isSelected: provider.selectedUser == user.userDetailsId,
                    onTap: () {
                      provider.setUserFilter(user.userDetailsId);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Action buttons row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      provider.toggleFilter();
                      provider.getTimeTrackReport(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Apply',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                  ),
                ),
                if (provider.fromDate != null ||
                    (provider.selectedUser != null &&
                        provider.selectedUser != 0)) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: CommonReportResetButton(
                      onReset: () {
                        provider.clearFilters();
                        provider.getTimeTrackReport(context);
                      },
                      label: 'Reset',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<TimeTrackReportProvider>(
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
                      children: List<Widget>.generate(
                          _dateButtonTitles.length, (index) {
                        String title = _dateButtonTitles[index];
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
                    TextField(
                      readOnly: true,
                      onTap: () => reportsProvider.selectDate(context, true),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        hintText: reportsProvider.fromDate != null
                            ? '${reportsProvider.fromDate!.toLocal()}'
                                .split(' ')[0]
                            : 'Date',
                        suffixIcon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.formatDate();
                          // Don't auto-fetch here — user will press Apply
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Select'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          reportsProvider.selectDateFilterOption(null);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Clear'),
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

  final List<String> _dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
