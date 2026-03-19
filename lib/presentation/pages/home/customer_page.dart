import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/main.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});
  static _CustomerPageState? _currentState;

  static void callFunction(int customerId) {
    _currentState?.onItemClick(customerId);
  }

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  final sideProvider =
      Provider.of<SidebarProvider>(navigatorKey.currentState!.context);

  @override
  void initState() {
    super.initState();
    CustomerPage._currentState = this;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      customerProvider.setSearchCriteria(
        '',
        '',
        '',
        '',
      );
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);

      customerProvider.getSearchCustomers(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      // Load all statuses by default (no ViewIn_Id) so the dropdown shows everything.
      // provider.getFollowUpStatus(context, '2');
      provider.getUserDetails(context);
      await provider.getFollowUpStatusCustomer(context);

      //search
      // searchController.addListener(() {
      //   customerProvider.selectDateFilterOption(null);
      //   customerProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   customerProvider.getSearchCustomers(query, '', '', '', context);
      // });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.setSearchCriteria(
        query,
        customerProvider.fromDateS,
        customerProvider.toDateS,
        customerProvider.status,
      );
      customerProvider.getSearchCustomers(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onItemClick(int customerId) {
    // final context = navigatorKey.currentState?.context;
    // if (context != null) {
    //   final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
    sideProvider.replaceWidgetCustomer(false, customerId.toString());
    // } else {
    //   print("Navigator context is null");
    // }
    // sideProvider
    //     .replaceWidgetCustomer(
    //     false, customerId.toString());
  }

  Future<void> loadExistingAudioFiles(List<AudioFileLead> audioFiless) async {
    final audioProvider =
        Provider.of<AudioFileProvider>(context, listen: false);

    // Clear any existing files first
    audioProvider.clearAudios();

    // Filter and load only audio files
    final audioFiles =
        audioFiless.where((file) => file.fileType == 'audio').toList();

    for (var audioFile in audioFiles) {
      try {
        // Create an AudioFile object with the remote URL
        final newAudioFile = AudioFile(
          data: Uint8List(0), // We'll use blobUrl for remote files
          name: audioFile.fileName ?? 'audio_file',
          extension: audioFile.filePath!.split('.').last.toLowerCase(),
          existingPath: audioFile.filePath, // Store the full URL
        );

        // For remote files, we'll use the URL directly for playback
        newAudioFile.blobUrl = audioFile.filePath;

        // Add to provider
        audioProvider.addExistingAudioFile(newAudioFile);

        print('Added existing audio file: ${audioFile.fileName}');
      } catch (e) {
        print('Error loading existing audio file: $e');
        // You might want to show a snackbar or toast here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading audio: ${audioFile.fileName}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final leadsProvider = Provider.of<LeadsProvider>(context);

    // Calculate dynamic heights for table
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 60.0;
    const searchBarHeight = 70.0;
    const paginationHeight = 60.0;
    const tableHeaderHeight = 50.0;

    final availableHeight = screenHeight -
        headerHeight -
        searchBarHeight -
        paginationHeight -
        tableHeaderHeight -
        40;
    final rowHeight = 48.0;
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppStyles.isWebScreen(context)
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0), // Further reduced vertical
                      child: Row(
                        children: [
                          const Text(
                            'Customers',
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFF152D70),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Flexible(child: Container()),
                          Container(
                            width: MediaQuery.of(context).size.width / 4,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: TextField(
                              controller: searchController,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: _onSearchChanged,
                              onSubmitted: (query) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                customerProvider.setSearchCriteria(
                                  query,
                                  customerProvider.fromDateS,
                                  customerProvider.toDateS,
                                  customerProvider.status,
                                );
                                customerProvider.getSearchCustomers(context);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search here....',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 11),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    customerProvider.setSearchCriteria(
                                      searchController.text,
                                      customerProvider.fromDateS,
                                      customerProvider.toDateS,
                                      customerProvider.status,
                                    );
                                    customerProvider
                                        .getSearchCustomers(context);
                                  },
                                  child: const Icon(Icons.search,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              customerProvider.toggleFilter();
                              print(customerProvider.isFilter);
                            },
                            icon: const Icon(Icons.filter_list),
                            label: Text(MediaQuery.of(context).size.width > 860
                                ? 'Filter'
                                : ''),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customerProvider.isFilter
                                  ? Colors.white
                                  : AppColors
                                      .primaryBlue, // Change foreground color
                              backgroundColor: customerProvider.isFilter
                                  ? const Color(0xFF5499D9)
                                  : Colors.white, // Change background color
                              side: BorderSide(
                                  color: customerProvider.isFilter
                                      ? const Color(0xFF5499D9)
                                      : AppColors
                                          .primaryBlue), // Change border color
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    )
                  //mobile design
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0), // Further reduced vertical
                      child: Wrap(
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Customers',
                            style: TextStyle(
                              fontSize: 24,
                              color: Color(0xFF152D70),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: TextField(
                              controller: searchController,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: _onSearchChanged,
                              onSubmitted: (query) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                customerProvider.setSearchCriteria(
                                  query,
                                  customerProvider.fromDateS,
                                  customerProvider.toDateS,
                                  customerProvider.status,
                                );
                                customerProvider.getSearchCustomers(context);
                              },
                              decoration: InputDecoration(
                                hintText: 'Search here....',
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 11),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    customerProvider.setSearchCriteria(
                                      searchController.text,
                                      customerProvider.fromDateS,
                                      customerProvider.toDateS,
                                      customerProvider.status,
                                    );
                                    customerProvider
                                        .getSearchCustomers(context);
                                  },
                                  child: const Icon(Icons.search,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          // const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              customerProvider.toggleFilter();
                              print(customerProvider.isFilter);
                            },
                            icon: const Icon(Icons.filter_list),
                            label: const Text('Filter'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: customerProvider.isFilter
                                  ? Colors.white
                                  : AppColors
                                      .primaryBlue, // Change foreground color
                              backgroundColor: customerProvider.isFilter
                                  ? const Color(0xFF5499D9)
                                  : Colors.white, // Change background color
                              side: BorderSide(
                                  color: customerProvider.isFilter
                                      ? const Color(0xFF5499D9)
                                      : AppColors
                                          .primaryBlue), // Change border color
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
              if (customerProvider.isFilter)
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: customerProvider.selectedStatus !=
                                                null &&
                                            customerProvider.selectedStatus != 0
                                        ? AppColors.primaryBlue
                                        : Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Text('Status: '),
                                  DropdownButton<int>(
                                    value: customerProvider.selectedStatus,
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
                                        provider.followUpData
                                            .map((status) =>
                                                DropdownMenuItem<int>(
                                                  value: status.statusId,
                                                  child: Text(
                                                    status.statusName ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ))
                                            .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        customerProvider.setStatus(
                                            newValue); // Update the status in the provider
                                      }
                                      String status = customerProvider
                                          .selectedStatus
                                          .toString();
                                      String fromDate =
                                          customerProvider.formattedFromDate;
                                      String toDate =
                                          customerProvider.formattedToDate;
                                      print(
                                          'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                      customerProvider.setSearchCriteria(
                                        customerProvider.search,
                                        fromDate,
                                        toDate,
                                        status,
                                      );
                                      customerProvider
                                          .getSearchCustomers(context);
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
                                      color: customerProvider.fromDate !=
                                                  null ||
                                              customerProvider.toDate != null
                                          ? AppColors.primaryBlue
                                          : Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    if (customerProvider.fromDate == null &&
                                        customerProvider.toDate == null)
                                      const Text('Follow Up Date: All'),
                                    if (customerProvider.fromDate != null &&
                                        customerProvider.toDate != null)
                                      Text(
                                          'Date : ${customerProvider.formattedFromDate} - ${customerProvider.formattedToDate}'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Colors.black45,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Spacer(),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     // Apply the selected filters (You can use values from the provider)
                            //     String status =
                            //         customerProvider.selectedStatus.toString();
                            //     String fromDate =
                            //         customerProvider.formattedFromDate;
                            //     String toDate = customerProvider.formattedToDate;
                            //     print(
                            //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                            //     customerProvider.setSearchCriteria(
                            //       customerProvider.search,
                            //       fromDate,
                            //       toDate,
                            //       status,
                            //     );
                            //     customerProvider.getSearchCustomers(context);
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
                            if (customerProvider.fromDate != null ||
                                customerProvider.toDate != null ||
                                (customerProvider.selectedStatus != null &&
                                    customerProvider.selectedStatus != 0) ||
                                customerProvider.search.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  customerProvider.selectDateFilterOption(null);
                                  customerProvider.removeStatus();
                                  searchController.clear();
                                  customerProvider.setSearchCriteria(
                                    '',
                                    '',
                                    '',
                                    '',
                                  );
                                  customerProvider.getSearchCustomers(context);
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
                      )
                    //mobile design
                    : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Wrap(
                          runSpacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: customerProvider.selectedStatus !=
                                                null &&
                                            customerProvider.selectedStatus != 0
                                        ? AppColors.primaryBlue
                                        : Colors.grey[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Status: '),
                                  DropdownButton<int>(
                                    value: customerProvider.selectedStatus,
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
                                        provider.followUpData
                                            .map((status) =>
                                                DropdownMenuItem<int>(
                                                  value: status.statusId,
                                                  child: Text(
                                                    status.statusName ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 14),
                                                  ),
                                                ))
                                            .toList(),
                                    onChanged: (int? newValue) {
                                      if (newValue != null) {
                                        customerProvider.setStatus(
                                            newValue); // Update the status in the provider
                                      }
                                      String status = customerProvider
                                          .selectedStatus
                                          .toString();
                                      String fromDate =
                                          customerProvider.formattedFromDate;
                                      String toDate =
                                          customerProvider.formattedToDate;
                                      print(
                                          'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                      customerProvider.setSearchCriteria(
                                        customerProvider.search,
                                        fromDate,
                                        toDate,
                                        status,
                                      );
                                      customerProvider
                                          .getSearchCustomers(context);
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
                                      color: customerProvider.fromDate !=
                                                  null ||
                                              customerProvider.toDate != null
                                          ? AppColors.primaryBlue
                                          : Colors.grey[300]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (customerProvider.fromDate == null &&
                                        customerProvider.toDate == null)
                                      const Text('Follow Up Date: All'),
                                    if (customerProvider.fromDate != null &&
                                        customerProvider.toDate != null)
                                      Text(
                                          'Date : ${customerProvider.formattedFromDate} - ${customerProvider.formattedToDate}'),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Colors.black45,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     // Apply the selected filters (You can use values from the provider)
                            //     String status =
                            //         customerProvider.selectedStatus.toString();
                            //     String fromDate =
                            //         customerProvider.formattedFromDate;
                            //     String toDate = customerProvider.formattedToDate;
                            //     print(
                            //         'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                            //     customerProvider.setSearchCriteria(
                            //       customerProvider.search,
                            //       fromDate,
                            //       toDate,
                            //       status,
                            //     );
                            //     customerProvider.getSearchCustomers(context);
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
                            if (customerProvider.fromDate != null ||
                                customerProvider.toDate != null ||
                                (customerProvider.selectedStatus != null &&
                                    customerProvider.selectedStatus != 0) ||
                                customerProvider.search.isNotEmpty)
                              ElevatedButton(
                                onPressed: () {
                                  customerProvider.selectDateFilterOption(null);
                                  customerProvider.removeStatus();
                                  searchController.clear();
                                  customerProvider.setSearchCriteria(
                                    '',
                                    '',
                                    '',
                                    '',
                                  );
                                  customerProvider.getSearchCustomers(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.textRed,
                                  side: BorderSide(color: AppColors.textRed),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 0,
                                  ),
                                ),
                                child: const Text('Reset'),
                              ),
                          ],
                        ),
                      ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0), // Further reduced vertical
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
                          if (AppStyles.isWebScreen(context))
                            Container(
                              height: tableHeaderHeight,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 0, 90, 69),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              6.0, // Match data row padding
                                          horizontal:
                                              12.0), // Compact horizontal
                                      child: Text('No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFFFFFFF))),
                                    ),
                                  ),
                                  // TableWidget(
                                  //     title: 'Order no',
                                  //     color: Color(0xFF607185)),
                                  TableWidget(
                                      flex: 3,
                                      title: 'Customer Name',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Mobile no',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Assigned Staff',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Remarks',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Follow-Up',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Follow Up Status',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Follow Up Date',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Action',
                                      padding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                ],
                              ),
                            ),
                          // Data Rows
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // To avoid scrolling issues when inside a parent widget
                              physics: AppStyles.isWebScreen(context)
                                  ? const NeverScrollableScrollPhysics()
                                  : const AlwaysScrollableScrollPhysics(),
                              itemCount: customerProvider
                                  .customerData.length, // Number of leads
                              itemBuilder: (context, index) {
                                var lead = customerProvider.customerData[index];
                                return GestureDetector(
                                  onTap: () {
                                    // sideprovider.replaceWidgetCustomer(
                                    //     false, lead.customerId.toString());
                                    // context.push(
                                    //     '${CustomerDetailsScreen.route}${lead.customerId.toString()}');
                                  },
                                  child: Container(
                                    height: AppStyles.isWebScreen(context)
                                        ? rowHeight
                                        : null,
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFF6F7F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    // Alternate row colors
                                    child: AppStyles.isWebScreen(context)
                                        ? Row(
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              // Padding(
                                              //   padding: const EdgeInsets.symmetric(
                                              //       vertical: 12.0, horizontal: 25.0),
                                              //   child: Text(lead.customerId.toString(),
                                              //       style: const TextStyle(
                                              //         fontWeight: FontWeight.bold,
                                              //       )),
                                              // ),
                                              SizedBox(
                                                width: 80,
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical:
                                                          6.0, // Compact vertical
                                                      horizontal: 12.0),
                                                  child: Text(
                                                      ((index + 1) +
                                                              customerProvider
                                                                  .startLimit -
                                                              1)
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      )),
                                                ),
                                              ),
                                              // TableWidget(title: lead.orderNo),
                                              TableWidget(
                                                flex: 3,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: InkWell(
                                                  onTap: () {
                                                    onItemClick(
                                                        lead.customerId);
                                                    // context.push(
                                                    //     '${CustomerDetailsScreen.route}${lead.customerId.toString()}');
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
                                                                        .min, // Ensures the Row takes only as much space as needed
                                                                children: [
                                                                  // Front image (before text)
                                                                  Icon(
                                                                    Icons
                                                                        .account_circle,
                                                                    size: 16,
                                                                    color: AppColors
                                                                        .primaryBlue,
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          8), // Space between the image and text
                                                                  Text(
                                                                    lead.customerName.length >
                                                                            20
                                                                        ? '${lead.customerName.substring(0, 20)}...'
                                                                        : lead
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
                                                                  const SizedBox(
                                                                      width:
                                                                          8), // Space between the text and back image
                                                                  // Back image (after text)
                                                                  Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .grey,
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                lead.customerName,
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
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.contactNumber),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.toUserName),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.remark),
                                              TableWidget(
                                                flex: 1,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: InkWell(
                                                  onTap: () async {
                                                    try {
                                                      final dropDownProvider =
                                                          Provider.of<
                                                                  DropDownProvider>(
                                                              context,
                                                              listen: false);
                                                      final settingsProvider =
                                                          Provider.of<
                                                                  SettingsProvider>(
                                                              context,
                                                              listen: false);

                                                      dropDownProvider
                                                              .selectedStatusId =
                                                          int.parse(lead
                                                              .statusId
                                                              .toString());
                                                      leadsProvider
                                                              .statusController
                                                              .text =
                                                          lead.statusName;
                                                      print(
                                                          'status id ${lead.statusId}');
                                                      print(
                                                          'status name ${lead.statusName}');
                                                      dropDownProvider
                                                              .selectedUserId =
                                                          int.parse(lead
                                                              .toUserId
                                                              .toString());
                                                      leadsProvider
                                                          .searchUserController
                                                          .text = lead.toUserName;
                                                      print(
                                                          'assign to ${lead.toUserName}');
                                                      print(
                                                          'assign to id ${lead.toUserId}');
                                                      leadsProvider
                                                          .setCutomerId(
                                                              lead.customerId);
                                                      leadsProvider
                                                              .branchController
                                                              .text =
                                                          lead.branchName;
                                                      settingsProvider
                                                              .selectedBranchId =
                                                          lead.branchId;
                                                      print(
                                                          'branch ${lead.branchId}');
                                                      print(
                                                          'branch name ${lead.branchName}');
                                                      leadsProvider
                                                              .departmentController
                                                              .text =
                                                          lead.departmentName;
                                                      settingsProvider
                                                              .selectedDepartmentId =
                                                          int.tryParse(lead
                                                                  .departmentId
                                                                  .toString()) ??
                                                              0;
                                                      print(
                                                          'department id ${lead.departmentId}');
                                                      print(
                                                          'department name ${lead.departmentName}');

                                                      leadsProvider
                                                          .nextFollowUpDateController
                                                          .text = lead
                                                              .nextFollowUpDate
                                                              .isNotEmpty
                                                          ? _formatDateSafely(lead
                                                              .nextFollowUpDate)
                                                          : '';
                                                      leadsProvider
                                                          .messageController
                                                          .clear();
                                                      dropDownProvider
                                                          .filterStaffByBranchAndDepartment(
                                                        branchId: lead.branchId,
                                                        departmentId:
                                                            int.tryParse(lead
                                                                    .departmentId
                                                                    .toString()) ??
                                                                0,
                                                      );
                                                    } catch (e) {}
                                                    showDialog(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext
                                                              context) =>
                                                          AddFollowupDialog(
                                                        customerName:
                                                            lead.customerName,
                                                      ),
                                                    );
                                                  },
                                                  child: Icon(
                                                    lead.lateFollowUp == '0'
                                                        ? Icons.event_available
                                                        : Icons.event_busy,
                                                    color:
                                                        lead.lateFollowUp == '0'
                                                            ? Colors.green
                                                            : Colors.red,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                // width: 200,
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Container(
                                                  padding: lead
                                                          .statusName.isNotEmpty
                                                      ? const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4)
                                                      : const EdgeInsets.all(0),
                                                  decoration: BoxDecoration(
                                                    // color: StatusUtils.getStatusColor(
                                                    //     int.parse(lead.statusId)),
                                                    color: parseColor(
                                                            lead.colorCode)
                                                        .withOpacity(0.1)
                                                        .withAlpha(30),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6),
                                                    border: Border.all(
                                                        color: Colors.black45,
                                                        width: 0.1),
                                                  ),
                                                  child: Text(
                                                    lead.statusName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: parseColor(
                                                          lead.colorCode),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      // color:
                                                      //     StatusUtils.getStatusTextColor(
                                                      //         int.parse(lead.statusId)),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: (lead.nextFollowUpDate
                                                          .isNotEmpty)
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(lead
                                                                  .nextFollowUpDate))
                                                      : ''),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: _HoverMenuAnchor(
                                                  builder: (context, controller,
                                                      child) {
                                                    return IconButton(
                                                      onPressed: () {
                                                        if (controller.isOpen) {
                                                          controller.close();
                                                        } else {
                                                          controller.open();
                                                        }
                                                      },
                                                      icon: const Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          size: 20,
                                                          color: Colors.grey),
                                                      padding: EdgeInsets.zero,
                                                    );
                                                  },
                                                  menuChildren: [
                                                    MenuItemButton(
                                                      onPressed: () =>
                                                          _handleLeadAction(
                                                              'edit', lead),
                                                      child: const Row(
                                                        children: [
                                                          Icon(Icons.edit,
                                                              size: 18,
                                                              color:
                                                                  Colors.blue),
                                                          SizedBox(width: 8),
                                                          Text('Edit Customer'),
                                                        ],
                                                      ),
                                                    ),
                                                    MenuItemButton(
                                                      onPressed: () =>
                                                          _handleLeadAction(
                                                              'quotation',
                                                              lead),
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                              Icons
                                                                  .request_quote,
                                                              size: 18,
                                                              color: Colors
                                                                  .orange),
                                                          SizedBox(width: 8),
                                                          Text('Quotation'),
                                                        ],
                                                      ),
                                                    ),
                                                    MenuItemButton(
                                                      onPressed: () =>
                                                          _handleLeadAction(
                                                              'document', lead),
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                              Icons.description,
                                                              size: 18,
                                                              color: Colors
                                                                  .purple),
                                                          SizedBox(width: 8),
                                                          Text('Document'),
                                                        ],
                                                      ),
                                                    ),
                                                    MenuItemButton(
                                                      onPressed: () =>
                                                          _handleLeadAction(
                                                              'task', lead),
                                                      child: const Row(
                                                        children: [
                                                          Icon(Icons.add_task,
                                                              size: 18,
                                                              color:
                                                                  Colors.teal),
                                                          SizedBox(width: 8),
                                                          Text('Task'),
                                                        ],
                                                      ),
                                                    ),
                                                    MenuItemButton(
                                                      onPressed: () =>
                                                          _handleLeadAction(
                                                              'delete', lead),
                                                      child: const Row(
                                                        children: [
                                                          Icon(Icons.delete,
                                                              size: 18,
                                                              color:
                                                                  Colors.red),
                                                          SizedBox(width: 8),
                                                          Text('Delete'),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        //Mobile Design
                                        : Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              // mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // SizedBox(
                                                //   width: 80,
                                                //   child: Padding(
                                                //     padding:
                                                //         const EdgeInsets.symmetric(
                                                //             vertical: 12.0,
                                                //             horizontal: 25.0),
                                                //     child: Text(
                                                //         ((index + 1) +
                                                //                 leadsProvider
                                                //                     .startLimit -
                                                //                 1)
                                                //             .toString(),
                                                //         style: const TextStyle(
                                                //           fontWeight: FontWeight.bold,
                                                //         )),
                                                //   ),
                                                // ),
                                                Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        // sideprovider
                                                        //     .replaceWidgetCustomer(
                                                        //         false,
                                                        //         lead.customerId
                                                        //             .toString());
                                                        context.push(
                                                            '${CustomerDetailsScreen.route}${lead.customerId.toString()}/${'true'}');
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
                                                                  .circular(50),
                                                        ),
                                                        constraints:
                                                            const BoxConstraints(
                                                          maxWidth:
                                                              120, // Set your desired max width here
                                                        ),
                                                        child: Text(
                                                          lead.customerName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      (lead.nextFollowUpDate
                                                              .isNotEmpty)
                                                          ? DateFormat(
                                                                  'dd MMM yyyy')
                                                              .format(DateTime
                                                                  .parse(lead
                                                                      .nextFollowUpDate))
                                                          : '',
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  lead.contactNumber,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Assigned Staff',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: AppColors
                                                                  .textGrey4),
                                                        ),
                                                        Text(
                                                          lead.toUserName,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Text(
                                                  lead.remark.trim(),
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Follow Up  ',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .textGrey4),
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        final dropDownProvider =
                                                            Provider.of<
                                                                    DropDownProvider>(
                                                                context,
                                                                listen: false);
                                                        final settingsProvider =
                                                            Provider.of<
                                                                    SettingsProvider>(
                                                                context,
                                                                listen: false);
                                                        dropDownProvider
                                                                .selectedStatusId =
                                                            int.parse(lead
                                                                .statusId
                                                                .toString());
                                                        leadsProvider
                                                                .statusController
                                                                .text =
                                                            lead.statusName;
                                                        print(
                                                            'status id ${lead.statusId}');
                                                        print(
                                                            'status name ${lead.statusName}');
                                                        dropDownProvider
                                                                .selectedUserId =
                                                            int.parse(lead
                                                                .toUserId
                                                                .toString());
                                                        leadsProvider
                                                            .searchUserController
                                                            .text = lead.toUserName;
                                                        print(
                                                            'assign to ${lead.toUserName}');
                                                        print(
                                                            'assign to id ${lead.toUserId}');
                                                        leadsProvider
                                                            .setCutomerId(lead
                                                                .customerId);
                                                        leadsProvider
                                                                .branchController
                                                                .text =
                                                            lead.branchName;
                                                        settingsProvider
                                                                .selectedBranchId =
                                                            lead.branchId;
                                                        print(
                                                            'branch ${lead.branchId}');
                                                        print(
                                                            'branch name ${lead.branchName}');
                                                        leadsProvider
                                                                .departmentController
                                                                .text =
                                                            lead.departmentName;
                                                        settingsProvider
                                                                .selectedDepartmentId =
                                                            int.tryParse(lead
                                                                    .departmentId
                                                                    .toString()) ??
                                                                0;
                                                        print(
                                                            'department id ${lead.departmentId}');
                                                        print(
                                                            'department name ${lead.departmentName}');

                                                        leadsProvider
                                                            .nextFollowUpDateController
                                                            .text = lead
                                                                .nextFollowUpDate
                                                                .isNotEmpty
                                                            ? _formatDateSafely(
                                                                lead.nextFollowUpDate)
                                                            : '';
                                                        leadsProvider
                                                            .messageController
                                                            .clear();
                                                        dropDownProvider
                                                            .filterStaffByBranchAndDepartment(
                                                          branchId:
                                                              lead.branchId,
                                                          departmentId:
                                                              int.tryParse(lead
                                                                      .departmentId
                                                                      .toString()) ??
                                                                  0,
                                                        );
                                                        showDialog(
                                                          barrierDismissible:
                                                              false,
                                                          context: context,
                                                          builder: (BuildContext
                                                                  context) =>
                                                              AddFollowupDialog(
                                                            customerName: lead
                                                                .customerName,
                                                          ),
                                                        );
                                                      },
                                                      child: Icon(
                                                        lead.lateFollowUp == '0'
                                                            ? Icons
                                                                .event_available
                                                            : Icons.event_busy,
                                                        color:
                                                            lead.lateFollowUp ==
                                                                    '0'
                                                                ? Colors.green
                                                                : Colors.red,
                                                        size: 20,
                                                      ),
                                                    ),
                                                    _HoverMenuAnchor(
                                                      builder: (context,
                                                          controller, child) {
                                                        return IconButton(
                                                          onPressed: () {
                                                            if (controller
                                                                .isOpen) {
                                                              controller
                                                                  .close();
                                                            } else {
                                                              controller
                                                                  .open();
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              size: 20,
                                                              color: Colors
                                                                  .grey),
                                                          padding:
                                                              EdgeInsets.zero,
                                                        );
                                                      },
                                                      menuChildren: [
                                                        MenuItemButton(
                                                          onPressed: () =>
                                                              _handleLeadAction(
                                                                  'edit', lead),
                                                          child: const Row(
                                                            children: [
                                                              Icon(Icons.edit,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .blue),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text(
                                                                  'Edit Customer'),
                                                            ],
                                                          ),
                                                        ),
                                                        MenuItemButton(
                                                          onPressed: () =>
                                                              _handleLeadAction(
                                                                  'quotation',
                                                                  lead),
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .request_quote,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .orange),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Quotation'),
                                                            ],
                                                          ),
                                                        ),
                                                        MenuItemButton(
                                                          onPressed: () =>
                                                              _handleLeadAction(
                                                                  'document',
                                                                  lead),
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .description,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .purple),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Document'),
                                                            ],
                                                          ),
                                                        ),
                                                        MenuItemButton(
                                                          onPressed: () =>
                                                              _handleLeadAction(
                                                                  'task', lead),
                                                          child: const Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .add_task,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .teal),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Task'),
                                                            ],
                                                          ),
                                                        ),
                                                        MenuItemButton(
                                                          onPressed: () =>
                                                              _handleLeadAction(
                                                                  'delete',
                                                                  lead),
                                                          child: const Row(
                                                            children: [
                                                              Icon(Icons.delete,
                                                                  size: 18,
                                                                  color: Colors
                                                                      .red),
                                                              SizedBox(
                                                                  width: 8),
                                                              Text('Delete'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      padding: lead.statusName
                                                              .isNotEmpty
                                                          ? const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 8,
                                                              vertical: 4)
                                                          : const EdgeInsets
                                                              .all(0),
                                                      decoration: BoxDecoration(
                                                        // color: StatusUtils.getStatusColor(
                                                        //     int.parse(lead.statusId)),
                                                        color: parseColor(
                                                                lead.colorCode)
                                                            .withOpacity(0.1)
                                                            .withAlpha(30),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                        border: Border.all(
                                                            color:
                                                                Colors.black45,
                                                            width: 0.1),
                                                      ),
                                                      child: Text(
                                                        lead.statusName,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style: TextStyle(
                                                          color: parseColor(
                                                              lead.colorCode),
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          // color:
                                                          //     StatusUtils.getStatusTextColor(
                                                          //         int.parse(lead.statusId)),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildPaginationControls(context),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    // Calculate the range for the current page
    int startItem = customerProvider.startLimit; // Now it starts from 1
    int endItem = (customerProvider.endLimit < customerProvider.totalCount)
        ? customerProvider.endLimit
        : customerProvider.totalCount; // Ensure it doesn't exceed total count

    return SizedBox(
      height: 60, // Reduced from 100
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: customerProvider.startLimit > 1
                ? () {
                    customerProvider.fetchPreviousPage(context);
                  }
                : null,
          ),
          Text(
            'Showing $startItem / $endItem of ${customerProvider.totalCount}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: customerProvider.endLimit < customerProvider.totalCount
                ? () {
                    customerProvider.fetchNextPage(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (contextx) => Consumer<CustomerProvider>(
        builder: (contextx, customerProvider, child) {
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
                            customerProvider.setDateFilter(title);
                            customerProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              customerProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: customerProvider.selectedDateFilterIndex ==
                                    index
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
                                customerProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: customerProvider.fromDate != null
                                  ? '${customerProvider.fromDate!.toLocal()}'
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
                                customerProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: customerProvider.toDate != null
                                  ? '${customerProvider.toDate!.toLocal()}'
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

                          customerProvider.formatDate();

                          print(customerProvider.formattedFromDate);
                          print(customerProvider.formattedToDate);
                          String status =
                              customerProvider.selectedStatus.toString();
                          String fromDate = customerProvider.formattedFromDate;
                          String toDate = customerProvider.formattedToDate;
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          customerProvider.setSearchCriteria(
                            customerProvider.search,
                            fromDate,
                            toDate,
                            status,
                          );
                          customerProvider.getSearchCustomers(context);
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
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          customerProvider.selectDateFilterOption(null);
                          String status =
                              customerProvider.selectedStatus.toString();
                          String fromDate = '';
                          String toDate = '';
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          customerProvider.setSearchCriteria(
                            customerProvider.search,
                            fromDate,
                            toDate,
                            status,
                          );
                          customerProvider.getSearchCustomers(context);
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

  void _handleLeadAction(String value, SearchLeadModel lead) async {
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    if (value == 'edit') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);
      await leadDetailsProvider.fetchLeadDetails(
          lead.customerId.toString(), context);

      leadsProvider.setCutomerId(int.tryParse(lead.customerId.toString()) ?? 0);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);

      if (leadDetailsProvider.leadDetails != null &&
          leadDetailsProvider.leadDetails!.isNotEmpty) {
        final leadDetails = leadDetailsProvider.leadDetails![0];
        leadsProvider.enquirySourceController.text =
            leadDetails.enquirySourceName.toString();
        dropDownProvider.selectedEnquirySourceId = leadDetails.enquirySourceId;
        await leadsProvider.getLeadDropdowns(context);
      }
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const NewLeadDrawerWidget(
            isEdit: true,
          );
        },
      );
    } else if (value == 'quotation') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => QuotationCreationWidget(
          isEdit: false,
          customerId: lead.customerId.toString(),
          quotationId: '0',
        ),
      );
    } else if (value == 'document') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => ImageUploadAlert(
          customerId: lead.customerId.toString(),
        ),
      );
    } else if (value == 'task') {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.customerId = lead.customerId.toString();
      customerDetailsProvider.clearTaskDetails();
      if (AppStyles.isWebScreen(context)) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => TaskCreationWidget(isEdit: false, taskId: '0'),
        );
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddTaskMobile(isEdit: false, taskId: '0')));
      }
    } else if (value == 'delete') {
      showConfirmationDialog(
        context: context,
        title: 'Delete Customer',
        content: 'Are you sure you want to delete this customer?',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () async {
          await leadsProvider.deleteLead(context, lead.customerId.toString());
          if (context.mounted) {
            Navigator.of(context).pop();
            customerProvider.getSearchCustomers(context);
          }
        },
      );
    }
  }

  String _formatDateSafely(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return ''; // Return an empty string if parsing fails
    }
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}

class _HoverMenuAnchor extends StatefulWidget {
  final Widget Function(BuildContext, MenuController, Widget?) builder;
  final List<Widget> menuChildren;

  const _HoverMenuAnchor({
    required this.builder,
    required this.menuChildren,
  });

  @override
  State<_HoverMenuAnchor> createState() => _HoverMenuAnchorState();
}

class _HoverMenuAnchorState extends State<_HoverMenuAnchor> {
  final MenuController _controller = MenuController();
  Timer? _hoverTimer;

  void _updateHover(bool isIn) {
    _hoverTimer?.cancel();
    if (isIn) {
      // Small 50ms delay before opening to ensure it's intentional
      _hoverTimer = Timer(const Duration(milliseconds: 50), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      // 200ms grace period to move pointer from button to menu
      _hoverTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted && _controller.isOpen) {
          _controller.close();
        }
      });
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _updateHover(true),
      onExit: (_) => _updateHover(false),
      child: MenuAnchor(
        controller: _controller,
        // Adjust vertically to overlap slightly for smoother transition
        alignmentOffset: const Offset(0, -5),
        builder: (context, controller, child) =>
            widget.builder(context, controller, child),
        menuChildren: widget.menuChildren.map((child) {
          return MouseRegion(
            onEnter: (_) => _updateHover(true),
            onExit: (_) => _updateHover(false),
            child: child,
          );
        }).toList(),
      ),
    );
  }
}
