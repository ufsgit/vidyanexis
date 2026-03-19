import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/solar_lead_report_provider.dart';

class SolarLeadReportPage extends StatefulWidget {
  const SolarLeadReportPage({super.key});

  @override
  State<SolarLeadReportPage> createState() => _SolarLeadReportPageState();
}

class _SolarLeadReportPageState extends State<SolarLeadReportPage> {
  TextEditingController searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<SolarLeadReportProvider>(context, listen: false);
      
      provider.selectDateFilterOption(null);
      provider.getSolarLeadReport(
        context,
        provider.Search,
        provider.fromDateS,
        provider.toDateS,
        provider.Status,
        provider.AssignedTo,
      );
      
      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getFollowUpStatus(context, '0');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SolarLeadReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppStyles.isWebScreen(context)
          ? null
          : AppBar(
              title: const Text('Solar Lead Reports'),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider, dropDownProvider),
                  if (provider.isFilter) _buildFilterContainer(context, provider, dropDownProvider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChartCard(
                            title: 'Leads Created Per Day',
                            data: provider.leadsCreatedPerDay,
                            yAxisTitle: 'Lead Count',
                            lineColor: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 24),
                          _buildChartCard(
                            title: 'Lead Conversion Count Per Day',
                            data: provider.conversionsPerDay,
                            yAxisTitle: 'Conversion Count',
                            lineColor: Colors.green,
                          ),
                          const SizedBox(height: 24),
                          _buildChartCard(
                            title: 'Project Cost by Conversion Date',
                            data: provider.projectCostPerDay,
                            yAxisTitle: 'Total Cost',
                            isCurrency: true,
                            lineColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, SolarLeadReportProvider provider, DropDownProvider dropDownProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (AppStyles.isWebScreen(context))
            const Text(
              'Solar Lead Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          const Spacer(),
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
                provider.getSolarLeadReport(
                  context,
                  query,
                  provider.fromDateS,
                  provider.toDateS,
                  provider.Status,
                  provider.AssignedTo,
                );
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
                      if (provider.Search.isNotEmpty) {
                        searchController.clear();
                        provider.getSolarLeadReport(
                          context,
                          '',
                          provider.fromDateS,
                          provider.toDateS,
                          provider.Status,
                          provider.AssignedTo,
                        );
                      } else {
                        provider.getSolarLeadReport(
                          context,
                          query,
                          provider.fromDateS,
                          provider.toDateS,
                          provider.Status,
                          provider.AssignedTo,
                        );
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
                    child: Text(provider.Search.isNotEmpty ? 'Cancel' : 'Search'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: () {
              provider.toggleFilter();
            },
            icon: const Icon(Icons.filter_list),
            label: Text(MediaQuery.of(context).size.width > 860 ? 'Filter' : ''),
            style: OutlinedButton.styleFrom(
              foregroundColor: provider.isFilter ? Colors.white : AppColors.primaryBlue,
              backgroundColor: provider.isFilter ? const Color(0xFF5499D9) : Colors.white,
              side: BorderSide(color: provider.isFilter ? const Color(0xFF5499D9) : AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterContainer(BuildContext context, SolarLeadReportProvider provider, DropDownProvider dropDownProvider) {
    return Container(
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
                color: provider.selectedStatus != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                const Text('Status: '),
                DropdownButton<int>(
                  value: provider.selectedStatus,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      dropDownProvider.followUpData
                          .map((status) => DropdownMenuItem<int>(
                                value: status.statusId,
                                child: Text(status.statusName ?? '', style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      provider.setStatus(newValue);
                    }
                    provider.getSolarLeadReport(
                      context,
                      provider.Search,
                      provider.formattedFromDate,
                      provider.formattedToDate,
                      provider.selectedStatus.toString(),
                      provider.selectedUser.toString(),
                    );
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              onClickTopButton(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1.5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.fromDate != null || provider.toDate != null
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  if (provider.fromDate == null && provider.toDate == null)
                    const Text('Entry Date: All'),
                  if (provider.fromDate != null && provider.toDate != null)
                    Text('Date : ${provider.formattedFromDate} - ${provider.formattedToDate}'),
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
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: provider.selectedUser != 0
                    ? AppColors.primaryBlue
                    : Colors.grey[300]!,
              ),
            ),
            child: Row(
              children: [
                const Text('Assigned to: '),
                DropdownButton<int>(
                  value: provider.selectedUser,
                  hint: const Text('All'),
                  items: [
                        const DropdownMenuItem<int>(
                          value: 0,
                          child: Text('All', style: TextStyle(fontSize: 14)),
                        ),
                      ] +
                      dropDownProvider.searchUserDetails
                          .map((user) => DropdownMenuItem<int>(
                                value: user.userDetailsId,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 150),
                                  child: Text(
                                    user.userDetailsName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ))
                          .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      provider.setUserFilterStatus(newValue);
                    }
                    provider.getSolarLeadReport(
                      context,
                      provider.Search,
                      provider.formattedFromDate,
                      provider.formattedToDate,
                      provider.selectedStatus.toString(),
                      provider.selectedUser.toString(),
                    );
                  },
                  underline: Container(),
                  isDense: true,
                  iconSize: 18,
                ),
              ],
            ),
          ),
          const Spacer(),
          if (provider.fromDate != null ||
              provider.toDate != null ||
              provider.selectedStatus != 0 ||
              provider.selectedUser != 0 ||
              provider.Search.isNotEmpty)
            ElevatedButton(
              onPressed: () {
                provider.removeStatus();
                searchController.clear();
                provider.getSolarLeadReport(context, '', '', '', '', '');
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
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<SolarLeadReportProvider>(
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length, (index) {
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
                          backgroundColor: reportsProvider.selectedDateFilterIndex == index
                              ? AppColors.primaryBlue
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: reportsProvider.selectedDateFilterIndex == index ? Colors.white : Colors.black,
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
                            onTap: () => reportsProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.fromDate != null
                                  ? '${reportsProvider.fromDate?.toLocal()}'.split(' ')[0]
                                  : 'From Date',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => reportsProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: reportsProvider.toDate != null
                                  ? '${reportsProvider.toDate?.toLocal()}'.split(' ')[0]
                                  : 'To Date',
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
                          reportsProvider.getSolarLeadReport(
                            context,
                            reportsProvider.Search,
                            reportsProvider.formattedFromDate,
                            reportsProvider.formattedToDate,
                            reportsProvider.selectedStatus.toString(),
                            reportsProvider.selectedUser.toString(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Apply'),
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
                          reportsProvider.getSolarLeadReport(
                            context,
                            reportsProvider.Search,
                            '',
                            '',
                            reportsProvider.selectedStatus.toString(),
                            reportsProvider.selectedUser.toString(),
                          );
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];


  Widget _buildChartCard({
    required String title,
    required List<ChartData> data,
    required String yAxisTitle,
    required Color lineColor,
    bool isCurrency = false,
  }) {
    if (data.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Center(
              child: Text(
                title.contains('Conversion') 
                    ? 'No converted leads found for the selected period' 
                    : title.contains('Cost')
                        ? 'No project cost data available for converted leads'
                        : 'No data available',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: DateTimeAxis(
                dateFormat: DateFormat('dd MMM'),
                majorGridLines: const MajorGridLines(width: 0),
                edgeLabelPlacement: EdgeLabelPlacement.shift,
                intervalType: DateTimeIntervalType.days,
              ),
              primaryYAxis: NumericAxis(
                title: AxisTitle(text: yAxisTitle),
                numberFormat: isCurrency 
                    ? NumberFormat.compactCurrency(symbol: '₹', decimalDigits: 0) 
                    : NumberFormat.compact(),
                axisLine: const AxisLine(width: 0),
                majorTickLines: const MajorTickLines(size: 0),
              ),
              tooltipBehavior: TooltipBehavior(
                enable: true,
                header: '',
                canShowMarker: true,
              ),
              series: <CartesianSeries<ChartData, DateTime>>[
                SplineSeries<ChartData, DateTime>(
                  dataSource: data,
                  xValueMapper: (ChartData d, _) => d.date,
                  yValueMapper: (ChartData d, _) => d.value,
                  name: title,
                  color: lineColor,
                  width: 3,
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 5,
                    width: 5,
                    borderWidth: 2,
                    borderColor: Colors.white,
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
