import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/time_track_report_provider.dart';
import 'package:vidyanexis/controller/models/time_track_chart_data.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final providerTimeTrack =
          Provider.of<TimeTrackReportProvider>(context, listen: false);
      providerTimeTrack.clearFilters(); // Clear previous filters on load
      providerTimeTrack.getTimeTrackReport(context);

      // Fetch user details for dropdown
      Provider.of<DropDownProvider>(context, listen: false)
          .getUserDetails(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final providerTimeTrack = Provider.of<TimeTrackReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Match background style
      appBar: AppBar(
        surfaceTintColor: AppColors.scaffoldColor,
        backgroundColor: AppColors.whiteColor,
        title: const Text(
          'Time Track Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: providerTimeTrack.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search and Filter Header
                    _buildHeader(context, providerTimeTrack),
                    const SizedBox(height: 16),

                    // Filter Section (Collapsible)
                    if (providerTimeTrack.isFilter)
                      _buildFilterSection(
                          context, providerTimeTrack, dropDownProvider),
                    if (providerTimeTrack.isFilter) const SizedBox(height: 16),

                    // Chart Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Time Tracking Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF505050),
                                ),
                              ),
                              // Date/Year indicator (using from/to date if selected, else Year)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  (providerTimeTrack.fromDate != null &&
                                          providerTimeTrack.toDate != null)
                                      ? '${providerTimeTrack.formattedFromDate} - ${providerTimeTrack.formattedToDate}'
                                      : DateTime.now().year.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 300,
                            child: SfCartesianChart(
                              margin: const EdgeInsets.all(0),
                              isTransposed:
                                  false, // Normal orientation: X-axis (Time) is horizontal, Y-axis (Count) is vertical
                              primaryXAxis: CategoryAxis(
                                title: AxisTitle(text: 'Time'),
                                majorGridLines: const MajorGridLines(width: 0),
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF606060),
                                ),
                              ),
                              primaryYAxis: NumericAxis(
                                title: AxisTitle(text: 'Count'),
                                minimum: 0,
                                // maximum: 100, // Remove fixed maximum to allow auto-scaling
                                interval: 1, // Adjusted interval for count
                                majorGridLines: MajorGridLines(
                                  width: 1,
                                  color: Colors.grey.shade200,
                                  dashArray: const <double>[5, 5],
                                ),
                                majorTickLines: const MajorTickLines(width: 0),
                                labelStyle: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF606060),
                                ),
                              ),
                              tooltipBehavior: TooltipBehavior(
                                enable: true,
                                color: Colors.white,
                                borderColor: Colors.grey.shade300,
                                borderWidth: 1,
                                textStyle: const TextStyle(color: Colors.black),
                              ),
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                                alignment: ChartAlignment.center,
                                legendItemBuilder: (String name, dynamic series,
                                    dynamic point, int index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              series: <CartesianSeries<TimeTrackChartData,
                                  String>>[
                                SplineSeries<TimeTrackChartData, String>(
                                  name: 'Tracked',
                                  dataSource: List<TimeTrackChartData>.from(
                                      providerTimeTrack.chartData),
                                  xValueMapper: (TimeTrackChartData data, _) =>
                                      data.x,
                                  yValueMapper: (TimeTrackChartData data, _) =>
                                      data.y1,
                                  color: Colors.blue,
                                  width: 2,
                                  markerSettings:
                                      const MarkerSettings(isVisible: false),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List Section
                    if (providerTimeTrack.timeTrackList.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: providerTimeTrack.timeTrackList.length,
                        itemBuilder: (context, index) {
                          final item = providerTimeTrack.timeTrackList[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primaryBlue.withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // title: Text(
                              //   'Time: ${item.entryDate}',
                              //   style: const TextStyle(
                              //     fontWeight: FontWeight.w600,
                              //     fontSize: 14,
                              //   ),
                              // ),
                              // subtitle: Text(
                              //   'Count: ${item.count}',
                              //   style: TextStyle(
                              //     color: Colors.grey[600],
                              //     fontSize: 13,
                              //   ),
                              // ),
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No records found"),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, TimeTrackReportProvider provider) {
    return Row(
      children: [
        /*
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
                // provider.setSearch(query); // Implement search logic if needed
                // provider.getTimeTrackReport(context);
              },
              decoration: InputDecoration(
                hintText: 'Search here....',
                prefixIcon: const Icon(Icons.search),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    searchController.clear();
                    // provider.setSearch('');
                    // provider.getTimeTrackReport(context);
                  },
                  icon: const Icon(Icons.close),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        */
        // const Spacer(), // Added spacer to push filter button if needed, or just let it start
        // OutlinedButton.icon(
        //   onPressed: () => provider.toggleFilter(),
        //   icon: const Icon(Icons.filter_list),
        //   label: const Text('Filter'),
        //   style: OutlinedButton.styleFrom(
        //     foregroundColor:
        //         provider.isFilter ? Colors.white : AppColors.primaryBlue,
        //     backgroundColor:
        //         provider.isFilter ? const Color(0xFF5499D9) : Colors.white,
        //     side: BorderSide(
        //       color: provider.isFilter
        //           ? const Color(0xFF5499D9)
        //           : AppColors.primaryBlue,
        //     ),
        //     padding: const EdgeInsets.symmetric(
        //       horizontal: 16,
        //       vertical: 12,
        //     ),
        //   ),
        // ),
        /*
        const SizedBox(width: 16),
        CustomElevatedButton(
          onPressed: () {
            exportToExcel(
              headers: [
                'Date',
                'Count',
              ],
              data: provider.timeTrackList.map((item) {
                return {
                  'Date': item.entryDate,
                  'Count': item.count,
                };
              }).toList(),
              fileName: 'Time_Track_Report',
            );
          },
          buttonText: 'Export to Excel',
          textColor: AppColors.whiteColor,
          borderColor: AppColors.appViolet,
          backgroundColor: AppColors.appViolet,
        )
        */
      ],
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    TimeTrackReportProvider provider,
    DropDownProvider dropDownProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // DATE FILTER (FIXED SIZE)
              SizedBox(
                width: 360, // ✅ SAME WIDTH
                child: GestureDetector(
                  onTap: () {
                    onClickTopButton(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (provider.fromDate != null ||
                                provider.toDate != null)
                            ? AppColors.primaryBlue
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.fromDate == null && provider.toDate == null
                                ? 'Date: All'
                                : 'Date : ${provider.formattedFromDate}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.arrow_drop_down_outlined,
                          color: Colors.black45,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // BY USER FILTER (FIXED SIZE)
              SizedBox(
                width: 360, // ✅ SAME WIDTH
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: provider.selectedUser != null &&
                              provider.selectedUser != 0
                          ? AppColors.primaryBlue
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('By User: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: provider.selectedUser,
                            hint: const Text('User'),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem<int>(
                                value: 0,
                                child: Text(
                                  'User',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              ...dropDownProvider.searchUserDetails.map(
                                (user) => DropdownMenuItem<int>(
                                  value: user.userDetailsId,
                                  child: Text(
                                    user.userDetailsName ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                provider.setUserFilter(
                                  newValue == 0 ? null : newValue,
                                );
                                provider.getTimeTrackReport(context);
                              }
                            },
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // RESET BUTTON (UNCHANGED, COMMENTED AS YOU HAD)
          // Align(
          //   alignment: Alignment.bottomRight,
          //   child: ((provider.fromDate != null ||
          //           provider.toDate != null ||
          //           (provider.selectedUser != null &&
          //               provider.selectedUser != 0)))
          //       ? ElevatedButton(
          //           onPressed: () {
          //             provider.clearFilters();
          //             provider.getTimeTrackReport(context);
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.white,
          //             foregroundColor: AppColors.textRed,
          //             side: BorderSide(color: AppColors.textRed),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 16,
          //               vertical: 12,
          //             ),
          //             shape: RoundedRectangleBorder(
          //               borderRadius: BorderRadius.circular(20),
          //             ),
          //           ),
          //           child: const Text('Reset'),
          //         )
          //       : const SizedBox(),
          // ),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
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
                          reportsProvider.getTimeTrackReport(context);
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
                          reportsProvider.getTimeTrackReport(context);
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
