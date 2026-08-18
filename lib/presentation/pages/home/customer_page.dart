import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/utils/csv_function.dart';
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
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_multi_level_dropdown.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'dart:developer';
import 'package:go_router/go_router.dart';

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
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();
  Timer? _debounce;
  final sideProvider =
      Provider.of<SidebarProvider>(navigatorKey.currentState!.context);
  int userId = 0;
  String userName = '';
  String userType = '';

  @override
  void initState() {
    super.initState();
    CustomerPage._currentState = this;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";

      customerProvider.setSearchCriteria('', '', '');
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);

      customerProvider.getSearchCustomers(context, isSilent: true);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      // Load all statuses by default (no ViewIn_Id) so the dropdown shows everything.
      // provider.getFollowUpStatus(context, '2');
      provider.getUserDetails(context);
      await provider.getFollowUpStatusCustomer(context);
      provider.getEnquirySource(context);
      provider.getEnquiryFor(context);
      provider.getTaskType(context);

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
          query, customerProvider.fromDateS, customerProvider.toDateS);
      customerProvider.getSearchCustomers(context, isSilent: true);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void onItemClick(dynamic customerId) {
    if (AppStyles.isWebScreen(context)) {
      sideProvider.replaceWidgetCustomer(false, customerId.toString());
    } else {
      context.push('${CustomerDetailsScreen.route}$customerId/${'true'}');
    }
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
    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Calculate dynamic heights for table
    final screenHeight = MediaQuery.of(context).size.height;
    const headerHeight = 60.0;
    const searchBarHeight = 70.0;
    const paginationHeight = 60.0;
    const tableHeaderHeight = 40.0;

    final availableHeight = screenHeight -
        headerHeight -
        searchBarHeight -
        paginationHeight -
        tableHeaderHeight -
        40;
    final double rowHeight = AppStyles.isWebScreen(context) ? 36.0 : 48.0;
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
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, top: 8.0, bottom: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Entry Type Filter
                              if (settingsProvider.customerPermissionMeAndAll == 1)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        customerProvider.setEntryType('myown');
                                        customerProvider.getSearchCustomers(
                                            context,
                                            isSilent: true);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: customerProvider.entryType !=
                                                      'all'
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'ME',
                                          style: TextStyle(
                                            color: customerProvider.entryType !=
                                                    'all'
                                                ? AppColors.primaryBlue
                                                : Colors.grey,
                                            fontWeight:
                                                customerProvider.entryType !=
                                                        'all'
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () {
                                        customerProvider.setEntryType('all');
                                        customerProvider.getSearchCustomers(
                                            context,
                                            isSilent: true);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: customerProvider.entryType ==
                                                      'all'
                                                  ? AppColors.primaryBlue
                                                  : Colors.transparent,
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'ALL',
                                          style: TextStyle(
                                            color: customerProvider.entryType ==
                                                    'all'
                                                ? AppColors.primaryBlue
                                                : Colors.grey,
                                            fontWeight:
                                                customerProvider.entryType ==
                                                        'all'
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              Container(
                                width: 280,
                                height: 38,
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
                                child: TextField(
                                  controller: searchController,
                                  focusNode: searchFocusNodeWeb,
                                  textAlignVertical: TextAlignVertical.center,
                                  onTap: () {
                                    Future.microtask(() {
                                      if (searchController.text.isNotEmpty &&
                                          searchController
                                                  .selection.baseOffset ==
                                              0 &&
                                          searchController
                                                  .selection.extentOffset ==
                                              searchController.text.length) {
                                        searchController.selection =
                                            TextSelection.collapsed(
                                                offset: searchController
                                                    .text.length);
                                      }
                                    });
                                  },
                                  onSubmitted: (query) {
                                    if (_debounce?.isActive ?? false) {
                                      _debounce!.cancel();
                                    }
                                    customerProvider.setSearchCriteria(
                                      query,
                                      customerProvider.fromDateS,
                                      customerProvider.toDateS,
                                    );
                                    customerProvider.getSearchCustomers(context,
                                        isSilent: true);
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Search here...',
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
                                        if (_debounce?.isActive ?? false) {
                                          _debounce!.cancel();
                                        }
                                        customerProvider.setSearchCriteria(
                                          searchController.text,
                                          customerProvider.fromDateS,
                                          customerProvider.toDateS,
                                        );
                                        customerProvider.getSearchCustomers(
                                            context,
                                            isSilent: true);
                                      },
                                      child: const Icon(Icons.search,
                                          color: Color(0xFF64748B), size: 18),
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuButton<int>(
                                icon: const Icon(Icons.sort,
                                    color: Color(0xFF64748B)),
                                tooltip: 'Sort By',
                                onSelected: (int value) {
                                  customerProvider.setSortOption(
                                      value, context);
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem(value: 0, child: Text('Default')),
                                  const PopupMenuItem(value: 9, child: Text('Latest')),
                                  const PopupMenuItem(value: 1, child: Text('ID No (Descending)')),
                                  const PopupMenuItem(value: 2, child: Text('ID No (Ascending)')),
                                  const PopupMenuItem(value: 3, child: Text('Creation Date (Newest)')),
                                  const PopupMenuItem(value: 4, child: Text('Creation Date (Oldest)')),
                                  const PopupMenuItem(value: 5, child: Text('Followup Date (Newest)')),
                                  const PopupMenuItem(value: 6, child: Text('Followup Date (Oldest)')),
                                  const PopupMenuItem(value: 7, child: Text('Name (A-Z)')),
                                  const PopupMenuItem(value: 8, child: Text('Name (Z-A)')),
                                ],
                              ),
                              CustomFilterButton(
                                onPressed: () {
                                  customerProvider.toggleFilter();
                                },
                                isFilter: customerProvider.isFilter,
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, color: Color(0xFF64748B), size: 20),
                                onPressed: () {
                                  customerProvider.setSearchCriteria(
                                    searchController.text,
                                    customerProvider.fromDateS,
                                    customerProvider.toDateS,
                                  );
                                  customerProvider.getSearchCustomers(
                                      context,
                                      isSilent: true);
                                },
                                tooltip: 'Refresh',
                              ),
                            if (settingsProvider.menuIsSaveMap[167].toString() == '1')
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (customerProvider.customerData.isNotEmpty) {
                                    exportToExcel(
                                      headers: [
                                        'Customer Code',
                                        'Customer Name',
                                        'Mobile No',
                                        'Email',
                                        'Enquiry For',
                                        'Enquiry Source',
                                        'Assigned To',
                                        'Next Follow-up Date',
                                        'Status',
                                        'Total Project Cost',
                                      ],
                                      data: customerProvider.customerData.map((cust) {
                                        return {
                                          'Customer Code': cust.getDisplayLeadCode(settingsProvider.leadCodeWithEnquiryCode),
                                          'Customer Name': cust.customerName,
                                          'Mobile No': cust.contactNumber,
                                          'Email': cust.email,
                                          'Enquiry For': cust.enquiryFor,
                                          'Enquiry Source': cust.enquirySourceName,
                                          'Assigned To': cust.toUserName,
                                          'Next Follow-up Date': cust.nextFollowUpDate,
                                          'Status': cust.statusName,
                                          'Total Project Cost': cust.totalProjectCost,
                                        };
                                      }).toList(),
                                      fileName: 'Customers_Export',
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No data to export')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.file_download, size: 16),
                                label: Text(
                                  'Export Excel',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.whiteColor,
                                  foregroundColor: AppColors.secondaryBlue,
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          Container(
                            width: double.infinity,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: TextField(
                              controller: searchController,
                              focusNode: searchFocusNodeMobile,
                              textAlignVertical: TextAlignVertical.center,
                              onTap: () {
                                Future.microtask(() {
                                  if (searchController.text.isNotEmpty &&
                                      searchController.selection.baseOffset ==
                                          0 &&
                                      searchController.selection.extentOffset ==
                                          searchController.text.length) {
                                    searchController.selection =
                                        TextSelection.collapsed(
                                            offset:
                                                searchController.text.length);
                                  }
                                });
                              },
                              onSubmitted: (query) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce!.cancel();
                                }
                                customerProvider.setSearchCriteria(
                                  query,
                                  customerProvider.fromDateS,
                                  customerProvider.toDateS,
                                );
                                customerProvider.getSearchCustomers(context,
                                    isSilent: true);
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
                                    );
                                    customerProvider.getSearchCustomers(context,
                                        isSilent: true);
                                  },
                                  child: const Icon(Icons.search,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          PopupMenuButton<int>(
                            icon: const Icon(Icons.sort,
                                color: Color(0xFF152D70)),
                            tooltip: 'Sort By',
                            onSelected: (int value) {
                              customerProvider.setSortOption(value, context);
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(value: 0, child: Text('Default')),
                              const PopupMenuItem(value: 9, child: Text('Latest')),
                              const PopupMenuItem(value: 1, child: Text('ID No (Descending)')),
                              const PopupMenuItem(value: 2, child: Text('ID No (Ascending)')),
                              const PopupMenuItem(value: 3, child: Text('Creation Date (Newest)')),
                              const PopupMenuItem(value: 4, child: Text('Creation Date (Oldest)')),
                              const PopupMenuItem(value: 5, child: Text('Followup Date (Newest)')),
                              const PopupMenuItem(value: 6, child: Text('Followup Date (Oldest)')),
                              const PopupMenuItem(value: 7, child: Text('Name (A-Z)')),
                              const PopupMenuItem(value: 8, child: Text('Name (Z-A)')),
                            ],
                          ),
                          const SizedBox(width: 8),
                          CustomFilterButton(
                            onPressed: () {
                              customerProvider.toggleFilter();
                              print(customerProvider.isFilter);
                            },
                            isFilter: customerProvider.isFilter,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
              if (customerProvider.isFilter)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildStatusFilter(customerProvider, provider),
                      GestureDetector(
                        onTap: () {
                          onClickTopButton(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: customerProvider.fromDate != null ||
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
                      _buildAssignedStaffFilter(customerProvider),
                      _buildEnquiryForFilter(customerProvider),
                      _buildEnquirySourceFilter(customerProvider),
                      _buildBranchFilter(customerProvider),
                      if (customerProvider.fromDate != null ||
                          customerProvider.toDate != null ||
                          (customerProvider.selectedStatusIds.isNotEmpty &&
                              customerProvider.selectedStatusIds.first != 0) ||
                          (customerProvider.selectedUser != null &&
                              customerProvider.selectedUser != 0) ||
                          (customerProvider.selectedEnquiryFor != null &&
                              customerProvider.selectedEnquiryFor != 0) ||
                          (customerProvider.selectedEnquirySource != null &&
                              customerProvider.selectedEnquirySource != 0) ||
                          (customerProvider.selectedBranch != null &&
                              customerProvider.selectedBranch != 0) ||
                          customerProvider.search.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            customerProvider.selectDateFilterOption(null);
                            customerProvider.removeStatus();
                            customerProvider.setEntryType('myown');
                            searchController.clear();
                            customerProvider.setSearchCriteria('', '', '');
                            customerProvider.getSearchCustomers(context,
                                isSilent: true);
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
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
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 0,
                      bottom: 4.0), // Further reduced vertical
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
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
                          // Header Row (Table Column Titles)
                          if (AppStyles.isWebScreen(context))
                            Container(
                              height: tableHeaderHeight,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  TableWidget(
                                    width: 80,
                                    title: 'Sl No.',
                                    fontWeight: FontWeight.bold,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 12.0),
                                    color: Color(0xFFFFFFFF),
                                  ),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Lead Code',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Customer Name',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Address',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Mobile no',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Assigned Staff',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Consumer No.',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Remarks',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Follow Up Status',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Follow Up Date',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  TableWidget(
                                      flex: 2,
                                      title: 'Duration',
                                      fontWeight: FontWeight.bold,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      color: Color(0xFFFFFFFF)),
                                  if (settingsProvider.menuIsViewMap[142] == 1)
                                    TableWidget(
                                        flex: 2,
                                        title: 'Location',
                                        fontWeight: FontWeight.bold,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 8.0),
                                        color: Color(0xFFFFFFFF)),
                                ],
                              ),
                            ),
                          // Data Rows
                          Expanded(
                            child: ListView.builder(
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
                                    height: rowHeight,
                                    decoration: BoxDecoration(
                                      color: index % 2 == 0
                                          ? Colors.white
                                          : const Color(0xFFF6F7F9),
                                      borderRadius: BorderRadius.circular(4),
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
                                              TableWidget(
                                                width: 80,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 12.0),
                                                title: ((index + 1) +
                                                        customerProvider
                                                            .startLimit -
                                                        1)
                                                    .toString(),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 6.0, horizontal: 8.0),
                                                title: lead.getDisplayLeadCode(settingsProvider.leadCodeWithEnquiryCode),
                                              ),
                                              // TableWidget(title: lead.orderNo),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 8.0),
                                                data: Row(
                                                  children: [
                                                    Expanded(
                                                      child: InkWell(
                                                        onTap: () =>
                                                            onItemClick(lead
                                                                .customerId),
                                                        child: Tooltip(
                                                          message:
                                                              lead.customerName,
                                                          child: Text(
                                                            lead.customerName,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.blue,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    _HoverMenuAnchor(
                                                      builder: (context,
                                                          controller,
                                                          onHover,
                                                          child) {
                                                        return IconButton(
                                                          onPressed: () {
                                                            if (controller
                                                                .isOpen) {
                                                              controller
                                                                  .close();
                                                            } else {
                                                              controller.open();
                                                            }
                                                          },
                                                          icon: const Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey),
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              const BoxConstraints(),
                                                        );
                                                      },
                                                      menuChildren: [
                                                        if (settingsProvider
                                                                    .menuIsSaveMap[
                                                                13] ==
                                                            1)
                                                          (onHover) =>
                                                              MultiLevelHoverMenu(
                                                                isSubMenu:
                                                                    false,
                                                                title:
                                                                    'Create Task',
                                                                onHoverChange:
                                                                    (hovering) {
                                                                  onHover(
                                                                      hovering);
                                                                },
                                                                leadingIcon: const Icon(
                                                                    Icons
                                                                        .add_task,
                                                                    size: 18,
                                                                    color: Colors
                                                                        .teal),
                                                                children: provider
                                                                    .taskType
                                                                    .where((taskType) =>
                                                                        taskType
                                                                            .manualCreation ==
                                                                        1)
                                                                    .map(
                                                                        (taskType) {
                                                                  final users = provider
                                                                      .searchUserDetails
                                                                      .where(
                                                                          (user) {
                                                                    return user
                                                                            .departmentId
                                                                            .toString() ==
                                                                        taskType
                                                                            .departmentIds
                                                                            .toString();
                                                                  }).toList();

                                                                  if (users
                                                                      .isEmpty) {
                                                                    return MenuItemButton(
                                                                      onPressed:
                                                                          null,
                                                                      child: Text(
                                                                          taskType
                                                                              .taskTypeName),
                                                                    );
                                                                  }

                                                                  return MultiLevelHoverMenu(
                                                                    title: taskType
                                                                        .taskTypeName,
                                                                    children:
                                                                        users.map(
                                                                            (user) {
                                                                      return MenuItemButton(
                                                                        onPressed:
                                                                            () {
                                                                          _quickSaveTask(
                                                                              lead,
                                                                              taskType,
                                                                              user);
                                                                        },
                                                                        child: Text(
                                                                            user.userDetailsName),
                                                                      );
                                                                    }).toList(),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                        if (settingsProvider
                                                                    .menuIsSaveMap[
                                                                16] ==
                                                            1)
                                                          (onHover) =>
                                                                MenuItemButton(
                                                                  onPressed: () =>
                                                                      _handleLeadAction(
                                                                          'quotation',
                                                                          lead),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .request_quote,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .orange),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Text(
                                                                          'Quotation'),
                                                                    ],
                                                                  ),
                                                                ),
                                                          if (settingsProvider
                                                                      .menuIsViewMap[
                                                                  16] ==
                                                              1)
                                                            (onHover) =>
                                                                MenuItemButton(
                                                                  onPressed: () =>
                                                                      _handleLeadAction(
                                                                          'quotation_list_tab',
                                                                          lead),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .list_alt,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .orangeAccent),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Text(
                                                                          'Quotation list'),
                                                                    ],
                                                                  ),
                                                                ),
                                                          if (settingsProvider
                                                                      .menuIsSaveMap[
                                                                  19] ==
                                                              1)
                                                            (onHover) =>
                                                                MenuItemButton(
                                                                  onPressed: () =>
                                                                      _handleLeadAction(
                                                                          'document',
                                                                          lead),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .description,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .purple),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Text(
                                                                          'Document'),
                                                                    ],
                                                                  ),
                                                                ),
                                                          if (settingsProvider
                                                                      .menuIsViewMap[
                                                                  19] ==
                                                              1)
                                                            (onHover) =>
                                                                MenuItemButton(
                                                                  onPressed: () =>
                                                                      _handleLeadAction(
                                                                          'documents_tab',
                                                                          lead),
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .folder,
                                                                          size:
                                                                              18,
                                                                          color: Colors
                                                                              .blue),
                                                                      const SizedBox(
                                                                          width:
                                                                              8),
                                                                      const Text(
                                                                          'Documents Tab'),
                                                                    ],
                                                                  ),
                                                                ),
                                                        if (settingsProvider
                                                                    .menuIsEditMap[
                                                                4] ==
                                                            1)
                                                          (onHover) =>
                                                              MenuItemButton(
                                                                onPressed: () =>
                                                                    _handleLeadAction(
                                                                        'edit',
                                                                        lead),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .edit,
                                                                        size:
                                                                            18,
                                                                        color: Colors
                                                                            .blue),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    const Text(
                                                                        'Edit Customer'),
                                                                  ],
                                                                ),
                                                              ),
                                                        if (settingsProvider
                                                                    .menuIsDeleteMap[
                                                                4] ==
                                                            1)
                                                          (onHover) =>
                                                              MenuItemButton(
                                                                onPressed: () =>
                                                                    _handleLeadAction(
                                                                        'delete',
                                                                        lead),
                                                                child: Row(
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .delete,
                                                                        size:
                                                                            18,
                                                                        color: Colors
                                                                            .red),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    const Text(
                                                                        'Delete'),
                                                                  ],
                                                                ),
                                                              ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              TableWidget(
                                                flex: 2,
                                                fontSize: 12,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 8.0),
                                                data: Tooltip(
                                                  message: lead.displayAddress,
                                                  child: Text(
                                                    lead.displayAddress,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.contactNumber),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.toUserName),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.consumerNo),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  title: lead.remark),
                                              TableWidget(
                                                flex: 2,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0),
                                                data: InkWell(
                                                  onTap: () => _onStatusClick(
                                                      context, lead),
                                                  child: Container(
                                                    padding: lead.statusName
                                                            .isNotEmpty
                                                        ? const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4)
                                                        : EdgeInsets.zero,
                                                    decoration: BoxDecoration(
                                                      color: parseColor(
                                                              lead.colorCode)
                                                          .withOpacity(0.12),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      border: Border.all(
                                                          color: parseColor(lead
                                                                  .colorCode)
                                                              .withOpacity(0.5),
                                                          width: 0.5),
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
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  title: lead.nextFollowUpDate
                                                          .isNotEmpty
                                                      ? lead.nextFollowUpDate
                                                          .toDayMonthYearFormat()
                                                      : ''),
                                              TableWidget(
                                                  flex: 2,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  title: lead.leadDuration),
                                              if (settingsProvider
                                                      .menuIsViewMap[142] ==
                                                  1)
                                                TableWidget(
                                                    flex: 2,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.normal,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0),
                                                    title: lead.locationName ??
                                                        ''),
                                            ],
                                          )
                                        //Mobile Design
                                        : Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 12),
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () =>
                                                              onItemClick(lead
                                                                  .customerId),
                                                          child: Text(
                                                            lead.customerName,
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        lead.nextFollowUpDate
                                                            .toFormattedDate(),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              lead.lateFollowUp ==
                                                                      '0'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'To: ${lead.toUserName}',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors
                                                            .grey.shade600),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  if (lead.remark.isNotEmpty)
                                                    Text(
                                                      lead.remark,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.black87),
                                                    ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      InkWell(
                                                        onTap: () =>
                                                            _onStatusClick(
                                                                context, lead),
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: parseColor(lead
                                                                    .colorCode)
                                                                .withOpacity(
                                                                    0.15),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            border: Border.all(
                                                                color: parseColor(
                                                                    lead.colorCode)),
                                                          ),
                                                          child: Text(
                                                            lead.statusName,
                                                            style: TextStyle(
                                                              color: parseColor(
                                                                  lead.colorCode),
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
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
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                          );
                          customerProvider.getSearchCustomers(context,
                              isSilent: true);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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
                          );
                          customerProvider.getSearchCustomers(context,
                              isSilent: true);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
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
    } else if (value == 'quotation_list_tab') {
      CustomerDetailsProvider customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.setCustomerId(lead.customerId);
      customerDetailsProvider.setInitialTabName("Quotations");
      final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
      sideProvider.name = 'Customers /';

      context.push('/customerDetails/${lead.customerId}/false');
    } else if (value == 'document') {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => ImageUploadAlert(
          customerId: lead.customerId.toString(),
        ),
      );
    } else if (value == 'documents_tab') {
      CustomerDetailsProvider customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.setCustomerId(lead.customerId);
      customerDetailsProvider.setInitialTabName("Documents");
      final sideProvider = Provider.of<SidebarProvider>(context, listen: false);
      sideProvider.name = 'Customers /';

      context.push('/customerDetails/${lead.customerId}/false');
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
                builder: (context) =>
                    AddTaskMobile(isEdit: false, taskId: '0')));
      }
    } else if (value == 'delete') {
      showConfirmationDialog(
        context: context,
        title: 'Delete Customer',
        content: 'Are you sure you want to delete this customer?',
        onCancel: () => Navigator.of(context).pop(),
        onConfirm: () async {
          Navigator.of(context).pop(); // Close confirmation dialog first
          await leadsProvider.deleteLead(context, lead.customerId.toString());
          if (context.mounted) {
            customerProvider.getSearchCustomersNoContext();
          }
        },
      );
    }
  }

  Future<void> _quickSaveTask(SearchLeadModel lead, TaskTypeModel taskType,
      SearchUserDetails user) async {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    customerDetailsProvider.customerId = lead.customerId.toString();
    customerDetailsProvider.clearTaskDetails();

    // Set task type
    customerDetailsProvider.updateTaskType(
        taskType.taskTypeId, taskType.taskTypeName);

    // Set default AMC status if any
    final defaultStatusId = taskType.defaultStatusId;
    customerDetailsProvider.updateAMCStatus(
        defaultStatusId != 0 ? defaultStatusId : 1, '');

    // Set user
    final userInTask = UserInTaskModel(
        userDetailsId: user.userDetailsId,
        userDetailsName: user.userDetailsName);
    customerDetailsProvider.addAssignedWorker(userInTask);

    // Perform save task
    await customerDetailsProvider.saveTask(
      '0',
      '0',
      taskType.taskTypeId.toString(),
      '', // description
      DateFormat('dd MMM yyyy').format(
          DateTime.now().add(Duration(days: taskType.duration))), // date
      DateFormat('HH:mm').format(DateTime.now()), // time
      user.userDetailsId.toString(), // assignedWorker
      context,
      false, // isEdit
      [], // audioFiles
      dismissDialog: false,
    );

    // Refresh customer list
    if (mounted) {
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.getSearchCustomers(context, isSilent: true);
    }
  }

  void _openTaskDialog(
      SearchLeadModel lead, TaskTypeModel taskType, SearchUserDetails user) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);
    customerDetailsProvider.customerId = lead.customerId.toString();
    customerDetailsProvider.clearTaskDetails();

    // Pre-populate data
    customerDetailsProvider.updateTaskType(
        taskType.taskTypeId, taskType.taskTypeName);
    final userInTask = UserInTaskModel(
        userDetailsId: user.userDetailsId,
        userDetailsName: user.userDetailsName);
    customerDetailsProvider.addAssignedWorker(userInTask);

    // Open Dialog
    if (AppStyles.isWebScreen(context)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: TaskCreationWidget(isEdit: false, taskId: '0'),
        ),
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddTaskMobile(isEdit: false, taskId: '0')));
    }
  }

  void _onStatusClick(BuildContext context, SearchLeadModel lead) {
    try {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);

      dropDownProvider.selectedStatusId =
          int.tryParse(lead.statusId.toString()) ?? 0;
      leadsProvider.statusController.text = lead.statusName;

      dropDownProvider.selectedUserId =
          int.tryParse(lead.toUserId.toString()) ?? 0;
      leadsProvider.searchUserController.text = lead.toUserName;

      leadsProvider.setCutomerId(lead.customerId);
      leadsProvider.branchController.text = lead.branchName;
      settingsProvider.selectedBranchId = lead.branchId;
      settingsProvider.selectedDepartmentId =
          int.tryParse(lead.departmentId.toString()) ?? 0;
      leadsProvider.departmentController.text = lead.departmentName;

      leadsProvider.nextFollowUpDateController.text =
          lead.nextFollowUpDate.isNotEmpty
              ? lead.nextFollowUpDate.toDayMonthYearFormat()
              : '';
      leadsProvider.messageController.clear();

      dropDownProvider.filterStaffByBranchAndDepartment(
        branchId: lead.branchId,
        departmentId: int.tryParse(lead.departmentId.toString()) ?? 0,
      );
    } catch (e) {
      log('Error in _onStatusClick: $e');
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AddFollowupDialog(
        customerName: lead.customerName,
        statusId: lead.statusId.toString(),
        amount: lead.amount,
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

  Widget _buildStatusFilter(
      CustomerProvider customerProvider, DropDownProvider dropDownProvider) {
    final bool hasSelection = customerProvider.selectedStatusIds.isNotEmpty &&
        customerProvider.selectedStatusIds.first != 0;

    // Build label text from selected statuses
    String labelText = 'All';
    if (hasSelection) {
      final selectedNames = dropDownProvider.followUpData
          .where((s) => customerProvider.selectedStatusIds.contains(s.statusId))
          .map((s) => s.statusName ?? '')
          .toList();
      labelText = selectedNames.join(', ');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: hasSelection ? AppColors.primaryBlue : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              // Use a bottom sheet / dialog for multi-select
              await showDialog(
                context: context,
                barrierColor: Colors.transparent,
                builder: (ctx) {
                  return _StatusMultiSelectDialog(
                    allStatuses: dropDownProvider.followUpData,
                    selectedIds:
                        List<int>.from(customerProvider.selectedStatusIds),
                    onApply: (selectedIds) {
                      if (selectedIds.isEmpty || selectedIds.contains(0)) {
                        customerProvider.toggleStatus(0);
                      } else {
                        customerProvider.toggleStatus(0); // resets to [0]
                        for (final id in selectedIds) {
                          customerProvider.toggleStatus(id);
                        }
                      }
                      customerProvider.setSearchCriteria(
                        customerProvider.search,
                        customerProvider.formattedFromDate,
                        customerProvider.formattedToDate,
                      );
                      customerProvider.getSearchCustomers(context,
                          isSilent: true);
                    },
                  );
                },
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.2),
                  child: Text(
                    'Status: $labelText',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          hasSelection ? AppColors.primaryBlue : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: hasSelection ? AppColors.primaryBlue : Colors.black45,
                ),
              ],
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                customerProvider.toggleStatus(0); // Reset to All
                customerProvider.setSearchCriteria(
                  customerProvider.search,
                  customerProvider.formattedFromDate,
                  customerProvider.formattedToDate,
                );
                customerProvider.getSearchCustomers(context, isSilent: true);
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedStaffFilter(CustomerProvider customerProvider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        bool isAdmin = userType == '1';

        if (!isAdmin) {
          return const SizedBox();
        }
        int dropdownValue;
        List<DropdownMenuItem<int>> dropdownItems;

        if (isAdmin) {
          // Admin: Show all users with "All" option
          dropdownItems = [
                const DropdownMenuItem<int>(
                  value: 0,
                  child: Text(
                    'All',
                    style: TextStyle(fontSize: 14),
                  ),
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
                  .toList();
          dropdownValue = customerProvider.selectedUser ?? 0;
        } else {
          // Non-admin staff: Show only their own name
          dropdownItems = [
            DropdownMenuItem<int>(
              value: userId, // Use userId from state
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Text(
                  userName.isNotEmpty ? userName : 'Current User',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ];
          dropdownValue = userId;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (customerProvider.selectedUser != null &&
                      customerProvider.selectedUser != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: dropdownValue,
              hint: const Text('Assigned Staff: All',
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: dropdownItems,
              selectedItemBuilder: (BuildContext context) {
                return dropdownItems.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Assigned Staff: ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: isAdmin
                  ? (int? newValue) {
                      if (newValue != null) {
                        customerProvider.setUserFilterStatus(newValue);
                      }
                      customerProvider.getSearchCustomers(context,
                          isSilent: true);
                    }
                  : null,
              isDense: true,
              iconSize: 18,
              disabledHint: Text(
                'Assigned Staff: ${userName.isNotEmpty ? userName : 'Current User'}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnquiryForFilter(CustomerProvider customerProvider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        final List<DropdownMenuItem<int>> items = [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text(
                  'All',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ] +
            dropDownProvider.enquiryForList
                .map((item) => DropdownMenuItem<int>(
                      value: item.enquiryForId,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          item.enquiryForName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ))
                .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (customerProvider.selectedEnquiryFor != null &&
                      customerProvider.selectedEnquiryFor != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: customerProvider.selectedEnquiryFor ?? 0,
              hint: const Text('Enquiry For: All',
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: items,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enquiry For: ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: (int? newValue) {
                if (newValue != null) {
                  customerProvider.setEnquiryForFilter(newValue);
                }
                customerProvider.getSearchCustomers(context, isSilent: true);
              },
              isDense: true,
              iconSize: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnquirySourceFilter(CustomerProvider customerProvider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        final List<DropdownMenuItem<int>> items = [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text(
                  'All',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ] +
            dropDownProvider.enquiryData
                .map((item) => DropdownMenuItem<int>(
                      value: item.enquirySourceId,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          item.enquirySourceName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ))
                .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (customerProvider.selectedEnquirySource != null &&
                      customerProvider.selectedEnquirySource != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: customerProvider.selectedEnquirySource ?? 0,
              hint: const Text('Enquiry Source: All',
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: items,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enquiry Source: ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: (int? newValue) {
                if (newValue != null) {
                  customerProvider.setEnquirySourceFilter(newValue);
                }
                customerProvider.getSearchCustomers(context, isSilent: true);
              },
              isDense: true,
              iconSize: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBranchFilter(CustomerProvider customerProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final List<DropdownMenuItem<int>> items = [
              const DropdownMenuItem<int>(
                value: 0,
                child: Text(
                  'All',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ] +
            settingsProvider.branchModel
                .map((branch) => DropdownMenuItem<int>(
                      value: branch.branchId,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          branch.branchName ?? '',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ))
                .toList();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (customerProvider.selectedBranch != null &&
                      customerProvider.selectedBranch != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: customerProvider.selectedBranch ?? 0,
              hint: const Text('Department: All',
                  style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: items,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Department: ',
                          style:
                              TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: (int? newValue) {
                if (newValue != null) {
                  customerProvider.setBranchFilter(newValue);
                }
                customerProvider.getSearchCustomers(context, isSilent: true);
              },
              isDense: true,
              iconSize: 18,
            ),
          ),
        );
      },
    );
  }

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
  final Widget Function(
      BuildContext, MenuController, void Function(bool), Widget?) builder;
  final List<Widget Function(void Function(bool))> menuChildren;

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
      // Small 150ms delay before opening to ensure it's intention
      _hoverTimer = Timer(const Duration(milliseconds: 150), () {
        if (mounted && !_controller.isOpen) {
          _controller.open();
        }
      });
    } else {
      // 200ms grace period to move pointer between menu levels
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
            widget.builder(context, controller, _updateHover, child),
        menuChildren: widget.menuChildren.map((builder) {
          final child = builder(_updateHover);
          // Check if the child is our MultiLevelHoverMenu to pass the recursive callback
          if (child is MultiLevelHoverMenu) {
            return MultiLevelHoverMenu(
              title: child.title,
              leadingIcon: child.leadingIcon,
              onTap: child.onTap,
              isSubMenu: child.isSubMenu,
              hoverColor: child.hoverColor,
              onHoverChange: (hovering) {
                _updateHover(hovering);
              },
              children: child.children,
            );
          }
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

// ---------------------------------------------------------------------------
// Multi-select Status dialog
// ---------------------------------------------------------------------------
class _StatusMultiSelectDialog extends StatefulWidget {
  final List allStatuses; // List<MandatoryStatusModel>
  final List<int> selectedIds;
  final void Function(List<int>) onApply;

  const _StatusMultiSelectDialog({
    required this.allStatuses,
    required this.selectedIds,
    required this.onApply,
  });

  @override
  State<_StatusMultiSelectDialog> createState() =>
      _StatusMultiSelectDialogState();
}

class _StatusMultiSelectDialogState extends State<_StatusMultiSelectDialog> {
  late List<int> _tempSelected;

  @override
  void initState() {
    super.initState();
    // Clone so we don't mutate the original list
    _tempSelected = List<int>.from(widget.selectedIds);
    // Remove the placeholder 0 so the UI starts clean
    _tempSelected.remove(0);
  }

  void _toggle(int id) {
    setState(() {
      if (_tempSelected.contains(id)) {
        _tempSelected.remove(id);
      } else {
        _tempSelected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 360,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Scrollable list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allStatuses.length,
                itemBuilder: (ctx, index) {
                  final status = widget.allStatuses[index];
                  final int id = status.statusId as int;
                  final String name = (status.statusName ?? '') as String;
                  final bool isChecked = _tempSelected.contains(id);
                  return CheckboxListTile(
                    dense: true,
                    title: Text(name, style: const TextStyle(fontSize: 14)),
                    value: isChecked,
                    activeColor: const Color(0xFF152D70),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (_) => _toggle(id),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // Action buttons
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _tempSelected.clear());
                        widget.onApply([0]);
                        Navigator.pop(context);
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        backgroundColor: const Color(0xFF152D70),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        widget.onApply(
                          _tempSelected.isEmpty
                              ? [0]
                              : List<int>.from(_tempSelected),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
