import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/add_task_model.dart';
import 'package:vidyanexis/controller/models/amc_report_model.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';

import 'package:vidyanexis/presentation/pages/home/checklist_management_page.dart';
import 'package:vidyanexis/presentation/pages/home/inovice_tab.dart';
import 'package:vidyanexis/presentation/pages/home/reciept_screen.dart';
import 'package:vidyanexis/presentation/pages/home/expense_screen.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_expense_management.dart';

import 'package:vidyanexis/presentation/pages/inventory/stock_return_page.dart';
import 'package:vidyanexis/presentation/pages/inventory/stock_use_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_expense.dart';
import 'package:vidyanexis/presentation/pages/home/refund_form_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_checklist_management_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_payment_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/customer_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/document_list_model.dart';

import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_service.dart';
import 'package:vidyanexis/presentation/pages/home/edit_quotation_screen.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/pages/home/customer_task_overview_tab.dart';

import 'package:vidyanexis/presentation/widgets/customer/amc_creation_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_details_widget.dart';

import 'package:vidyanexis/presentation/widgets/customer/service_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/service_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_card.dart';

import 'package:vidyanexis/presentation/widgets/customer/follow_up_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/payment_schedule_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/customer_profie_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/forms_tab_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/utils/file_share_function.dart';
import 'package:vidyanexis/utils/file_downloader.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_commercial.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_residential.dart';
import 'package:vidyanexis/presentation/pages/home/kseb_print_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_agreement_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_feasibility_pdf.dart';
import 'package:vidyanexis/utils/pdf_action_helper.dart';
import 'package:vidyanexis/presentation/widgets/customer/pdf/print_customer_details_pdf.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class CustomerDetailsScreen extends StatefulWidget {
  static const String route = '/customerDetails/';

  final String customerId;
  final String report;

  const CustomerDetailsScreen(
      {super.key, required this.customerId, required this.report});

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen>
    with TickerProviderStateMixin {
  int? selectedTaskTypeId;
  int? selectedAmcStatusId;
  int? selectedServiceStatusId;
  int? selectedQuotationStatusId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final sidebarProvider =
      //     Provider.of<SidebarProvider>(context, listen: false);
      // sidebarProvider.setSelectedIndex(1);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider
          .setCustomerId(int.tryParse(widget.customerId) ?? 0);
      customerDetailsProvider.getTaskList(widget.customerId, context);
      customerDetailsProvider
          .fetchLeadDetails(widget.customerId, context)
          .then((value) {
        if (customerDetailsProvider.leadDetails != null &&
            customerDetailsProvider.leadDetails!.isNotEmpty) {
          final lead = customerDetailsProvider.leadDetails!.first;
          final leadsProvider =
              Provider.of<LeadsProvider>(context, listen: false);

          leadsProvider.getCustomFieldsByEnquiryForId(context,
              enquiryForId: lead.enquiryForId, leadId: lead.customerId);

          final settingsProvider =
              Provider.of<SettingsProvider>(context, listen: false);
          settingsProvider.getMenuPermissionDataPrint(
              lead.enquiryForId.toString(), context);
        }
      });
      // Eager loading removed for lazy tab initialization
      // APIs will be fetched when their respective tabs are opened.
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getTaskType(context);
      dropDownProvider.getAMCStatus(context);
      dropDownProvider.getEnquirySource(context);
      dropDownProvider.getEnquiryFor(context);
    });

    getUserName();
  }

  late TabController _tabController;
  List<Tab> _tabs = [];
  bool _isControllerInitialized = false;
  Key _checklistKey = UniqueKey();

  bool _canScrollLeft = false;
  bool _canScrollRight = false;
  final GlobalKey _firstTabKey = GlobalKey();

  void _scrollTabs(double delta) {
    if (_firstTabKey.currentContext != null) {
      final scrollable = Scrollable.of(_firstTabKey.currentContext!);
      scrollable.position.animateTo(
        scrollable.position.pixels + delta,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settingsprovider = Provider.of<SettingsProvider>(context);
    final sideprovider = Provider.of<SidebarProvider>(context);

    final newTabs = [
      Tab(key: _firstTabKey, text: "Info"),
      if (settingsprovider.menuIsViewMap[13] == 1) const Tab(text: "Summary"),
      if (settingsprovider.menuIsViewMap[13] == 1) const Tab(text: "Tasks"),
      if (settingsprovider.menuIsViewMap[16] == 1)
        const Tab(text: "Quotations"),
      if (settingsprovider.menuIsViewMap[19] == 1) const Tab(text: "Documents"),
      if (settingsprovider.menuIsViewMap[85] == 1) const Tab(text: "Forms"),
      if (settingsprovider.menuIsViewMap[14] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Complaints"),
      if (settingsprovider.menuIsViewMap[15] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Periodic Service"),
      if (settingsprovider.menuIsViewMap[100] == 1) const Tab(text: "History"),
      if (settingsprovider.menuIsViewMap[18] == 1)
        const Tab(text: "Receipt"),
      if (settingsprovider.menuIsViewMap[48] == 1) const Tab(text: "Expense"),
      // Payment Tab (New)

      if (settingsprovider.menuIsViewMap[37] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "CheckList Management"),
      if (settingsprovider.menuIsViewMap[70] == 1)
        const Tab(text: "Payment Schedule"),
      if (settingsprovider.menuIsViewMap[81] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Payment"),
      if (settingsprovider.menuIsViewMap[71] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Refund Form"),
      if (settingsprovider.menuIsViewMap[21] == 1) const Tab(text: "Invoice"),
      if (settingsprovider.menuIsViewMap[78] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Stock Use "),
      if (settingsprovider.menuIsViewMap[79] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Stock Return"),
    ];

    if (!_isControllerInitialized || newTabs.length != _tabs.length) {
      _tabs = newTabs;

      int initialIndex = 0;
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      if (customerDetailsProvider.initialTabName != null) {
        initialIndex = _tabs.indexWhere(
            (tab) => tab.text == customerDetailsProvider.initialTabName);
        if (initialIndex == -1) initialIndex = 0;
        customerDetailsProvider.setInitialTabName(null);
      }

      _tabController = TabController(
          length: _tabs.length, vsync: this, initialIndex: initialIndex);
      _tabController.addListener(() {
        if (!_tabController.indexIsChanging) {
          _fetchDataForCurrentTab();
          setState(() {});
        }
      });
      _isControllerInitialized = true;
      
      // Fetch data for the initially selected tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchDataForCurrentTab();
      });
    }
  }

  void _fetchDataForCurrentTab() {
    if (_tabController.index < 0 || _tabController.index >= _tabs.length) return;
    String currentTabName = _tabs[_tabController.index].text ?? "";
    final provider = Provider.of<CustomerDetailsProvider>(context, listen: false);

    switch (currentTabName) {
      case "Info":
        break;
      case "Summary":
        // provider.getTaskOverview(...) // if needed
        break;
      case "Tasks":
        provider.getTaskList(widget.customerId, context);
        break;
      case "Quotations":
        provider.fetchQuotationListIfNeeded(widget.customerId, context);
        break;
      case "Documents":
        provider.getDocument(widget.customerId, context);
        break;
      case "Forms":
        provider.getTaskDocument(widget.customerId, context);
        break;
      case "History":
        provider.getFollowUpHistory(widget.customerId, context);
        break;
      case "Receipt":
        provider.getRecieptListApi(widget.customerId, context);
        break;
      case "Periodic Service":
        provider.getServiceList(widget.customerId, context);
        provider.getAmc(widget.customerId, '0', context);
        break;
    }
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _tabController.dispose();
    }
    super.dispose();
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? "Admin";
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // setTabs() {
  //   tabs = [
  //     if (settingsprovider.menuIsViewMap[13] == 1) const Tab(text: "Tasks"),
  //     if (settingsProvider.menuIsViewMap[14] == 1 &&
  //         sideprovider.name != 'Lead /')
  //       const Tab(text: "Complaints"),
  //     if (settingsProvider.menuIsViewMap[15] == 1 &&
  //         sideProvider.name != 'Lead /')
  //       const Tab(text: "Periodic Service"),
  //     if (settingsProvider.menuIsViewMap[16] == 1)
  //       const Tab(text: "Quotations"),
  //     if (settingsProvider.menuIsViewMap[19] == 1 &&
  //         sideProvider.name != 'Lead /')
  //       const Tab(text: "Documents"),
  //     if (settingsProvider.menuIsViewMap[18] == 1 &&
  //         sideProvider.name != 'Lead /')
  //       const Tab(text: "Receipt"),
  //     if (settingsProvider.menuIsViewMap[30] == 1)
  //       const Tab(text: "Task Documents"),
  //     if (settingsProvider.menuIsViewMap[37] == 1 &&
  //         sideProvider.name != 'Lead /')
  //       const Tab(text: "CheckList Management"),
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    final leadProvider = Provider.of<LeadsProvider>(context);

    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final sideprovider = Provider.of<SidebarProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    // final screenWidth = MediaQuery.of(context).size.width;

    final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);

    // final List<SidebarOption> sidebarOptions = [
    //   SidebarOption(
    //     title: 'Leads',
    //     iconPath: 'assets/images/Leads.svg',
    //     content: const LeadPage(),
    //   ),
    //   SidebarOption(
    //       title: 'Customers',
    //       iconPath: 'assets/images/user-group-03.svg',
    //       content: const CustomerPage()),
    //   // SidebarOption(
    //   //   title: 'Workers',
    //   //   iconPath: 'assets/images/Workers.svg',
    //   //   content: const Center(
    //   //     child: Text(
    //   //       'Workers',
    //   //       style: TextStyle(fontSize: 24),
    //   //     ),
    //   //   ),
    //   // ),
    //   // SidebarOption(
    //   //   title: 'Chats',
    //   //   iconPath: 'assets/images/comment-01.svg',
    //   //   content: const Center(
    //   //     child: Text(
    //   //       'Chats Content',
    //   //       style: TextStyle(fontSize: 24),
    //   //     ),
    //   //   ),
    //   // ),
    //   SidebarOption(
    //       title: 'Settings',
    //       iconPath: 'assets/images/settings-02.svg',
    //       content: const SettingsPage()),
    //   SidebarOption(
    //     title: 'Task Reports',
    //     iconPath: 'assets/images/Reports.svg',
    //     content: const Center(child: TaskPageReport()),
    //   ),
    //   SidebarOption(
    //     title: 'Service Reports',
    //     iconPath: 'assets/images/Reports.svg',
    //     content: const Center(child: ServicePageReport()),
    //   ),
    // ];

    return WillPopScope(
        onWillPop: () async {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            return false; // Prevent default behavior since we popped manually
          }

          // Existing fallback logic for web dashboard view override
          sideprovider.replaceWidget(true, '');
          sideprovider.replaceWidgetCustomer(true, '');
          AppStyles.isWebScreen(context)
              ? leadProvider.getSearchLeadsNoContext()
              : leadProvider.getSearchLeads(context);
          AppStyles.isWebScreen(context)
              ? customerProvider.getSearchCustomersNoContext()
              : customerProvider.getSearchCustomers(context);
          leadDetailsProvider.fetchLeadDetailsNoContext(widget.customerId);

          return false; // Prevent exiting the app
        },
        child: Scaffold(
          key: _scaffoldKey,
          // appBar: screenWidth < _breakpoint
          //     ? AppBar(
          //         backgroundColor: Colors.white,
          //         elevation: 0,
          //         title: const Image(
          //           image: AssetImage('assets/images/logo.png'),
          //           height: 40,
          //         ),
          //         centerTitle: false,
          //       )
          //     : null,
          // drawer: screenWidth < _breakpoint
          //     ? Drawer(
          //         child: FutureBuilder<String>(
          //           future: getUserName(),
          //           builder: (context, snapshot) {
          //             if (snapshot.hasError) {
          //               return const CommonEmptyState(message: 'Error loading username');
          //             } else {
          //               final userName = snapshot.data ?? '';
          //               return CustomSidebar(
          //                 userName: userName,
          //                 options: sidebarOptions,
          //                 isDrawer: true,
          //                 width: screenWidth * 0.85,
          //               );
          //             }
          //           },
          //         ),
          //       )
          //     : null,
          // endDrawer: TaskDetailsWidget(),
          body: SafeArea(
            child: Row(
              children: [
                // if (screenWidth >= _breakpoint)
                //   FutureBuilder<String>(
                //     future: getUserName(),
                //     builder: (context, snapshot) {
                //       if (snapshot.hasError) {
                //         return const Text('Error loading username');
                //       } else {
                //         final userName = snapshot.data ?? '';
                //         return CustomSidebar(
                //           onPressed: () {
                //             // print('Home');
                //             // context.go(HomePage.route);
                //           },
                //           options: sidebarOptions,
                //           width: 200,
                //           isDrawer: false,
                //           userName: userName,
                //         );
                //       }
                //     },
                //   ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //top
                        if (widget.report == 'true')
                          const SizedBox(
                            height: 20,
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 0),
                          color: Colors.white,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  // Check if we can pop (pushed via Navigator/GoRouter)
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                    return;
                                  }

                                  // Fallback for embedded views (mostly old web logic)
                                  sideprovider.replaceWidget(true, '');
                                  sideprovider.replaceWidgetCustomer(true, '');
                                  AppStyles.isWebScreen(context)
                                      ? leadProvider.getSearchLeadsNoContext()
                                      : leadProvider.getSearchLeads(context);
                                  AppStyles.isWebScreen(context)
                                      ? customerProvider
                                          .getSearchCustomersNoContext()
                                      : customerProvider
                                          .getSearchCustomers(context);
                                  leadDetailsProvider.fetchLeadDetailsNoContext(
                                      widget.customerId);
                                },
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: Color(0xFF152D70),
                                ),
                              ),
                              const SizedBox(width: 10),
                              AppStyles.isWebScreen(context)
                                  ? Text(
                                      customerDetailsProvider.leadDetails !=
                                                  null &&
                                              customerDetailsProvider
                                                  .leadDetails!.isNotEmpty
                                          ? customerDetailsProvider
                                              .leadDetails![0].customerName
                                          : '',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFF152D70),
                                          fontWeight: FontWeight.w600),
                                    )
                                  : Expanded(
                                      child: Text(
                                        customerDetailsProvider.leadDetails !=
                                                    null &&
                                                customerDetailsProvider
                                                    .leadDetails!.isNotEmpty
                                            ? customerDetailsProvider
                                                .leadDetails![0].customerName
                                            : '',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18),
                                      ),
                                    ),
                              const SizedBox(width: 10),
                              if (settingsprovider.menuIsEditMap[
                                      sideprovider.name == 'Lead /' ? 3 : 4] ==
                                  1)
                                IconButton(
                                    onPressed: () async {
                                      await leadDetailsProvider
                                          .fetchLeadDetails(
                                              widget.customerId, context);
                                      await leadProvider
                                          .getLeadDropdowns(context);
                                      leadProvider.setCutomerId(
                                          int.parse(widget.customerId));
                                      leadProvider
                                              .enquirySourceController.text =
                                          leadDetailsProvider
                                              .leadDetails![0].enquirySourceName
                                              .toString();
                                      leadProvider.enquiryForController.text =
                                          leadDetailsProvider
                                              .leadDetails![0].enquiryForName
                                              .toString();

                                      dropDownProvider.selectedEnquirySourceId =
                                          leadDetailsProvider
                                              .leadDetails![0].enquirySourceId;

                                      await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return const NewLeadDrawerWidget(
                                            isEdit: true,
                                          );
                                        },
                                      );
                                      customerDetailsProvider
                                          .fetchLeadDetails(
                                              widget.customerId, context)
                                          .then((value) {
                                        if (customerDetailsProvider
                                                    .leadDetails !=
                                                null &&
                                            customerDetailsProvider
                                                .leadDetails!.isNotEmpty) {
                                          final lead = customerDetailsProvider
                                              .leadDetails!.first;
                                          final leadsProvider =
                                              Provider.of<LeadsProvider>(
                                                  context,
                                                  listen: false);

                                          leadsProvider
                                              .getCustomFieldsByEnquiryForId(
                                                  context,
                                                  enquiryForId:
                                                      lead.enquiryForId,
                                                  leadId: lead.customerId);
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.edit)),
                              if (settingsprovider.menuIsDeleteMap[
                                      sideprovider.name == 'Lead /' ? 3 : 4] ==
                                  1)
                                IconButton(
                                  onPressed: () {
                                    showConfirmationDialog(
                                      context: context,
                                      title: 'Delete Customer/Lead',
                                      content:
                                          'Are you sure you want to delete this ${sideprovider.name == 'Lead /' ? 'lead' : 'customer'}?',
                                      onCancel: () =>
                                          Navigator.of(context).pop(),
                                      onConfirm: () async {
                                        // Close confirmation dialog first to avoid blocking the loader
                                        Navigator.of(context).pop();

                                        // Perform deletion while page is still mounted
                                        if (sideprovider.name == 'Lead /') {
                                          await leadProvider.deleteLead(
                                              context, widget.customerId);
                                        } else {
                                          await customerProvider.deleteCustomer(
                                              context, widget.customerId);
                                        }

                                        if (context.mounted) {
                                          // Optimistic removal from lists
                                          leadProvider.removeLeadFromList(
                                              widget.customerId);
                                          customerProvider
                                              .removeCustomerFromList(
                                                  widget.customerId);

                                          // Now go back from details page
                                          if (Navigator.of(context).canPop()) {
                                            Navigator.of(context).pop();
                                          } else {
                                            // Fallback for embedded views (Web logic)
                                            sideprovider.replaceWidget(
                                                true, '');
                                            sideprovider.replaceWidgetCustomer(
                                                true, '');
                                          }

                                          // Refresh the list silently on the previous page
                                          customerProvider
                                              .getSearchCustomersNoContext();
                                        }
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                ),
                              if (settingsprovider.menuIsViewMap[169] == 1 ||
                                  settingsprovider.menuIsViewMap[169].toString() == '1')
                                IconButton(
                                  tooltip: 'Export PDF',
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.blue),
                                  onPressed: () async {
                                    if (customerDetailsProvider.leadDetails != null &&
                                        customerDetailsProvider.leadDetails!.isNotEmpty) {
                                      final companyName = settingsprovider.companyDetails.isNotEmpty
                                          ? settingsprovider.companyDetails[0].companyName
                                          : '3rd Eye Security Systems';
                                      await generateCustomerDetailsPdf(
                                        customerData: customerDetailsProvider.leadDetails![0],
                                        customFields: leadProvider.customFieldEnquiryFor ?? [],
                                        companyName: companyName,
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('No details available to export')),
                                      );
                                    }
                                  },
                                ),
                              const SizedBox(width: 20),
                              if (_canScrollLeft)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _scrollTabs(-150),
                                  icon: const Icon(Icons.arrow_back_ios_new,
                                      size: 16),
                                ),
                              Expanded(
                                child: NotificationListener<Notification>(
                                  onNotification: (notification) {
                                    if (notification is ScrollNotification ||
                                        notification
                                            is ScrollMetricsNotification) {
                                      final metrics = notification
                                              is ScrollNotification
                                          ? notification.metrics
                                          : (notification
                                                  as ScrollMetricsNotification)
                                              .metrics;
                                      if (metrics.maxScrollExtent > 0) {
                                        setState(() {
                                          _canScrollLeft = metrics.pixels > 5;
                                          _canScrollRight = metrics.pixels <
                                              metrics.maxScrollExtent - 5;
                                        });
                                      } else {
                                        if (_canScrollLeft || _canScrollRight) {
                                          setState(() {
                                            _canScrollLeft = false;
                                            _canScrollRight = false;
                                          });
                                        }
                                      }
                                    }
                                    return false;
                                  },
                                  child: Container(
                                    height: 42,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      labelColor: AppColors.primaryBlue,
                                      unselectedLabelColor:
                                          const Color(0xFF64748B),
                                      indicator: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      indicatorPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 4),
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      tabAlignment: TabAlignment.start,
                                      isScrollable: true,
                                      dividerColor: Colors.transparent,
                                      labelPadding: const EdgeInsets.symmetric(
                                          horizontal: 14),
                                      labelStyle: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13),
                                      unselectedLabelStyle:
                                          GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                      tabs: _tabs,
                                    ),
                                  ),
                                ),
                              ),
                              if (_canScrollRight)
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => _scrollTabs(150),
                                  icon: const Icon(Icons.arrow_forward_ios,
                                      size: 16),
                                ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: "Refresh",
                                onPressed: () {
                                  _fetchDataForCurrentTab();
                                },
                                icon: const Icon(Icons.refresh,
                                    color: AppColors.primaryBlue, size: 20),
                              ),
                              if (settingsprovider.menuIsSaveMap[13] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text == "Tasks")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider.customerId =
                                          widget.customerId;
                                      customerDetailsProvider
                                          .clearTaskDetails();
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return TaskCreationWidget(
                                            isEdit: false,
                                            taskId: '0',
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Create Task'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[37] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text ==
                                      "CheckList Management")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddCheckListManagementWidget(
                                            documentChecklistModel:
                                                DocumentChecklistModel(),
                                          );
                                        },
                                      ).then((value) {
                                        if (value == true) {
                                          setState(() {
                                            _checklistKey = UniqueKey();
                                          });
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Checklist'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[15] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text ==
                                      "Periodic Service")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider.customerId =
                                          widget.customerId;
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AmcCreationWidget(
                                              amcId: '0',
                                              customerId: widget.customerId,
                                              isEdit: false);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Periodic Service'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[48] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text == "Expense")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final lead = customerDetailsProvider
                                                  .leadDetails?.isNotEmpty ==
                                              true
                                          ? customerDetailsProvider
                                              .leadDetails!.first
                                          : null;
                                      final customerName =
                                          lead?.customerName ?? '';

                                      final expProvider =
                                          Provider.of<ExpenseProvider>(context,
                                              listen: false);
                                      expProvider.userController.clear();
                                      expProvider.dateController.clear();
                                      expProvider.expenseTypeController.clear();
                                      expProvider.amountController.clear();
                                      expProvider.taxPercentageController
                                          .clear();
                                      expProvider.amountWithoutTaxController
                                          .clear();
                                      expProvider.cgstController.clear();
                                      expProvider.sgstController.clear();
                                      expProvider.expenseHeadController.clear();
                                      expProvider.commentController.clear();
                                      expProvider.projectController.clear();
                                      expProvider.projectTypeController.clear();
                                      expProvider.leadController.clear();

                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AddExpenseManagement(
                                              expenseModel: ExpenseModel(
                                                  customerId: int.tryParse(
                                                      widget.customerId),
                                                  customerName: customerName),
                                              isEdit: false);
                                        },
                                      ).then((_) {
                                        customerDetailsProvider
                                            .getExpenseListApi(
                                                widget.customerId.toString(),
                                                context);
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Expense'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[18] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text == "Receipt")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider.customerId =
                                          widget.customerId;
                                      customerDetailsProvider
                                          .clearRecieptDetails();
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return RecieptCreationWidget(
                                              recieptId: '0',
                                              customerId: widget.customerId,
                                              isEdit: false);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Receipt'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[14] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text ==
                                      "Complaints")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider.customerId =
                                          widget.customerId;
                                      customerDetailsProvider
                                          .clearServiceDetails();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return ServiceCreationWidget(
                                              taskId: '0',
                                              isEdit: false,
                                              customerId: widget.customerId);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Complaint'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[81] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text == "Payment")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider
                                          .clearPaymentDetails();
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (BuildContext context) {
                                          return AddPaymentWidget(
                                              customerId: widget.customerId);
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Payment'),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                              if (settingsprovider.menuIsSaveMap[16] == 1 &&
                                  _isControllerInitialized &&
                                  _tabs[_tabController.index].text ==
                                      "Quotations")
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      customerDetailsProvider.customerId =
                                          widget.customerId;
                                      customerDetailsProvider
                                          .qsubsidyAmountController.text = '0';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              QuotationCreationWidget(
                                                  quotationId: '0',
                                                  isEdit: false,
                                                  customerId:
                                                      widget.customerId),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('New Quotation '),
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        //down
                        Expanded(
                          child: Row(
                            children: [
                              // Left Panel
                              /* if (AppStyles.isWebScreen(context))
                              Expanded(
                                flex: 2,
                                child: customerDetailsProvider.leadDetails !=
                                            null &&
                                        customerDetailsProvider
                                            .leadDetails!.isNotEmpty
                                    ? ListView(
                                        padding: const EdgeInsets.all(16.0),
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                            ),
                                            child: Row(
                                              children: [
                                                const CircleAvatar(
                                                  radius: 20,
                                                  backgroundColor:
                                                      Color(0xFFA2C6EB),
                                                  child: Icon(
                                                      Icons.person_rounded,
                                                      size: 30,
                                                      color: Color(0xFFE5F0FF)),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          customerDetailsProvider
                                                              .leadDetails![0]
                                                              .customerName,
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      // Text(
                                                      //   'Order No : 20392',
                                                      //   style: TextStyle(
                                                      //       fontWeight: FontWeight.w500),
                                                      // )
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      if (settingsprovider
                                                                  .menuIsEditMap[
                                                              4] ==
                                                          1)
                                                        IconButton(
                                                            onPressed:
                                                                () async {
                                                              await leadDetailsProvider
                                                                  .fetchLeadDetails(
                                                                      widget
                                                                          .customerId,
                                                                      context);
                                                              await leadProvider
                                                                  .getLeadDropdowns(
                                                                      context);

                                                              leadProvider
                                                                  .setCutomerId(
                                                                      int.parse(
                                                                          widget
                                                                              .customerId));
                                                              final leadsProvider =
                                                                  Provider.of<
                                                                          LeadsProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);
                                                              leadsProvider
                                                                      .enquirySourceController
                                                                      .text =
                                                                  leadDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .enquirySourceName
                                                                      .toString();
                                                              final dropDownProvider =
                                                                  Provider.of<
                                                                          DropDownProvider>(
                                                                      context,
                                                                      listen:
                                                                          false);
                                                              dropDownProvider
                                                                      .selectedEnquirySourceId =
                                                                  leadDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .enquirySourceId;
                                                              // sideprovider
                                                              //     .setSelectedIndex(1);
                                                              // context
                                                              //     .go(HomePage.route);
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return const NewLeadDrawerWidget(
                                                                    isEdit:
                                                                        true,
                                                                  );
                                                                },
                                                              );
                                                              // customerDetailsProvider
                                                              //         .nameController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .customerName;
                                                              // customerDetailsProvider
                                                              //         .phoneController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .contactNumber;
                                                              // customerDetailsProvider
                                                              //         .emailController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .email;
                                                              // customerDetailsProvider
                                                              //         .addressController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .address1;
                                                              // customerDetailsProvider
                                                              //         .cityController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .address2;
                                                              // customerDetailsProvider
                                                              //         .districtController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .address3;
                                                              // customerDetailsProvider
                                                              //         .pincodeController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .pincode;
                                                              // customerDetailsProvider
                                                              //         .maplinkController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .mapLink;
                                                              // customerDetailsProvider
                                                              //         .stateController
                                                              //         .text =
                                                              //     customerDetailsProvider
                                                              //         .leadDetails![0]
                                                              //         .address4;
                                                              // editProfile(context);
                                                            },
                                                            icon: const Icon(
                                                                Icons.edit))
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 2),
                                          ),
                                          CustomerCard(
                                            title: "Contact",
                                            content: [
                                              // DetailRow(
                                              //     label: "Email",
                                              //     value: customerDetailsProvider
                                              //         .leadDetails![0].email),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Divider(
                                                  color: Colors.grey.withOpacity(
                                                      0.4), // You can adjust the color as per your design
                                                  thickness: 0.4,
                                                  height: 1,
                                                ),
                                              ),
                                              DetailRow(
                                                  label: "Phone no",
                                                  value: customerDetailsProvider
                                                      .leadDetails![0]
                                                      .contactNumber
                                                      .toString()),
                                            ],
                                          ),
                                          CustomerCard(
                                            title: "More Info",
                                            content: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  DetailRow(
                                                      label: "Address",
                                                      value:
                                                          customerDetailsProvider
                                                                  .leadDetails![
                                                                      0]
                                                                  .address ??
                                                              ''),
                                                  SizedBox(
                                                    height: 2
                                                  ),
                                                  DetailRow(
                                                      label: "Enquiry For",
                                                      value: customerDetailsProvider
                                                              .leadDetails![0]
                                                              .enquiryForName ??
                                                          ''),
                                                  SizedBox(
                                                    height: 2
                                                  ),
                                                  DetailRow(
                                                      label: "Enquiry Source",
                                                      value: customerDetailsProvider
                                                              .leadDetails![0]
                                                              .enquirySourceName ??
                                                          ''),
                                                  SizedBox(
                                                    height: 2
                                                  ),
                                                  DetailRow(
                                                      label: "Consumer Number",
                                                      value: customerDetailsProvider
                                                              .leadDetails![0]
                                                              .consumerNumber ??
                                                          ''),
                                                  // SizedBox(
                                                  //   height: 2
                                                  // ),
                                                  // DetailRow(
                                                  //     label: "Contact Number",
                                                  //     value: customerDetailsProvider
                                                  //             .leadDetails![0]
                                                  //             .phoneNumber ??
                                                  //         ''),
                                                  const SizedBox(
                                                    height: 2),
                                                  ),
                                                  const Text(
                                                    "Location: ",
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF8E97A3)),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: InkWell(
                                                          onTap: () {
                                                            String
                                                                locationData =
                                                                customerDetailsProvider
                                                                    .leadDetails![
                                                                        0]
                                                                    .location
                                                                    .toString();

                                                            print(
                                                                'DEBUG: Raw location data: "$locationData"');
                                                            print(
                                                                'DEBUG: Location length: ${locationData.length}');
                                                            print(
                                                                'DEBUG: Location characters: ${locationData.codeUnits}');

                                                            _openMaps(
                                                                locationData);
                                                          },
                                                          child: Text(
                                                            customerDetailsProvider
                                                                .leadDetails![0]
                                                                .location
                                                                .toString(),
                                                            style:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .blue),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ),
                                                      IconButton(
                                                        color: Colors.grey,
                                                        onPressed: () {
                                                          Clipboard.setData(
                                                            ClipboardData(
                                                              text: customerDetailsProvider
                                                                  .leadDetails![
                                                                      0]
                                                                  .location
                                                                  .toString(),
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Link copied to clipboard!'),
                                                            ),
                                                          );
                                                        },
                                                        icon: const Icon(
                                                            Icons.copy),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // Basic Information
                                          CustomerCard(
                                            title: "Basic",
                                            content: [
                                              DetailRow(
                                                label: "Lead Name",
                                                value: customerDetailsProvider
                                                        .leadDetails![0]
                                                        .customerName ??
                                                    '',
                                              ),
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                label: "Source",
                                                value: customerDetailsProvider
                                                        .leadDetails![0]
                                                        .sourceCategoryName ??
                                                    '',
                                              ),
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                label: "Mobile No",
                                                value: customerDetailsProvider
                                                    .leadDetails![0]
                                                    .contactNumber
                                                    .toString(),
                                              ),
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                label: "Enquiry Source",
                                                value: customerDetailsProvider
                                                        .leadDetails![0]
                                                        .enquirySourceName ??
                                                    '',
                                              ),
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                label: "Enquiry For",
                                                value: customerDetailsProvider
                                                        .leadDetails![0]
                                                        .enquiryForName ??
                                                    '',
                                              ),
                                              const SizedBox(height: 2),

                                              DetailRow(
                                                label: "Total project cost",
                                                value: customerDetailsProvider
                                                    .leadDetails![0]
                                                    .displayProjectCost,
                                              ),
                                              // DetailRow(
                                              //   label: "Engineer",
                                              //   value: customerDetailsProvider
                                              //       .leadDetails![0].engineerName,
                                              // ),
                                              // DetailRow(
                                              //   label: "Engineer Organization",
                                              //   value: customerDetailsProvider
                                              //       .leadDetails![0].organization,
                                              // ),
                                              // DetailRow(
                                              //   label: "Engineer Mobile",
                                              //   value: customerDetailsProvider
                                              //       .leadDetails![0].engineerMobile,
                                              // ),
                                              // DetailRow(
                                              //   label: "Engineer City",
                                              //   value: customerDetailsProvider
                                              //       .leadDetails![0].engineerCity,
                                              // ),
                                              // DetailRow(
                                              //   label: "Engineer District",
                                              //   value: customerDetailsProvider
                                              //       .leadDetails![0].engineerDistrict,
                                              // ),
                                            ],
                                          ),

                                          // Address Details
                                          CustomerCard(
                                            title: "Address Details",
                                            content: [
                                              // Address
                                              DetailRow(
                                                  label: "Address",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .address ??
                                                      ''),

                                              // Place
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Place",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .address1 ??
                                                      ''),

                                              // State
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "State",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .address3 ??
                                                      ''),

                                              // Landmark
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Landmark",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .landmark ??
                                                      ''),

                                              // Pincode
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Pincode",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .pinCode ??
                                                      ''),

                                              // Latitude
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Latitude",
                                                  value: customerDetailsProvider
                                                      .leadDetails![0].latitude
                                                      .toString()),

                                              // Longitude
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Longitude",
                                                  value: customerDetailsProvider
                                                      .leadDetails![0].longitude
                                                      .toString()),

                                              // District
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "District",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .districtName ??
                                                      ''),

                                              // Firestation
                                              const SizedBox(height: 2),
                                              DetailRow(
                                                  label: "Firestation",
                                                  value: customerDetailsProvider
                                                      .leadDetails![0]
                                                      .firestationName.toString()),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'Location',
                                                style: TextStyle(
                                                    color: Color(0xFF8E97A3)),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: InkWell(
                                                      onTap: () {
                                                        String locationData =
                                                            customerDetailsProvider
                                                                .leadDetails![0]
                                                                .location
                                                                .toString();

                                                        print(
                                                            'DEBUG: Raw location data: "$locationData"');
                                                        print(
                                                            'DEBUG: Location length: ${locationData.length}');
                                                        print(
                                                            'DEBUG: Location characters: ${locationData.codeUnits}');

                                                        _openMaps(locationData);
                                                      },
                                                      child: Text(
                                                        customerDetailsProvider
                                                            .leadDetails![0]
                                                            .location
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: Colors.blue),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    color: Colors.grey,
                                                    onPressed: () {
                                                      Clipboard.setData(
                                                        ClipboardData(
                                                          text:
                                                              customerDetailsProvider
                                                                  .leadDetails![
                                                                      0]
                                                                  .location
                                                                  .toString(),
                                                        ),
                                                      );
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Link copied to clipboard!'),
                                                        ),
                                                      );
                                                    },
                                                    icon:
                                                        const Icon(Icons.copy),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          // Additional
                                          CustomerCard(
                                            title: "Additional Details",
                                            content: (leadProvider
                                                            .customFieldEnquiryFor ??
                                                        [])
                                                    .isNotEmpty
                                                ? (leadProvider.customFieldEnquiryFor ?? [])
                                                    .where((field) =>
                                                        (field.customFieldName !=
                                                                null &&
                                                            field
                                                                .customFieldName
                                                                .toString()
                                                                .isNotEmpty) &&
                                                        (field.datavalue !=
                                                                null &&
                                                            field.datavalue
                                                                .toString()
                                                                .isNotEmpty))
                                                    .map<Widget>(
                                                      (field) => DetailRow(
                                                        label: field
                                                            .customFieldName
                                                            .toString()
                                                            .replaceAll(
                                                                '_', ' '),
                                                        value: field.datavalue
                                                                ?.toString() ??
                                                            '',
                                                      ),
                                                    )
                                                    .toList()
                                                : [],
                                          )
                                        ],
                                      )
                                    : Container(),
                              ), */
                              // Right Panel
                              /* if (!AppStyles.isWebScreen(context))
                              const SizedBox(
                                width: 15,
                              ), */
                              Expanded(
                                // flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 15.0),
                                  child: Column(
                                    children: [
                                      /* // COMMENTED OUT OLD TAB BAR SECTION
                                      // Tabs
                                      // Tabs
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TabBar(
                                              labelColor: AppColors.primaryBlue,
                                              unselectedLabelColor:
                                                  Colors.black54,
                                              indicatorColor:
                                                  AppColors.primaryBlue,
                                              tabAlignment: TabAlignment.start,
                                              isScrollable: true,
                                              dividerColor: Colors.white,
                                              labelStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              unselectedLabelStyle:
                                                  const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              tabs: tabs,
                                            ),
                                          ),
                                          if (settingsprovider
                                                  .menuIsSaveMap[13] ==
                                              1)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: ElevatedButton.icon(
                                                onPressed: () {
                                                  customerDetailsProvider
                                                          .customerId =
                                                      widget.customerId;
                                                  customerDetailsProvider
                                                      .clearTaskDetails();
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return TaskCreationWidget(
                                                        isEdit: false,
                                                        taskId: '0',
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(Icons.add),
                                                label:
                                                    const Text('Create Task'),
                                                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), 
                                                  backgroundColor:
                                                      AppColors.primaryBlue,
                                                  foregroundColor: Colors.white,
                                                  padding:
                                                      AppStyles.isWebScreen(
                                                              context)
                                                          ? const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 12)
                                                          : const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 16,
                                                              vertical: 0),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    */

                                      // Tab views
                                      Expanded(
                                        child: TabBarView(
                                          controller: _tabController,
                                          children: [
                                            // Info Tab
                                            customerDetailsProvider
                                                            .leadDetails !=
                                                        null &&
                                                    customerDetailsProvider
                                                        .leadDetails!.isNotEmpty
                                                ? (AppStyles.isWebScreen(
                                                        context)
                                                    ? Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Left Half
                                                          Expanded(
                                                            child: ListView(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              children: [
                                                                // Contact
                                                                CustomerCard(
                                                                  title:
                                                                      "Contact",
                                                                  content: [
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                          Divider(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.4),
                                                                        thickness:
                                                                            0.4,
                                                                        height:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                    DetailRow(
                                                                        label:
                                                                            "Phone no",
                                                                        value: customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .contactNumber
                                                                            .toString()),
                                                                  ],
                                                                ),
                                                                // More Info
                                                                // CustomerCard(
                                                                //   title:
                                                                //       "More Info",
                                                                //   content: [
                                                                //     Column(
                                                                //       crossAxisAlignment:
                                                                //           CrossAxisAlignment
                                                                //               .start,
                                                                //       children: [
                                                                //         DetailRow(
                                                                //             label:
                                                                //                 "Address",
                                                                //             value:
                                                                //                 customerDetailsProvider.leadDetails![0].address ?? ''),
                                                                //         const SizedBox(
                                                                //             height:
                                                                //                 2),
                                                                //         DetailRow(
                                                                //             label:
                                                                //                 "Enquiry For",
                                                                //             value:
                                                                //                 customerDetailsProvider.leadDetails![0].enquiryForName ?? ''),
                                                                //         const SizedBox(
                                                                //             height:
                                                                //                 2),
                                                                //         DetailRow(
                                                                //             label:
                                                                //                 "Enquiry Source",
                                                                //             value:
                                                                //                 customerDetailsProvider.leadDetails![0].enquirySourceName ?? ''),
                                                                //         const SizedBox(
                                                                //             height:
                                                                //                 2),
                                                                //         DetailRow(
                                                                //             label:
                                                                //                 "Consumer Number",
                                                                //             value:
                                                                //                 customerDetailsProvider.leadDetails![0].consumerNumber ?? ''),
                                                                //         const SizedBox(
                                                                //           height:
                                                                //               2,
                                                                //         ),
                                                                //         const Text(
                                                                //           "Location: ",
                                                                //           style:
                                                                //               TextStyle(color: Color(0xFF8E97A3)),
                                                                //         ),
                                                                //         Row(
                                                                //           children: [
                                                                //             Expanded(
                                                                //               child: InkWell(
                                                                //                 onTap: () {
                                                                //                   String locationData = customerDetailsProvider.leadDetails![0].location.toString();

                                                                //                   print('DEBUG: Raw location data: "$locationData"');
                                                                //                   print('DEBUG: Location length: ${locationData.length}');
                                                                //                   print('DEBUG: Location characters: ${locationData.codeUnits}');

                                                                //                   _openMaps(locationData);
                                                                //                 },
                                                                //                 child: Text(
                                                                //                   customerDetailsProvider.leadDetails![0].location.toString(),
                                                                //                   style: const TextStyle(color: Colors.blue),
                                                                //                   overflow: TextOverflow.ellipsis,
                                                                //                   maxLines: 1,
                                                                //                 ),
                                                                //               ),
                                                                //             ),
                                                                //             IconButton(
                                                                //               color: Colors.grey,
                                                                //               onPressed: () {
                                                                //                 Clipboard.setData(
                                                                //                   ClipboardData(
                                                                //                     text: customerDetailsProvider.leadDetails![0].location.toString(),
                                                                //                   ),
                                                                //                 );
                                                                //                 ScaffoldMessenger.of(context).showSnackBar(
                                                                //                   const SnackBar(
                                                                //                     content: Text('Link copied to clipboard!'),
                                                                //                   ),
                                                                //                 );
                                                                //               },
                                                                //               icon: const Icon(Icons.copy),
                                                                //             ),
                                                                //           ],
                                                                //         ),
                                                                //       ],
                                                                //     ),
                                                                //   ],
                                                                // ),
                                                                // Basic Information
                                                                CustomerCard(
                                                                  title:
                                                                      "Basic",
                                                                  content: [
                                                                    DetailRow(
                                                                      label:
                                                                          "Lead Name",
                                                                      value: customerDetailsProvider
                                                                              .leadDetails![0]
                                                                              .customerName ??
                                                                          '',
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Source",
                                                                      value: customerDetailsProvider
                                                                              .leadDetails![0]
                                                                              .sourceCategoryName ??
                                                                          '',
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Mobile No",
                                                                      value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .contactNumber
                                                                          .toString(),
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Enquiry Source",
                                                                      value: customerDetailsProvider
                                                                              .leadDetails![0]
                                                                              .enquirySourceName ??
                                                                          '',
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Enquiry For",
                                                                      value: customerDetailsProvider
                                                                              .leadDetails![0]
                                                                              .enquiryForName ??
                                                                          '',
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Total project cost",
                                                                      value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .displayProjectCost,
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                      label:
                                                                          "Sub Source",
                                                                      value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .referenceName,
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Address Details
                                                                CustomerCard(
                                                                  title:
                                                                      "Address Details",
                                                                  content: [
                                                                    // Address
                                                                    DetailRow(
                                                                        label:
                                                                            "Address",
                                                                        value: customerDetailsProvider.leadDetails![0].address ??
                                                                            ''),

                                                                    // Place
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Place",
                                                                        value: customerDetailsProvider.leadDetails![0].address1 ??
                                                                            ''),

                                                                    // State
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "State",
                                                                        value: customerDetailsProvider.leadDetails![0].address3 ??
                                                                            ''),

                                                                    // Landmark
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Landmark",
                                                                        value: customerDetailsProvider.leadDetails![0].landmark ??
                                                                            ''),

                                                                    // Pincode
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Pincode",
                                                                        value: customerDetailsProvider.leadDetails![0].pinCode ??
                                                                            ''),

                                                                    // Latitude
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Latitude",
                                                                        value: customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .latitude
                                                                            .toString()),

                                                                    // Longitude
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Longitude",
                                                                        value: customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .longitude
                                                                            .toString()),

                                                                    // District
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "District",
                                                                        value: customerDetailsProvider.leadDetails![0].districtName ??
                                                                            ''),

                                                                    // Consumer Number
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    DetailRow(
                                                                        label:
                                                                            "Consumer Number",
                                                                        value: customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .consumerNumber
                                                                            .toString()),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    const Text(
                                                                      'Location',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Color(0xFF8E97A3)),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              String locationData = customerDetailsProvider.leadDetails![0].location.toString();

                                                                              print('DEBUG: Raw location data: "$locationData"');
                                                                              print('DEBUG: Location length: ${locationData.length}');
                                                                              print('DEBUG: Location characters: ${locationData.codeUnits}');

                                                                              _openMaps(locationData);
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              customerDetailsProvider.leadDetails![0].location.toString(),
                                                                              style: const TextStyle(color: Colors.blue),
                                                                              overflow: TextOverflow.ellipsis,
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        IconButton(
                                                                          color:
                                                                              Colors.grey,
                                                                          onPressed:
                                                                              () async {
                                                                            final locStr =
                                                                                customerDetailsProvider.leadDetails![0].location.toString() ?? '';
                                                                            if (locStr == 'null' ||
                                                                                locStr.trim().isEmpty) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(content: Text('No location available to copy')),
                                                                              );
                                                                              return;
                                                                            }
                                                                            await Clipboard.setData(ClipboardData(text: locStr));
                                                                            if (context.mounted) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(content: Text('Link copied to clipboard!')),
                                                                              );
                                                                            }
                                                                          },
                                                                          icon:
                                                                              const Icon(Icons.copy),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          // Right Half
                                                          Expanded(
                                                            child: ListView(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              children: [
                                                                // Additional Details
                                                                Wrap(
                                                                  spacing: 10,
                                                                  runSpacing:
                                                                      10,
                                                                  crossAxisAlignment:
                                                                      WrapCrossAlignment
                                                                          .center,
                                                                  children: [
                                                                    if (sideprovider
                                                                            .name !=
                                                                        'Lead /')
                                                                      if (settingsprovider
                                                                              .menuIsDeleteMap[4] ==
                                                                          1)
                                                                        CustomElevatedButton(
                                                                          radius:
                                                                              4,
                                                                          backgroundColor:
                                                                              AppColors.whiteColor,
                                                                          borderColor:
                                                                              AppColors.textRed,
                                                                          textColor:
                                                                              AppColors.textRed,
                                                                          buttonText:
                                                                              'Remove Registration',
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) {
                                                                                return AlertDialog(
                                                                                  title: const Text('Remove Registration'),
                                                                                  content: const Text('Are you sure you want to Remove Registration '),
                                                                                  actions: <Widget>[
                                                                                    TextButton(
                                                                                      child: const Text('Cancel'),
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop(); // Close the dialog
                                                                                      },
                                                                                    ),
                                                                                    TextButton(
                                                                                      child: const Text('Remove Registration'),
                                                                                      onPressed: () {
                                                                                        customerDetailsProvider.removeRegister(widget.customerId, context);
                                                                                      },
                                                                                    ),
                                                                                  ],
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                    if ((settingsprovider.menuIsViewMap[61] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[61] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'KSEB',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'KSEB PDF',
                                                                            onGenerate:
                                                                                () async {
                                                                              return await generateKsebPdfBytes(
                                                                                    customerDetails: customerDetailsProvider.leadDetails!.first,
                                                                                    context: context,
                                                                                  ) ??
                                                                                  Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[63] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[63] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Vendor Agreement',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Vendor Agreement',
                                                                            onGenerate:
                                                                                () async {
                                                                              return await generateVendorAgreementPdfBytes(
                                                                                    customerDetails: customerDetailsProvider.leadDetails!.first,
                                                                                    context: context,
                                                                                  ) ??
                                                                                  Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[62] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[62] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Vendor Feasibility',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Vendor Feasibility',
                                                                            onGenerate:
                                                                                () async {
                                                                              return await generateRtsFeasibilityReportPdfBytes(
                                                                                    customerDetails: customerDetailsProvider.leadDetails!.first,
                                                                                    context: context,
                                                                                  ) ??
                                                                                  Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[101] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[101] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Annexture1',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Annexture1',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfAnnexure1}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure1}${widget.customerId}');
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[102] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[102] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Annexture2',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Annexture 2',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfAnnexure2}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure2}${widget.customerId}');
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[103] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[103] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Annexture3',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Annexture 3',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfAnnexure3}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure3}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[105] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[105] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Net meter Agreement',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Net meter Agreement',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[106] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[106] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'MNRE Agreement',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'MNRE Agreement',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfMnreAgreement}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfMnreAgreement}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[107] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[107] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Loan Agreement',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Loan Agreement',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfLoanAgreement}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfLoanAgreement}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[108] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[108] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Schedule',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Schedule',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfSchedule}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfSchedule}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[109] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[109] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Completion Report',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Completion Report',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfCompletionReport}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfCompletionReport}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[110] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[110] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'KSEB Net Meter',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'KSEB Net Meter',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfKsebNetMeter}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfKsebNetMeter}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[111] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[111] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Vendor Agreement A3s',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Vendor Agreement A3s',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfVendorAgreement}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfVendorAgreement}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[112] ==
                                                                                1 ||
                                                                            settingsprovider.menuIsViewMapPrint[112] ==
                                                                                1) &&
                                                                        sideprovider.name !=
                                                                            'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius:
                                                                            4,
                                                                        backgroundColor:
                                                                            AppColors.whiteColor,
                                                                        borderColor:
                                                                            AppColors.bluebutton,
                                                                        textColor:
                                                                            AppColors.bluebutton,
                                                                        buttonText:
                                                                            'Warranty',
                                                                        onPressed:
                                                                            () async {
                                                                          PdfActionHelper
                                                                              .showPdfOptions(
                                                                            context:
                                                                                context,
                                                                            title:
                                                                                'Warranty',
                                                                            pdfUrl:
                                                                                '${HttpUrls.getPdfWarranty}${widget.customerId}',
                                                                            onGenerate:
                                                                                () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfWarranty}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[163] == 1 || settingsprovider.menuIsViewMapPrint[163] == 1) && sideprovider.name != 'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius: 4,
                                                                        backgroundColor: AppColors.whiteColor,
                                                                        borderColor: AppColors.bluebutton,
                                                                        textColor: AppColors.bluebutton,
                                                                        buttonText: 'Work Completion Report',
                                                                        onPressed: () async {
                                                                          PdfActionHelper.showPdfOptions(
                                                                            context: context,
                                                                            title: 'Work Completion Report',
                                                                            pdfUrl: '${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}',
                                                                            onGenerate: () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[164] == 1 || settingsprovider.menuIsViewMapPrint[164] == 1) && sideprovider.name != 'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius: 4,
                                                                        backgroundColor: AppColors.whiteColor,
                                                                        borderColor: AppColors.bluebutton,
                                                                        textColor: AppColors.bluebutton,
                                                                        buttonText: 'Checklist',
                                                                        onPressed: () async {
                                                                          PdfActionHelper.showPdfOptions(
                                                                            context: context,
                                                                            title: 'Checklist',
                                                                            pdfUrl: '${HttpUrls.getPdfChecklist}${widget.customerId}',
                                                                            onGenerate: () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfChecklist}${widget.customerId}');
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                    if ((settingsprovider.menuIsViewMap[175] == 1 || settingsprovider.menuIsViewMapPrint[175] == 1) && sideprovider.name != 'Lead /')
                                                                      CustomElevatedButton(
                                                                        radius: 4,
                                                                        backgroundColor: AppColors.whiteColor,
                                                                        borderColor: AppColors.bluebutton,
                                                                        textColor: AppColors.bluebutton,
                                                                        buttonText: 'Status Image',
                                                                        onPressed: () async {
                                                                          PdfActionHelper.showPdfOptions(
                                                                            context: context,
                                                                            title: 'Status Image',
                                                                            pdfUrl: '${HttpUrls.generateStatusImage}${widget.customerId}',
                                                                            onGenerate: () async {
                                                                              await Loader.showLoader(context);
                                                                              final bytes = await customerDetailsProvider.getStatusImageBytes(widget.customerId);
                                                                              Loader.stopLoader(context);
                                                                              return bytes ?? Uint8List(0);
                                                                            },
                                                                          );
                                                                        },
                                                                      ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                // ACTION BUTTONS (Moved here)
                                                                CustomerCard(
                                                                  title:
                                                                      "Additional Details",
                                                                  content: (leadProvider.customFieldEnquiryFor ??
                                                                              [])
                                                                          .isNotEmpty
                                                                      ? (leadProvider.customFieldEnquiryFor ??
                                                                              [])
                                                                          .where((field) =>
                                                                              (field.customFieldName != null && field.customFieldName.toString().isNotEmpty) &&
                                                                              (field.datavalue != null && field.datavalue.toString().isNotEmpty))
                                                                          .map<Widget>((field) => DetailRow(
                                                                                label: field.customFieldName.toString().replaceAll('_', ' '),
                                                                                value: field.datavalue?.toString() ?? '',
                                                                              ))
                                                                          .toList()
                                                                      : [
                                                                          if ((leadProvider.customFieldEnquiryFor ?? [])
                                                                              .isEmpty)
                                                                            const Text('No additional details available')
                                                                        ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : ListView(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16.0),
                                                        children: [
                                                          // Duplicate cards for Mobile View
                                                          // Contact
                                                          CustomerCard(
                                                            title: "Contact",
                                                            content: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Divider(
                                                                  color: Colors
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.4),
                                                                  thickness:
                                                                      0.4,
                                                                  height: 1,
                                                                ),
                                                              ),
                                                              DetailRow(
                                                                  label:
                                                                      "Phone no",
                                                                  value: customerDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .contactNumber
                                                                      .toString()),
                                                            ],
                                                          ),
                                                          // // More Info
                                                          // CustomerCard(
                                                          //   title: "More Info",
                                                          //   content: [
                                                          //     Column(
                                                          //       crossAxisAlignment:
                                                          //           CrossAxisAlignment
                                                          //               .start,
                                                          //       children: [
                                                          //         DetailRow(
                                                          //             label:
                                                          //                 "Address",
                                                          //             value: customerDetailsProvider
                                                          //                     .leadDetails![0]
                                                          //                     .address ??
                                                          //                 ''),
                                                          //         const SizedBox(
                                                          //             height:
                                                          //                 2),
                                                          //         DetailRow(
                                                          //             label:
                                                          //                 "Enquiry For",
                                                          //             value: customerDetailsProvider
                                                          //                     .leadDetails![0]
                                                          //                     .enquiryForName ??
                                                          //                 ''),
                                                          //         const SizedBox(
                                                          //             height:
                                                          //                 2),
                                                          //         DetailRow(
                                                          //             label:
                                                          //                 "Enquiry Source",
                                                          //             value: customerDetailsProvider
                                                          //                     .leadDetails![0]
                                                          //                     .enquirySourceName ??
                                                          //                 ''),
                                                          //         const SizedBox(
                                                          //             height:
                                                          //                 2),
                                                          //         DetailRow(
                                                          //             label:
                                                          //                 "Consumer Number",
                                                          //             value: customerDetailsProvider
                                                          //                     .leadDetails![0]
                                                          //                     .consumerNumber ??
                                                          //                 ''),
                                                          //         const SizedBox(
                                                          //             height:
                                                          //                 2),
                                                          //         const Text(
                                                          //           "Location: ",
                                                          //           style: TextStyle(
                                                          //               color: Color(
                                                          //                   0xFF8E97A3)),
                                                          //         ),
                                                          //         Row(
                                                          //           children: [
                                                          //             Expanded(
                                                          //               child:
                                                          //                   InkWell(
                                                          //                 onTap:
                                                          //                     () {
                                                          //                   String
                                                          //                       locationData =
                                                          //                       customerDetailsProvider.leadDetails![0].location.toString();
                                                          //                   _openMaps(locationData);
                                                          //                 },
                                                          //                 child:
                                                          //                     Text(
                                                          //                   customerDetailsProvider.leadDetails![0].location.toString(),
                                                          //                   style:
                                                          //                       const TextStyle(color: Colors.blue),
                                                          //                   overflow:
                                                          //                       TextOverflow.ellipsis,
                                                          //                   maxLines:
                                                          //                       1,
                                                          //                 ),
                                                          //               ),
                                                          //             ),
                                                          //             IconButton(
                                                          //               color: Colors
                                                          //                   .grey,
                                                          //               onPressed:
                                                          //                   () {
                                                          //                 Clipboard
                                                          //                     .setData(
                                                          //                   ClipboardData(
                                                          //                     text: customerDetailsProvider.leadDetails![0].location.toString(),
                                                          //                   ),
                                                          //                 );
                                                          //                 ScaffoldMessenger.of(context)
                                                          //                     .showSnackBar(
                                                          //                   const SnackBar(
                                                          //                     content: Text('Link copied to clipboard!'),
                                                          //                   ),
                                                          //                 );
                                                          //               },
                                                          //               icon: const Icon(
                                                          //                   Icons.copy),
                                                          //             ),
                                                          //           ],
                                                          //         ),
                                                          //       ],
                                                          //     ),
                                                          //   ],
                                                          // ),
                                                          // Basic Information
                                                          CustomerCard(
                                                            title: "Basic",
                                                            content: [
                                                              DetailRow(
                                                                label:
                                                                    "Lead Name",
                                                                value: customerDetailsProvider
                                                                        .leadDetails![
                                                                            0]
                                                                        .customerName ??
                                                                    '',
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label: "Source",
                                                                value: customerDetailsProvider
                                                                        .leadDetails![
                                                                            0]
                                                                        .sourceCategoryName ??
                                                                    '',
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label:
                                                                    "Mobile No",
                                                                value: customerDetailsProvider
                                                                    .leadDetails![
                                                                        0]
                                                                    .contactNumber
                                                                    .toString(),
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label:
                                                                    "Enquiry Source",
                                                                value: customerDetailsProvider
                                                                        .leadDetails![
                                                                            0]
                                                                        .enquirySourceName ??
                                                                    '',
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label:
                                                                    "Enquiry For",
                                                                value: customerDetailsProvider
                                                                        .leadDetails![
                                                                            0]
                                                                        .enquiryForName ??
                                                                    '',
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label:
                                                                    "Sub Source",
                                                                value: customerDetailsProvider
                                                                    .leadDetails![
                                                                        0]
                                                                    .referenceName,
                                                              ),
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                label:
                                                                    "Total project cost :",
                                                                value: customerDetailsProvider
                                                                        .leadDetails![
                                                                            0]
                                                                        .totalProjectCost
                                                                        .toString() ??
                                                                    '',
                                                              ),
                                                            ],
                                                          ),
                                                          // Address Details
                                                          CustomerCard(
                                                            title:
                                                                "Address Details",
                                                            content: [
                                                              // Address
                                                              DetailRow(
                                                                  label:
                                                                      "Address",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .address ??
                                                                      ''),

                                                              // Place
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Place",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .address1 ??
                                                                      ''),

                                                              // State
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "State",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .address3 ??
                                                                      ''),

                                                              // Landmark
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Landmark",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .landmark ??
                                                                      ''),

                                                              // Pincode
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Pincode",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .pinCode ??
                                                                      ''),

                                                              // Latitude
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Latitude",
                                                                  value: customerDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .latitude
                                                                      .toString()),

                                                              // Longitude
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Longitude",
                                                                  value: customerDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .longitude
                                                                      .toString()),

                                                              // District
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "District",
                                                                  value: customerDetailsProvider
                                                                          .leadDetails![
                                                                              0]
                                                                          .districtName ??
                                                                      ''),

                                                              // Consumer Number
                                                              const SizedBox(
                                                                  height: 2),
                                                              DetailRow(
                                                                  label:
                                                                      "Consumer Number",
                                                                  value: customerDetailsProvider
                                                                      .leadDetails![
                                                                          0]
                                                                      .consumerNumber
                                                                      .toString()),
                                                              const SizedBox(
                                                                  height: 2),
                                                              const Text(
                                                                'Location',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xFF8E97A3)),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        String locationData = customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .location
                                                                            .toString();
                                                                        _openMaps(
                                                                            locationData);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        customerDetailsProvider
                                                                            .leadDetails![0]
                                                                            .location
                                                                            .toString(),
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.blue),
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        maxLines:
                                                                            1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    color: Colors
                                                                        .grey,
                                                                    onPressed:
                                                                        () async {
                                                                      final locStr =
                                                                          customerDetailsProvider.leadDetails![0].location.toString() ??
                                                                              '';
                                                                      if (locStr ==
                                                                              'null' ||
                                                                          locStr
                                                                              .trim()
                                                                              .isEmpty) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('No location available to copy')),
                                                                        );
                                                                        return;
                                                                      }
                                                                      await Clipboard.setData(
                                                                          ClipboardData(
                                                                              text: locStr));
                                                                      if (context
                                                                          .mounted) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(
                                                                          const SnackBar(
                                                                              content: Text('Link copied to clipboard!')),
                                                                        );
                                                                      }
                                                                    },
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .copy),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ), // Additional Details
                                                          Wrap(
                                                            spacing: 10,
                                                            runSpacing: 10,
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .center,
                                                            children: [
                                                              if (sideprovider
                                                                      .name !=
                                                                  'Lead /')
                                                                if (settingsprovider
                                                                            .menuIsDeleteMap[
                                                                        4] ==
                                                                    1)
                                                                  CustomElevatedButton(
                                                                    radius: 4,
                                                                    backgroundColor:
                                                                        AppColors
                                                                            .whiteColor,
                                                                    borderColor:
                                                                        AppColors
                                                                            .textRed,
                                                                    textColor:
                                                                        AppColors
                                                                            .textRed,
                                                                    buttonText:
                                                                        'Remove Registration',
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AlertDialog(
                                                                            title:
                                                                                const Text('Remove Registration'),
                                                                            content:
                                                                                const Text('Are you sure you want to Remove Registration '),
                                                                            actions: <Widget>[
                                                                              TextButton(
                                                                                child: const Text('Cancel'),
                                                                                onPressed: () {
                                                                                  Navigator.of(context).pop(); // Close the dialog
                                                                                },
                                                                              ),
                                                                              TextButton(
                                                                                child: const Text('Remove Registration'),
                                                                                onPressed: () {
                                                                                  customerDetailsProvider.removeRegister(widget.customerId, context);
                                                                                },
                                                                              ),
                                                                            ],
                                                                          );
                                                                        },
                                                                      );
                                                                    },
                                                                  ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          61] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'KSEB',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'KSEB PDF',
                                                                      onGenerate:
                                                                          () async {
                                                                        return await generateKsebPdfBytes(
                                                                              customerDetails: leadDetailsProvider.leadDetails!.first,
                                                                              context: context,
                                                                            ) ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          63] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Vendor Agreement',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Vendor Agreement',
                                                                      onGenerate:
                                                                          () async {
                                                                        return await generateVendorAgreementPdfBytes(
                                                                              customerDetails: leadDetailsProvider.leadDetails!.first,
                                                                              context: context,
                                                                            ) ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          62] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Vendor Feasibility',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Vendor Feasibility',
                                                                      onGenerate:
                                                                          () async {
                                                                        return await generateRtsFeasibilityReportPdfBytes(
                                                                              customerDetails: leadDetailsProvider.leadDetails!.first,
                                                                              context: context,
                                                                            ) ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          61] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Annexture1',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Annexture1',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfAnnexure1}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure1}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          63] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Annexture2',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Annexture 2',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfAnnexure2}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure2}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          62] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Annexture3',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Annexture 3',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfAnnexure3}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfAnnexure3}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          105] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Net meter Agreement',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Net meter Agreement',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfNetMeterAgreement}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          106] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'MNRE Agreement',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'MNRE Agreement',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfMnreAgreement}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfMnreAgreement}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          107] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Loan Agreement',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Loan Agreement',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfLoanAgreement}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfLoanAgreement}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          108] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Schedule',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Schedule',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfSchedule}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfSchedule}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          109] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Completion Report',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Completion Report',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfCompletionReport}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfCompletionReport}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          110] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'KSEB Net Meter',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'KSEB Net Meter',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfKsebNetMeter}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfKsebNetMeter}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          111] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Vendor Agreement A3s',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Vendor Agreement A3s',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfVendorAgreement}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfVendorAgreement}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (settingsprovider
                                                                              .menuIsViewMap[
                                                                          112] ==
                                                                      1 &&
                                                                  sideprovider
                                                                          .name !=
                                                                      'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor:
                                                                      AppColors
                                                                          .whiteColor,
                                                                  borderColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  textColor:
                                                                      AppColors
                                                                          .bluebutton,
                                                                  buttonText:
                                                                      'Warranty',
                                                                  onPressed:
                                                                      () async {
                                                                    PdfActionHelper
                                                                        .showPdfOptions(
                                                                      context:
                                                                          context,
                                                                      title:
                                                                          'Warranty',
                                                                      pdfUrl:
                                                                          '${HttpUrls.getPdfWarranty}${widget.customerId}',
                                                                      onGenerate:
                                                                          () async {
                                                                        await Loader.showLoader(
                                                                            context);
                                                                        final bytes =
                                                                            await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfWarranty}${widget.customerId}');
                                                                        Loader.stopLoader(
                                                                            context);
                                                                        return bytes ??
                                                                            Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (sideprovider.name != 'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor: AppColors.whiteColor,
                                                                  borderColor: AppColors.bluebutton,
                                                                  textColor: AppColors.bluebutton,
                                                                  buttonText: 'Work Completion Report',
                                                                  onPressed: () async {
                                                                    PdfActionHelper.showPdfOptions(
                                                                      context: context,
                                                                      title: 'Work Completion Report',
                                                                      pdfUrl: '${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}',
                                                                      onGenerate: () async {
                                                                        await Loader.showLoader(context);
                                                                        final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfWorkCompletionReport}${widget.customerId}');
                                                                        Loader.stopLoader(context);
                                                                        return bytes ?? Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                              if (sideprovider.name != 'Lead /')
                                                                CustomElevatedButton(
                                                                  radius: 4,
                                                                  backgroundColor: AppColors.whiteColor,
                                                                  borderColor: AppColors.bluebutton,
                                                                  textColor: AppColors.bluebutton,
                                                                  buttonText: 'Checklist',
                                                                  onPressed: () async {
                                                                    PdfActionHelper.showPdfOptions(
                                                                      context: context,
                                                                      title: 'Checklist',
                                                                      pdfUrl: '${HttpUrls.getPdfChecklist}${widget.customerId}',
                                                                      onGenerate: () async {
                                                                        await Loader.showLoader(context);
                                                                        final bytes = await customerDetailsProvider.getAnnexurePdfBytes('${HttpUrls.getPdfChecklist}${widget.customerId}');
                                                                        Loader.stopLoader(context);
                                                                        return bytes ?? Uint8List(0);
                                                                      },
                                                                    );
                                                                  },
                                                                ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              height: 20),
                                                          // ACTION BUTTONS (Moved here mobile)
                                                          CustomerCard(
                                                            title:
                                                                "Additional Details",
                                                            content: (leadProvider
                                                                            .customFieldEnquiryFor ??
                                                                        [])
                                                                    .isNotEmpty
                                                                ? (leadProvider
                                                                            .customFieldEnquiryFor ??
                                                                        [])
                                                                    .where((field) =>
                                                                        (field.customFieldName !=
                                                                                null &&
                                                                            field.customFieldName
                                                                                .toString()
                                                                                .isNotEmpty) &&
                                                                        (field.datavalue !=
                                                                                null &&
                                                                            field.datavalue
                                                                                .toString()
                                                                                .isNotEmpty))
                                                                    .map<Widget>(
                                                                        (field) =>
                                                                            DetailRow(
                                                                              label: field.customFieldName.toString().replaceAll('_', ' '),
                                                                              value: field.datavalue?.toString() ?? '',
                                                                            ))
                                                                    .toList()
                                                                : [
                                                                    if ((leadProvider.customFieldEnquiryFor ??
                                                                            [])
                                                                        .isEmpty)
                                                                      const Text(
                                                                          'No additional details available')
                                                                  ],
                                                          ),
                                                        ],
                                                      ))
                                                : Container(),
                                            // Summary Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[13] ==
                                                1)
                                              CustomerTaskOverviewTab(
                                                  customerId:
                                                      widget.customerId),

                                            // Tasks Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[13] ==
                                                1)
                                              customerDetailsProvider.isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        /* Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            if (AppStyles
                                                                .isWebScreen(
                                                                    context))
                                                              Expanded(
                                                                child:
                                                                    TaskChipsScroller(
                                                                  chips: [
                                                                    _buildTaskChip(
                                                                        'All tasks',
                                                                        null),
                                                                    ...dropDownProvider
                                                                        .taskType
                                                                        .map(
                                                                            (task) {
                                                                      return Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                8.0),
                                                                        child: _buildTaskChip(
                                                                            task.taskTypeName,
                                                                            task.taskTypeId),
                                                                      );
                                                                    }).toList(),
                                                                  ],
                                                                ),
                                                              )
                                                            // Expanded(
                                                            //   child: Container(
                                                            //     height: 40,
                                                            //     margin:
                                                            //         const EdgeInsets
                                                            //             .all(4.0),
                                                            //     padding:
                                                            //         const EdgeInsets
                                                            //             .symmetric(
                                                            //             horizontal:
                                                            //                 8),
                                                            //     decoration:
                                                            //         BoxDecoration(
                                                            //       color: const Color(
                                                            //           0xFFEFF2F5),
                                                            //       borderRadius:
                                                            //           BorderRadius
                                                            //               .circular(
                                                            //                   8),
                                                            //     ),
                                                            //     child:
                                                            //         ScrollConfiguration(
                                                            //       behavior: ScrollConfiguration.of(
                                                            //               context)
                                                            //           .copyWith(
                                                            //         scrollbars:
                                                            //             true,
                                                            //         dragDevices: {
                                                            //           PointerDeviceKind
                                                            //               .touch,
                                                            //           PointerDeviceKind
                                                            //               .mouse,
                                                            //         },
                                                            //       ),
                                                            //       child:
                                                            //           SingleChildScrollView(
                                                            //         scrollDirection:
                                                            //             Axis.horizontal,
                                                            //         child: Row(
                                                            //           children: [
                                                            //             _buildTaskChip(
                                                            //                 'All tasks',
                                                            //                 null),
                                                            //             ...dropDownProvider
                                                            //                 .taskType
                                                            //                 .map(
                                                            //                     (task) {
                                                            //               return Padding(
                                                            //                 padding: const EdgeInsets
                                                            //                     .only(
                                                            //                     left: 8.0),
                                                            //                 child: _buildTaskChip(
                                                            //                     task.taskTypeName,
                                                            //                     task.taskTypeId),
                                                            //               );
                                                            //             }).toList(),
                                                            //           ],
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //   ),
                                                            // )
                                                            else
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        30),
                                                              ),

                                                            // Create Task Button
                                                            if (settingsprovider
                                                                        .menuIsSaveMap[
                                                                    13] ==
                                                                1)
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child:
                                                                    ElevatedButton
                                                                        .icon(
                                                                  onPressed:
                                                                      () {
                                                                    customerDetailsProvider
                                                                            .customerId =
                                                                        widget
                                                                            .customerId;
                                                                    customerDetailsProvider
                                                                        .clearTaskDetails();
                                                                    showDialog(
                                                                      barrierDismissible:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return TaskCreationWidget(
                                                                          isEdit:
                                                                              false,
                                                                          taskId:
                                                                              '0',
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .add),
                                                                  label: const Text(
                                                                      'Create Task'),
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    backgroundColor:
                                                                        AppColors
                                                                            .primaryBlue,
                                                                    foregroundColor:
                                                                        Colors
                                                                            .white,
                                                                    padding: AppStyles.isWebScreen(
                                                                            context)
                                                                        ? const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                16,
                                                                            vertical:
                                                                                12)
                                                                        : const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal:
                                                                                16,
                                                                            vertical:
                                                                                0),
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),

                                                        */
                                                        // Filtered Task List
                                                        _buildFilteredTaskList(
                                                          onTap:
                                                              (taskMasterId) {
                                                            leadProvider.setCutomerId(
                                                                int.parse(widget
                                                                    .customerId));
                                                            print(
                                                                'Task ID: $taskMasterId');
                                                            customerDetailsProvider
                                                                .getTaskDetails(
                                                                    taskMasterId
                                                                        .toString(),
                                                                    context);
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                return TaskDetailsWidget(
                                                                  taskId: taskMasterId
                                                                      .toString(),
                                                                  customerId: widget
                                                                      .customerId
                                                                      .toString(),
                                                                );
                                                              },
                                                            );
                                                          },
                                                          taskTypeId:
                                                              selectedTaskTypeId,
                                                        )
                                                      ],
                                                    ),

                                            // Quotations Tab (can be customized as needed)
                                            if (settingsprovider
                                                    .menuIsViewMap[16] ==
                                                1)
                                              customerDetailsProvider.isLoading
                                                  ? const Center(
                                                      child:
                                                          CircularProgressIndicator())
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        // Display 4 Chips based on Task_Type_Id filter
                                                        // Display filtered task list
                                                        _buildFilteredQuatationList(
                                                          onTap: (quatationId) {
                                                            leadProvider.setCutomerId(
                                                                int.parse(widget
                                                                    .customerId));
                                                            print(
                                                                'Quotation ID: $quatationId');
                                                            customerDetailsProvider
                                                                .getQuatationListByMasterId(
                                                                    quatationId
                                                                        .toString(),
                                                                    context);
                                                            // _scaffoldKey.currentState
                                                            //     ?.openEndDrawer();
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return QuotationDetailsWidget(
                                                                    customerId:
                                                                        widget
                                                                            .customerId,
                                                                    serviceId:
                                                                        quatationId
                                                                            .toString(),
                                                                  );
                                                                },
                                                              ),
                                                            );
                                                          },
                                                          quatationId:
                                                              selectedQuotationStatusId,
                                                        )
                                                      ],
                                                    ),

                                            //Documents Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[19] ==
                                                1)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Documents',
                                                          style: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: const Color(
                                                                0xFF1E293B),
                                                          ),
                                                        ),
                                                        if (settingsprovider
                                                                    .menuIsSaveMap[
                                                                19] ==
                                                            1)
                                                          GestureDetector(
                                                            onTap: () {
                                                              showDialog(
                                                                barrierDismissible:
                                                                    false,
                                                                context:
                                                                    context,
                                                                builder: (context) =>
                                                                    ImageUploadAlert(
                                                                        customerId:
                                                                            widget.customerId),
                                                              );
                                                            },
                                                            child: Container(
                                                              width: 44,
                                                              height: 44,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .secondaryBlue,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    color: AppColors
                                                                        .secondaryBlue
                                                                        .withOpacity(
                                                                            0.3),
                                                                    blurRadius:
                                                                        8,
                                                                    offset:
                                                                        const Offset(
                                                                            0,
                                                                            4),
                                                                  ),
                                                                ],
                                                              ),
                                                              child: const Icon(
                                                                Icons
                                                                    .add_rounded,
                                                                color: Colors
                                                                    .white,
                                                                size: 26,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 16),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        itemCount:
                                                            customerDetailsProvider
                                                                .documentList
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          var userData =
                                                              customerDetailsProvider
                                                                      .documentList[
                                                                  index];
                                                          userData.userName;
                                                          List<ImageDetail>
                                                              images = userData
                                                                  .imageDetails;

                                                          return Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom:
                                                                        24.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                // Header: Uploaded By
                                                                Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius:
                                                                          14,
                                                                      backgroundColor:
                                                                          getAvatarColor(
                                                                              userData.userName),
                                                                      child:
                                                                          Text(
                                                                        userData.userName.isNotEmpty
                                                                            ? userData.userName[0].toUpperCase()
                                                                            : 'U',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      'Uploaded By ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w500,
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              AppColors.textGrey4),
                                                                    ),
                                                                    Text(
                                                                      userData
                                                                          .userName,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            14,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                    height: 12),
                                                                // Images List
                                                                Builder(builder:
                                                                    (context) {
                                                                  final isWeb =
                                                                      AppStyles
                                                                          .isWebScreen(
                                                                              context);
                                                                  final imageSize =
                                                                      isWeb
                                                                          ? 140.0
                                                                          : 100.0;

                                                                  final imageWidgets = images
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final index =
                                                                        entry
                                                                            .key;
                                                                    final image =
                                                                        entry
                                                                            .value;
                                                                    return SizedBox(
                                                                      width:
                                                                          imageSize,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Stack(
                                                                            children: [
                                                                              Center(
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    int currentIndex = index;
                                                                                    _showFullScreenImage(context, currentIndex, images, true);
                                                                                  },
                                                                                  child: ClipRRect(
                                                                                    borderRadius: BorderRadius.circular(4),
                                                                                    child: Image.network(
                                                                                      image.filePath,
                                                                                      width: imageSize,
                                                                                      height: imageSize,
                                                                                      fit: BoxFit.cover,
                                                                                      loadingBuilder: (context, child, loadingProgress) {
                                                                                        if (loadingProgress == null) return child;
                                                                                        return SizedBox(
                                                                                          height: imageSize,
                                                                                          width: imageSize,
                                                                                          child: Center(
                                                                                            child: CircularProgressIndicator(
                                                                                              value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                                        return GestureDetector(
                                                                                          onTap: () async {
                                                                                            final Uri url = Uri.parse(image.filePath);
                                                                                            try {
                                                                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                                                                            } catch (e) {
                                                                                              print('Could not launch $url: $e');
                                                                                            }
                                                                                          },
                                                                                          child: Container(
                                                                                            color: Colors.grey[200],
                                                                                            width: imageSize,
                                                                                            height: imageSize,
                                                                                            child: const Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                Icon(Icons.picture_as_pdf, color: Colors.red, size: 40),
                                                                                                SizedBox(height: 2),
                                                                                                Text('Open PDF', style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 10)),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Positioned(
                                                                                top: 5,
                                                                                right: 5,
                                                                                child: Row(
                                                                                  mainAxisSize: MainAxisSize.min,
                                                                                  children: [
                                                                                    GestureDetector(
                                                                                      onTap: () async {
                                                                                        try {
                                                                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading file...')));
                                                                                          final downloadedPath = await FileDownloader.download(image.filePath);
                                                                                          if (context.mounted) {
                                                                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloaded to $downloadedPath')));
                                                                                          }
                                                                                        } catch (e) {
                                                                                          if (context.mounted) {
                                                                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to download file')));
                                                                                          }
                                                                                        }
                                                                                      },
                                                                                      child: const CircleAvatar(
                                                                                        radius: 12,
                                                                                        backgroundColor: AppColors.whiteColor,
                                                                                        child: Icon(Icons.download, size: 20, color: AppColors.primaryBlue),
                                                                                      ),
                                                                                    ),
                                                                                    if (settingsprovider.menuIsDeleteMap[19] == 1) ...[
                                                                                      const SizedBox(width: 4),
                                                                                      GestureDetector(
                                                                                        onTap: () {
                                                                                          showConfirmationDialog(
                                                                                            isLoading: customerDetailsProvider.isDeleteLoading,
                                                                                            context: context,
                                                                                            title: 'Confirm Deletion',
                                                                                            content: 'Are you sure you want to delete this file?',
                                                                                            onCancel: () {
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            onConfirm: () {
                                                                                              customerDetailsProvider.deleteImage(context, image.imageId.toString(), widget.customerId);
                                                                                              Navigator.of(context).pop();
                                                                                            },
                                                                                            confirmButtonText: 'Delete',
                                                                                          );
                                                                                        },
                                                                                        child: const CircleAvatar(
                                                                                          radius: 12,
                                                                                          backgroundColor: AppColors.whiteColor,
                                                                                          child: Icon(Icons.delete, size: 20, color: AppColors.textRed),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 6),
                                                                          if (image.isVerified ==
                                                                              '1') ...[
                                                                            Row(
                                                                              children: [
                                                                                Icon(
                                                                                  Icons.check,
                                                                                  color: Colors.green,
                                                                                ),
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    "Verified by ${image.verifiedName}",
                                                                                    style: TextStyle(fontSize: 12, color: AppColors.textBlack),
                                                                                    textAlign: TextAlign.left,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Text(
                                                                              DateFormat('dd/MM/yyyy h:mm a').format(DateTime.parse(image.verifiedDate)),
                                                                              style: TextStyle(fontSize: 10, color: AppColors.textGrey4),
                                                                              textAlign: TextAlign.center,
                                                                            ),
                                                                          ] else if (settingsprovider.menuIsViewMap[176] ==
                                                                              1)
                                                                            Row(
                                                                              children: [
                                                                                Expanded(
                                                                                  child: Text(
                                                                                    "Verification Pending",
                                                                                    style: TextStyle(fontSize: 10, color: AppColors.textBlack, fontWeight: FontWeight.w600),
                                                                                    textAlign: TextAlign.center,
                                                                                    maxLines: 2,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: 10,
                                                                                ),
                                                                                Expanded(
                                                                                  child: CustomElevatedButton(
                                                                                    onPressed: () {
                                                                                      customerDetailsProvider.verifyDocument(image.imageId, context);
                                                                                    },
                                                                                    buttonText: 'Verify',
                                                                                    backgroundColor: AppColors.primaryBlue,
                                                                                    textColor: AppColors.whiteColor,
                                                                                    borderColor: AppColors.primaryBlue,
                                                                                    textSize: 12,
                                                                                    horizontalPadding: 2,
                                                                                    verticalPadding: 2,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          const SizedBox(
                                                                              height: 10),
                                                                          Text(
                                                                            image.documentTypeName,
                                                                            style:
                                                                                TextStyle(fontSize: 12, color: AppColors.textBlack),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                          Text(
                                                                            DateFormat('dd/MM/yyyy h:mm a').format(DateTime.parse(image.entryDate)),
                                                                            style:
                                                                                TextStyle(fontSize: 10, color: AppColors.textGrey4),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          ),
                                                                          Text(
                                                                            image.description,
                                                                            style:
                                                                                TextStyle(fontSize: 12, color: AppColors.textBlack),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList();

                                                                  return MouseRegion(
                                                                    cursor:
                                                                        SystemMouseCursors
                                                                            .click,
                                                                    child: isWeb
                                                                        ? SizedBox(
                                                                            width:
                                                                                double.infinity,
                                                                            child:
                                                                                Wrap(
                                                                              spacing: 16,
                                                                              runSpacing: 16,
                                                                              children: imageWidgets,
                                                                            ),
                                                                          )
                                                                        : SizedBox(
                                                                            height:
                                                                                160,
                                                                            child:
                                                                                Scrollbar(
                                                                              controller: customerDetailsProvider.imageScrollController,
                                                                              thumbVisibility: true,
                                                                              child: ListView.separated(
                                                                                controller: customerDetailsProvider.imageScrollController,
                                                                                scrollDirection: Axis.horizontal,
                                                                                separatorBuilder: (context, index) => const SizedBox(width: 12),
                                                                                physics: const ClampingScrollPhysics(),
                                                                                itemCount: imageWidgets.length,
                                                                                itemBuilder: (context, index) => imageWidgets[index],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  );
                                                                })
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            //Forms
                                            if (settingsprovider
                                                    .menuIsViewMap[85] ==
                                                1)
                                              FormsTabWidget(
                                                  customerId:
                                                      widget.customerId),

                                            // Complaints Tab (can be customized as needed)
                                            if (settingsprovider
                                                    .menuIsViewMap[14] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                customerDetailsProvider
                                                        .isLoading
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // Display 4 Chips based on Task_Type_Id filter
                                                          // Display filtered task list
                                                          _buildFilteredServiceList(
                                                            onTap: (serviceId) {
                                                              leadProvider
                                                                  .setCutomerId(
                                                                      int.parse(
                                                                          widget
                                                                              .customerId));
                                                              print(
                                                                  'Service ID: $serviceId');
                                                              customerDetailsProvider
                                                                  .getServiceDetails(
                                                                      serviceId
                                                                          .toString(),
                                                                      context);
                                                              // _scaffoldKey.currentState
                                                              //     ?.openEndDrawer();
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return ServiceDetailsWidget(
                                                                    customerId:
                                                                        widget
                                                                            .customerId,
                                                                    serviceId:
                                                                        serviceId
                                                                            .toString(),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            serviceId:
                                                                selectedServiceStatusId,
                                                          )
                                                        ],
                                                      ),

                                            // Periodic Service Tab (can be customized as needed)
                                            if (settingsprovider
                                                    .menuIsViewMap[15] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                customerDetailsProvider
                                                        .isLoading
                                                    ? const Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              AppStyles.isWebScreen(
                                                                      context)
                                                                  ? Container(
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: const Color(
                                                                            0xFFEFF2F5),
                                                                        borderRadius:
                                                                            BorderRadius.circular(4),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                        child:
                                                                            Wrap(
                                                                          spacing:
                                                                              8.0, // Space between chips
                                                                          runSpacing:
                                                                              4.0, // Space between rows
                                                                          children: [
// _buildAMCChip('All Periodic Service',
//     null), // All tasks (no filter)
// Wrap(
//   spacing: 8.0, // Space between chips
//   runSpacing: 4.0,
//   children: dropDownProvider.amcStatus.map((task) {
//     return _buildAMCChip(task.amcStatusName, task.amcStatusId);
//   }).toList(),
// ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          30),
                                                                    ),
                                                            ],
                                                          ),
                                                          // const SizedBox(
                                                          //   height: 16,
                                                          // ),
                                                          _buildAmcTaskWidget(
                                                            onTap: (taskId,
                                                                productName,
                                                                service,
                                                                entryDate,
                                                                amount,
                                                                description,
                                                                amcStatus,
                                                                customerName,
                                                                amcId,
                                                                fromDate,
                                                                toDate,
                                                                amc) {
                                                              leadProvider
                                                                  .setCutomerId(
                                                                      int.parse(
                                                                          widget
                                                                              .customerId));
                                                              print(
                                                                  'Task ID: $taskId');

                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return AmcWidget(
                                                                    onPressed:
                                                                        () {
                                                                      customerDetailsProvider
                                                                              .customerId =
                                                                          widget
                                                                              .customerId;
                                                                      showDialog(
                                                                        barrierDismissible:
                                                                            false,
                                                                        context:
                                                                            context,
                                                                        builder:
                                                                            (BuildContext
                                                                                context) {
                                                                          return AmcCreationWidget(
                                                                              amcId: amcId.toString(),
                                                                              amcAmountController: amount,
                                                                              amcDescriptionController: description,
                                                                              amcProductNameController: productName,
                                                                              amcServiceController: service,
                                                                              fromDateController: fromDate,
                                                                              toDateController: toDate,
                                                                              customerId: widget.customerId,
                                                                              amc: amc,
                                                                              isEdit: true);
                                                                        },
                                                                      );
                                                                    },
                                                                    customerName:
                                                                        customerName,
                                                                    customerStatus:
                                                                        amcStatus,
                                                                    amount:
                                                                        '₹${double.parse(amount)}',
                                                                    description:
                                                                        description,
                                                                    productName:
                                                                        productName,
                                                                    service:
                                                                        service,
                                                                    entryDate:
                                                                        entryDate,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            amcId:
                                                                selectedAmcStatusId,
                                                          )
                                                        ],
                                                      ),

                                            // Follow-Up Details Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[100] ==
                                                1)
                                              const FollowUpTabWidget(),

                                            //Reciepts Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[18] ==
                                                1)
                                                ReceiptScreen(
                                                    widget.customerId),

                                            //Expense Tab
                                            if (settingsprovider
                                                    .menuIsViewMap[48] ==
                                                1)
                                              ExpenseScreen(widget.customerId),

                                            //CheckList Management
                                            if (settingsprovider
                                                    .menuIsViewMap[37] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                CheckListManagementWidget(
                                                    key: _checklistKey,
                                                    customerId:
                                                        widget.customerId),

                                            //Payment Schedule
                                            if (settingsprovider
                                                    .menuIsViewMap[70] ==
                                                1)
                                              PaymentScheduleTabWidget(
                                                  customerId:
                                                      widget.customerId),
                                            // Payment Tab (New)
                                            if (settingsprovider
                                                    .menuIsViewMap[81] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                PaymentTabWidget(
                                                    customerId:
                                                        widget.customerId),

                                            //Refund Form
                                            if (settingsprovider
                                                    .menuIsViewMap[71] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                RefundFormPage(
                                                    widget.customerId),

                                            if (settingsprovider
                                                    .menuIsViewMap[21] ==
                                                1)
                                              InvoiceTabPage(
                                                  customerId:
                                                      widget.customerId),

                                            if (settingsprovider
                                                    .menuIsViewMap[78] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                StockUsePage(
                                                    customerId: int.parse(
                                                  widget.customerId,
                                                )),
                                            if (settingsprovider
                                                    .menuIsViewMap[79] ==
                                                1)
                                              if (sideprovider.name != 'Lead /')
                                                StockReturnPage(
                                                    customerId: int.parse(
                                                  widget.customerId,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildFilteredServiceList(
      {int? serviceId, void Function(int)? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    var filteredService = serviceId == null
        ? customerDetailsProvider.serviceList
        : customerDetailsProvider.serviceList
            .where((task) => task.serviceStatusId == serviceId)
            .toList();

    if (customerDetailsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return filteredService.isEmpty
        ? const Center(child: Text("No Complaints available."))
        : Expanded(
            child: ListView.builder(
              itemCount: filteredService.length,
              itemBuilder: (context, taskIndex) {
                var task = filteredService[taskIndex];
                return GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap(task.serviceId);
                      customerDetailsProvider.setServiceEditDropDown(
                          task.serviceTypeId,
                          task.serviceTypeName,
                          task.serviceStatusId,
                          task.serviceStatusName);
                      customerDetailsProvider.taskDescriptionController.text =
                          task.description.toString();
                      customerDetailsProvider.serviceController.text =
                          task.serviceName.toString();
                      customerDetailsProvider.serviceAmountController.text =
                          task.amount.toString();
                    }
                  },
                  child: ServiceCard(
                    category: "3",
                    taskId: task.serviceId.toString(),
                    title: task.serviceTypeName.toString(),
                    servicename: task.serviceName.toString(),
                    serviceno: task.serviceNo.toString(),
                    date: task.serviceDate.toString(),
                    status: task.serviceStatusName.toString(),
                    posted: task.createDate.toString(),
                    serviceTypeId: task.serviceTypeId,
                    serviceTypeName: task.serviceTypeName,
                    serviceStatusId: task.serviceStatusId,
                    description: task.description.toString(),
                    customerId: widget.customerId.toString(),
                    amount: task.amount.toString(),
                  ),
                );
              },
            ),
          );
  }

  //amc
  // Widget _buildAMCChip(String label, int? taskTypeId) {
  //   return FilterChip(
  //     label: Text(
  //       label,
  //       style: TextStyle(
  //         fontWeight: FontWeight.bold, // Make text bold
  //         fontSize: 14,
  //         color: selectedAmcStatusId == taskTypeId
  //             ? AppColors.primaryBlue
  //             : const Color(0xFF607085),
  //       ),
  //     ),
  //     selected: selectedAmcStatusId == taskTypeId,
  //     onSelected: (bool selected) {
  //       setState(() {
  //         selectedAmcStatusId =
  //             selected ? taskTypeId : null; // Update the selectedTaskTypeId
  //       });
  //     },
  //     backgroundColor:
  //         const Color(0xFFEFF2F5), // Color when the chip is selected
  //     selectedColor: Colors.white, // Color when the chip is unselected
  //     showCheckmark: false, // Removes the tick mark
  //     shape: RoundedRectangleBorder(
  //       // Removes the border by making it flat
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     side: BorderSide.none, // Ensures no border is displayed
  //     elevation: 0, // Removes the elevation
  //   );
  // }

  Widget _buildAmcTaskWidget(
      {int? amcId,
      void Function(
        int taskId,
        String productName,
        String service,
        String entryDate,
        String amount,
        String description,
        String amcStatus,
        String customerName,
        String amcId,
        String fromDate,
        String toDate,
        AmcReportModeld amc,
      )? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    var filteredAmcList = amcId == null
        ? customerDetailsProvider.amcList
        : customerDetailsProvider.amcList
            .where((task) => task.amcStatusId == amcId)
            .toList();

    const borderColor = Color(0xFFE9EDF1);

    return filteredAmcList.isEmpty
        ? const CommonEmptyState(message: 'No Periodic Service found.')
        : Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: borderColor),
                  left: BorderSide(color: borderColor),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeaderCell('#', width: 50.0),
                        _buildHeaderCell('Service Name', flex: 2),
                        _buildHeaderCell('Product Name', flex: 2),
                        _buildHeaderCell('Category', flex: 2),
                        _buildHeaderCell('Amount', flex: 2),
                        _buildHeaderCell('To Date', flex: 2),
                        _buildHeaderCell('Options', flex: 2),
                      ],
                    ),
                  ),
                  // List
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredAmcList.length,
                      itemBuilder: (context, index) {
                        var amc = filteredAmcList[index];
                        return GestureDetector(
                          onTap: () {
                            if (onTap != null) {
                              onTap(
                                  amc.amcId,
                                  amc.productName,
                                  amc.serviceName,
                                  amc.date.toString(),
                                  amc.amount,
                                  amc.description,
                                  amc.amcStatusName,
                                  amc.customerName,
                                  amc.amcId.toString(),
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(amc.fromDate.toString())),
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.parse(amc.toDate.toString())),
                                  amc);
                            }
                          },
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDataCell((index + 1).toString(),
                                    width: 50.0),
                                _buildDataCell(amc.serviceName,
                                    flex: 2, isBold: true),
                                _buildDataCell(amc.productName, flex: 2),
                                _buildDataCell(
                                    amc.categoryName.isNotEmpty
                                        ? amc.categoryName
                                        : 'AMC',
                                    flex: 2),
                                _buildDataCell("₹${double.parse(amc.amount)}",
                                    flex: 2),
                                _buildDataCell(
                                    DateFormat('dd MMM yyyy')
                                        .format(DateTime.parse(amc.toDate)),
                                    flex: 2),
                                _buildWidgetCell(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (settingsprovider.menuIsEditMap[15] ==
                                          1)
                                        IconButton(
                                          tooltip: 'Edit',
                                          icon: const Icon(Icons.edit,
                                              size: 20, color: Colors.blue),
                                          onPressed: () {
                                            customerDetailsProvider.customerId =
                                                widget.customerId;
                                            customerDetailsProvider
                                                .setAmcDropDown(amc.amcStatusId,
                                                    amc.amcStatusName);

                                            showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AmcCreationWidget(
                                                    amcId: amc.amcId.toString(),
                                                    amcAmountController:
                                                        amc.amount,
                                                    amcDescriptionController:
                                                        amc.description,
                                                    amcProductNameController:
                                                        amc.productName,
                                                    amcServiceController:
                                                        amc.serviceName,
                                                    fromDateController:
                                                        DateFormat('dd-MM-yyyy')
                                                            .format(DateTime.parse(
                                                                amc.fromDate
                                                                    .toString())),
                                                    toDateController: DateFormat(
                                                            'dd-MM-yyyy')
                                                        .format(DateTime.parse(
                                                            amc.toDate
                                                                .toString())),
                                                    customerId:
                                                        widget.customerId,
                                                    amc: amc,
                                                    isEdit: true);
                                              },
                                            );
                                          },
                                        ),
                                      if (settingsprovider
                                              .menuIsDeleteMap[15] ==
                                          1)
                                        IconButton(
                                          tooltip: 'Delete',
                                          icon: const Icon(Icons.delete,
                                              size: 20, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return ConfirmationDialog(
                                                  title:
                                                      'Delete Periodic Service',
                                                  content:
                                                      'Are you sure you want to delete this service?',
                                                  onCancel: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  onConfirm: () {
                                                    Navigator.of(context).pop();
                                                    customerDetailsProvider
                                                        .deleteAMC(
                                                            amc.amcId
                                                                .toString(),
                                                            widget.customerId,
                                                            context);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                        ),
                                    ],
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
          );
  }

// Method to build filtered task list based on task type ID
  Widget _buildFilteredTaskList({int? taskTypeId, void Function(int)? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    var filteredTasks = taskTypeId == null
        ? customerDetailsProvider.taskList
        : customerDetailsProvider.taskList
            .where((task) => task.taskTypeId == taskTypeId)
            .toList();

    const borderColor = Color(0xFFE9EDF1);

    if (customerDetailsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return filteredTasks.isEmpty
        ? const Center(child: Text("No tasks available."))
        : !AppStyles.isWebScreen(context)
            ? Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    var task = filteredTasks[index];
                    return TaskCard(
                      task: task,
                    );
                  },
                ),
              )
            : Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: borderColor),
                      left: BorderSide(color: borderColor),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderCell('#', width: 50.0),
                            _buildHeaderCell('Tasks', flex: 2),
                            _buildHeaderCell('Action Required', flex: 3),
                            _buildHeaderCell('Schedule', flex: 2),
                            _buildHeaderCell('Created Date', flex: 2),
                            _buildHeaderCell('Status', flex: 1),
                            _buildHeaderCell('Options', flex: 1),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            var task = filteredTasks[index];
                            return GestureDetector(
                              onTap: () {
                                if (onTap != null) {
                                  onTap(task.taskMasterId);
                                  customerDetailsProvider.setTaskEditDropDown(
                                      task.taskTypeId,
                                      task.taskTypeName,
                                      task.toUserId,
                                      task.toUsername,
                                      task.taskStatusId,
                                      task.taskStatusName);
                                  customerDetailsProvider
                                      .taskDescriptionController
                                      .text = task.description.toString();
                                  customerDetailsProvider
                                      .taskChoosedateController
                                      .text = task.taskDate.toString() !=
                                              'null' &&
                                          task.taskDate.toString().isNotEmpty
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(
                                              task.taskDate.toString()))
                                      : '';
                                  customerDetailsProvider
                                      .taskChoosetimeController
                                      .text = task.taskTime.toString();
                                }
                              },
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildDataCell((index + 1).toString(),
                                        width: 50.0),
                                    _buildDataCell(task.taskTypeName,
                                        flex: 2, isBold: true),
                                    _buildWidgetCell(
                                      flex: 3,
                                      child: Builder(builder: (context) {
                                        String assignedTo = task.toUsername;

                                        if (assignedTo.isEmpty ||
                                            assignedTo == 'null') {
                                          // First try to look up by ID from DropDownProvider
                                          final dropDownProvider =
                                              Provider.of<DropDownProvider>(
                                                  context,
                                                  listen: false);
                                          if (task.toUserId > 0 &&
                                              dropDownProvider.searchUserDetails
                                                  .isNotEmpty) {
                                            final user = dropDownProvider
                                                .searchUserDetails
                                                .firstWhere(
                                              (u) =>
                                                  u.userDetailsId ==
                                                  task.toUserId, // Assuming userDetailsId is int
                                              orElse: () => dropDownProvider
                                                  .searchUserDetails.first,
                                            );
                                            // check if we actually found a match or just the first one (dummy)
                                            if (user.userDetailsId ==
                                                task.toUserId) {
                                              assignedTo =
                                                  user.userDetailsName ?? '';
                                            }
                                          }

                                          // If still empty, check taskUser list
                                          if ((assignedTo.isEmpty ||
                                                  assignedTo == 'null') &&
                                              task.taskUser.isNotEmpty) {
                                            assignedTo = task.taskUser
                                                .map((e) => e.toUsername)
                                                .join(', ');
                                          }
                                        }
                                        return Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 4,
                                              backgroundColor: getAvatarColor(
                                                  assignedTo.isNotEmpty
                                                      ? assignedTo
                                                      : 'A'),
                                              child: Text(
                                                (assignedTo.isNotEmpty
                                                        ? assignedTo
                                                        : 'A')[0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                                child: Text(assignedTo,
                                                    overflow:
                                                        TextOverflow.ellipsis)),
                                          ],
                                        );
                                      }),
                                    ),
                                    _buildDataCell(
                                        task.taskDate.toString() != 'null'
                                            ? DateFormat('dd MMM yyyy')
                                                .format(task.taskDate)
                                            : '',
                                        flex: 2),
                                    _buildDataCell(
                                        task.entryDate != null
                                            ? DateFormat('dd MMM yyyy')
                                                .format(task.entryDate!)
                                            : '',
                                        flex: 2),
                                    _buildWidgetCell(
                                      flex: 1,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: StatusUtils.getTaskColor(
                                                task.taskStatusId),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            task.taskStatusName,
                                            style: TextStyle(
                                              color:
                                                  StatusUtils.getTaskTextColor(
                                                      task.taskStatusId),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    _buildWidgetCell(
                                      flex: 1,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (settingsprovider
                                                  .menuIsEditMap[13] ==
                                              1)
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  size: 20, color: Colors.blue),
                                              onPressed: () {
                                                if (onTap != null) {
                                                  // onTap(task.taskMasterId); // Removed to prevent navigation
                                                  customerDetailsProvider
                                                      .setTaskEditDropDown(
                                                          task.taskTypeId,
                                                          task.taskTypeName,
                                                          task.toUserId,
                                                          task.toUsername,
                                                          task.taskStatusId,
                                                          task.taskStatusName);
                                                  customerDetailsProvider
                                                          .taskDescriptionController
                                                          .text =
                                                      task.description
                                                          .toString();
                                                  customerDetailsProvider
                                                      .taskChoosedateController
                                                      .text = task.taskDate
                                                                  .toString() !=
                                                              'null' &&
                                                          task.taskDate
                                                              .toString()
                                                              .isNotEmpty
                                                      ? DateFormat(
                                                              'dd MMM yyyy')
                                                          .format(DateTime
                                                              .parse(task
                                                                  .taskDate
                                                                  .toString()))
                                                      : '';
                                                  customerDetailsProvider
                                                          .taskChoosetimeController
                                                          .text =
                                                      task.taskTime.toString();
                                                  customerDetailsProvider
                                                          .addTaskModel.taskUser =
                                                      task.taskUser
                                                          .map((e) =>
                                                              UserInTaskModel(
                                                                userDetailsId:
                                                                    e.toUserId,
                                                                userDetailsName:
                                                                    e.toUsername,
                                                              ))
                                                          .toList();

                                                  // Open TaskCreationWidget in edit mode
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return TaskCreationWidget(
                                                        isEdit: true,
                                                        taskId: task.taskId
                                                            .toString(),
                                                        task: task,
                                                      );
                                                    },
                                                  );
                                                }
                                              },
                                            ),
                                          if (settingsprovider
                                                  .menuIsDeleteMap[13] ==
                                              1)
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  size: 20, color: Colors.red),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return ConfirmationDialog(
                                                      title: 'Delete Task',
                                                      content:
                                                          'Are you sure you want to delete this task?',
                                                      onCancel: () =>
                                                          Navigator.of(context)
                                                              .pop(),
                                                      onConfirm: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                        customerDetailsProvider
                                                            .deleteTask(
                                                                task.taskId
                                                                    .toString(),
                                                                widget
                                                                    .customerId,
                                                                context);
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                        ],
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
              );
  }

  Widget _buildHeaderCell(String text,
      {int flex = 1, bool isAction = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: isAction
          ? const Center(child: Icon(Icons.add, color: Colors.grey, size: 20))
          : Text(
              text,
              style: const TextStyle(
                color: Color(0xFF7D8B9B),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildDataCell(String text,
      {int flex = 1, bool isBold = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
            color: AppColors.textBlack,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return Expanded(
      flex: flex,
      child: child,
    );
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1}) {
    const borderColor = Color(0xFFE9EDF1);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _buildFilteredQuatationList(
      {int? quatationId, void Function(int)? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);

    var filteredQuotations = quatationId == null
        ? customerDetailsProvider.quotationList
        : customerDetailsProvider.quotationList
            .where((task) => task.quotationStatusId == quatationId)
            .toList();

    const borderColor = Color(0xFFE9EDF1);

    if (customerDetailsProvider.isQuotationListLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return filteredQuotations.isEmpty
        ? const Center(child: Text("No Quotations available."))
        : !AppStyles.isWebScreen(context)
            ? Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredQuotations.length,
                  itemBuilder: (context, index) {
                    var task = filteredQuotations[index];
                    return QuotationCard(
                      category: task.quotationTypeId.toString(),
                      taskId: task.quotationMasterId.toString(),
                      title: task.productName,
                      statusId: task.quotationStatusId.toString(),
                      status: task.quotationStatusName,
                      createdBy: task.createdByName,
                      posted: task.entryDate?.toString() ?? '',
                      customerId: widget.customerId,
                      servicename: '',
                      warranty: task.warranty,
                      terms: task.termsAndConditions,
                      subsidy: task.subsidyAmount,
                      quotation_details: task.quotationDetails ?? [],
                      bill_of_materials: task.billOfMaterials ?? [],
                      productionChartModel: task.productionChartModel ?? [],
                      advancePercentage: task.advancePercentage,
                      deliveryPercentage: task.onDeliveryPercentage,
                      completionPercentage: task.workCompletionPercentage,
                      quotation: task,
                    );
                  },
                ),
              )
            : Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: filteredQuotations.map((task) {
                        return SizedBox(
                          width: 350,
                          child: QuotationCard(
                            category: task.quotationTypeId.toString(),
                            taskId: task.quotationMasterId.toString(),
                            title: task.productName,
                            statusId: task.quotationStatusId.toString(),
                            status: task.quotationStatusName,
                            createdBy: task.createdByName,
                            posted: task.entryDate?.toString() ?? '',
                            customerId: widget.customerId,
                            servicename: '',
                            warranty: task.warranty,
                            terms: task.termsAndConditions,
                            subsidy: task.subsidyAmount,
                            quotation_details: task.quotationDetails ?? [],
                            bill_of_materials: task.billOfMaterials ?? [],
                            productionChartModel:
                                task.productionChartModel ?? [],
                            advancePercentage: task.advancePercentage,
                            deliveryPercentage: task.onDeliveryPercentage,
                            completionPercentage: task.workCompletionPercentage,
                            quotation: task,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
  }

  Future<void> _handleEditQuotation(
      String taskId, CustomerDetailsProvider customerDetailsProvider) async {
    await customerDetailsProvider.getQuatationListByMasterId(taskId, context);
    final quotation = customerDetailsProvider.quotationListByMaster.first;

    // ---- BASIC DETAILS ----
    customerDetailsProvider.customerId = widget.customerId;
    customerDetailsProvider.qproductnameController.text = quotation.productName;
    customerDetailsProvider.advanceController.text =
        quotation.advancePercentage;
    customerDetailsProvider.deliveryController.text =
        quotation.onDeliveryPercentage;
    customerDetailsProvider.workCompletionController.text =
        quotation.workCompletionPercentage;
    customerDetailsProvider.qsubsidyAmountController.text =
        quotation.subsidyAmount;
    customerDetailsProvider.qwarrentyController.text = quotation.warranty;
    customerDetailsProvider.qtermsConditionsController.text =
        quotation.termsAndConditions;
    customerDetailsProvider.quotationDescriptionController.text =
        quotation.description;
    customerDetailsProvider.quotationDescription2Controller.text =
        quotation.description2;
    customerDetailsProvider.quotationDescription3Controller.text =
        quotation.description3;

    // ---- STATUS ----
    customerDetailsProvider.selectedQuotationStatus =
        quotation.quotationStatusId;
    customerDetailsProvider.selectedQuotationStatusName =
        quotation.quotationStatusName;

    // ---- FEES ----
    customerDetailsProvider.registrationFeeController.text =
        quotation.ksebRegistrationFee.toString();
    customerDetailsProvider.feasibilityFeeController.text =
        quotation.ksebFeasibilityFee.toString();
    customerDetailsProvider.systemPriceController.text =
        quotation.ksebSystemPrice.toString();
    customerDetailsProvider.additionalStructureController.text =
        quotation.additionalStructure.toString();

    // ---- TOTALS ----
    customerDetailsProvider.subtotalController.text =
        quotation.totalAmount.toString();
    customerDetailsProvider.totalController.text =
        quotation.netTotal.toString();

    // ---- ITEMS ----
    customerDetailsProvider.updateItemsFromQuotationDetailsNew(
      quotation.quotationDetails,
      quotation.billOfMaterials,
      quotation.productionChart,
      quotation.structureMaterials,
    );

    // ---- GST ----
    final taxable = double.tryParse(quotation.taxableAmount) ?? 0;
    final gst = double.tryParse(quotation.gstAmount) ?? 0;
    final gstPer = double.tryParse(quotation.gstPer) ?? 0;

    customerDetailsProvider.gstTaxableAmountController.text =
        taxable.toStringAsFixed(2);
    customerDetailsProvider.cgstTaxableAmountController.text =
        (taxable / 2).toStringAsFixed(2);
    customerDetailsProvider.sgstTaxableAmountController.text =
        (taxable / 2).toStringAsFixed(2);

    customerDetailsProvider.totalGstAmountController.text =
        gst.toStringAsFixed(2);
    customerDetailsProvider.totalCgstAmountController.text =
        (gst / 2).toStringAsFixed(2);
    customerDetailsProvider.totalSgstAmountController.text =
        (gst / 2).toStringAsFixed(2);

    customerDetailsProvider.totalGstPerController.text =
        gstPer.toStringAsFixed(2);
    customerDetailsProvider.totalCgstPerController.text =
        (gstPer / 2).toStringAsFixed(2);
    customerDetailsProvider.totalSgstPerController.text =
        (gstPer / 2).toStringAsFixed(2);

    // ---- QUOTATION TYPE ----
    customerDetailsProvider.quotationTypeController.text =
        quotation.quotationTypeName;
    customerDetailsProvider.selectedQuotationType = quotation.quotationTypeId;

    // ---- CABLE DETAILS ----
    customerDetailsProvider.cableStructureController.text =
        quotation.cableStructure;
    customerDetailsProvider.cableTypeController.text = quotation.cableType;
    customerDetailsProvider.cableShortCircuitTempController.text =
        quotation.cableShortCircuitTemp;
    customerDetailsProvider.cableStandardController.text =
        quotation.cableStandard;
    customerDetailsProvider.cableConductorClassController.text =
        quotation.cableConductorClass;
    customerDetailsProvider.cableMaterialController.text =
        quotation.cableMaterial;
    customerDetailsProvider.cableProtectionController.text =
        quotation.cableProtection;
    customerDetailsProvider.cableWarrantyController.text =
        quotation.cableWarranty;
    customerDetailsProvider.cableTensileStrengthController.text =
        quotation.cableTensileStrength;

    // ---- OTHER DETAILS ----
    customerDetailsProvider.plantCapacityController.text =
        quotation.plantCapacity;
    customerDetailsProvider.moduleTechnologiesController.text =
        quotation.moduleTechnologies;
    customerDetailsProvider.mountingStructureTechnologiesController.text =
        quotation.mountingStructureTechnologies;
    customerDetailsProvider.projectSchemeController.text =
        quotation.projectScheme;
    customerDetailsProvider.powerEvacuationController.text =
        quotation.powerEvacuation;
    customerDetailsProvider.areaApproximateController.text =
        quotation.areaApproximate;
    customerDetailsProvider.solarPlantOutputConnectionController.text =
        quotation.solarPlantOutputConnection;
    customerDetailsProvider.schemeController.text = quotation.scheme;
    customerDetailsProvider.qvalidityController.text = quotation.validity;
    customerDetailsProvider.qtendorNumberController.text =
        quotation.tendorNumber;
    customerDetailsProvider.paymentTermsController.text =
        quotation.paymentTermsName;
    customerDetailsProvider.incoTermsController.text = quotation.incoTerms;
    customerDetailsProvider.shippingChargesController.text =
        quotation.shippingCharges;
    customerDetailsProvider.totalAdCESSController.text = quotation.otherTax;
    customerDetailsProvider.totalCgstAmountController.text =
        quotation.totalCgstAmount;
    customerDetailsProvider.totalSgstAmountController.text =
        quotation.totalSgstAmount;

    customerDetailsProvider.commercialItems = quotation.commercialItems;

    customerDetailsProvider.scopeOfWorkItems = quotation.scopeOfWorkItems;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return EditQuotationScreen(
              quotationId: taskId, customerId: widget.customerId);
        },
      ),
    );
  }

  Future<void> _openMaps(String location) async {
    print('DEBUG: _openMaps called with: "$location"');

    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No location available')),
      );
      return;
    }

    String cleanLocation = location.trim();

    // Check if location is already a URL
    if (cleanLocation.startsWith('http://') ||
        cleanLocation.startsWith('https://')) {
      print('DEBUG: Location is already a URL');
      try {
        await launchUrl(Uri.parse(cleanLocation),
            mode: LaunchMode.externalApplication);
        return;
      } catch (e) {
        print('DEBUG: Error launching existing URL: $e');
        // If the existing URL fails, try to extract coordinates
        RegExp coordRegex = RegExp(r'q=(-?\d+\.?\d*),(-?\d+\.?\d*)');
        Match? match = coordRegex.firstMatch(cleanLocation);
        if (match != null) {
          String coords = '${match.group(1)},${match.group(2)}';
          String newUrl = 'https://www.google.com/maps/search/$coords';
          print('DEBUG: Trying extracted coordinates URL: $newUrl');
          await launchUrl(Uri.parse(newUrl),
              mode: LaunchMode.externalApplication);
          return;
        }
      }
    }

    // Check if location contains coordinates
    bool isCoordinates =
        RegExp(r'^-?\d+\.?\d*\s*,\s*-?\d+\.?\d*$').hasMatch(cleanLocation);
    print('DEBUG: Is coordinates: $isCoordinates');

    String webUrl;

    if (isCoordinates) {
      webUrl = 'https://www.google.com/maps/search/$cleanLocation';
    } else {
      final encodedLocation = Uri.encodeComponent(cleanLocation);
      webUrl = 'https://www.google.com/maps/search/$encodedLocation';
    }

    print('DEBUG: Final URL: $webUrl');

    try {
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      print('DEBUG: Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open maps: $e')),
      );
    }
  }

  void editProfile(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          scrollable: true,
          title: const Text('Edit Profile'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width / 3,
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.nameController,
                        hintText: 'Name*',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.phoneController,
                        hintText: 'Phone*',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.emailController,
                        hintText: 'Email',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.addressController,
                        hintText: 'Address',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.cityController,
                        hintText: 'City',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.districtController,
                        hintText: 'District',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.stateController,
                        hintText: 'State',
                        labelText: '',
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.pincodeController,
                        hintText: 'Pincode',
                        labelText: '',
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Spacer()
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        height: 54,
                        controller: customerDetailsProvider.maplinkController,
                        hintText: 'Location',
                        labelText: '',
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                if (customerDetailsProvider.nameController.text.isNotEmpty &&
                    customerDetailsProvider.phoneController.text.isNotEmpty) {
                  customerDetailsProvider.updateProfile(
                      widget.customerId, context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          'Cannot save',
                          style: TextStyle(
                            color: AppColors.appViolet,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'Missing Details',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'OK',
                              style: TextStyle(
                                color: AppColors.appViolet,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text(
                'Confirm',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, int initialIndex,
      List<dynamic> items, bool baseImgUrl) {
    showDialog(
      context: context,
      builder: (context) {
        // Create a PageController to control the PageView
        PageController pageController =
            PageController(initialPage: initialIndex);

        return Dialog(
          backgroundColor: Colors.black,
          child: FocusScope(
            autofocus: true, // Enable focus for keyboard events
            child: KeyboardListener(
              autofocus: true, // Automatically focus on the listener
              focusNode: FocusNode(), // Focus node to capture keyboard events
              onKeyEvent: (KeyEvent event) {
                if (event is KeyDownEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                    // Navigate to the previous image
                    if (pageController.page! > 0) {
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey ==
                      LogicalKeyboardKey.arrowRight) {
                    // Navigate to the next image
                    if (pageController.page! < items.length - 1) {
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  } else if (event.logicalKey == LogicalKeyboardKey.escape) {
                    // Close the dialog on 'Escape' key
                    Navigator.of(context).pop();
                  }
                }
              },
              child: Stack(
                children: [
                  // PageView.builder to swipe through images
                  PageView.builder(
                    itemCount: items.length, // Total number of images
                    controller:
                        pageController, // Set the controller for the PageView
                    itemBuilder: (context, index) {
                      String imagePath = items[index].filePath;
                      return Center(
                        child: Image.network(
                          baseImgUrl
                              ? imagePath
                              : HttpUrls.imgBaseUrl + imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (BuildContext context, Object error,
                              StackTrace? stackTrace) {
                            // Return a placeholder or error image in case of an error
                            return Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey.withOpacity(0.2)),
                              child: const Icon(
                                Icons.hide_image_outlined,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  // Positioned 'Previous' button on the left
                  Positioned(
                    top: 0,
                    left: 20,
                    bottom: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Go to previous image
                        if (pageController.page! > 0) {
                          pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                  // Positioned 'Next' button on the right
                  Positioned(
                    top: 0,
                    right: 20,
                    bottom: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () {
                        // Go to next image
                        if (pageController.page! < items.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),

                  // Close button
                  // Download button
                  Positioned(
                    top: 20,
                    right: 70,
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        int currentIndex = pageController.hasClients &&
                                pageController.page != null
                            ? pageController.page!.round()
                            : initialIndex;
                        String path = items[currentIndex].filePath;
                        String imageUrl =
                            baseImgUrl ? path : HttpUrls.imgBaseUrl + path;

                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Share'),
                              content: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chat,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      try {
                                        final launched =
                                            await FileShare.shareToWhatsApp(
                                          imageUrl,
                                          caption: 'Sharing image',
                                        );
                                        if (!launched) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Could not open WhatsApp.')));
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Could not share image: $e')));
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.email),
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      try {
                                        final launched =
                                            await FileShare.shareViaEmail(
                                          imageUrl,
                                          subject: 'Sharing image',
                                          body: 'Sharing image',
                                        );
                                        if (!launched) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text(
                                                      'Could not open mail client.')));
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Could not share via mail: $e')));
                                      }
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('Cancel'),
                                )
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // Close button
                  Positioned(
                    top: 20,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
