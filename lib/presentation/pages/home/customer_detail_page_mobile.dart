import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/home/checklist_management_page.dart';
import 'package:vidyanexis/presentation/pages/home/inovice_tab.dart';
import 'package:vidyanexis/presentation/pages/home/reciept_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/forms_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_schedule_tab_widget.dart';
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

import 'package:vidyanexis/presentation/widgets/customer/task_list_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/presentation/pages/home/customer_task_overview_tab.dart';
import 'package:vidyanexis/presentation/widgets/customer/customer_detail_custom_tab.dart';

class CustomerDetailPageMobile extends StatefulWidget {
  static const String route = '/customer-detail-mobile/';
  final SearchLeadModel? lead;

  final bool fromLead;
  final int customerId;
  final String? initialTab;

  const CustomerDetailPageMobile(
      {super.key,
      this.lead,
      required this.fromLead,
      required this.customerId,
      this.initialTab});

  @override
  State<CustomerDetailPageMobile> createState() =>
      _CustomerDetailPageMobileState();
}

class _CustomerDetailPageMobileState extends State<CustomerDetailPageMobile> {
  int _selectedIndex = 0;
  List<String> tabLabels = [];
  List<Widget> tabPages = [];

  @override
  void initState() {
    super.initState();

    final settingsprovider =
        Provider.of<SettingsProvider>(context, listen: false);

    _buildTabs(settingsprovider);

    if (widget.initialTab != null) {
      final index = tabLabels.indexWhere(
          (label) => label.toLowerCase() == widget.initialTab!.toLowerCase());
      if (index != -1) {
        _selectedIndex = index;
      }
    }

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

  void _buildTabs(SettingsProvider settingsprovider) {
    tabLabels = ["Details"];
    tabPages = [DetailsTabMobile(customerId: widget.customerId.toString())];

    if (settingsprovider.menuIsViewMap[13] == 1) {
      tabLabels.add("Summary");
      tabPages.add(
          CustomerTaskOverviewTab(customerId: widget.customerId.toString()));

      tabLabels.add("Tasks");
      tabPages
          .add(TaskListPageMobile(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[16] == 1) {
      tabLabels.add("Quotations");
      tabPages
          .add(QuotationMobileView(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[19] == 1) {
      tabLabels.add("Documents");
      tabPages.add(
          DocumentsListPagePhone(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[85] == 1) {
      tabLabels.add("Forms");
      tabPages.add(FormsTabWidget(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[100] == 1) {
      tabLabels.add("Activity");
      tabPages.add(
          ActivityTabPage(lead: widget.lead, customerId: widget.customerId));
    }

    if (!widget.fromLead && settingsprovider.menuIsViewMap[14] == 1) {
      tabLabels.add("Complaints");
      tabPages
          .add(ComplaintsPageMobile(customerId: widget.customerId.toString()));
    }

    if (!widget.fromLead && settingsprovider.menuIsViewMap[15] == 1) {
      tabLabels.add("Periodic Services");
      tabPages.add(
          PeriodicServicesMobile(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[18] == 1) {
      tabLabels.add("Receipt");
      tabPages.add(RecieptPhone(widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[48] == 1) {
      tabLabels.add("Expense");
      tabPages.add(ExpenseTabWidget(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[70] == 1) {
      tabLabels.add("Payment Schedule");
      tabPages.add(
          PaymentScheduleTabWidget(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[81] == 1) {
      tabLabels.add("Payment");
      tabPages.add(PaymentTabWidget(customerId: widget.customerId.toString()));
    }

    if (!widget.fromLead && settingsprovider.menuIsViewMap[37] == 1) {
      tabLabels.add("CheckList Management");
      tabPages.add(
          CheckListManagementWidget(customerId: widget.customerId.toString()));
    }

    if (settingsprovider.menuIsViewMap[21] == 1) {
      tabLabels.add("Invoice");
      tabPages.add(InvoiceTabPage(customerId: widget.customerId.toString()));
    }
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
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whiteColor,
        leadingWidth: 40,
        leading: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: AppColors.textGrey4),
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
          if (_selectedIndex == 0)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (settingsprovider.menuIsEditMap[3] == 1)
                  IconButton(
                    icon: Icon(Icons.edit_outlined,
                        size: 22, color: AppColors.primaryBlue),
                    tooltip: 'Edit',
                    onPressed: () async {
                      final leadsProvider =
                          Provider.of<LeadsProvider>(context, listen: false);
                      await leadsProvider.getLeadDropdowns(context);
                      final dropDownProvider =
                          Provider.of<DropDownProvider>(context, listen: false);
                      if (leadDetailsProvider.leadDetails != null &&
                          leadDetailsProvider.leadDetails!.isNotEmpty) {
                        leadsProvider.enquirySourceController.text =
                            leadDetailsProvider
                                .leadDetails![0].enquirySourceName;
                        leadsProvider.enquiryForController.text =
                            leadDetailsProvider.leadDetails![0].enquiryForName;
                      }
                      dropDownProvider.selectedEnquirySourceId = int.parse(
                          widget.lead?.enquirySourceId.toString() ?? '0');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewLeadDrawerMobileWidget(
                            customerId: widget.customerId.toString(),
                            isEdit: true,
                          ),
                        ),
                      );
                    },
                  ),
                if (settingsprovider.menuIsDeleteMap[3] == 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 22, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () {
                      showConfirmationDialog(
                        context: context,
                        isLoading: customerDetailsProvider.isDeleteLoading,
                        title: 'Confirm Deletion',
                        content: 'Are you sure you want to delete this Lead?',
                        onCancel: () => Navigator.of(context).pop(),
                        onConfirm: () async {
                          final leadsProvider = Provider.of<LeadsProvider>(
                              context,
                              listen: false);
                          final customerId = widget.customerId.toString();

                          leadsProvider.removeLeadFromList(customerId);
                          Provider.of<CustomerProvider>(context, listen: false)
                              .removeCustomerFromList(customerId);

                          await leadsProvider.deleteLead(context, customerId);

                          if (context.mounted) {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Provider.of<CustomerProvider>(context,
                                    listen: false)
                                .getSearchCustomersNoContext();
                          }
                        },
                        confirmButtonText: 'Delete',
                      );
                    },
                  ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          CustomerDetailCustomTab(
            tabs: tabLabels,
            selectedIndex: _selectedIndex,
            onTabChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: tabPages,
            ),
          ),
        ],
      ),
    );
  }
}
