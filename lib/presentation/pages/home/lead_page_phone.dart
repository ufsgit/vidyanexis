import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/drop_down_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/models/enquiry_for_model.dart';
import 'package:techtify/controller/models/follow_up_model.dart';
import 'package:techtify/controller/models/search_lead_status_model.dart';
import 'package:techtify/controller/models/search_user_details_model.dart';
import 'package:techtify/controller/settings_provider.dart';
import 'package:techtify/controller/side_bar_provider.dart';
import 'package:techtify/presentation/pages/home/quotation_mobile_view.dart';
import 'package:techtify/presentation/widgets/custom_calender_widget.dart';
import 'package:techtify/presentation/widgets/customer/status_dropdown_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';
import 'package:techtify/presentation/widgets/home/lead_widget.dart';
import 'package:techtify/presentation/widgets/home/loading_circle.dart';
import 'package:techtify/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:techtify/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:techtify/utils/extensions.dart';

class LeadPagePhone extends StatefulWidget {
  final bool fromDashBoard;

  const LeadPagePhone({super.key, this.fromDashBoard = false});

  @override
  State<LeadPagePhone> createState() => _LeadPagePhoneState();
}

class _LeadPagePhoneState extends State<LeadPagePhone> {
  TextEditingController searchController = TextEditingController();
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
    leadProvider.setSearchCriteria(
      '',
      '',
      '',
      '',
      '',
    );
    await leadProvider.getSearchLeads(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      final leadProvider = Provider.of<LeadsProvider>(context, listen: false);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
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
      leadProvider.setSearchCriteria(
        '',
        '',
        '',
        '',
        '',
      );
      leadProvider.getSearchLeads(context);
      leadProvider.scrollController.addListener(() {
        leadProvider.scrollListener(context);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final searchProvider =
            Provider.of<SidebarProvider>(context, listen: false);
        final leadProvider = Provider.of<LeadsProvider>(context, listen: false);

        searchProvider.stopSearch();
      } catch (e) {
        print('Error resetting search state: $e');
      }
    });

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
                searchProvider.stopSearch();
                leadProvider.toggleFilter();

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
              title: "Leads",
              onSearch: (String query) {
                if (leadProvider.search.isNotEmpty) {
                  leadProvider.setSearchCriteria(
                    '',
                    leadProvider.fromDateS,
                    leadProvider.toDateS,
                    leadProvider.status,
                    leadProvider.enquiryForS,
                  );
                } else {
                  leadProvider.setSearchCriteria(
                    query,
                    leadProvider.fromDateS,
                    leadProvider.toDateS,
                    leadProvider.status,
                    leadProvider.enquiryForS,
                  );
                }
                leadProvider.getSearchLeads(context);
              },
              searchController: searchController,
            )
          : CustomAppBar(
              onSearchTap: () {
                searchProvider.startSearch();
                leadProvider.toggleFilter();
              },
              onFilterTap: () {
                log('sdf');
                leadProvider.toggleFilter();
              },
              onClearTap: () {
                searchProvider.stopSearch();
                leadProvider.toggleFilter();

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
              title: "Leads",
              onSearch: (String query) {
                if (leadProvider.search.isNotEmpty) {
                  leadProvider.setSearchCriteria(
                    '',
                    leadProvider.fromDateS,
                    leadProvider.toDateS,
                    leadProvider.status,
                    leadProvider.enquiryForS,
                  );
                } else {
                  leadProvider.setSearchCriteria(
                    query,
                    leadProvider.fromDateS,
                    leadProvider.toDateS,
                    leadProvider.status,
                    leadProvider.enquiryForS,
                  );
                }
                leadProvider.getSearchLeads(context);
              },
              searchController: searchController,
            ),
      drawer: const SidebarDrawer(),
      body: leadProvider.isLoading
          ? const Center(
              child: LoadingCircle(),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (leadProvider.isFilter)
                    const SizedBox(
                      height: 16,
                    ),
                  if (leadProvider.isFilter)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 8.0, // horizontal spacing between items
                        runSpacing: 8.0, // vertical spacing between lines
                        alignment: WrapAlignment.start,
                        children: [
                          StatusDropdownWidget<int>(
                            containerWidth:
                                MediaQuery.sizeOf(context).width / 1.1,
                            statusName: 'Status',
                            items: [0] +
                                provider.followUpData
                                    .map((status) => status.statusId ?? 0)
                                    .toList(),
                            initialValue: leadProvider.selectedStatus,
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

                              leadProvider.setSearchCriteria(
                                leadProvider.search,
                                fromDate,
                                toDate,
                                status,
                                enquiryFor,
                              );
                              leadProvider.getSearchLeads(context);
                            },
                            displayStringFor: (int statusId) {
                              if (statusId == 0) return 'All';

                              final status = provider.followUpData.firstWhere(
                                  (status) => status.statusId == statusId,
                                  orElse: () => SearchLeadStatusModel(
                                      statusId: statusId,
                                      statusName: "Unknown"));

                              return status.statusName ?? 'Unknown';
                            },
                            areItemsEqual: (a, b) => a == b,
                            label: 'Status',
                          ),
                          GestureDetector(
                            onTap: () {
                              onClickTopButton(context);
                            },
                            child: Container(
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.scaffoldColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ConstrainedBox(
                                        constraints:
                                            const BoxConstraints(maxWidth: 230),
                                        child: CustomText(
                                          leadProvider.fromDate == null &&
                                                  leadProvider.toDate == null
                                              ? 'Date'
                                              : leadProvider.fromDate != null &&
                                                      leadProvider.toDate !=
                                                          null
                                                  ? 'Date : ${leadProvider.formattedFromDate.toString().toDayMonthYearFormat()} - ${leadProvider.formattedToDate.toString().toDayMonthYearFormat()}'
                                                  : "Date",
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
                          StatusDropdownWidget<int>(
                            containerWidth:
                                MediaQuery.sizeOf(context).width / 2.5,
                            statusName: 'Assigned staff',
                            items: [0] +
                                provider.searchUserDetails
                                    .map((status) => status.userDetailsId ?? 0)
                                    .toList(),
                            initialValue: leadProvider.selectedUser,
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
                            displayStringFor: (int statusId) {
                              if (statusId == 0) return 'All';

                              final status = provider.searchUserDetails
                                  .firstWhere(
                                      (status) =>
                                          status.userDetailsId == statusId,
                                      orElse: () => SearchUserDetails(
                                          userDetailsId: 0,
                                          userDetailsName: ''));

                              return status.userDetailsName ?? 'Unknown';
                            },
                            areItemsEqual: (a, b) => a == b,
                            label: 'All Staff',
                          ),
                          StatusDropdownWidget<int>(
                            containerWidth:
                                MediaQuery.sizeOf(context).width / 2.5,
                            statusName: 'Enquiry for',
                            items: [0] +
                                provider.enquiryForList
                                    .map((status) => status.enquiryForId ?? 0)
                                    .toList(),
                            initialValue: leadProvider.selectedEnquiryFor,
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

                              leadProvider.setSearchCriteria(
                                leadProvider.search,
                                fromDate,
                                toDate,
                                status,
                                enquiryFor,
                              );
                              leadProvider.getSearchLeads(context);
                            },
                            displayStringFor: (int statusId) {
                              if (statusId == 0) return 'All';

                              final status = provider.enquiryForList.firstWhere(
                                  (status) => status.enquiryForId == statusId,
                                  orElse: () => EnquiryForModel(
                                      enquiryForId: 0,
                                      enquiryForName: '',
                                      sourceCategoryId: 0,
                                      sourceCategoryName: '',
                                      deleteStatus: 0));

                              return status.enquiryForName ?? '';
                            },
                            areItemsEqual: (a, b) => a == b,
                            label: 'Enquiry for',
                          ),
                        ],
                      ),
                    ),
                  if (leadProvider.isFilter)
                    const SizedBox(
                      height: 16,
                    ),
                  // if (leadProvider.isFilter)
                  //   Container(
                  //     // margin: const EdgeInsets.only(top: 10),
                  //     padding: const EdgeInsets.all(10.0),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       borderRadius: BorderRadius.circular(20),
                  //     ),
                  //     child: Wrap(
                  //       runSpacing: 10,
                  //       crossAxisAlignment: WrapCrossAlignment.center,
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(horizontal: 20),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(20),
                  //             border: Border.all(
                  //                 color: leadProvider.selectedStatus != null &&
                  //                         leadProvider.selectedStatus != 0
                  //                     ? AppColors.primaryBlue
                  //                     : Colors.grey[300]!),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Text('Status: '),
                  //               DropdownButton<int>(
                  //                 value: leadProvider.selectedStatus,
                  //                 hint: const Text('All'),
                  //                 items: [
                  //                       const DropdownMenuItem<int>(
                  //                         value:
                  //                             0, // Use 0 or null to represent "All"
                  //                         child: Text(
                  //                           'All',
                  //                           style: TextStyle(fontSize: 14),
                  //                         ),
                  //                       ),
                  //                     ] +
                  //                     provider.followUpData
                  //                         .map((status) => DropdownMenuItem<int>(
                  //                               value: status.statusId,
                  //                               child: Text(
                  //                                 status.statusName ?? '',
                  //                                 style:
                  //                                     const TextStyle(fontSize: 14),
                  //                               ),
                  //                             ))
                  //                         .toList(),
                  //                 onChanged: (int? newValue) {
                  //                   if (newValue != null) {
                  //                     leadProvider.setStatus(
                  //                         newValue); // Update the status in the provider
                  //                   }
                  //                   String status =
                  //                       leadProvider.selectedStatus.toString();
                  //                   String fromDate = leadProvider.formattedFromDate;
                  //                   String toDate = leadProvider.formattedToDate;
                  //                   String enquiryFor =
                  //                       leadProvider.selectedEnquiryFor.toString();
                  //                   print(
                  //                       'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                  //                   leadProvider.setSearchCriteria(
                  //                     leadProvider.search,
                  //                     fromDate,
                  //                     toDate,
                  //                     status,
                  //                     enquiryFor,
                  //                   );
                  //                   leadProvider.getSearchLeads(context);
                  //                 },
                  //                 underline: Container(),
                  //                 isDense: true,
                  //                 iconSize: 18,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           width: 10,
                  //         ),
                  //         GestureDetector(
                  //           onTap: () {
                  //             onClickTopButton(context);
                  //           },
                  //           child: Container(
                  //             padding: const EdgeInsets.symmetric(
                  //                 horizontal: 20, vertical: 1.5),
                  //             decoration: BoxDecoration(
                  //               color: Colors.white,
                  //               borderRadius: BorderRadius.circular(20),
                  //               border: Border.all(
                  //                   color: leadProvider.fromDate != null ||
                  //                           leadProvider.toDate != null
                  //                       ? AppColors.primaryBlue
                  //                       : Colors.grey[300]!),
                  //             ),
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 if (leadProvider.fromDate == null &&
                  //                     leadProvider.toDate == null)
                  //                   const Text('Follow-Up Date: All'),
                  //                 if (leadProvider.fromDate != null &&
                  //                     leadProvider.toDate != null)
                  //                   CustomText(
                  //                     'Date : ${leadProvider.formattedFromDate} - ${leadProvider.formattedToDate}',
                  //                     fontSize: 14,
                  //                     fontWeight: FontWeight.w400,
                  //                     color: AppColors.textBlack,
                  //                     overflow: TextOverflow.ellipsis,
                  //                   ),
                  //                 const SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 const Icon(
                  //                   Icons.arrow_drop_down_outlined,
                  //                   color: Colors.black45,
                  //                   size: 20,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           width: 10,
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(horizontal: 20),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(20),
                  //             border: Border.all(
                  //                 color: leadProvider.selectedUser != null &&
                  //                         leadProvider.selectedUser != 0
                  //                     ? AppColors.primaryBlue
                  //                     : Colors.grey[300]!),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Text('Assigned Staff: '),
                  //               DropdownButton<int>(
                  //                 value: leadProvider.selectedUser,
                  //                 hint: const Text('All'),
                  //                 items: [
                  //                       const DropdownMenuItem<int>(
                  //                         value:
                  //                             0, // Use 0 or null to represent "All"
                  //                         child: Text(
                  //                           'All',
                  //                           style: TextStyle(fontSize: 14),
                  //                         ),
                  //                       ),
                  //                     ] +
                  //                     provider.searchUserDetails
                  //                         .map((user) => DropdownMenuItem<int>(
                  //                               value: user.userDetailsId!,
                  //                               child: ConstrainedBox(
                  //                                 constraints: const BoxConstraints(
                  //                                     maxWidth: 150),
                  //                                 child: Text(
                  //                                   user.userDetailsName ?? '',
                  //                                   overflow: TextOverflow
                  //                                       .ellipsis, // Adds ellipsis when the text is too long
                  //                                   style:
                  //                                       const TextStyle(fontSize: 14),
                  //                                 ),
                  //                               ),
                  //                             ))
                  //                         .toList(),
                  //                 onChanged: (int? newValue) {
                  //                   if (newValue != null) {
                  //                     leadProvider.setUserFilterStatus(
                  //                         newValue); // Update the status in the provider
                  //                   }
                  //                   String status =
                  //                       leadProvider.selectedStatus.toString();
                  //                   String fromDate = leadProvider.formattedFromDate;
                  //                   String toDate = leadProvider.formattedToDate;
                  //                   String enquiryFor =
                  //                       leadProvider.selectedEnquiryFor.toString();
                  //                   print(
                  //                       'Selected Status: $status, Selected From Date: $fromDate, Selected To Date: $toDate, Selected Enquiry For: $enquiryFor');
                  //                   leadProvider.setSearchCriteria(
                  //                     leadProvider.search,
                  //                     fromDate,
                  //                     toDate,
                  //                     status,
                  //                     enquiryFor,
                  //                   );
                  //                   leadProvider.getSearchLeads(context);
                  //                 },
                  //                 underline: Container(),
                  //                 isDense: true,
                  //                 iconSize: 18,
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           width: 10,
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.symmetric(horizontal: 20),
                  //           decoration: BoxDecoration(
                  //             color: Colors.white,
                  //             borderRadius: BorderRadius.circular(20),
                  //             border: Border.all(
                  //                 color: leadProvider.selectedEnquiryFor != null &&
                  //                         leadProvider.selectedEnquiryFor != 0
                  //                     ? AppColors.primaryBlue
                  //                     : Colors.grey[300]!),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Text('Enquiry For: '),
                  //               DropdownButton<int>(
                  //                 value: leadProvider.selectedEnquiryFor,
                  //                 hint: const Text('All'),
                  //                 items: [
                  //                       const DropdownMenuItem<int>(
                  //                         value:
                  //                             0, // Use 0 or null to represent "All"
                  //                         child: Text(
                  //                           'All',
                  //                           style: TextStyle(fontSize: 14),
                  //                         ),
                  //                       ),
                  //                     ] +
                  //                     provider.enquiryForList
                  //                         .map((user) => DropdownMenuItem<int>(
                  //                               value: user.enquiryForId,
                  //                               child: Text(
                  //                                 user.enquiryForName,
                  //                                 style:
                  //                                     const TextStyle(fontSize: 14),
                  //                               ),
                  //                             ))
                  //                         .toList(),
                  //                 onChanged: (int? newValue) {
                  //                   if (newValue != null) {
                  //                     leadProvider.setEnquiryForFilter(
                  //                         newValue); // Update the status in the provider
                  //                   }
                  //                   String status =
                  //                       leadProvider.selectedStatus.toString();
                  //                   String fromDate = leadProvider.formattedFromDate;
                  //                   String toDate = leadProvider.formattedToDate;
                  //                   String enquiryFor =
                  //                       leadProvider.selectedEnquiryFor.toString();
                  //                   print(
                  //                       'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate,Selected Enquiry For : $enquiryFor');
                  //                   leadProvider.setSearchCriteria(
                  //                     leadProvider.search,
                  //                     fromDate,
                  //                     toDate,
                  //                     status,
                  //                     enquiryFor,
                  //                   );
                  //                   leadProvider.getSearchLeads(context);
                  //                 },
                  //                 underline: Container(),
                  //                 isDense: true,
                  //                 iconSize: 18,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(
                  //           width: 10,
                  //         ),
                  //         if (leadProvider.fromDate != null ||
                  //             leadProvider.toDate != null ||
                  //             (leadProvider.selectedStatus != null &&
                  //                 leadProvider.selectedStatus != 0) ||
                  //             (leadProvider.selectedUser != null &&
                  //                 leadProvider.selectedUser != 0) ||
                  //             (leadProvider.selectedEnquiryFor != null &&
                  //                 leadProvider.selectedEnquiryFor != 0) ||
                  //             leadProvider.search.isNotEmpty)
                  //           ElevatedButton(
                  //             onPressed: () {
                  //               leadProvider.selectDateFilterOption(null);
                  //               leadProvider.removeStatus();
                  //               searchController.clear();
                  //               leadProvider.setSearchCriteria(
                  //                 '',
                  //                 '',
                  //                 '',
                  //                 '',
                  //                 '',
                  //               );
                  //               leadProvider.getSearchLeads(context);
                  //             },
                  //             style: ElevatedButton.styleFrom(
                  //               backgroundColor: Colors.white,
                  //               foregroundColor: AppColors.textRed,
                  //               side: BorderSide(color: AppColors.textRed),
                  //               padding: const EdgeInsets.symmetric(
                  //                 horizontal: 16,
                  //                 vertical: 0,
                  //               ),
                  //             ),
                  //             child: const Text('Reset'),
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  Expanded(
                    child: ListView.builder(
                      controller: leadProvider
                          .scrollController, // Keep the original controller for pagination
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Enable pull to refresh
                      itemCount: leadProvider.leadData.length,
                      itemBuilder: (context, index) {
                        var lead = leadProvider.leadData[index];
                        return Column(
                          children: [
                            Divider(
                              height: 2,
                              color: AppColors.grey,
                            ),
                            LeadCard(
                              isLead: true,
                              lead: lead,
                              isExpanded: leadProvider.expandedIndex == index,
                              onTap: () => leadProvider.toggleExpansion(index),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: FloatingActionButton(
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

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];
}
