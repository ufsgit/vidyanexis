import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';

import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/loading_circle.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/filter_chip_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class LeadPagePhone extends StatefulWidget {
  final bool fromDashBoard;

  const LeadPagePhone({super.key, this.fromDashBoard = false});

  @override
  State<LeadPagePhone> createState() => _LeadPagePhoneState();
}

class _LeadPagePhoneState extends State<LeadPagePhone> {
  TextEditingController searchController = TextEditingController();
  TextEditingController leadIdController = TextEditingController();
  Timer? _debounce;

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadProvider.setSearchCriteria(
        query,
        leadProvider.fromDateS,
        leadProvider.toDateS,
        leadId: leadIdController.text,
      );
      leadProvider.getSearchLeads(context, isSilent: true);
    });
  }

  Future<void> _refreshData() async {
    final searchProvider = Provider.of<SidebarProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
    final provider = Provider.of<DropDownProvider>(context, listen: false);
    // await leadProvider.toggleFilter();
    leadProvider.setFilter(false);

    searchProvider.stopSearch();
    provider.getEnquirySource(context);
    provider.getEnquiryFor(context);
    provider.getUserDetails(context);
    provider.getFollowUpStatus(context, '1');
    settingsProvider.searchsourceCategoryData('', context);
    provider.getDistricts(context);
    settingsProvider.searchBranch(context);
    settingsProvider.searchDepartment('', context);
    leadProvider.selectedStatusIds.clear();
    leadProvider.selectedStatusIds.add(0);
    leadProvider.selectedUserIds.clear();
    leadProvider.selectedUserIds.add(0);
    leadProvider.selectedEnquiryForIds.clear();
    leadProvider.selectedEnquiryForIds.add(0);
    leadProvider.selectedEnquirySourceIds.clear();
    leadProvider.selectedEnquirySourceIds.add(0);

    leadProvider.setSearchCriteria(
      '',
      '',
      '',
      leadId: leadIdController.text,
    );
    await leadProvider.getSearchLeads(context);
  }

  int userId = 0;
  String userName = '';
  String userType = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";
      //not admin type assign user filter
      if (userType != "1") {
        leadProvider.setUserFilterStatus(userId);
      }
      // leadProvider.leadData.clear();
      leadProvider.setFilter(false);
      settingsProvider.searchBranch(context);
      settingsProvider.searchDepartment('', context);
      leadProvider.resetExpansion();
      provider.getEnquirySource(context);
      provider.getEnquiryFor(context);
      provider.getUserDetails(context);
      provider.getFollowUpStatus(context, '1');
      settingsProvider.searchsourceCategoryData('', context);
      provider.getDistricts(context);
      leadProvider.totalCount;

      leadProvider.selectedStatusIds.clear();
      leadProvider.selectedStatusIds.add(0);
      leadProvider.selectedUserIds.clear();
      leadProvider.selectedUserIds.add(0);
      leadProvider.selectedEnquiryForIds.clear();
      leadProvider.selectedEnquiryForIds.add(0);
      leadProvider.selectedEnquirySourceIds.clear();
      leadProvider.selectedEnquirySourceIds.add(0);

      leadProvider.setSearchCriteria(
        '',
        '',
        '',
        leadId: '0',
      );
      leadProvider.getSearchLeads(context);
    });
    Provider.of<LeadsProvider>(context, listen: false)
        .scrollController
        .addListener(_scrollListener);
  }

  void _scrollListener() {
    if (mounted) {
      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      leadProvider.scrollListener(context);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    Provider.of<LeadsProvider>(context, listen: false)
        .scrollController
        .removeListener(_scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sideProvider = Provider.of<SidebarProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: widget.fromDashBoard
          ? CustomAppBar(
              leadingWidget: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back)),
              onSearchTap: () {
                searchProvider.startSearch();
                leadProvider.toggleFilter();
              },
              onFilterTap: () {
                log('sdf');
                leadProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                searchProvider.stopSearch();
                leadProvider.toggleFilter();

                leadProvider.selectDateFilterOption(null);
                leadProvider.removeStatus();
                leadProvider.setSearchCriteria('', '', '');
                leadProvider.getSearchLeads(context);
              },
              title: "Leads",
              showLogo: false,
              showUserName: false,
              showFilterIcon: false,
              showSort: true,
              showOrder: true,
              sortOrder: leadProvider.sortOrder,
              onOrderTap: () => leadProvider.toggleSortOrder(context),
              onSortTap: (value) {
                leadProvider.setSortOption(value, context);
              },
              onSearch: (String query) {
                leadProvider.setSearchCriteria(
                  query,
                  leadProvider.fromDateS,
                  leadProvider.toDateS,
                  leadId: leadIdController.text,
                );
                leadProvider.getSearchLeads(context);
              },
              // onChanged: _onSearchChanged,
              searchController: searchController,
            )
          : CustomAppBar(
              onSearchTap: () {
                searchProvider.startSearch();
                leadProvider.toggleFilter();
              },
              onFilterTap: () {
                leadProvider.toggleFilter();
              },
              onClearTap: () {
                searchController.clear();
                searchProvider.stopSearch();
                leadProvider.clearAllFilters();
                leadProvider.getSearchLeads(context);
              },
              title: "Leads",
              showLogo: false,
              showUserName: false,
              showFilterIcon: false,
              showSort: true,
              onSortTap: (value) {
                leadProvider.setSortOption(value, context);
              },
              onSearch: (String query) {
                leadProvider.setSearchCriteria(
                  query,
                  leadProvider.fromDateS,
                  leadProvider.toDateS,
                  leadId: leadIdController.text,
                );
                leadProvider.getSearchLeads(context);
              },
              // onChanged: _onSearchChanged,
              searchController: searchController,
            ),
      drawer: const SidebarDrawer(),
      body: leadProvider.isLoading
          ? const Center(
              child: LoadingCircle(),
            )
          : Column(
              children: [
                if (leadProvider.isFilter)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          CustomText(
                            'Lead ID',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textBlack,
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: leadIdController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: 'Enter Lead ID',
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (v) => leadProvider.setLeadId(v),
                          ),
                          const SizedBox(height: 16),
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
                                isSelected:
                                    leadProvider.selectedStatusIds.contains(0),
                                onTap: () {
                                  leadProvider.toggleStatus(0);
                                },
                              ),
                              ...provider.followUpData.map((status) {
                                return FilterChipWidget(
                                  label: status.statusName ?? 'Unknown',
                                  isSelected: leadProvider.selectedStatusIds
                                      .contains(status.statusId),
                                  onTap: () {
                                    leadProvider
                                        .toggleStatus(status.statusId ?? 0);
                                  },
                                );
                              }).toList(),
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
                                    borderRadius: BorderRadius.circular(10),
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
                                              leadProvider.fromDate == null &&
                                                      leadProvider.toDate ==
                                                          null
                                                  ? 'Date'
                                                  : 'Date : ${leadProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${leadProvider.formattedToDate.toString().toDayMonthYearFormat()}',
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
                          if (userId == 1) ...[
                            const SizedBox(height: 16),
                            CustomText(
                              'Assigned Staff',
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
                                  isSelected:
                                      leadProvider.selectedUserIds.contains(0),
                                  onTap: () {
                                    leadProvider.toggleUserFilter(0);
                                  },
                                ),
                                ...provider.searchUserDetails.map((staff) {
                                  return FilterChipWidget(
                                    label: staff.userDetailsName,
                                    isSelected: leadProvider.selectedUserIds
                                        .contains(staff.userDetailsId),
                                    onTap: () {
                                      leadProvider.toggleUserFilter(
                                          staff.userDetailsId ?? 0);
                                    },
                                  );
                                }).toList(),
                              ],
                            ),
                          ],
                          const SizedBox(height: 16),
                          CustomText(
                            'Enquiry For',
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
                                isSelected: leadProvider.selectedEnquiryForIds
                                    .contains(0),
                                onTap: () {
                                  leadProvider.toggleEnquiryForFilter(0);
                                },
                              ),
                              ...provider.enquiryForList.map((enquiry) {
                                return FilterChipWidget(
                                  label: enquiry.enquiryForName,
                                  isSelected: leadProvider.selectedEnquiryForIds
                                      .contains(enquiry.enquiryForId),
                                  onTap: () {
                                    leadProvider.toggleEnquiryForFilter(
                                        enquiry.enquiryForId ?? 0);
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomText(
                            'Enquiry Source',
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
                                isSelected: leadProvider
                                    .selectedEnquirySourceIds
                                    .contains(0),
                                onTap: () {
                                  leadProvider.toggleEnquirySourceFilter(0);
                                },
                              ),
                              ...provider.enquiryData.map((source) {
                                return FilterChipWidget(
                                  label: source.enquirySourceName,
                                  isSelected: leadProvider
                                      .selectedEnquirySourceIds
                                      .contains(source.enquirySourceId),
                                  onTap: () {
                                    leadProvider.toggleEnquirySourceFilter(
                                        source.enquirySourceId ?? 0);
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (leadProvider.fromDate != null ||
                              leadProvider.toDate != null ||
                              !leadProvider.selectedStatusIds
                                  .every((id) => id == 0) ||
                              !leadProvider.selectedUserIds
                                  .every((id) => id == 0) ||
                              !leadProvider.selectedEnquiryForIds
                                  .every((id) => id == 0) ||
                              !leadProvider.selectedEnquirySourceIds
                                  .every((id) => id == 0) ||
                              leadProvider.search.isNotEmpty)
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  leadProvider.clearAllFilters();
                                  searchController.clear();
                                  leadIdController.clear();
                                  leadProvider.getSearchLeads(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textRed,
                                  side: BorderSide(color: AppColors.textRed),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                if (!leadProvider.isFilter)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refreshData,
                      child: CustomScrollView(
                        controller: leadProvider.scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    'Total Leads: ${leadProvider.totalCount}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textBlack,
                                  ),
                                  CustomText(
                                    'Showing: ${leadProvider.leadData.length}',
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
                                if (index == leadProvider.leadData.length) {
                                  return leadProvider.isLoadingMore
                                      ? const Padding(
                                          padding: EdgeInsets.all(16),
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : const SizedBox.shrink();
                                }
                                var lead = leadProvider.leadData[index];
                                return Column(
                                  key: ValueKey(lead.customerId),
                                  children: [
                                    Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: const Color(0xFFCDD2D6),
                                    ),
                                    LeadCard(
                                      isLead: true,
                                      lead: lead,
                                      isExpanded:
                                          leadProvider.expandedIndex == index,
                                      onTap: () {
                                        leadProvider.toggleExpansion(index);
                                        if (leadProvider.expandedIndex ==
                                            index) {
                                          Provider.of<LeadCheckInProvider>(
                                                  context,
                                                  listen: false)
                                              .fetchLeadCheckInReports(context,
                                                  lead.customerId.toString());
                                        }
                                      },
                                    ),
                                  ],
                                );
                              },
                              childCount: leadProvider.leadData.length + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: leadProvider.isFilter
            ? SizedBox(
                height: 40,
                child: FloatingActionButton.extended(
                  heroTag: 'apply_filter_fab',
                  onPressed: () {
                    leadProvider.setSearchCriteria(
                      searchController.text,
                      leadProvider.fromDateS,
                      leadProvider.toDateS,
                      leadId: leadIdController.text,
                    );
                    leadProvider.getSearchLeads(context);
                    searchProvider.stopSearch();
                    leadProvider.setFilter(false);
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
            : leadProvider.expandedIndex != null
                ? null
                : FloatingActionButton(
                    heroTag: 'add_lead_fab',
                    shape: const CircleBorder(),
                    elevation: 0,
                    backgroundColor: AppColors.bluebutton,
                    onPressed: () async {
                      final dropDownProvider =
                          Provider.of<DropDownProvider>(context, listen: false);
                      dropDownProvider.updateEnquiryForName(null, '');
                      dropDownProvider.updateDistrict(null, '');

                      await leadProvider.getLeadDropdowns(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewLeadDrawerMobileWidget(
                            isEdit: false,
                            customerId: '0',
                          ),
                        ),
                      );
                    },
                    child: Icon(
                      Icons.add,
                      color: AppColors.whiteColor,
                    ),
                  ),
      ),
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<LeadsProvider>(
        builder: (contextx, leadProvider, child) {
          // return CustomCalendarWidget(
          //   decoration: CustomCalenderDecoration(
          //       selectedDateColor: AppColors.primaryBlue,
          //       trackColor: AppColors.lightBlueColor2),
          //   onApplyDateTapped: (date) {
          //     print(date);
          //   },
          //   startYear: 2000,
          //   endYear: 2050,
          // );
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
                            searchController.text,
                            fromDate,
                            toDate,
                            leadId: leadIdController.text,
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
                            searchController.text,
                            fromDate,
                            toDate,
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
