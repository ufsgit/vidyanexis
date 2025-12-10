import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/user_location_model.dart';
import 'package:vidyanexis/main.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/attendance_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/home/add_attendance.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class EmployeeLocationReportScreen extends StatefulWidget {
  const EmployeeLocationReportScreen({super.key});

  @override
  _EmployeeLocationReportScreenState createState() =>
      _EmployeeLocationReportScreenState();
}

class _EmployeeLocationReportScreenState
    extends State<EmployeeLocationReportScreen> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  final reportsProvider = Provider.of<CustomerDetailsProvider>(
      navigatorKey.currentState!.context,
      listen: false);
  Future<List<UserLocationModel>>? userLocationFuture;
  List<UserLocationModel> locationDataList = [];

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    final reportsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    userLocationFuture =
        reportsProvider.getUserLocationDetails(context, searchController.text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: Text(
          'Employee Location Report',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
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
                                getData();
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
                                      getData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.textGrey4,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(searchController.text.isNotEmpty
                                        ? 'Cancel'
                                        : 'Search'),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // CustomElevatedButton(
                          //   onPressed: () {
                          //     exportToExcel(
                          //       headers: ['Name', 'Date', 'Time', 'Location'],
                          //       data: reportsProvider.taskReport.map((task) {
                          //         return {
                          //           'Name': task.userDetailsName,
                          //           'Date': task.attendanceDate.isNotEmpty
                          //               ? DateFormat('dd MMM yyyy').format(
                          //                   DateTime.parse(task.attendanceDate))
                          //               : '',
                          //           'Time': task.attendanceTime,
                          //           'Location': task.location,
                          //         };
                          //       }).toList(),
                          //       fileName: 'Attendance_Report',
                          //     );
                          //   },
                          //   buttonText: 'Export to Excel',
                          //   textColor: AppColors.whiteColor,
                          //   borderColor: AppColors.appViolet,
                          //   backgroundColor: AppColors.appViolet,
                          // ),
                        ],
                      ),
                    )
                  //mobile design
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Container(
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (query) {
                                getData();
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
                                      getData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.textGrey4,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 0,
                                      ),
                                    ),
                                    child: Text(searchController.text.isNotEmpty
                                        ? 'Cancel'
                                        : 'Search'),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //
                          // CustomElevatedButton(
                          //   onPressed: () {
                          //     exportToExcel(
                          //       headers: ['Name', 'Date', 'Time', 'Location'],
                          //       data: reportsProvider.taskReport.map((task) {
                          //         return {
                          //           'Name': task.userDetailsName,
                          //           'Date': task.attendanceDate.isNotEmpty
                          //               ? DateFormat('dd MMM yyyy').format(
                          //                   DateTime.parse(task.attendanceDate))
                          //               : '',
                          //           'Time': task.attendanceTime,
                          //           'Location': task.location,
                          //         };
                          //       }).toList(),
                          //       fileName: 'Attendance_Report',
                          //     );
                          //   },
                          //   buttonText: 'Export to Excel',
                          //   textColor: AppColors.whiteColor,
                          //   borderColor: AppColors.appViolet,
                          //   backgroundColor: AppColors.appViolet,
                          // ),
                        ],
                      ),
                    ),

              AppStyles.isWebScreen(context)
                  ? Expanded(
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
                                          flex: 1,
                                          title: 'Name',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Location',
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          flex: 1,
                                          title: 'Date',
                                          color: Color(0xFF607185)),
                                    ],
                                  ),
                                ),
                                // Data Rows
                                Expanded(
                                  child: FutureBuilder<List<UserLocationModel>>(
                                      future: userLocationFuture,
                                      builder: (contextBuilder, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const SizedBox(height: 20),
                                                SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 3,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            AppColors
                                                                .appViolet),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'Loading data...',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.textGrey1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        locationDataList = snapshot.data ?? [];

                                        if (locationDataList.isEmpty) {
                                          return Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(height: 30),
                                                Icon(Icons.category_outlined,
                                                    size: 60,
                                                    color: AppColors.textGrey1
                                                        .withOpacity(0.3)),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No data found',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textGrey1,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Try refreshing',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: AppColors.textGrey1
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        return ListView.builder(
                                          shrinkWrap:
                                              true, // To avoid scrolling issues when inside a parent widget
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount: locationDataList
                                              .length, // Number of tasks
                                          itemBuilder: (context, index) {
                                            UserLocationModel model =
                                                locationDataList[index];
                                            return GestureDetector(
                                              onTap: () {
                                                // context.go(
                                                //     '${CustomerDetailsScreen.route}${task.customerId.toString()}');
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
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    // Padding(
                                                    //   padding: const EdgeInsets.symmetric(
                                                    //       vertical: 12.0, horizontal: 25.0),
                                                    //   child: Text(task.customerId.toString(),
                                                    //       style: const TextStyle(
                                                    //         fontWeight: FontWeight.bold,
                                                    //       )),
                                                    // ),
                                                    SizedBox(
                                                      width: 80,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12.0,
                                                                horizontal:
                                                                    25.0),
                                                        child: Text(
                                                            (index + 1)
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            )),
                                                      ),
                                                    ),
                                                    // TableWidget(title: task.orderNo),
                                                    TableWidget(
                                                      flex: 1,
                                                      data: GestureDetector(
                                                        onTap: () {
                                                          // context.push(
                                                          //     '${CustomerDetailsScreen.route}${task.customerId.toString()}/${'true'}');
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFFE9EDF1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                          ),
                                                          child: Text(
                                                            model.userDetailsName ??
                                                                "",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
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
                                                        title: formatDate(
                                                            model.location ??
                                                                '')),
                                                    TableWidget(
                                                        flex: 1,
                                                        title: formatTime(model
                                                                .locationDateTime ??
                                                            "")),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FutureBuilder<List<UserLocationModel>>(
                            future: userLocationFuture,
                            builder: (contextBuilder, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  AppColors.appViolet),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Loading data...',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textGrey1,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              locationDataList = snapshot.data ?? [];

                              if (locationDataList.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 30),
                                      Icon(Icons.category_outlined,
                                          size: 60,
                                          color: AppColors.textGrey1
                                              .withOpacity(0.3)),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No data found',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try refreshing',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.textGrey1
                                              .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                itemCount: locationDataList.length,
                                itemBuilder: (context, index) {
                                  UserLocationModel model =
                                      locationDataList[index];
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                          offset: const Offset(2, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // 🏷️ Task Name with Icon
                                          Row(
                                            children: [
                                              const Icon(Icons.person,
                                                  color: Colors.blue, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  model.userDetailsName ?? "",
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),

                                          // 📅 Attendance Date & Time (With Background)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 6, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      formatDate(model
                                                              .locationDateTime ??
                                                          ""),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade700),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.access_time,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      formatTime(model
                                                              .locationDateTime ??
                                                          ""),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors
                                                              .grey.shade700),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // 📍 Location
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.red, size: 18),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  model.location ?? "",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade700),
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 12),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<AttendanceReportProvider>(
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
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
                          String taskType =
                              reportsProvider.selectedTaskType.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          reportsProvider.setTaskSearchCriteria(
                            reportsProvider.Search,
                            fromDate,
                            toDate,
                            status,
                            assignedTo,
                            taskType,
                          );
                          reportsProvider.getSearchTaskReport(context);
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

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Allows the dialog to be dismissed by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black, // Set background color to black
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain, // Adjust image fit
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    // Return a placeholder or error image in case of an error
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.withOpacity(0.2)),
                      child: const Icon(
                        Icons.hide_image_outlined,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.white), // Close icon button
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog when button is pressed
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd MMM yyyy')
          .format(parsedDate); // Example: Jan 15, 2025
    } catch (e) {
      return date; // In case of error, return the original string
    }
  }

  String formatTime(String time) {
    try {
      DateTime parsedTime = DateFormat('HH:mm:ss').parse(time);
      return DateFormat('hh:mm a').format(parsedTime); // Example: 12:26 PM
    } catch (e) {
      return time; // In case of error, return the original string
    }
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
