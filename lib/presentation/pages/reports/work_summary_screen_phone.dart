import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/controller/work_summary_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/work_report_screen_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';

class WorkSummaryPhone extends StatefulWidget {
  const WorkSummaryPhone({super.key});

  @override
  State<WorkSummaryPhone> createState() => _WorkSummaryPhoneState();
}

class _WorkSummaryPhoneState extends State<WorkSummaryPhone> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsProvider =
          Provider.of<WorkSummaryProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '');
      reportsProvider.getSearchWorkSummary(context);
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);

      searchProvider.stopSearch();
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      provider.getAMCStatus(context);
      provider.getUserDetails(context);
      reportsProvider.setFilter(false);

      //search
      // searchController.addListener(() {
      //   reportsProvider.selectDateFilterOption(null);
      //   reportsProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   reportsProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final reportsProvider = Provider.of<WorkSummaryProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    // final customerDetailsProvider =
    //     Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: CustomAppBar(
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              searchProvider.stopSearch();
              customerProvider.setFilter(false);
              leadProvider.setFilter(false);
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: 'Work Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {
          reportsProvider.toggleFilter();
        },
        onSearchTap: () {
          searchProvider.startSearch();
          reportsProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          reportsProvider.toggleFilter();

          searchProvider.stopSearch();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
          );
          reportsProvider.getSearchWorkSummary(context);
        },
        showFilterIcon: false,
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
            query,
            reportsProvider.fromDateS,
            reportsProvider.toDateS,
            reportsProvider.Status,
            reportsProvider.AssignedTo,
          );
          reportsProvider.getSearchWorkSummary(context);
        },
        searchController: searchController,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reportsProvider.isFilter)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Wrap(
                spacing: 10, // horizontal spacing between elements
                runSpacing: 10, // vertical spacing between lines
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      onClickTopButton(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: reportsProvider.fromDate != null ||
                                  reportsProvider.toDate != null
                              ? AppColors.primaryBlue
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize
                            .min, // Add this to prevent Row from expanding
                        children: [
                          if (reportsProvider.fromDate == null &&
                              reportsProvider.toDate == null)
                            const Text('Date: All'),
                          if (reportsProvider.fromDate != null &&
                              reportsProvider.toDate != null)
                            Text(
                                'Date : ${reportsProvider.formattedFromDate} - ${reportsProvider.formattedToDate}'),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: reportsProvider.selectedUser != null &&
                                reportsProvider.selectedUser != 0
                            ? AppColors.primaryBlue
                            : Colors.grey[300]!,
                      ),
                    ),
                    child: IntrinsicWidth(
                      // Add this to ensure proper width calculation
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Select User: '),
                          Flexible(
                            // Add Flexible to allow dropdown to shrink
                            child: DropdownButton<int>(
                              value: reportsProvider.selectedUser,
                              hint: const Text('All'),
                              isExpanded: true, // Add this to prevent overflow
                              items: [
                                    const DropdownMenuItem<int>(
                                      value: 0,
                                      child: Text(
                                        'All',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ] +
                                  provider.searchUserDetails
                                      .map((status) => DropdownMenuItem<int>(
                                            value: status.userDetailsId,
                                            child: ConstrainedBox(
                                              constraints: const BoxConstraints(
                                                  maxWidth: 150),
                                              child: Text(
                                                status.userDetailsName ?? '',
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ))
                                      .toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  reportsProvider.setUserFilterStatus(newValue);
                                }
                                String status =
                                    reportsProvider.selectedStatus.toString();
                                String assignedTo =
                                    reportsProvider.selectedUser.toString();
                                String fromDate =
                                    reportsProvider.formattedFromDate;
                                String toDate = reportsProvider.formattedToDate;
                                print(
                                    'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                reportsProvider.setTaskSearchCriteria(
                                  reportsProvider.Search,
                                  fromDate,
                                  toDate,
                                  status,
                                  assignedTo,
                                );
                                reportsProvider.getSearchWorkSummary(context);
                              },
                              underline: Container(),
                              isDense: true,
                              iconSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (reportsProvider.fromDate != null ||
                      reportsProvider.toDate != null ||
                      (reportsProvider.selectedStatus != null &&
                          reportsProvider.selectedStatus != 0) ||
                      (reportsProvider.selectedUser != null &&
                          reportsProvider.selectedUser != 0) ||
                      reportsProvider.Search.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
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
                        reportsProvider.getSearchWorkSummary(context);
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
            ),
          Expanded(
            child: ListView.builder(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
              itemCount: reportsProvider.taskReport.length,
              itemBuilder: (context, index) {
                var lead = reportsProvider.taskReport[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return WorkReportPhone(
                          userId: lead.userDetailsId.toString(),
                          userName: lead.toStaff.toString(),
                        );
                        // return WorkReportDetailsScreenPhone(
                        //   userId: lead.userDetailsId.toString(),
                        //   userName: lead.toStaff.toString(),
                        // );
                      },
                    ));
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 35,
                              height: 35,
                              decoration: BoxDecoration(
                                color: getAvatarColor(lead.toStaff),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  lead.toStaff.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lead.toStaff,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlack),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              lead.noOfFollowUp.toString(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Follow-Ups",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textGrey4),
                            ),
                            const SizedBox(width: 8),
                            Transform.rotate(
                              angle: 4.7,
                              child: Image.asset(
                                "assets/icons/arrow_down_icon.png",
                                width: 22,
                                height: 22,
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 2,
                        color: AppColors.grey,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<WorkSummaryProvider>(
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
                          reportsProvider.getSearchWorkSummary(context);
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
                          reportsProvider.getSearchWorkSummary(context);
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
