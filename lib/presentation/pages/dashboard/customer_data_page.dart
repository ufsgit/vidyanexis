import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/audio_file_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_requests.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';
import 'package:vidyanexis/utils/extensions.dart';

class CustomerDataPage extends StatefulWidget {
  final String source;
  final String fromDate;
  final String toDate;
  final int user;

  const CustomerDataPage({
    super.key,
    required this.source,
    required this.fromDate,
    required this.toDate,
    required this.user,
  });

  @override
  State<CustomerDataPage> createState() => _CustomerDataPageState();
}

class _CustomerDataPageState extends State<CustomerDataPage> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  int _totalCount = 0;
  int _startLimit = 1;
  int _endLimit = 20;

  List<SearchLeadModel> _customers = [];
  List<SearchLeadModel> _filteredCustomers = [];
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  final _horizontalScrollController = ScrollController();
  late final ScrollController _fixedVerticalController;
  late final ScrollController _scrollableVerticalController;
  late final ScrollController _mobileScrollController;
  bool _isSyncing = false;
  int? _hoveredRowIndex;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    _fixedVerticalController = ScrollController();
    _scrollableVerticalController = ScrollController();
    _mobileScrollController = ScrollController();
    _fixedVerticalController.addListener(_syncScrollFromFixed);
    _scrollableVerticalController.addListener(_syncScrollFromScrollable);
    _mobileScrollController.addListener(_mobileScrollListener);
    _searchController
        .addListener(() => _onSearchChanged(_searchController.text));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      if (userId.isNotEmpty) {
        settingsProvider.getMenuPermissionData(userId, context);
      }

      await customerProvider.getCustomerFieldsApi();

      dropDownProvider.getFollowUpStatusCustomer(context);
      dropDownProvider.getUserDetails(context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      settingsProvider.getCompanyDetails();

      if (mounted) setState(() {});
    });

    _fetchCustomers();
  }

  void _mobileScrollListener() {
    if (!_mobileScrollController.hasClients) return;
    if (_mobileScrollController.position.pixels >=
            _mobileScrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _fetchCustomers(isPagination: true);
    }
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCustomers = List.from(_customers);
        _expandedIndex = null;
      });
    } else {
      final q = query.toLowerCase();
      setState(() {
        _expandedIndex = null;
        _filteredCustomers = _customers.where((c) {
          return c.customerName.toLowerCase().contains(q) ||
              c.contactNumber.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q) ||
              c.enquiryFor.toLowerCase().contains(q) ||
              c.branchName.toLowerCase().contains(q) ||
              c.statusName.toLowerCase().contains(q) ||
              c.toUserName.toLowerCase().contains(q) ||
              c.customerId.toString().contains(q);
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

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll('Color(', '').replaceAll(')', '');
      return Color(int.parse(hexValue));
    } catch (_) {
      return const Color(0xff34c759);
    }
  }

  /// Always non-null string map for Search_Customer_Dashboard
  Map<String, String> _buildBodyData({
    required int pageIndex1,
    required int pageIndex2,
  }) {
    final search = _searchController.text.trim();
    final fromDate = widget.fromDate.trim();
    final toDate = widget.toDate.trim();
    final isDate = (fromDate.isNotEmpty && toDate.isNotEmpty) ? '1' : '0';
    final toUserId = widget.user > 0 ? widget.user.toString() : '0';

    return {
      'lead_Name': search,
      'Is_Date': isDate,
      'Fromdate': fromDate,
      'Todate': toDate,
      'To_User_Id': toUserId,
      'Status_Id': '0',
      'Page_Index1': pageIndex1.toString(),
      'Page_Index2': pageIndex2.toString(),
      'Enquiry_For_Id': '0',
      'Enquiry_Source_Id': '0',
      'Source': widget.source,
    };
  }

  List<SearchLeadModel> _parseResponse(dynamic data) {
    List<SearchLeadModel> newItems = [];

    if (data is Map) {
      final List<dynamic> list = data['Data'] ?? data['data'] ?? [];
      newItems = list
          .map((e) => SearchLeadModel.fromJson(
                e is Map<String, dynamic>
                    ? e
                    : Map<String, dynamic>.from(e as Map),
              ))
          .toList();
      final total = int.tryParse(
            data['Total_Count']?.toString() ??
                data['total_count']?.toString() ??
                '0',
          ) ??
          0;
      if (total > 0) _totalCount = total;
    } else if (data is List) {
      final allItems = data.map((item) {
        final jsonMap = item is Map<String, dynamic>
            ? item
            : (item is Map
                ? Map<String, dynamic>.from(item)
                : <String, dynamic>{});
        return SearchLeadModel.fromJson(jsonMap);
      }).toList();

      newItems = allItems.where((item) => item.tp == 1).toList();
      final metadataIndex = allItems.indexWhere((item) => item.tp == 2);
      if (metadataIndex != -1) {
        _totalCount = allItems[metadataIndex].customerId;
      } else if (_totalCount == 0) {
        _totalCount = newItems.length;
      }
    }

    return newItems;
  }

  Future<void> _onStatusClick(
      BuildContext context, SearchLeadModel customer) async {
    final dropDownProvider =
        Provider.of<DropDownProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final audioProvider =
        Provider.of<AudioFileProvider>(context, listen: false);

    dropDownProvider.selectedStatusId =
        int.tryParse(customer.statusId.toString());
    leadsProvider.statusController.text = customer.statusName;
    dropDownProvider.selectedUserId =
        int.tryParse(customer.toUserId.toString());
    leadsProvider.searchUserController.text = customer.toUserName;
    leadsProvider.setCutomerId(customer.customerId);
    leadsProvider.branchController.text = customer.branchName;
    settingsProvider.selectedBranchId = customer.branchId;
    settingsProvider.selectedDepartmentId =
        int.tryParse(customer.departmentId.toString()) ?? 0;
    leadsProvider.departmentController.text = customer.departmentName;
    leadsProvider.nextFollowUpDateController.text =
        customer.nextFollowUpDate.isNotEmpty
            ? customer.nextFollowUpDate.toDayMonthYearFormat()
            : '';
    leadsProvider.messageController.text = customer.remark;
    dropDownProvider.filterStaffByBranchAndDepartment(
      branchId: customer.branchId,
      departmentId: int.tryParse(customer.departmentId.toString()) ?? 0,
    );
    audioProvider.clearAudios();

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AddFollowupDialog(
        customerName: customer.customerName,
        statusId: customer.statusId.toString(),
        amount: customer.amount,
      ),
    );
    if (mounted) await _fetchCustomers();
  }

  Future<void> _fetchCustomers({bool isPagination = false}) async {
    if (!isPagination) {
      setState(() {
        _isLoading = true;
        _hasMoreData = true;
        _customers.clear();
        _filteredCustomers.clear();
        _startLimit = 1;
        _endLimit = _pageSize;
        _currentPage = 1;
      });
    } else {
      if (_isLoadingMore || !_hasMoreData) return;
      setState(() => _isLoadingMore = true);
      _startLimit += _pageSize;
      _endLimit += _pageSize;
      _currentPage++;
    }

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchCustomerDashboard,
        bodyData: _buildBodyData(
          pageIndex1: _startLimit,
          pageIndex2: _endLimit,
        ),
      );

      if (response.statusCode == 200) {
        final newItems = _parseResponse(response.data);

        if (!isPagination) {
          _customers = newItems;
        } else {
          if (!AppStyles.isWebScreen(context)) {
            _customers.addAll(newItems);
          } else {
            _customers = newItems;
          }
        }

        if (newItems.isEmpty || _customers.length >= _totalCount) {
          _hasMoreData = false;
        }

        if (!mounted) return;
        setState(() {
          _filteredCustomers = List.from(_customers);
          if (_searchController.text.isNotEmpty) {
            _onSearchChanged(_searchController.text);
          }
          _isLoading = false;
          _isLoadingMore = false;
          _errorMessage = null;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load: ${response.statusCode}';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e, st) {
      log('CustomerDataPage fetch error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _fetchNextPage() async {
    if (_endLimit >= _totalCount && _totalCount > 0) return;
    await _fetchCustomers(isPagination: true);
  }

  Future<void> _fetchPreviousPage() async {
    if (_startLimit <= 1) return;
    final newStart = (_startLimit - _pageSize).clamp(1, _startLimit);
    final newEnd = newStart + _pageSize - 1;
    setState(() {
      _startLimit = newStart;
      _endLimit = newEnd;
      _currentPage = ((newStart - 1) ~/ _pageSize) + 1;
      _isLoading = true;
      _customers.clear();
      _filteredCustomers.clear();
    });

    try {
      final response = await HttpRequest.httpGetRequest(
        endPoint: HttpUrls.searchCustomerDashboard,
        bodyData: _buildBodyData(
          pageIndex1: _startLimit,
          pageIndex2: _endLimit,
        ),
      );

      if (response.statusCode == 200) {
        final newItems = _parseResponse(response.data);
        if (!mounted) return;
        setState(() {
          _customers = newItems;
          _filteredCustomers = List.from(newItems);
          _isLoading = false;
          _hasMoreData = _customers.length < _totalCount;
        });
      } else {
        if (!mounted) return;
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Widget _buildPaginationControls() {
    final startItem = _customers.isEmpty ? 0 : _startLimit;
    final endItem = _customers.isEmpty
        ? 0
        : (_startLimit + _customers.length - 1).clamp(0, _totalCount);

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed:
                (_startLimit > 1) && !_isLoadingMore ? _fetchPreviousPage : null,
          ),
          Text(
            'Showing $startItem - $endItem of $_totalCount',
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: (endItem < _totalCount) && !_isLoadingMore
                ? _fetchNextPage
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
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : w)
        .join(' ');

    final sideProvider = Provider.of<SidebarProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final isMobile = !AppStyles.isWebScreen(context);
    const double tableHeaderHeight = 40.0;
    const double rowHeight = 36.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isMobile
          ? CustomAppBar(
              title: title,
              showFilterIcon: false,
              onSearchTap: () => sideProvider.startSearch(),
              onClearTap: () {
                sideProvider.stopSearch();
                _searchController.clear();
                _fetchCustomers();
              },
              onSearch: (q) {
                _searchController.text = q;
                _fetchCustomers();
              },
              searchController: _searchController,
              leadingWidget: IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color(0xFF152D70),
                onPressed: () {
                  if (sideProvider.reportPage != null) {
                    sideProvider.setReportPage(null);
                  } else {
                    context.pop();
                  }
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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back,
                        color: Color(0xFF152D70)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color(0xFF152D70),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_totalCount > 0)
                    Text(
                      '($_totalCount)',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF152D70),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const Spacer(),
                  Container(
                    width: MediaQuery.of(context).size.width / 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      onSubmitted: (_) => _fetchCustomers(),
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
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh,
                        color: Color(0xFF64748B), size: 20),
                    onPressed: () => _fetchCustomers(),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
          if (isMobile)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomText(
                    'Total Customers: $_totalCount',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey3,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : _filteredCustomers.isEmpty
                        ? const Center(child: Text('No customers found'))
                        : isMobile
                            ? _buildMobileList()
                            : _buildWebTable(
                                customerProvider,
                                settingsProvider,
                                tableHeaderHeight,
                                rowHeight,
                              ),
          ),
          if (!isMobile) ...[
            const SizedBox(height: 10),
            _buildPaginationControls(),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return RefreshIndicator(
      onRefresh: () => _fetchCustomers(),
      child: ListView.builder(
        controller: _mobileScrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredCustomers.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredCustomers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final customer = _filteredCustomers[index];
          return Column(
            key: ValueKey(customer.customerId),
            children: [
              Divider(height: 1, thickness: 1, color: AppColors.grey),
              LeadCard(
                isLead: false,
                lead: customer,
                isExpanded: _expandedIndex == index,
                onTap: () {
                  setState(() {
                    _expandedIndex =
                        _expandedIndex == index ? null : index;
                  });
                },
                onSaved: () => _fetchCustomers(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWebTable(
    CustomerProvider customerProvider,
    SettingsProvider settingsProvider,
    double tableHeaderHeight,
    double rowHeight,
  ) {
    final sideProvider = Provider.of<SidebarProvider>(context, listen: false);

    final bool showCustomerCode = settingsProvider.showCustomerCode == 1;
    final bool showLeadCode = settingsProvider.showLeadCode == 1;
    final bool showLocation = settingsProvider.menuIsViewMap[142] == 1;
    final bool showRamcoLocation = settingsProvider.ramcoLocationPermission == 1;

    final bool apiLoaded = customerProvider.customerFields.isNotEmpty;

    final sortedFields = List.of(customerProvider.customerFields)
      ..sort((a, b) => (a.sort ?? 99).compareTo(b.sort ?? 99));

    bool visible(int id) =>
        !apiLoaded || customerProvider.isCustomerFieldVisible(id);
    String fieldName(int id, String fallback) => !apiLoaded
        ? fallback
        : customerProvider.getCustomerFieldName(id, fallback);

    final double fixedWidth = 80.0 +
        (showLeadCode ? 150.0 : 0.0) +
        (showCustomerCode ? 150.0 : 0.0) +
        (visible(1) ? 230.0 : 0.0) +
        (visible(3) ? 140.0 : 0.0);

    final scrollableFieldIds = !apiLoaded
        ? [2, 4, 5, 6, 7, 8, 9, 11, 10]
        : sortedFields
            .where((f) => f.isVisibility == 1)
            .map((f) => f.customerFieldsId!)
            .toList();

    Widget headerCell(double w, String title) => TableWidget(
          width: w,
          title: title,
          fontWeight: FontWeight.normal,
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          color: const Color(0xFFFFFFFF),
        );

    Widget textCell(double w, String text) => TableWidget(
          width: w,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
          title: text,
        );

    final Map<dynamic, CustomerCustomField> uniqueCustomFields = {};
    for (var lead in _filteredCustomers) {
      for (var cf in lead.customFields) {
        final key =
            cf.customFieldId != 0 ? cf.customFieldId : cf.customFieldName;
        if (key != null &&
            key != '' &&
            key != 0 &&
            !uniqueCustomFields.containsKey(key)) {
          uniqueCustomFields[key] = cf;
        }
      }
    }
    final List<CustomerCustomField> customFieldColumns =
        uniqueCustomFields.values.toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    Widget buildScrollableHeader() {
      return Row(children: [
        for (final id in scrollableFieldIds) ...[
          if (id == 2) headerCell(180, fieldName(2, 'Place')),
          if (id == 4) headerCell(140, fieldName(4, 'AMC Date')),
          if (id == 5) headerCell(190, fieldName(5, 'Work Completion Date')),
          if (id == 6) headerCell(220, fieldName(6, 'Remarks')),
          if (id == 7) headerCell(160, fieldName(7, 'Follow Up Status')),
          if (id == 8) headerCell(140, fieldName(8, 'Follow Up Date')),
          if (id == 9) headerCell(140, fieldName(9, 'Consumer No')),
          if (id == 10) headerCell(150, fieldName(10, 'Assigned Staff')),
          if (id == 11) ...[
            for (final cf in customFieldColumns)
              headerCell(200, cf.customFieldName),
          ],
        ],
        if (showRamcoLocation) headerCell(120, 'Location'),
        if (showLocation) headerCell(140, 'Location'),
      ]);
    }

    Widget buildScrollableRow(SearchLeadModel lead) {
      return Row(children: [
        for (final id in scrollableFieldIds) ...[
          if (id == 2) textCell(180, lead.displayPlace),
          if (id == 4) textCell(140, lead.amcDateDisplay),
          if (id == 5) textCell(190, lead.workCompletionDateDisplay),
          if (id == 6) textCell(220, lead.remark),
          if (id == 7)
            TableWidget(
              width: 160,
              padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              data: InkWell(
                onTap: () => settingsProvider.customerStatusBlock == 1
                    ? null
                    : _onStatusClick(context, lead),
                child: Container(
                  padding: lead.statusName.isNotEmpty
                      ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: parseColor(lead.colorCode).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: parseColor(lead.colorCode).withOpacity(0.5),
                        width: 0.5),
                  ),
                  child: Text(
                    lead.statusName,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: parseColor(lead.colorCode),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          if (id == 8)
            textCell(
              140,
              lead.nextFollowUpDate.isNotEmpty
                  ? lead.nextFollowUpDate.toDayMonthYearFormat()
                  : '',
            ),
          if (id == 9) textCell(140, lead.consumerNo),
          if (id == 10) textCell(150, lead.toUserName),
          if (id == 11) ...[
            for (final cf in customFieldColumns)
              TableWidget(
                width: 200,
                fontSize: 12,
                fontWeight: FontWeight.normal,
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                data: Tooltip(
                  message: lead.customFields
                      .firstWhere(
                        (c) =>
                            (cf.customFieldId != 0 &&
                                c.customFieldId == cf.customFieldId) ||
                            (cf.customFieldId == 0 &&
                                c.customFieldName == cf.customFieldName),
                        orElse: () => CustomerCustomField(),
                      )
                      .datavalue,
                  child: Text(
                    lead.customFields
                        .firstWhere(
                          (c) =>
                              (cf.customFieldId != 0 &&
                                  c.customFieldId == cf.customFieldId) ||
                              (cf.customFieldId == 0 &&
                                  c.customFieldName == cf.customFieldName),
                          orElse: () => CustomerCustomField(),
                        )
                        .datavalue,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ],
        if (showRamcoLocation)
          textCell(
            120,
            (lead.location?.toString() ?? '').trim().isNotEmpty ? 'Yes' : 'No',
          ),
        if (showLocation) textCell(140, lead.locationName ?? ''),
      ]);
    }

    final double scrollableWidth = scrollableFieldIds.fold(0.0, (sum, id) {
          final w = {
            2: 180.0,
            4: 140.0,
            5: 190.0,
            6: 220.0,
            7: 160.0,
            8: 140.0,
            9: 140.0,
            10: 150.0,
            11: customFieldColumns.length * 200.0,
          };
          return sum + (w[id] ?? 0.0);
        }) +
        (showRamcoLocation ? 120.0 : 0.0) +
        (showLocation ? 140.0 : 0.0);

    return Scrollbar(
      controller: _scrollableVerticalController,
      thumbVisibility: true,
      trackVisibility: true,
      interactive: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: fixedWidth,
            child: Column(
              children: [
                Container(
                  height: tableHeaderHeight,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const TableWidget(
                        width: 80,
                        title: 'Sl No.',
                        fontWeight: FontWeight.normal,
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 12.0),
                        color: Color(0xFFFFFFFF),
                      ),
                      if (showLeadCode)
                        const TableWidget(
                          width: 150,
                          title: 'Lead Code',
                          fontWeight: FontWeight.normal,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          color: Color(0xFFFFFFFF),
                        ),
                      if (showCustomerCode)
                        const TableWidget(
                          width: 150,
                          title: 'Customer Code',
                          fontWeight: FontWeight.normal,
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          color: Color(0xFFFFFFFF),
                        ),
                      if (visible(1))
                        TableWidget(
                          width: 230,
                          title: fieldName(1, 'Customer Name'),
                          fontWeight: FontWeight.normal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          color: const Color(0xFFFFFFFF),
                        ),
                      if (visible(3))
                        TableWidget(
                          width: 140,
                          title: fieldName(3, 'Mobile no'),
                          fontWeight: FontWeight.normal,
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                          color: const Color(0xFFFFFFFF),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context)
                        .copyWith(scrollbars: false),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _fixedVerticalController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final lead = _filteredCustomers[index];
                        return MouseRegion(
                          onEnter: (_) {
                            if (_hoveredRowIndex != index) {
                              setState(() => _hoveredRowIndex = index);
                            }
                          },
                          onExit: (_) {
                            if (_hoveredRowIndex != null) {
                              setState(() => _hoveredRowIndex = null);
                            }
                          },
                          child: Container(
                            height: rowHeight,
                            decoration: BoxDecoration(
                              color: index == _hoveredRowIndex
                                  ? const Color(0xFFE2E8F0)
                                  : (index % 2 == 0
                                      ? const Color(0xFFE8EDF2)
                                      : const Color(0xFFF5F5F5)),
                              border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: Row(
                              children: [
                                TableWidget(
                                  width: 80,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6.0, horizontal: 12.0),
                                  title: (lead.rowNo > 0)
                                      ? lead.rowNo.toString()
                                      : (_startLimit + index).toString(),
                                ),
                                if (showLeadCode)
                                  TableWidget(
                                    width: 150,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    title: lead.customerId.toString(),
                                  ),
                                if (showCustomerCode)
                                  TableWidget(
                                    width: 150,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    title: lead.displayCustomerCode.isNotEmpty
                                        ? lead.displayCustomerCode
                                        : lead.getDisplayLeadCode(
                                            settingsProvider
                                                .leadCodeWithEnquiryCode),
                                  ),
                                if (visible(1))
                                  TableWidget(
                                    width: 230,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    data: Tooltip(
                                      message: lead.customerName,
                                      child: TextButton(
                                        onPressed: () {
                                          sideProvider.name = 'Customers /';
                                          context.push(
                                              '/customerDetails/${lead.customerId}/false');
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.blue
                                              .withValues(alpha: 0.1),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          lead.customerName.isNotEmpty
                                              ? '${lead.customerName[0].toUpperCase()}${lead.customerName.substring(1)}'
                                              : lead.customerName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (visible(3))
                                  TableWidget(
                                    width: 140,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0, horizontal: 8.0),
                                    title: lead.contactNumber,
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
                  width: scrollableWidth < 400 ? 400 : scrollableWidth,
                  child: Column(
                    children: [
                      Container(
                        height: tableHeaderHeight,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: buildScrollableHeader(),
                      ),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context)
                              .copyWith(scrollbars: false),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            controller: _scrollableVerticalController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _filteredCustomers.length,
                            itemBuilder: (context, index) {
                              final lead = _filteredCustomers[index];
                              return MouseRegion(
                                onEnter: (_) {
                                  if (_hoveredRowIndex != index) {
                                    setState(() => _hoveredRowIndex = index);
                                  }
                                },
                                onExit: (_) {
                                  if (_hoveredRowIndex != null) {
                                    setState(() => _hoveredRowIndex = null);
                                  }
                                },
                                child: Container(
                                  height: rowHeight,
                                  decoration: BoxDecoration(
                                    color: index == _hoveredRowIndex
                                        ? const Color(0xFFE2E8F0)
                                        : (index % 2 == 0
                                            ? const Color(0xFFE8EDF2)
                                            : const Color(0xFFF5F5F5)),
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200)),
                                  ),
                                  child: buildScrollableRow(lead),
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
    );
  }
}
