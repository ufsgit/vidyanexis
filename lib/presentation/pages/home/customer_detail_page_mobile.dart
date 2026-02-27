import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/home/checklist_management_page.dart';
import 'package:vidyanexis/presentation/pages/home/inovice_tab.dart';
import 'package:vidyanexis/presentation/pages/home/reciept_phone.dart';
import 'package:vidyanexis/presentation/pages/home/reciept_screen.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_schedule_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_document_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_tab_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/expense_tab_widget.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/home/quotation_mobile_view.dart';
import 'package:vidyanexis/presentation/widgets/customer/activity_tab_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/complaints_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/details_tab_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/documents_list_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/periodic_services_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/pop_menu_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/reciept_list_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_list_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';

class CustomerDetailPageMobile extends StatefulWidget {
  static const String route = '/customer-detail-mobile/';
  final SearchLeadModel? lead;

  final bool fromLead;
  final int customerId;

  const CustomerDetailPageMobile(
      {super.key, this.lead, required this.fromLead, required this.customerId});

  @override
  State<CustomerDetailPageMobile> createState() =>
      _CustomerDetailPageMobileState();
}

class _CustomerDetailPageMobileState extends State<CustomerDetailPageMobile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Tab> tabs = [];

  @override
  void initState() {
    super.initState();

    final settingsprovider =
        Provider.of<SettingsProvider>(context, listen: false);
    tabs = [
      const Tab(text: "Details"),
      if (settingsprovider.menuIsViewMap[13] == 1) const Tab(text: "Tasks"),
      if (settingsprovider.menuIsViewMap[16] == 1)
        const Tab(text: "Quotations"),
      if (settingsprovider.menuIsViewMap[73] == 1) const Tab(text: "Activity"),
      if (!widget.fromLead && settingsprovider.menuIsViewMap[14] == 1)
        const Tab(text: "Complaints"),
      if (!widget.fromLead && settingsprovider.menuIsViewMap[15] == 1)
        const Tab(text: "Periodic Services"),
      if (settingsprovider.menuIsViewMap[19] == 1) const Tab(text: "Documents"),
      if (!widget.fromLead && settingsprovider.menuIsViewMap[18] == 1)
        const Tab(text: "Receipt"),
      if (!widget.fromLead && settingsprovider.menuIsViewMap[18] == 1)
        const Tab(text: "Expense"),
      if (settingsprovider.menuIsViewMap[70] == 1)
        const Tab(text: "Payment Schedule"),
      if (settingsprovider.menuIsViewMap[81] == 1) const Tab(text: "Payment"),
      // const Tab(text: "Task Documents"),
      if (!widget.fromLead && settingsprovider.menuIsViewMap[37] == 1)
        const Tab(text: "CheckList Management"),
      if (settingsprovider.menuIsViewMap[21] == 1) const Tab(text: "Invoice"),
    ];
    int tabCount = tabs.length;
    _tabController = TabController(length: tabCount, vsync: this);

    _tabController.addListener(_handleTabSelection);
    _tabController.animation?.addListener(_handleTabAnimation);

    // int tabCount = 4 +
    //     (settingsprovider.menuIsViewMap[13] == 1 ? 1 : 0) +
    //     (!widget.fromLead ? 7 : 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);

      leadDetailsProvider.fetchLeadDetails(
          widget.customerId.toString(), context);
      dropDownProvider.getTaskType(context);
      dropDownProvider.getAMCStatus(context);
    });
  }

  void _handleTabSelection() {
    setState(() {});
  }

  void _handleTabAnimation() {
    if (_tabController.indexIsChanging == false &&
        _tabController.animation!.value == _tabController.index) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.animation?.removeListener(_handleTabAnimation);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsprovider = Provider.of<SettingsProvider>(context);
    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);

    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    Color getAvatarColor(String name) {
      final colors = [
        Colors.blue.withOpacity(.75),
        Colors.purple.withOpacity(.75),
        Colors.orange.withOpacity(.75),
        Colors.teal.withOpacity(.75),
        Colors.pink.withOpacity(.75),
        Colors.indigo.withOpacity(.75),
        Colors.green.withOpacity(.75),
        Colors.deepOrange.withOpacity(.75),
        Colors.cyan.withOpacity(.75),
        Colors.brown.withOpacity(.75),
      ];
      final nameHash = name.hashCode.abs();
      return colors[nameHash % colors.length];
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: !leadDetailsProvider.isFetchLoading
            ? Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: getAvatarColor(widget.lead?.customerName ?? ''),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        (leadDetailsProvider.isFetchLoading ||
                                leadDetailsProvider.leadDetails == null ||
                                leadDetailsProvider.leadDetails!.isEmpty ||
                                leadDetailsProvider
                                    .leadDetails![0].customerName.isEmpty)
                            ? ''
                            : leadDetailsProvider.leadDetails![0].customerName
                                .substring(0, 1)
                                .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (leadDetailsProvider.isFetchLoading ||
                            leadDetailsProvider.leadDetails == null ||
                            leadDetailsProvider.leadDetails!.isEmpty)
                        ? ''
                        : leadDetailsProvider.leadDetails![0].customerName,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack),
                  ),
                ],
              )
            : const SizedBox(),
        actions: [
          Builder(
            builder: (context) {
              final currentIndex = _tabController.index;
              return Visibility(
                visible: currentIndex == 0,
                maintainState: true,
                maintainAnimation: true,
                maintainSize: false,
                child: CustomPopMenuButtonWidget(
                  onOptionSelected: (PopupMenuOptions option) async {
                    switch (option) {
                      case PopupMenuOptions.edit:
                        final leadsProvider =
                            Provider.of<LeadsProvider>(context, listen: false);
                        await leadsProvider.getLeadDropdowns(context);

                        final dropDownProvider = Provider.of<DropDownProvider>(
                            context,
                            listen: false);

                        if (leadDetailsProvider.leadDetails != null &&
                            leadDetailsProvider.leadDetails!.isNotEmpty) {
                          leadsProvider.enquirySourceController.text =
                              leadDetailsProvider
                                  .leadDetails![0].enquirySourceName;

                          leadsProvider.enquiryForController.text =
                              leadDetailsProvider
                                  .leadDetails![0].enquiryForName;
                        }
                        // log(leadsProvider.enquiryForController.text);
                        dropDownProvider.selectedEnquirySourceId = int.parse(
                            widget.lead?.enquirySourceId.toString() ?? '0');

                        // log(leadsProvider.enquirySourceController.text);
                        // log(dropDownProvider.selectedEnquirySourceId
                        //     .toString());

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewLeadDrawerMobileWidget(
                              customerId: widget.customerId.toString(),
                              isEdit: true,
                            ),
                          ),
                        );
                        break;

                      case PopupMenuOptions.delete:
                        widget.fromLead
                            ? showConfirmationDialog(
                                context: context,
                                isLoading:
                                    customerDetailsProvider.isDeleteLoading,
                                title: 'Confirm Deletion',
                                content:
                                    'Are you sure you want to delete this Lead?',
                                onCancel: () {
                                  Navigator.of(context).pop();
                                },
                                onConfirm: () async {
                                  final leadsProvider =
                                      Provider.of<LeadsProvider>(context,
                                          listen: false);
                                  final customerId =
                                      widget.customerId.toString();

                                  // Optimistic removal
                                  leadsProvider.removeLeadFromList(customerId);
                                  Provider.of<CustomerProvider>(context,
                                          listen: false)
                                      .removeCustomerFromList(customerId);

                                  Navigator.pop(context); // dialog
                                  Navigator.pop(context); // details page

                                  // Perform actions in background
                                  if (widget.fromLead) {
                                    leadsProvider.deleteLead(
                                        context, customerId);
                                  } else {
                                    Provider.of<CustomerProvider>(context,
                                            listen: false)
                                        .deleteCustomer(context, customerId);
                                  }
                                  Provider.of<CustomerProvider>(context,
                                          listen: false)
                                      .getSearchCustomers(context);
                                },
                                confirmButtonText: 'Delete',
                              )
                            : showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Remove Registration'),
                                    content: const Text(
                                        'Are you sure you want to Remove Registration '),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                      ),
                                      TextButton(
                                        child:
                                            const Text('Remove Registration'),
                                        onPressed: () async {
                                          await customerDetailsProvider
                                              .removeRegister(
                                                  widget.customerId.toString(),
                                                  context);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );

                        break;
                    }
                  },
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                dividerColor: AppColors.grey,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                isScrollable: true,
                dividerHeight: 2,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: AppColors.primaryBlue,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: AppColors.textGrey4,
                // onTap: (index) {
                //   setState(() {});
                // },
                labelStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey4),
                tabs: tabs,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details Tab
          DetailsTabMobile(
            customerId: widget.customerId.toString(),
          ),
          // Tasks Tab
          if (settingsprovider.menuIsViewMap[13] == 1)
            TaskListPageMobile(
              customerId: widget.customerId.toString(),
            ),
          // Quotations Tab
          if (settingsprovider.menuIsViewMap[16] == 1)
            QuotationMobileView(
              customerId: widget.customerId.toString(),
            ),
          if (settingsprovider.menuIsViewMap[73] == 1)
            ActivityTabPage(
              lead: widget.lead,
              customerId: widget.customerId,
            ),

          if (!widget.fromLead && settingsprovider.menuIsViewMap[14] == 1)
            ComplaintsPageMobile(
              customerId: widget.customerId.toString(),
            ),
          if (!widget.fromLead && settingsprovider.menuIsViewMap[15] == 1)
            PeriodicServicesMobile(
              customerId: widget.customerId.toString(),
            ),
          if (settingsprovider.menuIsViewMap[19] == 1)
            DocumentsListPagePhone(
              customerId: widget.customerId.toString(),
            ),
          if (!widget.fromLead && settingsprovider.menuIsViewMap[18] == 1)
            RecieptPhone(widget.customerId.toString()),
          if (!widget.fromLead && settingsprovider.menuIsViewMap[18] == 1)
            ExpenseTabWidget(customerId: widget.customerId.toString()),
          if (settingsprovider.menuIsViewMap[70] == 1)
            PaymentScheduleTabWidget(customerId: widget.customerId.toString()),
          if (settingsprovider.menuIsViewMap[81] == 1)
            PaymentTabWidget(customerId: widget.customerId.toString()),

          // TaskDocumentsPage(
          //   customerId: widget.customerId.toString(),
          // ),

          if (!widget.fromLead && settingsprovider.menuIsViewMap[37] == 1)
            CheckListManagementWidget(customerId: widget.customerId.toString()),

          // RecieptListPageMobile(
          //   customerId: widget.customerId.toString(),
          // ),
          if (settingsprovider.menuIsViewMap[21] == 1)
            InvoiceTabPage(customerId: widget.customerId.toString()),
        ],
      ),
    );
  }
}
