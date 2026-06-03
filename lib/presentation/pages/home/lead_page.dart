import 'package:vidyanexis/controller/models/Sales_model.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_history_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/inventory/sales_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_multi_level_dropdown.dart';
import 'package:vidyanexis/controller/models/task_type_model.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/constants/app_styles.dart';

class LeadPage extends StatefulWidget {
  final bool fromDashBoard;

  const LeadPage({super.key, this.fromDashBoard = false});

  @override
  State<LeadPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController searchController = TextEditingController();
  TextEditingController leadIdController = TextEditingController();
  FocusNode searchFocusNodeWeb = FocusNode();
  FocusNode searchFocusNodeMobile = FocusNode();
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

  final Map<int, Map<String, bool>> _checkedCustomers = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollableVerticalController.dispose();
    searchFocusNodeWeb.dispose();
    searchFocusNodeMobile.dispose();
    searchController.dispose();
    leadIdController.dispose();
    scrollController.dispose();
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

      provider.getEnquirySource(context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchsourceCategoryData('', context);
      provider.getDistricts(context);

      provider.getEnquiryFor(context);
      provider.getUserDetails(context);
      provider.getTaskType(context);
      provider.getFollowUpStatus(context, "1");
      leadProvider.setSearchCriteria('', '', '');
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
          query, leadProvider.fromDateS, leadProvider.toDateS,
          leadId: leadIdController.text);
      leadProvider.getSearchLeads(context);
    });
  }

  String getDaysCount(String date) {
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
    const tableHeaderHeight = 40.0;
    const double paddingSafety = 10.0;

    final double availableHeight = screenHeight -
        headerHeight -
        searchSectionHeight -
        paginationHeight -
        tableHeaderHeight -
        paddingSafety;

    // Calculate exact row height for 20 rows
    final double rowHeight = AppStyles.isWebScreen(context) ? 36.0 : 48.0;

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
              child: AppStyles.isWebScreen(context)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.fromDashBoard)
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBlue
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: 20,
                                    color: AppColors.textGrey4,
                                  ),
                                ),
                              ),
                            if (widget.fromDashBoard)
                              const SizedBox(
                                width: 8,
                              ),
                            Text(
                              'Leads',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                color: const Color(0xFF1E293B),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Entry Type Filter
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    leadProvider.setEntryType('myown');
                                    leadProvider.getSearchLeads(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: leadProvider.entryType != 'all' ? AppColors.primaryBlue : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'ME',
                                      style: TextStyle(
                                        color: leadProvider.entryType != 'all' ? AppColors.primaryBlue : Colors.grey,
                                        fontWeight: leadProvider.entryType != 'all' ? FontWeight.w600 : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () {
                                    leadProvider.setEntryType('all');
                                    leadProvider.getSearchLeads(context);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: leadProvider.entryType == 'all' ? AppColors.primaryBlue : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'ALL',
                                      style: TextStyle(
                                        color: leadProvider.entryType == 'all' ? AppColors.primaryBlue : Colors.grey,
                                        fontWeight: leadProvider.entryType == 'all' ? FontWeight.w600 : FontWeight.normal,
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
                                    color: const Color(0xFFCBD5E1), width: 1.0),
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
                                        searchController.selection.baseOffset == 0 &&
                                        searchController.selection.extentOffset == searchController.text.length) {
                                      searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
                                    }
                                  });
                                },
                                onSubmitted: (query) {
                                  if (_debounce?.isActive ?? false)
                                    _debounce!.cancel();
                                  leadProvider.setSearchCriteria(
                                      query,
                                      leadProvider.fromDateS,
                                      leadProvider.toDateS,
                                      leadId: leadIdController.text);
                                  leadProvider.getSearchLeads(context);
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
                                      leadProvider.setSearchCriteria(
                                          searchController.text,
                                          leadProvider.fromDateS,
                                          leadProvider.toDateS,
                                          leadId: leadIdController.text);
                                      leadProvider.getSearchLeads(context);
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
                                leadProvider.setSortOption(value, context);
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 0,
                                  child: Text('Default'),
                                ),
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('ID No'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Creation Date'),
                                ),
                                const PopupMenuItem(
                                  value: 3,
                                  child: Text('Followup Date'),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                leadProvider.sortOrder == 'ASC'
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: const Color(0xFF64748B),
                                size: 20,
                              ),
                              onPressed: () =>
                                  leadProvider.toggleSortOrder(context),
                              tooltip: leadProvider.sortOrder == 'ASC'
                                  ? 'Ascending'
                                  : 'Descending',
                            ),
                            CustomFilterButton(
                              onPressed: () {
                                leadProvider.toggleFilter();
                                print(leadProvider.isFilter);
                              },
                              isFilter: leadProvider.isFilter,
                            ),
                            if (settingsProvider.menuIsSaveMap[3] == 1)
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final dropDownProvider =
                                      Provider.of<DropDownProvider>(context,
                                          listen: false);
                                  dropDownProvider.updateEnquiryForName(
                                      null, '');
                                  dropDownProvider.updateDistrict(null, '');

                                  await leadProvider.getLeadDropdowns(context);

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const NewLeadDrawerWidget(
                                        isEdit: false,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(
                                  'New Lead',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  foregroundColor: Colors.white,
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
                    )
                  : Row(
                      children: [
                        if (widget.fromDashBoard)
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: 20,
                                color: AppColors.textGrey4,
                              ),
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
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: TextField(
                            controller: searchController,
                            focusNode: searchFocusNodeMobile,
                            textAlignVertical: TextAlignVertical.center,
                            onTap: () {
                              Future.microtask(() {
                                if (searchController.text.isNotEmpty &&
                                    searchController.selection.baseOffset == 0 &&
                                    searchController.selection.extentOffset == searchController.text.length) {
                                  searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
                                }
                              });
                            },
                            onSubmitted: (query) {
                              if (_debounce?.isActive ?? false)
                                _debounce!.cancel();
                              leadProvider.setSearchCriteria(query,
                                  leadProvider.fromDateS, leadProvider.toDateS,
                                  leadId: leadIdController.text);
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
                                  if (_debounce?.isActive ?? false) {
                                    _debounce!.cancel();
                                  }
                                  leadProvider.setSearchCriteria(
                                      searchController.text,
                                      leadProvider.fromDateS,
                                      leadProvider.toDateS,
                                      leadId: leadIdController.text);
                                  leadProvider.getSearchLeads(context);
                                },
                                child: const Icon(Icons.search,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        PopupMenuButton<int>(
                          icon:
                              const Icon(Icons.sort, color: Color(0xFF152D70)),
                          tooltip: 'Sort By',
                          onSelected: (int value) {
                            leadProvider.setSortOption(value, context);
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 0,
                              child: Text('Default'),
                            ),
                            const PopupMenuItem(
                              value: 1,
                              child: Text('ID No'),
                            ),
                            const PopupMenuItem(
                              value: 2,
                              child: Text('Creation Date'),
                            ),
                            const PopupMenuItem(
                              value: 3,
                              child: Text('Followup Date'),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            leadProvider.sortOrder == 'ASC'
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: const Color(0xFF152D70),
                            size: 20,
                          ),
                          onPressed: () =>
                              leadProvider.toggleSortOrder(context),
                          tooltip: leadProvider.sortOrder == 'ASC'
                              ? 'Ascending'
                              : 'Descending',
                        ),
                        const SizedBox(width: 8),
                        CustomFilterButton(
                          onPressed: () {
                            leadProvider.toggleFilter();
                            print(leadProvider.isFilter);
                          },
                          isFilter: leadProvider.isFilter,
                        ),
                        const SizedBox(width: 16),
                        if (settingsProvider.menuIsSaveMap[3] == 1)
                          ElevatedButton.icon(
                            onPressed: () async {
                              final dropDownProvider =
                                  Provider.of<DropDownProvider>(context,
                                      listen: false);
                              dropDownProvider.updateEnquiryForName(null, '');
                              dropDownProvider.updateDistrict(null, '');

                              await leadProvider.getLeadDropdowns(context);

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
                            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
                    _buildStatusFilter(leadProvider, provider),
                    _buildLeadIdFilter(leadProvider),
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
                              color: leadProvider.fromDate != null ||
                                      leadProvider.toDate != null
                                  ? AppColors.primaryBlue
                                  : Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                    if (userType == '1') ...[
                      _buildAssignedStaffFilter(leadProvider),
                    ],
                    _buildEnquiryForFilter(leadProvider),
                    _buildEnquirySourceFilter(leadProvider),

                    if (leadProvider.fromDate != null ||
                        leadProvider.toDate != null ||
                        (leadProvider.selectedStatus != null &&
                            leadProvider.selectedStatus != 0) ||
                        (leadProvider.selectedUser != null &&
                            leadProvider.selectedUser != 0) ||
                        (leadProvider.selectedEnquiryFor != null &&
                            leadProvider.selectedEnquiryFor != 0) ||
                        (leadProvider.selectedEnquirySource != null &&
                            leadProvider.selectedEnquirySource != 0) ||
                        leadProvider.search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          leadProvider.selectDateFilterOption(null);
                          leadProvider.toggleStatus(0); // Reset status to [0]
                          leadProvider.setEntryType('myown');
                          searchController.clear();
                          leadIdController.clear();
                          leadProvider.setSearchCriteria('', '', '',
                              leadId: '0');
                          leadProvider.getSearchLeads(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                            width: 700,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Fixed Header
                                Container(
                                  height: tableHeaderHeight,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryBlue,
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        bottomLeft: Radius.circular(8)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TableWidget(
                                        width: 60,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        alignment: Alignment.center,
                                        data: Text(
                                          'SL',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 80,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        alignment: Alignment.center,
                                        data: Text(
                                          'ID',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        flex: 2,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        alignment: Alignment.centerLeft,
                                        data: Text(
                                          'Name',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        flex: 2,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        alignment: Alignment.centerLeft,
                                        data: Text(
                                          'Address',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      TableWidget(
                                        width: 150,
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 12.0),
                                        alignment: Alignment.centerLeft,
                                        data: Text(
                                          'Contact',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Fixed Data Rows

                                Expanded(
                                  child: leadProvider.leadData.isEmpty
                                      ? const Center(
                                          child: Text('No data available'))
                                      : ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(scrollbars: false),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: false,
                                            controller:
                                                _fixedVerticalController,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount:
                                                leadProvider.leadData.length,
                                            itemBuilder: (context, index) {
                                              if (index >=
                                                  leadProvider
                                                      .leadData.length) {
                                                return const SizedBox();
                                              }
                                              var lead =
                                                  leadProvider.leadData[index];
                                              return MouseRegion(
                                                onEnter: (_) {
                                                  if (_hoveredRowIndex !=
                                                      index) {
                                                    setState(() =>
                                                        _hoveredRowIndex =
                                                            index);
                                                  }
                                                },
                                                onExit: (_) {
                                                  if (_hoveredRowIndex !=
                                                      null) {
                                                    setState(() =>
                                                        _hoveredRowIndex =
                                                            null);
                                                  }
                                                },
                                                child: Container(
                                                  height: rowHeight,
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
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      TableWidget(
                                                        width: 60,
                                                        alignment:
                                                            Alignment.center,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Row(
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
                                                      TableWidget(
                                                        width: 80,
                                                        alignment:
                                                            Alignment.center,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Text(
                                                          lead.customerId
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        flex: 2,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Tooltip(
                                                                message: lead
                                                                    .customerName,
                                                                child:
                                                                    TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    CustomerDetailsProvider
                                                                        customerDetailsProvider =
                                                                        Provider.of<CustomerDetailsProvider>(
                                                                            context,
                                                                            listen:
                                                                                false);
                                                                    customerDetailsProvider
                                                                        .setCustomerId(
                                                                            lead.customerId);
                                                                    sideProvider
                                                                            .name =
                                                                        'Lead /';

                                                                    context.push(
                                                                        '/customerDetails/${lead.customerId}/false');
                                                                  },
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    backgroundColor: Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.1),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(4)),
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            6),
                                                                    fixedSize:
                                                                        const Size
                                                                            .fromHeight(
                                                                            32),
                                                                    tapTargetSize:
                                                                        MaterialTapTargetSize
                                                                            .shrinkWrap,
                                                                  ),
                                                                  child: Text(
                                                                    (lead.customerName.isNotEmpty ??
                                                                            false)
                                                                        ? '${lead.customerName[0].toUpperCase()}${lead.customerName.substring(1)}'
                                                                        : lead.customerName ??
                                                                            '',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                    style:
                                                                        const TextStyle(
                                                                      color: Colors
                                                                          .blue,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            _HoverMenuAnchor(
                                                              builder: (context,
                                                                  controller,
                                                                  onHoverNotify,
                                                                  child) {
                                                                return IconButton(
                                                                  onPressed:
                                                                      () {
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
                                                                      EdgeInsets
                                                                          .zero,
                                                                );
                                                              },
                                                              menuChildren: [
                                                                // Multi-level Create Task menu
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
                                                                          // This is the logic for _HoverMenuAnchor that we will expose
                                                                          onHover(
                                                                              hovering);
                                                                        },
                                                                        leadingIcon: const Icon(
                                                                            Icons
                                                                                .add_task,
                                                                            size:
                                                                                18,
                                                                            color:
                                                                                Colors.teal),
                                                                        children: provider
                                                                            .taskType
                                                                            .where((taskType) =>
                                                                                taskType.manualCreation ==
                                                                                1)
                                                                            .map((taskType) {
                                                                          // Find users for this task type based on department
                                                                          final users = provider
                                                                              .searchUserDetails
                                                                              .where((user) {
                                                                            return user.departmentId.toString() ==
                                                                                taskType.departmentIds.toString();
                                                                          }).toList();

                                                                          if (users
                                                                              .isEmpty) {
                                                                            return MenuItemButton(
                                                                              onPressed: null,
                                                                              child: Text(taskType.taskTypeName),
                                                                            );
                                                                          }

                                                                          return MultiLevelHoverMenu(
                                                                            title:
                                                                                taskType.taskTypeName,
                                                                            children:
                                                                                users.map((user) {
                                                                              return MenuItemButton(
                                                                                onPressed: () {
                                                                                  _quickSaveTask(lead, taskType, user);
                                                                                },
                                                                                child: Text(user.userDetailsName),
                                                                              );
                                                                            }).toList(),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                if (settingsProvider
                                                                            .menuIsViewMap[
                                                                        94] ==
                                                                    1)
                                                                  (onHover) =>
                                                                      MenuItemButton(
                                                                        onHover: onHover,
                                                                        onPressed: () => _handleLeadAction(
                                                                            'convert',
                                                                            lead),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.sync,
                                                                                size: 18,
                                                                                color: Colors.green),
                                                                            SizedBox(width: 8),
                                                                            Text('Convert'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                if (settingsProvider
                                                                            .menuIsSaveMap[
                                                                        16] ==
                                                                    1)
                                                                  (onHover) =>
                                                                      MenuItemButton(
                                                                        onHover: onHover,
                                                                        onPressed: () => _handleLeadAction(
                                                                            'quotation',
                                                                            lead),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.request_quote,
                                                                                size: 18,
                                                                                color: Colors.orange),
                                                                            SizedBox(width: 8),
                                                                            Text('Quotation'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                if (settingsProvider
                                                                            .menuIsSaveMap[
                                                                        19] ==
                                                                    1)
                                                                  (onHover) =>
                                                                      MenuItemButton(
                                                                        onHover: onHover,
                                                                        onPressed: () => _handleLeadAction(
                                                                            'document',
                                                                            lead),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.description,
                                                                                size: 18,
                                                                                color: Colors.purple),
                                                                            SizedBox(width: 8),
                                                                            Text('Document'),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                if (settingsProvider
                                                                            .menuIsEditMap[
                                                                        3] ==
                                                                    1)
                                                                  (onHover) =>
                                                                      MenuItemButton(
                                                                        onHover: onHover,
                                                                        onPressed: () => _handleLeadAction(
                                                                            'edit',
                                                                            lead),
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Icon(Icons.edit,
                                                                                size: 18,
                                                                                color: Colors.blue),
                                                                            SizedBox(width: 8),
                                                                            Text('Edit Lead'),
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
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Tooltip(
                                                          message: lead
                                                              .displayAddress,
                                                          child: Text(
                                                            lead.displayAddress,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    10.0),
                                                        data: Text(
                                                          lead.contactNumber,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
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
                                  width: 2120,
                                  child: Column(
                                    children: [
                                      // Header row
                                      Container(
                                        height: tableHeaderHeight,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryBlue,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8)),
                                        ),
                                        child: Row(
                                          children: [
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Enquiry for',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 175,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Status',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 250,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Remark',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 120,
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: const Text(
                                                'History',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Department',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Assigned Staff',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Follow-Up Date',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 110,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Date',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 120,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Branch',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 120,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Sub Source',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Source',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            if (settingsProvider
                                                    .menuIsViewMap[142] ==
                                                1)
                                              TableWidget(
                                                width: 150,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 12.0),
                                                alignment: Alignment.centerLeft,
                                                data: const Text(
                                                  'Location',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Consumer Name',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TableWidget(
                                              width: 150,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 12.0),
                                              alignment: Alignment.centerLeft,
                                              data: Text(
                                                'Contact No',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Data rows
                                      Expanded(
                                        child: ScrollConfiguration(
                                          behavior:
                                              ScrollConfiguration.of(context)
                                                  .copyWith(scrollbars: false),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: false,
                                            controller:
                                                _scrollableVerticalController,
                                            physics:
                                                const AlwaysScrollableScrollPhysics(),
                                            itemCount:
                                                leadProvider.leadData.length,
                                            itemBuilder: (context, index) {
                                              if (index >=
                                                  leadProvider
                                                      .leadData.length) {
                                                return const SizedBox();
                                              }
                                              final dropDownProvider =
                                                  Provider.of<DropDownProvider>(
                                                      context,
                                                      listen: false);
                                              var lead =
                                                  leadProvider.leadData[index];
                                              return MouseRegion(
                                                onEnter: (_) {
                                                  if (_hoveredRowIndex !=
                                                      index) {
                                                    setState(() =>
                                                        _hoveredRowIndex =
                                                            index);
                                                  }
                                                },
                                                onExit: (_) {
                                                  if (_hoveredRowIndex !=
                                                      null) {
                                                    setState(() =>
                                                        _hoveredRowIndex =
                                                            null);
                                                  }
                                                },
                                                child: Container(
                                                  height: rowHeight,
                                                  color: index % 2 == 0
                                                      ? Colors.white
                                                      : const Color(0xFFF6F7F9),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      TableWidget(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                dropDownProvider
                                                                    .getEnquiryForNameById(
                                                                        lead.enquiryForId,
                                                                        lead.enquiryFor),
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                            if (lead.enquiryForId == 25 && settingsProvider.leadInSales == 1) ...[
                                                              const SizedBox(
                                                                  width: 4),
                                                              MouseRegion(
                                                                cursor:
                                                                    SystemMouseCursors
                                                                        .click,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    String
                                                                        formattedDate =
                                                                        DateFormat('dd MMM yyyy')
                                                                            .format(DateTime.now());

                                                                    Navigator
                                                                        .push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                        builder:
                                                                            (_) =>
                                                                                SalesWidget(
                                                                          isEdit:
                                                                              true,
                                                                          editId:
                                                                              '0',
                                                                          data:
                                                                              SalesModel(
                                                                            customerId:
                                                                                lead.customerId,
                                                                            customerName:
                                                                                lead.customerName,
                                                                            salesMasterId:
                                                                                0,
                                                                            invoiceNo:
                                                                                '',
                                                                            entryDate:
                                                                                '',
                                                                            salesDate:
                                                                                formattedDate,
                                                                            totalAmount:
                                                                                '',
                                                                            totalDiscount:
                                                                                '',
                                                                            taxableAmount:
                                                                                '',
                                                                            totalCgst:
                                                                                '',
                                                                            totalSgst:
                                                                                '',
                                                                            totalIgst:
                                                                                '',
                                                                            netTotal:
                                                                                '',
                                                                            description:
                                                                                '',
                                                                            address:
                                                                                lead.address,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            3),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          const LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xFF2563EB),
                                                                          Color(
                                                                              0xFF1D4ED8),
                                                                        ],
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              4),
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                          color:
                                                                              const Color(0xFF2563EB).withOpacity(0.3),
                                                                          blurRadius:
                                                                              2,
                                                                          offset: const Offset(
                                                                              0,
                                                                              1),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: const [
                                                                        Icon(
                                                                          Icons
                                                                              .trending_up_rounded,
                                                                          color:
                                                                              Colors.white,
                                                                          size:
                                                                              11,
                                                                        ),
                                                                        SizedBox(
                                                                            width:
                                                                                3),
                                                                        Text(
                                                                          'Sales',
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                10,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            letterSpacing:
                                                                                0.2,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        width: 175,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Tooltip(
                                                          message:
                                                              lead.statusName,
                                                          child: TextButton(
                                                            onPressed: () {
                                                              _onStatusClick(
                                                                  context,
                                                                  lead);
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  AppColors.parseColor(lead
                                                                          .colorCode)
                                                                      .withOpacity(
                                                                          0.2),
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
                                                                      vertical:
                                                                          6),
                                                              fixedSize:
                                                                  const Size
                                                                      .fromHeight(
                                                                      32),
                                                              tapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                            ),
                                                            child: Text(
                                                              lead.statusName,
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: AppColors
                                                                    .parseColor(
                                                                        lead.colorCode),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 250,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Tooltip(
                                                          message: lead.remark,
                                                          child: Text(
                                                            lead.remark,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        13),
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 120,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: TextButton.icon(
                                                          onPressed: () {
                                                            LeadHistoryDialog.show(
                                                              context,
                                                              customerId: lead.customerId.toString(),
                                                              customerName: lead.customerName,
                                                            );
                                                          },
                                                          icon: const Icon(
                                                            Icons.history_rounded,
                                                            size: 15,
                                                            color: AppColors.primaryBlue,
                                                          ),
                                                          label: const Text(
                                                            'History',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: AppColors.primaryBlue,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          style: TextButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                                                            padding: EdgeInsets.zero,
                                                            alignment: Alignment.centerLeft,
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Text(
                                                          lead.departmentName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Text(
                                                          lead.toUserName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Text(
                                                          lead.nextFollowUpDate
                                                              .toDayMonthYearFormat(),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        width: 110,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Text(
                                                          _formatDateSafely(
                                                              lead.entryDate),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 120,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Text(
                                                          lead.branchName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        width: 120,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        data: Text(
                                                          lead.referenceName,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Text(
                                                          '${dropDownProvider.getEnquirySourceNameById(lead.enquirySourceId, lead.enquirySourceName)}${lead.referenceName.isNotEmpty ? ' - ${lead.referenceName}' : ''}',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                      if (settingsProvider
                                                                  .menuIsViewMap[
                                                              142] ==
                                                          1)
                                                        TableWidget(
                                                          width: 150,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4.0,
                                                                  horizontal:
                                                                      12.0),
                                                          data: Text(
                                                            lead.locationName ??
                                                                '',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        12),
                                                          ),
                                                        ),
                                                      TableWidget(
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Text(
                                                          lead.consumerName,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
                                                        ),
                                                      ),
                                                      TableWidget(
                                                        width: 150,
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 4.0,
                                                                horizontal:
                                                                    12.0),
                                                        data: Text(
                                                          lead.contactNo,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12),
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
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPaginationControls(context),
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
                            leadProvider.setDateFilter(title);
                            leadProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                                borderRadius: BorderRadius.circular(4),
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
                              searchController.text, fromDate, toDate);
                          leadProvider.getSearchLeads(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
                              searchController.text, fromDate, toDate);
                          leadProvider.getSearchLeads(context);
                        },
                        style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
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
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
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
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
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

  Widget _buildLeadIdFilter(LeadsProvider leadProvider) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (leadIdController.text.isNotEmpty)
              ? AppColors.primaryBlue
              : Colors.grey[300]!,
        ),
      ),
      child: TextField(
        controller: leadIdController,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        // onChanged: (v) => _onSearchChanged(searchController.text),
        onSubmitted: (v) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          leadProvider.setSearchCriteria(searchController.text,
              leadProvider.fromDateS, leadProvider.toDateS,
              leadId: v);
          leadProvider.getSearchLeads(context);
        },
        decoration: const InputDecoration(
          hintText: 'Lead ID',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

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
                        value: user.userDetailsId,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: (leadProvider.selectedUser != null &&
                      leadProvider.selectedUser != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: dropdownValue,
              hint: const Text('Assigned Staff: All', style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: dropdownItems,
              selectedItemBuilder: (BuildContext context) {
                return dropdownItems.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Assigned Staff: ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
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
                          searchController.text, fromDate, toDate);
                      leadProvider.getSearchLeads(context);
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

  Widget _buildEnquiryForFilter(LeadsProvider leadProvider) {
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
            .map((user) => DropdownMenuItem<int>(
                  value: user.enquiryForId,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.enquiryForName,
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
              color: (leadProvider.selectedEnquiryFor != null &&
                      leadProvider.selectedEnquiryFor != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: leadProvider.selectedEnquiryFor ?? 0,
              hint: const Text('Enquiry For: All', style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: items,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enquiry For: ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: (int? newValue) {
                if (newValue != null) {
                  leadProvider.setEnquiryForFilter(newValue);
                }
                String fromDate = leadProvider.formattedFromDate;
                String toDate = leadProvider.formattedToDate;
                leadProvider.setSearchCriteria(
                    searchController.text, fromDate, toDate);
                leadProvider.getSearchLeads(context);
              },
              isDense: true,
              iconSize: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnquirySourceFilter(LeadsProvider leadProvider) {
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
            .map((user) => DropdownMenuItem<int>(
                  value: user.enquirySourceId,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      user.enquirySourceName,
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
              color: (leadProvider.selectedEnquirySource != null &&
                      leadProvider.selectedEnquirySource != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: leadProvider.selectedEnquirySource ?? 0,
              hint: const Text('Enquiry Source: All', style: TextStyle(fontSize: 14, color: Colors.black87)),
              items: items,
              selectedItemBuilder: (BuildContext context) {
                return items.map<Widget>((DropdownMenuItem<int> item) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Enquiry Source: ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                      item.child,
                    ],
                  );
                }).toList();
              },
              onChanged: (int? newValue) {
                if (newValue != null) {
                  leadProvider.setEnquirySourceFilter(newValue);
                }
                String fromDate = leadProvider.formattedFromDate;
                String toDate = leadProvider.formattedToDate;
                leadProvider.setSearchCriteria(
                    searchController.text, fromDate, toDate);
                leadProvider.getSearchLeads(context);
              },
              isDense: true,
              iconSize: 18,
            ),
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

  void _handleLeadAction(String value, SearchLeadModel lead) async {
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
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
      if (!mounted) return;

      final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
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
        if (!mounted) return;
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
    } else if (value == 'convert') {
      leadProvider.convertLead(context, lead.customerId.toString());
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

    // Refresh lead list
    if (mounted) {
      final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadsProvider.getSearchLeads(context);
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

  Widget _buildStatusFilter(
      LeadsProvider leadsProvider, DropDownProvider dropDownProvider) {
    final bool hasSelection = leadsProvider.selectedStatusIds.isNotEmpty &&
        leadsProvider.selectedStatusIds.first != 0;

    // Build label text from selected statuses
    String labelText = 'All';
    if (hasSelection) {
      final selectedNames = dropDownProvider.followUpData
          .where((s) => leadsProvider.selectedStatusIds.contains(s.statusId))
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
                        List<int>.from(leadsProvider.selectedStatusIds),
                    onApply: (selectedIds) {
                      if (selectedIds.isEmpty || selectedIds.contains(0)) {
                        leadsProvider.toggleStatus(0);
                      } else {
                        // Reset first to clear [0] or others if needed
                        leadsProvider.toggleStatus(0); // This resets to [0]
                        for (final id in selectedIds) {
                          leadsProvider.toggleStatus(id);
                        }
                      }
                      leadsProvider.setSearchCriteria(
                        searchController.text,
                        leadsProvider.fromDateS,
                        leadsProvider.toDateS,
                      );
                      leadsProvider.getSearchLeads(context);
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
                leadsProvider.toggleStatus(0); // Reset to All
                leadsProvider.setSearchCriteria(
                  searchController.text,
                  leadsProvider.fromDateS,
                  leadsProvider.toDateS,
                );
                leadsProvider.getSearchLeads(context);
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
                itemBuilder: (ctx, idx) {
                  final status = widget.allStatuses[idx];
                  final id = status.statusId;
                  final name = status.statusName ?? '';
                  final isSelected = _tempSelected.contains(id);

                  return InkWell(
                    onTap: () => _toggle(id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: isSelected
                                ? AppColors.primaryBlue
                                : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              name,
                              style: TextStyle(
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.black
                                    : Colors.grey[700],
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
            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_tempSelected);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 40),
                    ),
                    child: const Text('Apply'),
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
