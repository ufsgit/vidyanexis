import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';

import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';

import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/extensions.dart';

class LeadPage extends StatefulWidget {
  final bool fromDashBoard;

  const LeadPage({super.key, this.fromDashBoard = false});

  @override
  State<LeadPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  // final ScrollController _horizontalScrollController = ScrollController();
  // final ScrollController _verticalScrollController = ScrollController();
  final _horizontalScrollController = ScrollController();
  late final ScrollController _fixedVerticalController;
  late final ScrollController _scrollableVerticalController;
  Timer? _debounce;
  bool _isSyncing = false;

  // Dummy data
  final List<String> emails = [
    'john.doe@example.com',
    'jane.smith@company.com',
    'mike.wilson@business.org',
    'sarah.brown@gmail.com',
    'david.lee@outlook.com'
  ];

  final List<String> sources = [
    'Website',
    'Social Media',
    'Email Campaign',
    'Referral',
    'Cold Call'
  ];

  final List<String> scores = [
    '85/100',
    '72/100',
    '91/100',
    '68/100',
    '79/100'
  ];

  final List<String> dates = [
    '15 Jan 2024',
    '12 Jan 2024',
    '18 Jan 2024',
    '10 Jan 2024',
    '20 Jan 2024'
  ];

  final List<String> priorities = ['High', 'Medium', 'Low', 'High', 'Medium'];

  final List<Color> priorityColors = [
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.blue
  ];

  Map<int, Map<String, bool>> _checkedCustomers = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _horizontalScrollController.dispose();
    _fixedVerticalController.dispose();
    _scrollableVerticalController.dispose();
    super.dispose();
  }

  // bool isEdit = false;
  int? _hoveredRowIndex;

  int userId = 0;
  String userName = '';
  String userType = '';

  @override
  void initState() {
    super.initState();
    _fixedVerticalController = ScrollController();
    _scrollableVerticalController = ScrollController();

    // Setup scroll synchronization
    _fixedVerticalController.addListener(_syncScrollFromFixed);
    _scrollableVerticalController.addListener(_syncScrollFromScrollable);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";
      //not admin type assign user filter
      if (userType != "1") {
        leadProvider.setUserFilterStatus(userId);
      }

      provider.getEnquirySource(context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchsourceCategoryData('', context);
      provider.getDistricts(context);

      provider.getEnquiryFor(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, "1");
      leadProvider.setSearchCriteria(
        '',
        '',
        '',
        '',
        '',
      );
      leadProvider.getSearchLeads(context);

      //search
      // searchController.addListener(() {
      //   leadProvider.selectDateFilterOption(null);
      //   leadProvider.removeStatus();
      //   String query = searchController.text;
      //   print(query);
      //   leadProvider.getSearchLeads(query, '', '', '', context);
      // });
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadProvider.setSearchCriteria(
        query,
        leadProvider.fromDateS,
        leadProvider.toDateS,
        leadProvider.status,
        leadProvider.enquiryForS,
      );
      leadProvider.getSearchLeads(context);
    });
  }

  getDaysCount(String date) {
    if (date.isNotEmpty) {
      DateTime dateTime = DateTime.parse(date);

      // Remove time part from both dates
      DateTime today = DateTime.now();
      today = DateTime(today.year, today.month, today.day);
      DateTime target = DateTime(dateTime.year, dateTime.month, dateTime.day);

      Duration difference = today.difference(target);
      return difference.inDays.toString() == "0"
          ? "Today"
          : "(${difference.inDays.toString()} days ago)";
    }
    return "";
  }

  void _syncScrollFromFixed() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_scrollableVerticalController.hasClients) {
      _scrollableVerticalController.jumpTo(_fixedVerticalController.offset);
    }
    _isSyncing = false;
  }

  void _syncScrollFromScrollable() {
    if (_isSyncing) return;
    _isSyncing = true;
    if (_fixedVerticalController.hasClients) {
      _fixedVerticalController.jumpTo(_scrollableVerticalController.offset);
    }
    _isSyncing = false;
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final sideProvider = Provider.of<SidebarProvider>(context);

    // Calculate dynamic heights for table
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = 60.0;
    // Adjust search section height based on filter visibility
    final double searchSectionHeight = leadProvider.isFilter ? 130.0 : 70.0;
    const paginationHeight = 60.0;
    const tableHeaderHeight = 50.0;
    const double paddingSafety = 10.0;

    final double availableHeight = screenHeight -
        headerHeight -
        searchSectionHeight -
        paginationHeight -
        tableHeaderHeight -
        paddingSafety;

    // Calculate exact row height for 20 rows
    final double rowHeight = 35;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  if (widget.fromDashBoard)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Color(0xFF152D70),
                      ),
                    ),
                  if (widget.fromDashBoard)
                    const SizedBox(
                      width: 8,
                    ),
                  const Text(
                    'Leads',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF152D70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Flexible(child: Container()),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: TextField(
                      controller: searchController,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: _onSearchChanged,
                      onSubmitted: (query) {
                        if (_debounce?.isActive ?? false) _debounce!.cancel();
                        leadProvider.setSearchCriteria(
                          query,
                          leadProvider.fromDateS,
                          leadProvider.toDateS,
                          leadProvider.status,
                          leadProvider.enquiryForS,
                        );
                        leadProvider.getSearchLeads(context);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search here....',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            if (_debounce?.isActive ?? false)
                              _debounce!.cancel();
                            leadProvider.setSearchCriteria(
                              searchController.text,
                              leadProvider.fromDateS,
                              leadProvider.toDateS,
                              leadProvider.status,
                              leadProvider.enquiryForS,
                            );
                            leadProvider.getSearchLeads(context);
                          },
                          child: const Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      leadProvider.toggleFilter();
                      // leadProvider.selectDateFilterOption(null);
                      // leadProvider.removeStatus();
                      // leadProvider.getSearchLeads('', '', '', '', context);
                      print(leadProvider.isFilter);
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: leadProvider.isFilter
                          ? Colors.white
                          : AppColors.primaryBlue, // Change foreground color
                      backgroundColor: leadProvider.isFilter
                          ? const Color(0xFF5499D9)
                          : Colors.white, // Change background color
                      side: BorderSide(
                          color: leadProvider.isFilter
                              ? const Color(0xFF5499D9)
                              : AppColors.primaryBlue), // Change border color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // New Lead Button
                  if (settingsProvider.menuIsSaveMap[3] == 1)
                    ElevatedButton.icon(
                      onPressed: () async {
                        final dropDownProvider = Provider.of<DropDownProvider>(
                            context,
                            listen: false);
                        dropDownProvider.updateEnquiryForName(null, '');
                        dropDownProvider.updateDistrict(null, '');

                        await leadProvider.getLeadDropdowns(context);

                        // _scaffoldKey.currentState
                        //     ?.openEndDrawer(); // Open drawer
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const NewLeadDrawerWidget(
                              isEdit: false,
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('New Lead'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            if (leadProvider.isFilter)
              Container(
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
                            color: leadProvider.selectedStatus != null &&
                                    leadProvider.selectedStatus != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Status: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedStatus,
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
                                    .map((status) => DropdownMenuItem<int>(
                                          value: status.statusId,
                                          child: Text(
                                            status.statusName ?? '',
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setStatus(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  leadProvider.selectedStatus.toString();
                              String fromDate = leadProvider.formattedFromDate;
                              String toDate = leadProvider.formattedToDate;
                              String enquiryFor =
                                  leadProvider.selectedEnquiryFor.toString();
                              print(
                                  'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                              leadProvider.setSearchCriteria(
                                leadProvider.search,
                                fromDate,
                                toDate,
                                status,
                                enquiryFor,
                              );
                              leadProvider.getSearchLeads(context);
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
                              color: leadProvider.fromDate != null ||
                                      leadProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            if (leadProvider.fromDate == null &&
                                leadProvider.toDate == null)
                              const Text('Follow-Up Date: All'),
                            if (leadProvider.fromDate != null &&
                                leadProvider.toDate != null)
                              Text(
                                  'Date : ${leadProvider.formattedFromDate} - ${leadProvider.formattedToDate}'),
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
                    const SizedBox(
                      width: 10,
                    ),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(
                    //         color: leadProvider.selectedUser != null &&
                    //                 leadProvider.selectedUser != 0
                    //             ? AppColors.primaryBlue
                    //             : Colors.grey[300]!),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       const Text('Assigned Staff: '),
                    //       DropdownButton<int>(
                    //         value: leadProvider.selectedUser,
                    //         hint: const Text('All'),
                    //         items: [
                    //               const DropdownMenuItem<int>(
                    //                 value:
                    //                     0, // Use 0 or null to represent "All"
                    //                 child: Text(
                    //                   'All',
                    //                   style: TextStyle(fontSize: 14),
                    //                 ),
                    //               ),
                    //             ] +
                    //             provider.searchUserDetails
                    //                 .map((user) => DropdownMenuItem<int>(
                    //                       value: user.userDetailsId!,
                    //                       child: ConstrainedBox(
                    //                         constraints: const BoxConstraints(
                    //                             maxWidth: 150),
                    //                         child: Text(
                    //                           user.userDetailsName ?? '',
                    //                           overflow: TextOverflow
                    //                               .ellipsis, // Adds ellipsis when the text is too long
                    //                           style:
                    //                               const TextStyle(fontSize: 14),
                    //                         ),
                    //                       ),
                    //                     ))
                    //                 .toList(),
                    //         onChanged: userId == 1
                    //             ? (int? newValue) {
                    //                 if (newValue != null) {
                    //                   leadProvider.setUserFilterStatus(
                    //                       newValue); // Update the status in the provider
                    //                 }
                    //                 String status =
                    //                     leadProvider.selectedStatus.toString();
                    //                 String fromDate =
                    //                     leadProvider.formattedFromDate;
                    //                 String toDate =
                    //                     leadProvider.formattedToDate;
                    //                 String enquiryFor = leadProvider
                    //                     .selectedEnquiryFor
                    //                     .toString();
                    //                 print(
                    //                     'Selected Status: $status, Selected From Date: $fromDate, Selected To Date: $toDate, Selected Enquiry For: $enquiryFor');
                    //                 leadProvider.setSearchCriteria(
                    //                   leadProvider.search,
                    //                   fromDate,
                    //                   toDate,
                    //                   status,
                    //                   enquiryFor,
                    //                 );
                    //                 leadProvider.getSearchLeads(context);
                    //               }
                    //             : null,
                    //         // onChanged: null,
                    //         underline: Container(),
                    //         isDense: true,
                    //         iconSize: 18,
                    //       )
                    //     ],
                    //   ),
                    // ),
                    if (userType == '1') ...[
                      _buildAssignedStaffFilter(leadProvider),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadProvider.selectedEnquiryFor != null &&
                                    leadProvider.selectedEnquiryFor != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Enquiry For: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedEnquiryFor,
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
                                provider.enquiryForList
                                    .map((user) => DropdownMenuItem<int>(
                                          value: user.enquiryForId,
                                          child: Text(
                                            user.enquiryForName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setEnquiryForFilter(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  leadProvider.selectedStatus.toString();
                              String fromDate = leadProvider.formattedFromDate;
                              String toDate = leadProvider.formattedToDate;
                              String enquiryFor =
                                  leadProvider.selectedEnquiryFor.toString();
                              print(
                                  'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                              leadProvider.setSearchCriteria(
                                leadProvider.search,
                                fromDate,
                                toDate,
                                status,
                                enquiryFor,
                              );
                              leadProvider.getSearchLeads(context);
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadProvider.selectedEnquirySource != null &&
                                    leadProvider.selectedEnquirySource != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Enquiry Source: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedEnquirySource,
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
                                provider.enquiryData
                                    .map((user) => DropdownMenuItem<int>(
                                          value: user.enquirySourceId,
                                          child: Text(
                                            user.enquirySourceName,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setEnquirySourceFilter(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  leadProvider.selectedStatus.toString();
                              String fromDate = leadProvider.formattedFromDate;
                              String toDate = leadProvider.formattedToDate;
                              String enquiryFor =
                                  leadProvider.selectedEnquiryFor.toString();
                              int enquirySource =
                                  leadProvider.selectedEnquirySource ?? 0;
                              print(
                                  'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                              leadProvider.setSearchCriteria(
                                leadProvider.search,
                                fromDate,
                                toDate,
                                status,
                                enquiryFor,
                                enquirySource: enquirySource,
                              );
                              leadProvider.getSearchLeads(context);
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (leadProvider.fromDate != null ||
                        leadProvider.toDate != null ||
                        (leadProvider.selectedStatus != null &&
                            leadProvider.selectedStatus != 0) ||
                        // (leadProvider.selectedUser != null &&
                        //     leadProvider.selectedUser != 0) ||
                        (leadProvider.selectedEnquiryFor != null &&
                            leadProvider.selectedEnquiryFor != 0) ||
                        (leadProvider.selectedEnquirySource != null &&
                            leadProvider.selectedEnquirySource != 0) ||
                        leadProvider.search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          leadProvider.selectDateFilterOption(null);
                          leadProvider.removeStatus();
                          searchController.clear();
                          leadProvider.setSearchCriteria(
                            '',
                            '',
                            '',
                            '',
                            '',
                          );
                          leadProvider.getSearchLeads(context);
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
              child: Scrollbar(
                controller: _scrollableVerticalController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Fixed columns section
                    SizedBox(
                      width: 600,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Fixed Header
                          Container(
                            height: tableHeaderHeight,
                            decoration: const BoxDecoration(
                              color: const Color.fromARGB(255, 0, 90, 69),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 6.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'SL',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 4.0),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'ID',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableWidget(
                                    width: 110,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    data: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Date',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                    color: Color(0xFF607185)),
                                TableWidget(
                                    flex: 3,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    data: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Name',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                    color: Color(0xFF607185)),
                                TableWidget(
                                    width: 150,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    data: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Contact',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFFFFFFFF),
                                        ),
                                      ),
                                    ),
                                    color: Color(0xFF607185)),
                              ],
                            ),
                          ),

                          // Fixed Data Rows

                          Expanded(
                            child: leadProvider.leadData.isEmpty
                                ? const Center(child: Text('No data available'))
                                : ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(scrollbars: false),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: false,
                                      controller: _fixedVerticalController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: leadProvider.leadData.length,
                                      itemBuilder: (context, index) {
                                        if (index >=
                                            leadProvider.leadData.length) {
                                          return const SizedBox();
                                        }
                                        var lead = leadProvider.leadData[index];
                                        return MouseRegion(
                                          onEnter: (_) {
                                            if (_hoveredRowIndex != index) {
                                              setState(() =>
                                                  _hoveredRowIndex = index);
                                            }
                                          },
                                          onExit: (_) {
                                            if (_hoveredRowIndex != null) {
                                              setState(() =>
                                                  _hoveredRowIndex = null);
                                            }
                                          },
                                          child: Container(
                                            height: rowHeight,
                                            decoration: BoxDecoration(
                                              color: index % 2 == 0
                                                  ? Colors.white
                                                  : const Color(0xFFF6F7F9),
                                              // borderRadius:
                                              //     BorderRadius.circular(
                                              //         8),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: _hoveredRowIndex ==
                                                            index
                                                        ? const Color.fromARGB(
                                                            255, 240, 237, 237)
                                                        : null,
                                                  ),
                                                  width: 80,
                                                  // Reduced from 80 to 60 -> Back to 80
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 6.0,
                                                        horizontal: 6.0),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              ((index + 1) +
                                                                      leadProvider
                                                                          .startLimit -
                                                                      1)
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 13,
                                                              )),
                                                          if (lead.leadTypeId ==
                                                              UserStatusType
                                                                  .hotLead
                                                                  .value)
                                                            const Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          4.0),
                                                              child: Text("⭐",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          10)),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 55,
                                                  // Reduced from 80 to 60
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                            horizontal: 4.0),
                                                    child: Center(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                              lead.customerId
                                                                  .toString(),
                                                              style:
                                                                  const TextStyle()),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 110,
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      "${_formatDateSafely(lead.entryDate)}",
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  flex: 3,
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Tooltip(
                                                      message:
                                                          lead.customerName,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          CustomerDetailsProvider customerDetailsProvider = Provider.of<CustomerDetailsProvider>(context, listen: false);
                                                          customerDetailsProvider.setCustomerId(lead.customerId);
                                                          sideProvider.name =
                                                              'Lead /';

                                                          context.push(
                                                              '/customerDetails/${lead.customerId}/false');
                                                        },
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor:
                                                              Colors.blue
                                                                  .withOpacity(
                                                                      0.1),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5)),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 5),
                                                          minimumSize:
                                                              const Size(0, 0),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        child: Text(
                                                          (lead.customerName
                                                                      ?.isNotEmpty ??
                                                                  false)
                                                              ? '${lead.customerName![0].toUpperCase()}${lead.customerName!.substring(1)}'
                                                              : lead.customerName ??
                                                                  '',
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.blue,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 150,
                                                  data: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        lead.contactNumber,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Scrollbar(
                        controller: _horizontalScrollController,
                        thumbVisibility: true,
                        trackVisibility: true,
                        interactive: true,
                        child: SingleChildScrollView(
                          controller: _horizontalScrollController,
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: 1520,
                            child: Column(
                              children: [
                                // Header row
                                Container(
                                  height: tableHeaderHeight,
                                  decoration: const BoxDecoration(
                                    color: const Color.fromARGB(255, 0, 90, 69),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(8),
                                        bottomRight: Radius.circular(8)),
                                  ),
                                  child: const Row(
                                    children: [
                                      TableWidget(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Enquiry for',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                          ),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Source',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                          ),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 120,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Branch',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                          ),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 175,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Text('Status',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 100,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Convert',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFFFFFFF),
                                              ),
                                            ),
                                          ),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 375,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Text('Remark',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Text('Department',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Text('Assigned Staff',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          color: Color(0xFF607185)),
                                      TableWidget(
                                          width: 150,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 6.0, horizontal: 8.0),
                                          data: Text('Follow-Up Date',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          color: Color(0xFF607185)),
                                    ],
                                  ),
                                ),
                                // Data rows
                                Expanded(
                                  child: ScrollConfiguration(
                                    behavior: ScrollConfiguration.of(context)
                                        .copyWith(scrollbars: false),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: false,
                                      controller: _scrollableVerticalController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: leadProvider.leadData.length,
                                      itemBuilder: (context, index) {
                                        if (index >=
                                            leadProvider.leadData.length) {
                                          return const SizedBox();
                                        }
                                        var lead = leadProvider.leadData[index];
                                        return MouseRegion(
                                          onEnter: (_) {
                                            if (_hoveredRowIndex != index) {
                                              setState(() =>
                                                  _hoveredRowIndex = index);
                                            }
                                          },
                                          onExit: (_) {
                                            if (_hoveredRowIndex != null) {
                                              setState(() =>
                                                  _hoveredRowIndex = null);
                                            }
                                          },
                                          child: Container(
                                            height: rowHeight,
                                            color: index % 2 == 0
                                                ? Colors.white
                                                : const Color(0xFFF6F7F9),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                TableWidget(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 6.0,
                                                            horizontal: 8.0),
                                                    width: 150,
                                                    data: Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        lead.enquiryFor,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    )),
                                                TableWidget(
                                                  width: 150,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      '${lead.sourceCategoryName}${lead.referenceName.isNotEmpty ? ' - ${lead.referenceName}' : ''}',
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width:
                                                      120, // Reduced from 100 to match Header
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      lead.branchName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  width: 175,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  data: Tooltip(
                                                    message: lead.statusName,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        _onStatusClick(
                                                            context, lead);
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor: AppColors
                                                                .parseColor(lead
                                                                    .colorCode)
                                                            .withOpacity(0.2),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        minimumSize:
                                                            const Size(0, 0),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      child: Text(
                                                        lead.statusName,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .parseColor(lead
                                                                  .colorCode),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 100,
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: TextButton(
                                                      onPressed: () {
                                                        leadProvider.convertLead(
                                                            context,
                                                            lead.customerId
                                                                .toString());
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor: Colors
                                                            .orange
                                                            .withOpacity(0.1),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        minimumSize:
                                                            const Size(0, 0),
                                                        tapTargetSize:
                                                            MaterialTapTargetSize
                                                                .shrinkWrap,
                                                      ),
                                                      child: const Text(
                                                        'Convert',
                                                        style: TextStyle(
                                                          color: Colors.orange,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 375,
                                                  data: Tooltip(
                                                    message: lead.remark,
                                                    child: Text(
                                                      lead.remark,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 13),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 150,
                                                  data: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      lead.departmentName,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 150,
                                                  data: Text(
                                                    lead.toUserName,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                ),
                                                TableWidget(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6.0,
                                                      horizontal: 8.0),
                                                  width: 150,
                                                  data: Text(
                                                    lead.nextFollowUpDate
                                                        .toDayMonthYearFormat(),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        fontSize: 13),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildPaginationControls(context),
          ],
        ),
      ),
    );
  }

  void _onStatusClick(BuildContext context, SearchLeadModel lead) {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final audioProvider =
        Provider.of<AudioFileProvider>(context, listen: false);

    dropDownProvider.selectedStatusId = int.tryParse(lead.statusId.toString());
    leadsProvider.statusController.text = lead.statusName;

    dropDownProvider.selectedUserId = int.tryParse(lead.toUserId.toString());
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
    leadsProvider.messageController.text = lead.remark;

    dropDownProvider.filterStaffByBranchAndDepartment(
      branchId: lead.branchId,
      departmentId: int.tryParse(lead.departmentId.toString()) ?? 0,
    );

    audioProvider.clearAudios();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AddFollowupDialog(
        customerName: lead.customerName,
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<LeadsProvider>(
        builder: (contextx, leadProvider, child) {
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
                            leadProvider.setDateFilter(title);
                            leadProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              leadProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: leadProvider.selectedDateFilterIndex == index
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
                            onTap: () => leadProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.fromDate != null
                                  ? '${leadProvider.fromDate!.toLocal()}'
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
                                leadProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.toDate != null
                                  ? '${leadProvider.toDate!.toLocal()}'
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

                          leadProvider.formatDate();

                          print(leadProvider.formattedFromDate);
                          print(leadProvider.formattedToDate);
                          String status =
                              leadProvider.selectedStatus.toString();
                          String fromDate = leadProvider.formattedFromDate;
                          String toDate = leadProvider.formattedToDate;
                          String enquiryFor =
                              leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            enquiryFor,
                          );
                          leadProvider.getSearchLeads(context);
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
                          leadProvider.selectDateFilterOption(null);
                          String status =
                              leadProvider.selectedStatus.toString();
                          String fromDate = '';
                          String toDate = '';
                          String enquiryFor =
                              leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            enquiryFor,
                          );
                          leadProvider.getSearchLeads(context);
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

// Simple text cell

// Score cell with colored background
  Widget _ScoreCell(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

// Priority cell with color indicator
  Widget _PriorityCell(String value, Color color, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);

    // Calculate the range for the current page
    int startItem = leadProvider.startLimit; // Now it starts from 1
    int endItem = (leadProvider.endLimit < leadProvider.totalCount)
        ? leadProvider.endLimit
        : leadProvider.totalCount; // Ensure it doesn't exceed total count

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: leadProvider.startLimit > 1
                ? () {
                    leadProvider.fetchPreviousPage(context);
                  }
                : null,
          ),
          Text(
            'Showing $startItem / $endItem of ${leadProvider.totalCount}',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: leadProvider.endLimit < leadProvider.totalCount
                ? () {
                    leadProvider.fetchNextPage(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Filters (no date): User, Client, Project Type, Expense Type
  Widget _buildAssignedStaffFilter(LeadsProvider leadProvider) {
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
                        value: user.userDetailsId!,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: Text(
                            user.userDetailsName ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ))
                  .toList();
          dropdownValue = leadProvider.selectedUser ?? 0;
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (leadProvider.selectedUser != null &&
                      leadProvider.selectedUser != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Assigned Staff: '),
              DropdownButton<int>(
                value: dropdownValue,
                hint: const Text('All'),
                items: dropdownItems,
                onChanged: isAdmin
                    ? (int? newValue) {
                        if (newValue != null) {
                          leadProvider.setUserFilterStatus(newValue);
                        }
                        String status = leadProvider.selectedStatus.toString();
                        String fromDate = leadProvider.formattedFromDate;
                        String toDate = leadProvider.formattedToDate;
                        String enquiryFor =
                            leadProvider.selectedEnquiryFor.toString();
                        print(
                            'Selected Status: $status, Selected From Date: $fromDate, Selected To Date: $toDate, Selected Enquiry For: $enquiryFor');
                        leadProvider.setSearchCriteria(
                          leadProvider.search,
                          fromDate,
                          toDate,
                          status,
                          enquiryFor,
                        );
                        leadProvider.getSearchLeads(context);
                      }
                    : null,
                underline: Container(),
                isDense: true,
                iconSize: 18,
                disabledHint: Text(
                  userName.isNotEmpty ? userName : 'Current User',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  String _formatDateSafely(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return ''; // Return an empty string if parsing fails
    }
  }
}
