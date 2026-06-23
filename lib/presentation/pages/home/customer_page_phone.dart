import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/loading_circle.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomerPagePhone extends StatefulWidget {
  const CustomerPagePhone({super.key});

  @override
  State<CustomerPagePhone> createState() => _CustomerPagePhoneState();
}

class _CustomerPagePhoneState extends State<CustomerPagePhone> {
  TextEditingController searchController = TextEditingController();
  Timer? _debounce;

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
      );
      customerProvider.getSearchCustomers(context);
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  CustomerProvider? _customerProvider;

  Future<void> _refreshData() async {
    final searchProvider = Provider.of<SidebarProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final customerProvider =
        Provider.of<CustomerProvider>(context, listen: false);
    final provider = Provider.of<DropDownProvider>(context, listen: false);
    customerProvider.setFilter(false);
    settingsProvider.searchBranch(context);
    settingsProvider.searchDepartment('', context);

    searchProvider.stopSearch();
    // Load all statuses by default (no ViewIn_Id) so the dropdown shows everything.
    // provider.getFollowUpStatus(context, '2');
    provider.getUserDetails(context);
    await provider.getFollowUpStatusCustomer(context);

    // Reset search criteria
    customerProvider.setSearchCriteria(
      '',
      '',
      '',
    );
    await customerProvider.getSearchCustomers(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
      _customerProvider = Provider.of<CustomerProvider>(context, listen: false);
      final customerProvider = _customerProvider!;
      customerProvider.setSearchCriteria(
        '',
        '',
        '',
      );
      customerProvider.resetExpansion();
      customerProvider.getSearchCustomers(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      // Load all statuses by default (no ViewIn_Id) so the dropdown shows everything.
      await provider.getFollowUpStatusCustomer(context);
      provider.getUserDetails(context);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      customerProvider.setFilter(false);

      customerProvider.scrollController.addListener(() {
        customerProvider.scrollListener(context);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _customerProvider?.scrollController.removeListener(() {
      _customerProvider?.scrollListener(context);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final sideprovider = Provider.of<SidebarProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.scaffoldColor,
      appBar: CustomAppBar(
        onSearchTap: () {
          customerProvider.toggleFilter();

          searchProvider.startSearch();
        },
        onFilterTap: () {
          log('sdf');
          customerProvider.toggleFilter();
        },
        onClearTap: () {
          searchController.clear();
          customerProvider.toggleFilter();
          searchProvider.stopSearch();
          customerProvider.setSearchCriteria(
            '',
            '',
            '',
          );
          customerProvider.getSearchCustomers(context);
        },
        title: 'Customers',
        showLogo: false,
        showUserName: false,
        showFilterIcon: false,
        showSort: true,
        showOrder: true,
        sortOrder: customerProvider.sortOrder,
        onOrderTap: () => customerProvider.toggleSortOrder(context),
        onSortTap: (value) {
          customerProvider.setSortOption(value, context);
        },
        onSearch: (String query) {
          customerProvider.setSearchCriteria(
            query,
            customerProvider.fromDateS,
            customerProvider.toDateS,
          );
          customerProvider.getSearchCustomers(context);
        },
        // onChanged: _onSearchChanged,
        searchController: searchController,
      ),
      drawer: const SidebarDrawer(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: customerProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_customer_filter_fab',
                  onPressed: () {
                    customerProvider.setSearchCriteria(
                      searchController.text,
                      customerProvider.fromDateS,
                      customerProvider.toDateS,
                    );
                    searchProvider.stopSearch();
                    customerProvider.getSearchCustomers(context);
                    customerProvider.toggleFilter();
                  },
                  backgroundColor: AppColors.darkGreen,
                  label: const CustomText(
                    'APPLY',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  icon: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
              )
            : null,
      ),
      body: customerProvider.isLoading
          ? const Center(
              child: LoadingCircle(),
            )
          : Column(
              children: [
                Container(
                  color: AppColors.whiteColor,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Entry Type Filter
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              customerProvider.setEntryType('myown');
                              customerProvider.getSearchCustomers(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: customerProvider.entryType != 'all'
                                        ? AppColors.primaryBlue
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                'ME',
                                style: TextStyle(
                                  color: customerProvider.entryType != 'all'
                                      ? AppColors.primaryBlue
                                      : Colors.grey,
                                  fontWeight:
                                      customerProvider.entryType != 'all'
                                          ? FontWeight.w500
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
                              customerProvider.getSearchCustomers(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 2),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: customerProvider.entryType == 'all'
                                        ? AppColors.primaryBlue
                                        : Colors.transparent,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              child: Text(
                                'ALL',
                                style: TextStyle(
                                  color: customerProvider.entryType == 'all'
                                      ? AppColors.primaryBlue
                                      : Colors.grey,
                                  fontWeight:
                                      customerProvider.entryType == 'all'
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      CustomFilterButton(
                        onPressed: () {
                          customerProvider.toggleFilter();
                        },
                        isFilter: customerProvider.isFilter,
                      ),
                    ],
                  ),
                ),
                if (customerProvider.isFilter)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            'Status',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: [
                              FilterChipWidget(
                                label: 'All',
                                isSelected: customerProvider.selectedStatusIds
                                    .contains(0),
                                onTap: () {
                                  customerProvider.toggleStatus(0);
                                },
                              ),
                              ...provider.followUpData.map((status) {
                                return FilterChipWidget(
                                  label: status.statusName ?? 'Unknown',
                                  isSelected: customerProvider.selectedStatusIds
                                      .contains(status.statusId),
                                  onTap: () {
                                    customerProvider
                                        .toggleStatus(status.statusId ?? 0);
                                  },
                                );
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            alignment: WrapAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  onClickTopButton(context);
                                },
                                child: Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.scaffoldColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 200),
                                            child: CustomText(
                                              customerProvider.fromDate ==
                                                          null &&
                                                      customerProvider.toDate ==
                                                          null
                                                  ? 'Date'
                                                  : 'Date : ${customerProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${customerProvider.formattedToDate.toString().toDayMonthYearFormat()}',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textBlack,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.textGrey3,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (customerProvider.fromDate != null ||
                              customerProvider.toDate != null ||
                              !customerProvider.selectedStatusIds
                                  .every((id) => id == 0) ||
                              customerProvider.search.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  customerProvider.clearAllFilters();
                                  searchController.clear();
                                  customerProvider.getSearchCustomers(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textRed,
                                  side: BorderSide(color: AppColors.textRed),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text('Reset All Filters'),
                              ),
                            ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                if (!customerProvider.isFilter)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: CustomScrollView(
                        controller: customerProvider.scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  CustomText(
                                    'Total Customers: ${customerProvider.totalCount}',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textGrey3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index ==
                                    customerProvider.customerData.length) {
                                  return customerProvider.isLoadingMore
                                      ? const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                }
                                var customer =
                                    customerProvider.customerData[index];
                                return Column(
                                  key: ValueKey(customer.customerId),
                                  children: [
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: AppColors.grey,
                                    ),
                                    LeadCard(
                                      isLead: false,
                                      lead: customer,
                                      isExpanded:
                                          customerProvider.expandedIndex ==
                                              index,
                                      onTap: () {
                                        customerProvider.toggleExpansion(index);
                                        if (customerProvider.expandedIndex ==
                                            index) {
                                          Provider.of<LeadCheckInProvider>(
                                                  context,
                                                  listen: false)
                                              .fetchLeadCheckInReports(
                                                  context,
                                                  customer.customerId
                                                      .toString());
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                              childCount:
                                  customerProvider.customerData.length + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<CustomerProvider>(
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
                          // String enquiryFor =
                          //     leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            searchController.text,
                            fromDate,
                            toDate,
                          );
                          leadProvider.getSearchCustomers(context);
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
                          leadProvider.selectDateFilterOption(null);
                          String status =
                              leadProvider.selectedStatus.toString();
                          String fromDate = '';
                          String toDate = '';
                          // String enquiryFor =
                          //     leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            searchController.text,
                            fromDate,
                            toDate,
                          );
                          leadProvider.getSearchCustomers(context);
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
