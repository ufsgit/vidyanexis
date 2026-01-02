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
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

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
  final sideProvider =
      Provider.of<SidebarProvider>(navigatorKey.currentState!.context);

  @override
  void initState() {
    super.initState();
    CustomerPage._currentState = this;

    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      provider.getFollowUpStatus(context, '2');
      provider.getUserDetails(context);

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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  onItemClick(int customerId) {
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

  loadExistingAudioFiles(List<AudioFileLead> audioFiless) async {
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
                      padding: const EdgeInsets.all(16.0),
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
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (query) {
                                // customerProvider.selectDateFilterOption(null);
                                // customerProvider.removeStatus();
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
                                      // leadsProvider.selectDateFilterOption(null);
                                      // leadsProvider.removeStatus();
                                      print(query);
                                      if (customerProvider.search.isNotEmpty) {
                                        searchController.clear();
                                        customerProvider.setSearchCriteria(
                                          '',
                                          customerProvider.fromDateS,
                                          customerProvider.toDateS,
                                          customerProvider.status,
                                        );
                                        customerProvider
                                            .getSearchCustomers(context);
                                      } else {
                                        customerProvider.setSearchCriteria(
                                          query,
                                          customerProvider.fromDateS,
                                          customerProvider.toDateS,
                                          customerProvider.status,
                                        );
                                        customerProvider
                                            .getSearchCustomers(context);
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
                                    child: Text(
                                        customerProvider.search.isNotEmpty
                                            ? 'Clear'
                                            : 'Search'),
                                  ),
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
                      padding: const EdgeInsets.all(16.0),
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
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: TextField(
                              controller: searchController,
                              onSubmitted: (query) {
                                // customerProvider.selectDateFilterOption(null);
                                // customerProvider.removeStatus();
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
                                      String query = searchController.text;
                                      // leadsProvider.selectDateFilterOption(null);
                                      // leadsProvider.removeStatus();
                                      print(query);
                                      if (customerProvider.search.isNotEmpty) {
                                        searchController.clear();
                                        customerProvider.setSearchCriteria(
                                          '',
                                          customerProvider.fromDateS,
                                          customerProvider.toDateS,
                                          customerProvider.status,
                                        );
                                        customerProvider
                                            .getSearchCustomers(context);
                                      } else {
                                        customerProvider.setSearchCriteria(
                                          query,
                                          customerProvider.fromDateS,
                                          customerProvider.toDateS,
                                          customerProvider.status,
                                        );
                                        customerProvider
                                            .getSearchCustomers(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.textGrey4,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 0,
                                      ),
                                    ),
                                    child: Text(
                                        customerProvider.search.isNotEmpty
                                            ? 'Clear'
                                            : 'Search'),
                                  ),
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
                          if (AppStyles.isWebScreen(context))
                            Container(
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
                                          vertical: 12.0, horizontal: 25.0),
                                      child: Text('No.',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFFFFFFF))),
                                    ),
                                  ),
                                  // TableWidget(
                                  //     title: 'Order no',
                                  //     color: Color(0xFF607185)),
                                  TableWidget(
                                      flex: 3,
                                      title: 'Customer Name',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Mobile no',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Assigned Staff',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Remarks',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Follow-Up',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Follow Up Status',
                                      color: const Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 1,
                                      title: 'Follow Up Date',
                                      color: const Color(0xFFFFFFFF)),
                                ],
                              ),
                            ),
                          // Data Rows
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap:
                                  true, // To avoid scrolling issues when inside a parent widget
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // Disable scrolling here, as parent scroll handles it
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
                                                      vertical: 12.0,
                                                      horizontal: 25.0),
                                                  child: Text(
                                                      ((index + 1) +
                                                              customerProvider
                                                                  .startLimit -
                                                              1)
                                                          .toString(),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                ),
                                              ),
                                              // TableWidget(title: lead.orderNo),
                                              TableWidget(
                                                flex: 3,
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
                                                                  Image.asset(
                                                                    'assets/images/lead_profile.png', // Replace with your image asset or NetworkImage
                                                                    width:
                                                                        15, // You can adjust the size of the image
                                                                    height:
                                                                        15, // You can adjust the size of the image
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
                                                                          14,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      width:
                                                                          8), // Space between the text and back image
                                                                  // Back image (after text)
                                                                  Image.asset(
                                                                    'assets/images/forward.png', // Replace with your image asset or NetworkImage
                                                                    width:
                                                                        12, // Adjust the size of the image
                                                                    height:
                                                                        12, // Adjust the size of the image
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
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 1,
                                                  title: lead.contactNumber),
                                              TableWidget(
                                                  flex: 2,
                                                  title: lead.toUserName),
                                              TableWidget(
                                                  flex: 2,
                                                  title: '${lead.remark}'),
                                              TableWidget(
                                                flex: 1,
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
                                                  child: Image.asset(
                                                    lead.lateFollowUp == '0'
                                                        ? 'assets/images/followup_yes.png'
                                                        : 'assets/images/followup_no.png',
                                                    color:
                                                        lead.lateFollowUp == '0'
                                                            ? Colors.green
                                                            : Colors.red,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                // width: 200,
                                                flex: 2,
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
                                                  flex: 1,
                                                  title: (lead.nextFollowUpDate
                                                          .isNotEmpty)
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(lead
                                                                  .nextFollowUpDate))
                                                      : ''),
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
                                                      child: Image.asset(
                                                        lead.lateFollowUp == '0'
                                                            ? 'assets/images/followup_yes.png'
                                                            : 'assets/images/followup_no.png',
                                                        color:
                                                            lead.lateFollowUp ==
                                                                    '0'
                                                                ? Colors.green
                                                                : Colors.red,
                                                        width: 20,
                                                        height: 20,
                                                      ),
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
      height: 100,
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
