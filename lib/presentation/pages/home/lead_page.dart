import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/add_followup_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
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
    _horizontalScrollController.dispose();
    _fixedVerticalController.dispose();
    _scrollableVerticalController.dispose();
    super.dispose();
  }

  bool viewProfile = false;
  bool viewFollowUp = false;
  // bool isEdit = false;
  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _fixedVerticalController = ScrollController();
    _scrollableVerticalController = ScrollController();

    // Setup scroll synchronization
    _fixedVerticalController.addListener(_syncScrollFromFixed);
    _scrollableVerticalController.addListener(_syncScrollFromScrollable);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

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
    if (_scrollableVerticalController.hasClients) {
      _scrollableVerticalController.jumpTo(_fixedVerticalController.offset);
    }
  }

  void _syncScrollFromScrollable() {
    if (_fixedVerticalController.hasClients) {
      _fixedVerticalController.jumpTo(_scrollableVerticalController.offset);
    }
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
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        color: Colors.grey[50],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (widget.fromDashBoard)
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Image.asset(
                        'assets/images/ArrowRight.png',
                        width: 24,
                        height: 24,
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
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: searchController,
                      onSubmitted: (query) {
                        // leadProvider.selectDateFilterOption(null);
                        // leadProvider.removeStatus();
                        print(query);
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
                              // leadProvider.selectDateFilterOption(null);
                              // leadProvider.removeStatus();
                              print(query);
                              if (leadProvider.search.isNotEmpty) {
                                searchController.clear();
                                leadProvider.setSearchCriteria(
                                  '',
                                  leadProvider.fromDateS,
                                  leadProvider.toDateS,
                                  leadProvider.status,
                                  leadProvider.enquiryForS,
                                );
                                leadProvider.getSearchLeads(context);
                              } else {
                                leadProvider.setSearchCriteria(
                                  query,
                                  leadProvider.fromDateS,
                                  leadProvider.toDateS,
                                  leadProvider.status,
                                  leadProvider.enquiryForS,
                                );
                                leadProvider.getSearchLeads(context);
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
                            child: Text(leadProvider.search.isNotEmpty
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
                        vertical: 12,
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

                        setState(() {
                          // isEdit = false;
                          viewProfile = false;
                          viewFollowUp = false;
                        });
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
                          vertical: 12,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: leadProvider.selectedUser != null &&
                                    leadProvider.selectedUser != 0
                                ? AppColors.primaryBlue
                                : Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          const Text('Assigned Staff: '),
                          DropdownButton<int>(
                            value: leadProvider.selectedUser,
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
                                provider.searchUserDetails
                                    .map((user) => DropdownMenuItem<int>(
                                          value: user.userDetailsId!,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 150),
                                            child: Text(
                                              user.userDetailsName ?? '',
                                              overflow: TextOverflow
                                                  .ellipsis, // Adds ellipsis when the text is too long
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                        ))
                                    .toList(),
                            onChanged: (int? newValue) {
                              if (newValue != null) {
                                leadProvider.setUserFilterStatus(
                                    newValue); // Update the status in the provider
                              }
                              String status =
                                  leadProvider.selectedStatus.toString();
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
                            },
                            underline: Container(),
                            isDense: true,
                            iconSize: 18,
                          )
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
                    const Spacer(),
                    if (leadProvider.fromDate != null ||
                        leadProvider.toDate != null ||
                        (leadProvider.selectedStatus != null &&
                            leadProvider.selectedStatus != 0) ||
                        (leadProvider.selectedUser != null &&
                            leadProvider.selectedUser != 0) ||
                        (leadProvider.selectedEnquiryFor != null &&
                            leadProvider.selectedEnquiryFor != 0) ||
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
            // Fixed version with synchronized scrolling
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: constraints.maxHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Fixed columns section
                          SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  .60, // Reduced from 0.75 to 0.70 for better responsive layout
                              child: ScrollConfiguration(
                                behavior:
                                    ScrollConfiguration.of(context).copyWith(
                                  scrollbars: false,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Fixed Header
                                    Container(
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 0, 90, 69),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            bottomLeft: Radius.circular(8)),
                                      ),
                                      child: const Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 75,
                                            // Reduced from 70 to 60
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      0.0, // Reduced from 10.0 to 4.0
                                                  horizontal:
                                                      15.0), // Reduced from 25.0 to 15.0
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'SL',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Type',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          TableWidget(
                                              width: 120,
                                              padding: EdgeInsets.zero,
                                              data: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Date',
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Age',
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              color: Color(0xFF607185)),
                                          TableWidget(
                                              flex: 1,
                                              padding: EdgeInsets.zero,
                                              data: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Name',
                                                    textAlign: TextAlign.start,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    // maxLines: 2,
                                                    style: const TextStyle(
                                                      // fontWeight:
                                                      //     FontWeight
                                                      //         .bold,
                                                      fontSize: 13,
                                                      color: const Color(
                                                          0xFFFFFFFF),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Contact',
                                                    textAlign: TextAlign.start,

                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    // maxLines: 2,
                                                    style: const TextStyle(
                                                      // fontWeight:
                                                      //     FontWeight
                                                      //         .bold,
                                                      fontSize: 13,
                                                      color: const Color(
                                                          0xFFFFFFFF),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              color: Color(0xFF607185)),
                                          TableWidget(
                                              flex: 1,
                                              padding: EdgeInsets.zero,
                                              data: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Location',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'District',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              color: Color(0xFF607185)),
                                          TableWidget(
                                              flex: 1,
                                              padding: EdgeInsets.zero,
                                              data: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Enquiry for',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    // Text(
                                                    //   'control No',
                                                    //   overflow:
                                                    //       TextOverflow.ellipsis,
                                                    //   // maxLines: 2,
                                                    //   style: const TextStyle(
                                                    //     // fontWeight:
                                                    //     //     FontWeight
                                                    //     //         .bold,
                                                    //     fontSize: 13,
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                              color: Color(0xFF607185)),
                                          TableWidget(
                                              flex: 1,
                                              padding: EdgeInsets.zero,
                                              data: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Channel-Source',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      'Sub Source',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              color: Color(0xFF607185)),
                                          TableWidget(
                                              flex: 1,
                                              padding: EdgeInsets.zero,
                                              data: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'Branch',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                        color: const Color(
                                                            0xFFFFFFFF),
                                                      ),
                                                    ),
                                                    Text(
                                                      '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      // maxLines: 2,
                                                      style: const TextStyle(
                                                        // fontWeight:
                                                        //     FontWeight
                                                        //         .bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              color: Color(0xFF607185)),
                                        ],
                                      ),
                                    ),

                                    // Fixed Data Rows

                                    Expanded(
                                      child: leadProvider.leadData.isEmpty
                                          ? const Center(
                                              child: Text('No data available'))
                                          : ListView.builder(
                                              controller:
                                                  _fixedVerticalController,
                                              physics:
                                                  const AlwaysScrollableScrollPhysics(),
                                              itemCount:
                                                  leadProvider.leadData.length,
                                              itemBuilder: (context, index) {
                                                var lead = leadProvider
                                                    .leadData[index];
                                                return MouseRegion(
                                                  onEnter: (_) => setState(() =>
                                                      _hoveredRowIndex = index),
                                                  onExit: (_) => setState(() =>
                                                      _hoveredRowIndex = null),
                                                  child: Container(
                                                    height:
                                                        60, // Reduced from 100 to 60
                                                    decoration: BoxDecoration(
                                                      color: index % 2 == 0
                                                          ? Colors.white
                                                          : const Color(
                                                              0xFFF6F7F9),
                                                      // borderRadius:
                                                      //     BorderRadius.circular(
                                                      //         8),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: _hoveredRowIndex ==
                                                                    index
                                                                ? const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    240,
                                                                    237,
                                                                    237)
                                                                : null,
                                                          ),
                                                          width: 50,
                                                          // Reduced from 80 to 60
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                    0.0, // Reduced from 12.0 to 4.0
                                                                horizontal:
                                                                    0.0), // Reduced from 25.0 to 15.0
                                                            child: Center(
                                                              child: Column(
                                                                children: [
                                                                  Text(
                                                                      ((index + 1) +
                                                                              leadProvider
                                                                                  .startLimit -
                                                                              1)
                                                                          .toString(),
                                                                      style:
                                                                          const TextStyle()),
                                                                  if (lead.leadTypeId ==
                                                                      UserStatusType
                                                                          .hotLead
                                                                          .value)
                                                                    const Text(
                                                                        "⭐")
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 27,
                                                        ),
                                                        TableWidget(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          width: 120,
                                                          data: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                "${_formatDateSafely(lead.entryDate)}",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                // maxLines: 2,
                                                                style:
                                                                    const TextStyle(
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .bold,
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              Text(
                                                                " ${getDaysCount(lead.entryDate).isEmpty ? "" : getDaysCount(lead.entryDate)}",
                                                                // lead.age ?? "",
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                // maxLines: 2,
                                                                style:
                                                                    TextStyle(
                                                                  // fontWeight:
                                                                  //     FontWeight
                                                                  //         .bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        TableWidget(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          flex: 1,
                                                          data: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            // spacing: 12,
                                                            children: [
                                                              Tooltip(
                                                                message: lead
                                                                    .customerName,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      viewProfile =
                                                                          true;
                                                                    });
                                                                    leadProvider
                                                                        .setCutomerId(
                                                                            lead.customerId);
                                                                    Scaffold.of(
                                                                            context)
                                                                        .openEndDrawer();
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    width: 125,
                                                                    child: Text(
                                                                      '${lead.customerName[0].toUpperCase()}${lead.customerName.substring(1)}',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      // maxLines: 2,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        // fontWeight:
                                                                        //     FontWeight
                                                                        //         .bold,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                lead.contactNumber,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        // TableWidget(flex: 1, title: lead.contactNumber),
                                                        // TableWidget(
                                                        //   flex: 2,
                                                        //   title: lead.address.trim(),
                                                        // ),
                                                        TableWidget(
                                                          flex: 1,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          data: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                lead.address,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                              Text(
                                                                "${lead.address2}",
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          // title:
                                                          //     lead.toUserName,
                                                        ),
                                                        TableWidget(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            flex: 1,
                                                            data: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  lead.enquiryFor,
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                                // const Text(
                                                                //   "control no",
                                                                //   style:
                                                                //       TextStyle(
                                                                //     fontSize:
                                                                //         13,
                                                                //   ),
                                                                // ),
                                                              ],
                                                            )),
                                                        TableWidget(
                                                          flex: 1,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          data: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            // spacing: 12,
                                                            // mainAxisAlignment:
                                                            //     MainAxisAlignment
                                                            //         .center,

                                                            children: [
                                                              Text(
                                                                lead.sourceCategoryName,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                              Text(
                                                                lead.referenceName,
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            12),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        TableWidget(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          flex: 1,
                                                          data: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  lead.branchName,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  // maxLines: 2,
                                                                  style:
                                                                      const TextStyle(
                                                                    // fontWeight:
                                                                    //     FontWeight
                                                                    //         .bold,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                  ],
                                ),
                              )),
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
                                  width:
                                      1000, // Reduced column widths for better responsive layout
                                  child: Column(
                                    children: [
                                      // Header row
                                      Container(
                                        height: 60,
                                        decoration: const BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 0, 90, 69),
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _HeaderCell(
                                                  'Status',
                                                  width: 160,
                                                ),
                                                // _HeaderCell('Done Date',
                                                //     width: 160),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _HeaderCell('Remark',
                                                    width: 160),
                                                // _HeaderCell('', width: 160),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _HeaderCell('Department',
                                                    width: 160),
                                                // _HeaderCell('', width: 160),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _HeaderCell('Assigned Staff',
                                                    width: 160),
                                                // _HeaderCell('', width: 160),
                                              ],
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _HeaderCell('Follow-Up Date',
                                                    width: 160),
                                                // _HeaderCell('', width: 160),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Data rows
                                      Expanded(
                                        child: ListView.builder(
                                          controller:
                                              _scrollableVerticalController,
                                          physics:
                                              const AlwaysScrollableScrollPhysics(),
                                          itemCount:
                                              leadProvider.leadData.length,
                                          itemBuilder: (context, index) {
                                            var lead =
                                                leadProvider.leadData[index];
                                            return MouseRegion(
                                              onEnter: (_) => setState(() =>
                                                  _hoveredRowIndex = index),
                                              onExit: (_) => setState(() =>
                                                  _hoveredRowIndex = null),
                                              child: Container(
                                                height: 60,
                                                color: index % 2 == 0
                                                    ? Colors.white
                                                    : const Color(0xFFF6F7F9),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              viewProfile =
                                                                  false;
                                                              viewFollowUp =
                                                                  true;
                                                            });
                                                            try {
                                                              final dropDownProvider =
                                                                  Provider.of<
                                                                          DropDownProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);
                                                              dropDownProvider
                                                                      .selectedStatusId =
                                                                  int.parse(lead
                                                                      .statusId
                                                                      .toString());
                                                              dropDownProvider
                                                                      .selectedUserId =
                                                                  int.parse(lead
                                                                      .toUserId
                                                                      .toString());
                                                              leadProvider
                                                                  .setCutomerId(
                                                                      lead.customerId);
                                                              leadProvider
                                                                      .branchController
                                                                      .text =
                                                                  lead.branchName;
                                                              settingsProvider
                                                                      .selectedBranchId =
                                                                  lead.branchId;
                                                              print(
                                                                  'knrgoiw ${lead.branchId}');
                                                              print(
                                                                  'knrgoiw ${lead.statusId}');
                                                              leadProvider
                                                                      .departmentController
                                                                      .text =
                                                                  lead.departmentName;
                                                              settingsProvider
                                                                      .selectedDepartmentId =
                                                                  int.parse(lead
                                                                      .departmentId
                                                                      .toString());
                                                              leadProvider
                                                                      .statusController
                                                                      .text =
                                                                  lead.statusName;
                                                              print(
                                                                  'dgonwrsog ${lead.statusId}');
                                                              print(
                                                                  'dgonwrsog ${lead.statusName}');
                                                              leadProvider
                                                                      .assignToFollowUpController
                                                                      .text =
                                                                  lead.toUserName;
                                                              leadProvider
                                                                  .nextFollowUpDateController
                                                                  .text = lead
                                                                      .nextFollowUpDate
                                                                      .isNotEmpty
                                                                  ? _formatDateSafely(
                                                                      lead.nextFollowUpDate)
                                                                  : '';
                                                              leadProvider
                                                                  .messageController
                                                                  .clear();
                                                            } catch (e) {}
                                                            Scaffold.of(context)
                                                                .openEndDrawer();
                                                          },
                                                          child: _DataCell(
                                                              lead.statusName, // appointment
                                                              width: 160),
                                                        ),
                                                        // _DataCell(
                                                        //     "Done date", // appointment
                                                        //     width: 150),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _DataCell(
                                                            lead.remark, // appointment
                                                            width: 160),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _DataCell(
                                                            lead.departmentName, // appointment
                                                            width: 160),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _DataCell(
                                                            lead.toUserName, // appointment
                                                            width: 160),
                                                      ],
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _DataCell(
                                                            lead.nextFollowUpDate
                                                                .toDayMonthYearFormat(), // appointment
                                                            width: 160),
                                                      ],
                                                    ),
                                                  ],
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPaginationControls(context),
      endDrawer: viewProfile
          ? LeadDetailsWidget(
              onEditPressed: () async {},
              onFollowUpPressed: () async {
                Navigator.pop(context);

                leadProvider.statusController.clear();
                leadProvider.assignToFollowUpController.clear();
                leadProvider.nextFollowUpDateController.clear();
                leadProvider.messageController.clear();
                final dropDownProvider =
                    Provider.of<DropDownProvider>(context, listen: false);
                dropDownProvider.selectedStatusId = null;
                dropDownProvider.selectedUserId = null;
                Future.delayed(const Duration(milliseconds: 0), () async {
                  setState(() {
                    viewProfile = false;
                    viewFollowUp = true;
                  });
                  await loadExistingAudioFiles(
                      leadDetailsProvider.leadDetails![0].audioFiles);
                  dropDownProvider.selectedStatusId = int.parse(
                      leadDetailsProvider.leadDetails![0].statusId.toString());
                  dropDownProvider.selectedUserId = int.parse(
                      leadDetailsProvider.leadDetails![0].toUserId.toString());
                  settingsProvider.selectedBranchId = int.parse(
                      leadDetailsProvider.leadDetails![0].branchId.toString());

                  leadProvider.setCutomerId(
                      leadDetailsProvider.leadDetails![0].customerId);
                  leadProvider.statusController.text =
                      leadDetailsProvider.leadDetails![0].statusName;

                  leadProvider.searchUserController.text =
                      leadDetailsProvider.leadDetails![0].toUserName;
                  dropDownProvider.setSelectedUserId(
                      leadDetailsProvider.leadDetails![0].toUserId);
                  dropDownProvider.filterStaffByBranchAndDepartment(
                    branchId: settingsProvider.selectedBranchId,
                    departmentId:
                        leadDetailsProvider.leadDetails![0].departmentId,
                  );
                  leadProvider.nextFollowUpDateController.text = leadProvider
                          .leadData[0].nextFollowUpDate.isNotEmpty
                      ? DateFormat('dd MMM yyyy').format(DateTime.parse(
                          leadDetailsProvider.leadDetails![0].nextFollowUpDate))
                      : '';
                  _scaffoldKey.currentState?.openEndDrawer();
                });
              },
              customerId: leadProvider.customerId.toString(),
            )
          : const AddFollowupDrawerWidget(),
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
  Widget _DataCell(String value, {required double width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 8.0), // Reduced vertical padding from 12.0 to 4.0
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          // maxLines: 2,
          style: const TextStyle(
            // fontWeight:
            //     FontWeight
            //         .bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

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
      height: 70,
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

class _HeaderCell extends StatelessWidget {
  final String title;
  final double width;

  const _HeaderCell(this.title, {required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 0.0,
            horizontal: 8.0), // Reduced vertical padding from 12.0 to 4.0
        child: Text(
          title,
          // maxLines: 1,
          // overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
  }
}
