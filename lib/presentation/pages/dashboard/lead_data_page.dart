import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/utils/extensions.dart';

class LeadDataPage extends StatefulWidget {
  final String source;
  final String fromDate;
  final String toDate;
  final int user;

  const LeadDataPage({
    super.key,
    required this.source,
    required this.fromDate,
    required this.toDate,
    required this.user,
  });

  @override
  State<LeadDataPage> createState() => _LeadDataPageState();
}

class _LeadDataPageState extends State<LeadDataPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  int _totalCount = 0;

  List<SearchLeadModel> _leads = [];
  List<SearchLeadModel> _filteredLeads = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  final _horizontalScrollController = ScrollController();
  late final ScrollController _fixedVerticalController;
  late final ScrollController _scrollableVerticalController;
  late final ScrollController _mobileScrollController;
  bool _isSyncing = false;
  int? _hoveredRowIndex;
  int? _expandedIndex;

  String userName = "Admin";
  String logo = "";
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _initData();
    _fixedVerticalController = ScrollController();
    _scrollableVerticalController = ScrollController();
    _mobileScrollController = ScrollController();

    _fixedVerticalController.addListener(_syncScrollFromFixed);
    _scrollableVerticalController.addListener(_syncScrollFromScrollable);
    _mobileScrollController.addListener(_mobileScrollListener);

    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });

    // ensure permissions are available before the drawer is opened; the home
    // page normally requests these, but LeadDataPage can be pushed from other
    // places so we double‑check here as well.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      if (userId.isNotEmpty) {
        settingsProvider.getMenuPermissionData(userId, context);
      }
    });

    _fetchLeads();
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Admin";
    });

    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    await settingsProvider.getCompanyDetails();
    if (mounted) {
      setState(() {
        logo = settingsProvider.logo.isNotEmpty
            ? (settingsProvider.logo.startsWith('http')
                ? settingsProvider.logo
                : "${HttpUrls.imgBaseUrl}${settingsProvider.logo}")
            : AppStyles.logo();
      });
    }

    PackageInfo.fromPlatform().then((value) {
      if (mounted) {
        setState(() {
          packageInfo = value;
        });
      }
    });
  }

  void _mobileScrollListener() {
    if (_mobileScrollController.hasClients) {
      if (_mobileScrollController.position.pixels >=
              _mobileScrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMoreData) {
        _fetchLeads(isPagination: true);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLeads = List.from(_leads);
        _expandedIndex = null;
      });
    } else {
      setState(() {
        _expandedIndex = null;
        _filteredLeads = _leads.where((lead) {
          final lowercaseQuery = query.toLowerCase();
          return lead.customerName.toLowerCase().contains(lowercaseQuery) ||
              lead.contactNumber.toLowerCase().contains(lowercaseQuery) ||
              lead.enquiryFor.toLowerCase().contains(lowercaseQuery) ||
              lead.branchName.toLowerCase().contains(lowercaseQuery) ||
              lead.statusName.toLowerCase().contains(lowercaseQuery) ||
              lead.toUserName.toLowerCase().contains(lowercaseQuery) ||
              lead.customerId.toString().contains(lowercaseQuery);
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _horizontalScrollController.dispose();
    _fixedVerticalController.dispose();
    _scrollableVerticalController.dispose();
    _mobileScrollController.dispose();
    super.dispose();
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

  String _formatDateSafely(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return '';
    }
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

  Future<void> _fetchLeads({bool isPagination = false}) async {
    if (!isPagination) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        _hasMoreData = true;
        _leads.clear();
        _filteredLeads.clear();
      });
    } else {
      if (_isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
    }

    int startLimit = ((_currentPage - 1) * _pageSize) + 1;
    int endLimit = _currentPage * _pageSize;

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchLeadDashboard,
        bodyData: {
          "lead_Name": "",
          "Is_Date": widget.fromDate.isNotEmpty ? "1" : "0",
          "Fromdate": widget.fromDate,
          "Todate": widget.toDate,
          "To_User_Id": widget.user.toString(),
          "Status_Id": "0",
          "Page_Index1": startLimit.toString(),
          "Page_Index2": endLimit.toString(),
          "Enquiry_For_Id": "0",
          "Enquiry_Source_Id": "0",
          "Source": widget.source,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<SearchLeadModel> newLeads = [];
        
        if (data is Map) {
          final List<dynamic> leadsData = data['Data'] ?? [];
          newLeads = leadsData.map((e) => SearchLeadModel.fromJson(e)).toList();
          _totalCount = int.tryParse(data['Total_Count']?.toString() ?? '0') ?? 0;
        } else if (data is List) {
          final List<SearchLeadModel> allItems =
              data.map((e) => SearchLeadModel.fromJson(e)).toList();

          // Separate real leads (tp == 1) from metadata (tp == 2)
          newLeads = allItems.where((item) => item.tp == 1).toList();

          // Find total count from metadata record (tp == 2) or fallback to list size
          int tpCount = 0;
          for (var item in allItems) {
            if (item.tp == 2) {
              tpCount = item.customerId;
              break;
            }
          }

          if (tpCount > 0) {
            _totalCount = tpCount;
          } else {
            // Fallback to DashboardProvider count matching this source
            final dashBoardProvider =
                Provider.of<DashboardProvider>(context, listen: false);
            String normalizedSource = widget.source
                .toLowerCase()
                .replaceAll('_', '')
                .replaceAll('s', '');

            int providerCount = 0;
            dashBoardProvider.leadCountMap.forEach((key, value) {
              String normalizedKey =
                  key.toLowerCase().replaceAll('_', '').replaceAll('s', '');
              // Handle special case for transferred/transffered
              if (normalizedKey.contains('transf') &&
                  normalizedSource.contains('transf')) {
                providerCount = value;
              } else if (normalizedKey == normalizedSource) {
                providerCount = value;
              }
            });

            if (providerCount > 0) {
              _totalCount = providerCount;
            } else if (newLeads.isNotEmpty) {
              // Use the largest RowNo seen or customerId as a last resort
              int maxRow = 0;
              for (var l in newLeads) {
                if (l.rowNo > maxRow) maxRow = l.rowNo;
              }
              _totalCount = maxRow > 0 ? maxRow : newLeads.last.customerId;
            }
          }
          
          // Consistency check: totalCount shouldn't be less than what we just received
          if (newLeads.length > _totalCount) {
             _totalCount = newLeads.length;
          }
        }

        if (newLeads.isNotEmpty || _totalCount >= 0) {
          // Extra safety check for empty lead rows that might still be in newLeads
          newLeads.removeWhere((lead) => lead.customerName.isEmpty && lead.tp != 1);

          if (newLeads.isEmpty && _totalCount > 0) {
             // If we have total count but No leads in this page, maybe it's the end
             if (isPagination) _hasMoreData = false;
          } else if (newLeads.isEmpty && _totalCount == 0) {
             _hasMoreData = false;
          } else {
            if (!isPagination) {
              _leads = newLeads;
            } else {
              if (!AppStyles.isWebScreen(context)) {
                _leads.addAll(newLeads);
              } else {
                _leads = newLeads;
              }
            }
            
            // Update hasMoreData for mobile/lazy loading
            if (_leads.length >= _totalCount) {
              _hasMoreData = false;
            }
          }

          setState(() {
            _filteredLeads = List.from(_leads);
            if (_searchController.text.isNotEmpty) {
              _onSearchChanged(_searchController.text);
            }
            _isLoading = false;
            _isLoadingMore = false;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid data format from server';
            _isLoading = false;
            _isLoadingMore = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load leads: ${response.statusCode}';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (_currentPage * _pageSize >= _totalCount && _totalCount > 0) return;
    await _fetchLeads(isPagination: true);
  }

  Future<void> _fetchPreviousPage() async {
    if (_currentPage <= 1) return;
    setState(() {
      _currentPage = _currentPage - 2;
    });
    await _fetchLeads(isPagination: true);
  }
    
  Widget _buildPaginationControls() {
    // Calculate the actual range based on server-provided row numbers if available
    int startItem = 0;
    int endItem = 0;
    
    if (_filteredLeads.isNotEmpty) {
      if (_filteredLeads.first.rowNo > 0) {
        startItem = _filteredLeads.first.rowNo;
        endItem = _filteredLeads.last.rowNo;
      } else {
        startItem = ((_currentPage - 1) * _pageSize) + 1;
        endItem = startItem + _filteredLeads.length - 1;
      }
    }

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (_currentPage > 1) && !_isLoadingMore
                ? () {
                    _fetchPreviousPage();
                  }
                : null,
          ),
          Text(
            'Showing $startItem - $endItem of $_totalCount',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: (endItem < _totalCount) && !_isLoadingMore
                ? () {
                    _fetchNextPage();
                  }
                : null,
          ),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    final title = widget.source
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');

    final sideProvider = Provider.of<SidebarProvider>(context);
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final isMobile = !AppStyles.isWebScreen(context);
    final double tableHeaderHeight = 50.0;
    final double rowHeight = 35.0;

    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: isMobile
            ? CustomAppBar(
                title: title,
                showFilterIcon: false,
                onSearchTap: () {
                  sideProvider.startSearch();
                },
                onClearTap: () {
                  sideProvider.stopSearch();
                  _searchController.clear();
                },
                onSearch: (_) {}, // Local listener handles search
                searchController: _searchController,
                leadingWidget: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFF152D70),
                  onPressed: () {
                    context.pop();
                  },
                ),
              )
            : null,
        body: Column(
          children: [
            if (!isMobile)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF152D70),
                        )),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFF152D70),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_leads.isNotEmpty)
                      Text(
                        '($_totalCount)',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF152D70),
                          fontWeight: FontWeight.w500,
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
                        controller: _searchController,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: 'Search here....',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          suffixIcon: Icon(Icons.search, color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : _filteredLeads.isEmpty
                          ? const Center(child: Text("No leads found"))
                          : isMobile
                              ? RefreshIndicator(
                                  onRefresh: () => _fetchLeads(),
                                  child: ListView.builder(
                                    controller: _mobileScrollController,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: _filteredLeads.length +
                                        (_isLoadingMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _filteredLeads.length) {
                                        return const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        );
                                      }
                                      final lead = _filteredLeads[index];
                                      return Column(
                                        children: [
                                          Divider(
                                            height: 2,
                                            color: AppColors.grey,
                                          ),
                                          LeadCard(
                                            isLead: true,
                                            lead: lead,
                                            isExpanded: _expandedIndex == index,
                                            onTap: () {
                                              setState(() {
                                                if (_expandedIndex == index) {
                                                  _expandedIndex = null;
                                                } else {
                                                  _expandedIndex = index;
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                )
                              : Scrollbar(
                                  controller: _scrollableVerticalController,
                                  thumbVisibility: true,
                                  trackVisibility: true,
                                  interactive: true,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Fixed columns section
                                      SizedBox(
                                        width: 600,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // Fixed Header
                                            Container(
                                              height: tableHeaderHeight,
                                              decoration: const BoxDecoration(
                                                color: Color.fromARGB(
                                                    255, 0, 90, 69),
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    bottomLeft:
                                                        Radius.circular(8)),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    width: 80,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                              horizontal: 6.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'SL',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 50,
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                              horizontal: 4.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'ID',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const TableWidget(
                                                      width: 110,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                              horizontal: 8.0),
                                                      data: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Date',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                      color: Color(0xFF607185)),
                                                  const TableWidget(
                                                      flex: 3,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                              horizontal: 8.0),
                                                      data: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Name',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                      color: Color(0xFF607185)),
                                                  const TableWidget(
                                                      width: 150,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 6.0,
                                                              horizontal: 8.0),
                                                      data: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          'Contact',
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                          ),
                                                        ),
                                                      ),
                                                      color: Color(0xFF607185)),
                                                ],
                                              ),
                                            ),
                                            // Fixed Data Rows
                                            Expanded(
                                              child: ScrollConfiguration(
                                                behavior:
                                                    ScrollConfiguration.of(
                                                            context)
                                                        .copyWith(
                                                            scrollbars: false),
                                                child: ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: false,
                                                  controller:
                                                      _fixedVerticalController,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemCount:
                                                      _filteredLeads.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var lead =
                                                        _filteredLeads[index];
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
                                                        decoration:
                                                            BoxDecoration(
                                                          color: index % 2 == 0
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFFF6F7F9),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
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
                                                              width: 80,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        6.0),
                                                                child: Center(
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                       Text(
                                                                           (lead.rowNo > 0)
                                                                               ? lead.rowNo.toString()
                                                                               : ((index + 1) +
                                                                                       (_currentPage - 1) *
                                                                                           _pageSize)
                                                                                   .toString(),
                                                                          style:
                                                                              const TextStyle(fontSize: 13)),
                                                                      if (lead.leadTypeId ==
                                                                          UserStatusType
                                                                              .hotLead
                                                                              .value)
                                                                        const Padding(
                                                                          padding:
                                                                              EdgeInsets.only(left: 4.0),
                                                                          child: Text(
                                                                              "⭐",
                                                                              style: TextStyle(fontSize: 10)),
                                                                        )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 55,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            6.0,
                                                                        horizontal:
                                                                            4.0),
                                                                child: Center(
                                                                  child: Text(
                                                                      lead.customerId
                                                                          .toString(),
                                                                      style: const TextStyle(
                                                                          fontSize:
                                                                              13)),
                                                                ),
                                                              ),
                                                            ),
                                                            TableWidget(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          6.0,
                                                                      horizontal:
                                                                          8.0),
                                                              width: 110,
                                                              data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  _formatDateSafely(
                                                                      lead.entryDate),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12),
                                                                ),
                                                              ),
                                                            ),
                                                            TableWidget(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          6.0,
                                                                      horizontal:
                                                                          8.0),
                                                              flex: 3,
                                                              data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Tooltip(
                                                                  message: lead
                                                                      .customerName,
                                                                  child:
                                                                      TextButton(
                                                                    onPressed:
                                                                        () {
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
                                                                          .withValues(
                                                                              alpha: 0.1),
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(5)),
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              10,
                                                                          vertical:
                                                                              5),
                                                                      minimumSize:
                                                                          const Size(
                                                                              0,
                                                                              0),
                                                                      tapTargetSize:
                                                                          MaterialTapTargetSize
                                                                              .shrinkWrap,
                                                                    ),
                                                                    child: Text(
                                                                      (lead.customerName
                                                                              .isNotEmpty)
                                                                          ? '${lead.customerName[0].toUpperCase()}${lead.customerName.substring(1)}'
                                                                          : lead
                                                                              .customerName,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .blue,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            13,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            TableWidget(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          6.0,
                                                                      horizontal:
                                                                          8.0),
                                                              width: 150,
                                                              data: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerLeft,
                                                                  child: Text(
                                                                    lead.contactNumber,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            13),
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
                                          controller:
                                              _horizontalScrollController,
                                          thumbVisibility: true,
                                          trackVisibility: true,
                                          interactive: true,
                                          child: SingleChildScrollView(
                                            controller:
                                                _horizontalScrollController,
                                            scrollDirection: Axis.horizontal,
                                            child: SizedBox(
                                              width: 1520,
                                              child: Column(
                                                children: [
                                                  // Header row
                                                  Container(
                                                    height: tableHeaderHeight,
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(
                                                          255, 0, 90, 69),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(8),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          8)),
                                                    ),
                                                    child: const Row(
                                                      children: [
                                                        TableWidget(
                                                            width: 150,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    'Enquiry for',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color(
                                                                            0xFFFFFFFF)))),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 150,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    'Source',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color(
                                                                            0xFFFFFFFF)))),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 120,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    'Branch',
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color(
                                                                            0xFFFFFFFF)))),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 175,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Text('Status',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13)),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 100,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    'Convert',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: Color(
                                                                            0xFFFFFFFF)))),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 375,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Text('Remark',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13)),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 150,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Text(
                                                                'Department',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13)),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 150,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Text(
                                                                'Assigned Staff',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13)),
                                                            color: Color(
                                                                0xFF607185)),
                                                        TableWidget(
                                                            width: 150,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        6.0,
                                                                    horizontal:
                                                                        8.0),
                                                            data: Text(
                                                                'Follow-Up Date',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        13)),
                                                            color: Color(
                                                                0xFF607185)),
                                                      ],
                                                    ),
                                                  ),
                                                  // Data rows
                                                  Expanded(
                                                    child: ScrollConfiguration(
                                                      behavior:
                                                          ScrollConfiguration
                                                                  .of(context)
                                                              .copyWith(
                                                                  scrollbars:
                                                                      false),
                                                      child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: false,
                                                        controller:
                                                            _scrollableVerticalController,
                                                        physics:
                                                            const AlwaysScrollableScrollPhysics(),
                                                        itemCount:
                                                            _filteredLeads
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          var lead =
                                                              _filteredLeads[
                                                                  index];
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
                                                              color: index %
                                                                          2 ==
                                                                      0
                                                                  ? Colors.white
                                                                  : const Color(
                                                                      0xFFF6F7F9),
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  TableWidget(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          150,
                                                                      data: Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child: Text(
                                                                              lead.enquiryFor,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 13)))),
                                                                  TableWidget(
                                                                      width:
                                                                          150,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      data: Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child: Text(
                                                                              '${lead.sourceCategoryName}${lead.referenceName.isNotEmpty ? ' - ${lead.referenceName}' : ''}',
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 12)))),
                                                                  TableWidget(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          120,
                                                                      data: Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child: Text(
                                                                              lead.branchName,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                              style: const TextStyle(fontSize: 13)))),
                                                                  TableWidget(
                                                                      width:
                                                                          175,
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      data: Tooltip(
                                                                          message: lead.statusName,
                                                                          child: TextButton(
                                                                              onPressed: () {
                                                                                _onStatusClick(context, lead);
                                                                              },
                                                                              style: TextButton.styleFrom(backgroundColor: AppColors.parseColor(lead.colorCode).withValues(alpha: 0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                                                              child: Text(lead.statusName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.parseColor(lead.colorCode)))))),
                                                                  TableWidget(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          100,
                                                                      data: Align(
                                                                          alignment: Alignment.centerLeft,
                                                                          child: TextButton(
                                                                              onPressed: () {
                                                                                leadsProvider.convertLead(context, lead.customerId.toString());
                                                                              },
                                                                              style: TextButton.styleFrom(backgroundColor: Colors.orange.withValues(alpha: 0.1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                                                              child: const Text('Convert', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500, fontSize: 13))))),
                                                                  TableWidget(
                                                                      padding: EdgeInsets.symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          375,
                                                                      data: Tooltip(
                                                                          message: lead
                                                                              .remark,
                                                                          child: Text(
                                                                              lead.remark,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 13)))),
                                                                  TableWidget(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          150,
                                                                      data: Align(
                                                                          alignment: Alignment
                                                                              .centerLeft,
                                                                          child: Text(
                                                                              lead.departmentName,
                                                                              maxLines: 1,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(fontSize: 13)))),
                                                                  TableWidget(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          150,
                                                                      data: Text(
                                                                          lead
                                                                              .toUserName,
                                                                          maxLines:
                                                                              1,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(fontSize: 13))),
                                                                  TableWidget(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              6.0,
                                                                          horizontal:
                                                                              8.0),
                                                                      width:
                                                                          150,
                                                                      data: Text(
                                                                          lead.nextFollowUpDate.isNotEmpty
                                                                              ? lead.nextFollowUpDate
                                                                                  .toDayMonthYearFormat()
                                                                              : '',
                                                                          maxLines:
                                                                              1,
                                                                          overflow: TextOverflow
                                                                              .ellipsis,
                                                                          style:
                                                                              const TextStyle(fontSize: 13))),
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
            if (!isMobile) ...[
              const SizedBox(height: 10),
              _buildPaginationControls(),
              const SizedBox(height: 10),
            ],
          ],
        ));
  }
}
