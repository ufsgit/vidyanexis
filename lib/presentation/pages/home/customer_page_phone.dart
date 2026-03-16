import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/search_lead_status_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/status_dropdown_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/loading_circle.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class CustomerPagePhone extends StatefulWidget {
  const CustomerPagePhone({super.key});

  @override
  State<CustomerPagePhone> createState() => _CustomerPagePhoneState();
}

class _CustomerPagePhoneState extends State<CustomerPagePhone> {
  TextEditingController searchController = TextEditingController();
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
      '',
    );
    await customerProvider.getSearchCustomers(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      searchProvider.stopSearch();
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      customerProvider.setSearchCriteria(
        '',
        '',
        '',
        '',
      );
      customerProvider.resetExpansion();
      customerProvider.getSearchCustomers(context);
      final provider = Provider.of<DropDownProvider>(context, listen: false);
      // Load all statuses by default (no ViewIn_Id) so the dropdown shows everything.
      provider.getFollowUpStatus(context, '');
      provider.getUserDetails(context);
      customerProvider.setFilter(false);

      customerProvider.scrollController.addListener(() {
        customerProvider.scrollListener(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final provider = Provider.of<DropDownProvider>(context);
    final sideprovider = Provider.of<SidebarProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.whiteColor,
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
            '',
          );
          customerProvider.getSearchCustomers(context);
        },
        title: 'Customers',
        showLogo: false,
        showUserName: false,
        showFilterIcon: false,
        onSearch: (String query) {
          customerProvider.setSearchCriteria(
            query,
            customerProvider.fromDateS,
            customerProvider.toDateS,
            customerProvider.status,
          );
          customerProvider.getSearchCustomers(context);
        },
        searchController: searchController,
      ),
      drawer: const SidebarDrawer(),
      body: customerProvider.isLoading
          ? const Center(
              child: LoadingCircle(),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (customerProvider.isFilter)
                    const SizedBox(
                      height: 16,
                    ),
                  if (customerProvider.isFilter)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          StatusDropdownWidget<int>(
                            containerWidth:
                                MediaQuery.sizeOf(context).width / 1.1,
                            statusName: 'Status',
                            items: [0] +
                                provider.followUpData
                                    .map((status) => status.statusId ?? 0)
                                    .toList(),
                            initialValue: customerProvider.selectedStatus,
                            onChanged: (int newValue) {
                              customerProvider.setStatus(newValue);
                              customerProvider.setSearchCriteria(
                                customerProvider.search,
                                customerProvider.formattedFromDate,
                                customerProvider.formattedToDate,
                                customerProvider.selectedStatus.toString(),
                              );
                              customerProvider.getSearchCustomers(context);
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
                            label: 'All',
                          ),
                          const SizedBox(
                            width: 8,
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
                                            const BoxConstraints(maxWidth: 150),
                                        child: CustomText(
                                          'Date',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_up_rounded,
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
                    ),
                  if (customerProvider.isFilter)
                    const SizedBox(
                      height: 16,
                    ),
                  // if (customerProvider.isFilter)
                  //   Container(
                  //     margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                  //                 color: customerProvider.selectedStatus != null &&
                  //                         customerProvider.selectedStatus != 0
                  //                     ? AppColors.primaryBlue
                  //                     : Colors.grey[300]!),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Text('Status: '),
                  //               DropdownButton<int>(
                  //                 value: customerProvider.selectedStatus,
                  //                 hint: const Text('All'),
                  //                 items: [
                  //                       const DropdownMenuItem<int>(
                  //                         value: 0,
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
                  //                     customerProvider.setStatus(newValue);
                  //                   }
                  //                   customerProvider.setSearchCriteria(
                  //                     customerProvider.search,
                  //                     customerProvider.formattedFromDate,
                  //                     customerProvider.formattedToDate,
                  //                     customerProvider.selectedStatus.toString(),
                  //                   );
                  //                   customerProvider.getSearchCustomers(context);
                  //                 },
                  //                 underline: Container(),
                  //                 isDense: true,
                  //                 iconSize: 18,
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //         const SizedBox(width: 10),
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
                  //                   color: customerProvider.fromDate != null ||
                  //                           customerProvider.toDate != null
                  //                       ? AppColors.primaryBlue
                  //                       : Colors.grey[300]!),
                  //             ),
                  //             child: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: [
                  //                 if (customerProvider.fromDate == null &&
                  //                     customerProvider.toDate == null)
                  //                   const Text('Follow Up Date: All'),
                  //                 if (customerProvider.fromDate != null &&
                  //                     customerProvider.toDate != null)
                  //                   Text(
                  //                       'Date : ${customerProvider.formattedFromDate} - ${customerProvider.formattedToDate}'),
                  //                 const SizedBox(width: 10),
                  //                 const Icon(
                  //                   Icons.arrow_drop_down_outlined,
                  //                   color: Colors.black45,
                  //                   size: 20,
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //         if (customerProvider.fromDate != null ||
                  //             customerProvider.toDate != null ||
                  //             (customerProvider.selectedStatus != null &&
                  //                 customerProvider.selectedStatus != 0) ||
                  //             customerProvider.search.isNotEmpty)
                  //           ElevatedButton(
                  //             onPressed: () {
                  //               customerProvider.selectDateFilterOption(null);
                  //               customerProvider.removeStatus();
                  //               searchController.clear();
                  //               customerProvider.setSearchCriteria('', '', '', '');
                  //               customerProvider.getSearchCustomers(context);
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
                      controller: customerProvider.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: customerProvider.customerData.length,
                      itemBuilder: (context, index) {
                        var customerData = customerProvider.customerData[index];
                        return Column(
                          children: [
                            Divider(
                              height: 2,
                              color: AppColors.grey,
                            ),
                            LeadCard(
                              isLead: false,
                              lead: customerData,
                              isExpanded:
                                  customerProvider.expandedIndex == index,
                              onTap: () {
                                customerProvider.toggleExpansion(index);
                                if (customerProvider.expandedIndex == index) {
                                  // Fetch check-in history when expanding to show correct status
                                  Provider.of<LeadCheckInProvider>(context,
                                          listen: false)
                                      .fetchLeadCheckInReports(context,
                                          customerData.customerId.toString());
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
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
                          // String enquiryFor =
                          //     leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            // enquiryFor,
                          );
                          leadProvider.getSearchCustomers(context);
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
                          // String enquiryFor =
                          //     leadProvider.selectedEnquiryFor.toString();
                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            // enquiryFor,
                          );
                          leadProvider.getSearchCustomers(context);
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
