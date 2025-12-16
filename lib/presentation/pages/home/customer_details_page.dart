import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/models/document_checklist_model.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/pages/home/checklist_management_page.dart';
import 'package:vidyanexis/presentation/pages/home/kseb_print_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/reciept_screen.dart';
import 'package:vidyanexis/presentation/pages/home/refund_form_page.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_agreement_pdf.dart';
import 'package:vidyanexis/presentation/pages/home/vendor_feasibility_pdf.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_checklist_management_widget.dart';
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
import 'package:vidyanexis/controller/models/task_document_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_reciept.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_service.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_card_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_creation_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/amc_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/quotation_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/reciept_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/service_card.dart';
import 'package:vidyanexis/presentation/widgets/customer/service_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_cark_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_chips_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/upload_image.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/presentation/widgets/home/customer_profie_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
      customerDetailsProvider.getTaskList(widget.customerId, context);
      customerDetailsProvider.fetchLeadDetails(widget.customerId, context);
      customerDetailsProvider.getServiceList(widget.customerId, context);
      customerDetailsProvider.getAmc(widget.customerId, '0', context);
      customerDetailsProvider.getQuatationList(widget.customerId, context);
      customerDetailsProvider.getDocument(widget.customerId, context);
      customerDetailsProvider.getTaskDocument(widget.customerId, context);
      customerDetailsProvider.getRecieptListApi(widget.customerId, context);
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

  @override
  void dispose() {
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
    final List<Tab> tabs = [
      if (settingsprovider.menuIsViewMap[13] == 1) const Tab(text: "Tasks"),
      if (settingsprovider.menuIsViewMap[14] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Complaints"),
      if (settingsprovider.menuIsViewMap[15] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Periodic Service"),
      if (settingsprovider.menuIsViewMap[16] == 1)
        const Tab(text: "Quotations"),
      if (settingsprovider.menuIsViewMap[19] == 1) const Tab(text: "Documents"),
      if (settingsprovider.menuIsViewMap[18] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Receipt"),
      // if (settingsprovider.menuIsViewMap[30] == 1)
      //   const Tab(text: "Task Documents"),
      if (settingsprovider.menuIsViewMap[37] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "CheckList Management"),
      if (settingsprovider.menuIsViewMap[37] == 1 &&
          sideprovider.name != 'Lead /')
        const Tab(text: "Refund Form"),
    ];
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

    return Scaffold(
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
      //               return const Center(child: Text('Error loading username'));
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //top
                  if (widget.report == 'true')
                    const SizedBox(
                      height: 20,
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            sideprovider.replaceWidget(true, '');
                            sideprovider.replaceWidgetCustomer(true, '');
                            AppStyles.isWebScreen(context)
                                ? leadProvider.getSearchLeadsNoContext()
                                : leadProvider.getSearchLeads(context);
                            AppStyles.isWebScreen(context)
                                ? customerProvider.getSearchCustomersNoContext()
                                : customerProvider.getSearchCustomers(context);
                            leadDetailsProvider
                                .fetchLeadDetailsNoContext(widget.customerId);
                            if (widget.report == 'true') {
                              Navigator.pop(context);
                            }
                          },
                          child: Image.asset(
                            'assets/images/ArrowRight.png',
                            width: 24,
                            height: 24,
                          ),
                        ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        AppStyles.isWebScreen(context)
                            ? Wrap(
                                children: [
                                  Text(
                                    sideprovider.name,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFF5499D9),
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    'Customer details',
                                    style: TextStyle(
                                        fontSize: 24,
                                        color: Color(0xFF152D70),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            : Text(
                                customerDetailsProvider.leadDetails != null &&
                                        customerDetailsProvider
                                            .leadDetails!.isNotEmpty
                                    ? customerDetailsProvider
                                        .leadDetails![0].customerName
                                    : '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 24),
                              ),
                        // const SizedBox(
                        //   width: 10,
                        // ),
                        if (!AppStyles.isWebScreen(context))
                          if (settingsprovider.menuIsEditMap[4] == 1)
                            IconButton(
                                onPressed: () async {
                                  await leadDetailsProvider.fetchLeadDetails(
                                      widget.customerId, context);
                                  await leadProvider.getLeadDropdowns(context);
                                  leadProvider.setCutomerId(
                                      int.parse(widget.customerId));
                                  leadProvider.enquirySourceController.text =
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

                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const NewLeadDrawerWidget(
                                        isEdit: true,
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.edit)),
                        if (sideprovider.name != 'Lead /')
                          if (settingsprovider.menuIsDeleteMap[4] == 1)
                            CustomElevatedButton(
                              backgroundColor: AppColors.whiteColor,
                              borderColor: AppColors.textRed,
                              textColor: AppColors.textRed,
                              buttonText: 'Remove Registration',
                              onPressed: () {
                                showDialog(
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
                                          onPressed: () {
                                            customerDetailsProvider
                                                .removeRegister(
                                                    widget.customerId, context);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                        if (settingsprovider.menuIsViewMap[61] == 1 &&
                            sideprovider.name != 'Lead /')
                          CustomElevatedButton(
                            backgroundColor: AppColors.whiteColor,
                            borderColor: AppColors.bluebutton,
                            textColor: AppColors.bluebutton,
                            buttonText: 'KSEB',
                            onPressed: () async {
                              final customer = (customerDetailsProvider
                                              .leadDetails !=
                                          null &&
                                      customerDetailsProvider
                                          .leadDetails!.isNotEmpty)
                                  ? customerDetailsProvider.leadDetails?.first
                                  : null;
                              ksebPdf(
                                  customerDetails: customer, context: context);
                            },
                          ),
                        if (settingsprovider.menuIsViewMap[63] == 1 &&
                            sideprovider.name != 'Lead /')
                          CustomElevatedButton(
                            backgroundColor: AppColors.whiteColor,
                            borderColor: AppColors.bluebutton,
                            textColor: AppColors.bluebutton,
                            buttonText: 'Vendor Agreement',
                            onPressed: () async {
                              final customer = (customerDetailsProvider
                                              .leadDetails !=
                                          null &&
                                      customerDetailsProvider
                                          .leadDetails!.isNotEmpty)
                                  ? customerDetailsProvider.leadDetails?.first
                                  : null;
                              vendorAgreementPdf(
                                  customerDetails: customer, context: context);
                            },
                          ),
                        if (settingsprovider.menuIsViewMap[62] == 1 &&
                            sideprovider.name != 'Lead /')
                          CustomElevatedButton(
                            backgroundColor: AppColors.whiteColor,
                            borderColor: AppColors.bluebutton,
                            textColor: AppColors.bluebutton,
                            buttonText: 'Vendor Feasibility',
                            onPressed: () async {
                              final customer = (customerDetailsProvider
                                              .leadDetails !=
                                          null &&
                                      customerDetailsProvider
                                          .leadDetails!.isNotEmpty)
                                  ? customerDetailsProvider.leadDetails?.first
                                  : null;

                              rtsFeasibilityReportPdf(
                                  customerDetails: customer, context: context);
                            },
                          ),
                      ],
                    ),
                  ),
                  //down
                  Expanded(
                    child: Row(
                      children: [
                        // Left Panel
                        if (AppStyles.isWebScreen(context))
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  Color(0xFFA2C6EB),
                                              child: Icon(Icons.person_rounded,
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
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600),
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
                                                          .menuIsEditMap[4] ==
                                                      1)
                                                    IconButton(
                                                        onPressed: () async {
                                                          await leadDetailsProvider
                                                              .fetchLeadDetails(
                                                                  widget
                                                                      .customerId,
                                                                  context);
                                                          await leadProvider
                                                              .getLeadDropdowns(
                                                                  context);

                                                          leadProvider.setCutomerId(
                                                              int.parse(widget
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
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return const NewLeadDrawerWidget(
                                                                isEdit: true,
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
                                        height: 15,
                                      ),
                                      CustomerCard(
                                        title: "Contact",
                                        content: [
                                          // DetailRow(
                                          //     label: "Email",
                                          //     value: customerDetailsProvider
                                          //         .leadDetails![0].email),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
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
                                                  .leadDetails![0].contactNumber
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
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .address ??
                                                      ''),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              DetailRow(
                                                  label: "Enquiry For",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .enquiryForName ??
                                                      ''),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              DetailRow(
                                                  label: "Enquiry Source",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .enquirySourceName ??
                                                      ''),
                                              SizedBox(
                                                height: 8,
                                              ),
                                              DetailRow(
                                                  label: "Consumer Number",
                                                  value: customerDetailsProvider
                                                          .leadDetails![0]
                                                          .consumerNumber ??
                                                      ''),
                                              // SizedBox(
                                              //   height: 8,
                                              // ),
                                              // DetailRow(
                                              //     label: "Contact Number",
                                              //     value: customerDetailsProvider
                                              //             .leadDetails![0]
                                              //             .phoneNumber ??
                                              //         ''),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              const Text(
                                                "Location: ",
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
                                        ],
                                      ),
                                    ],
                                  )
                                : Container(),
                          ),
                        // Right Panel
                        if (!AppStyles.isWebScreen(context))
                          const SizedBox(
                            width: 15,
                          ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: DefaultTabController(
                              length: tabs.length,
                              child: Column(
                                children: [
                                  // Tabs
                                  TabBar(
                                    labelColor: AppColors.primaryBlue,
                                    unselectedLabelColor: Colors.black54,
                                    indicatorColor: AppColors.primaryBlue,
                                    tabAlignment: TabAlignment.start,
                                    isScrollable: true,
                                    dividerColor: Colors.white,
                                    labelStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    unselectedLabelStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    tabs: tabs,
                                  ),

                                  // Tab views
                                  Expanded(
                                    child: TabBarView(
                                      children: [
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
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
                                                                    .all(30),
                                                          ),

                                                        // Create Task Button
                                                        if (settingsprovider
                                                                    .menuIsSaveMap[
                                                                13] ==
                                                            1)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child:
                                                                ElevatedButton
                                                                    .icon(
                                                              onPressed: () {
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
                                                                  Icons.add),
                                                              label: const Text(
                                                                  'Create Task'),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryBlue,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: AppStyles
                                                                        .isWebScreen(
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

                                                    // Filtered Task List
                                                    _buildFilteredTaskList(
                                                      onTap: (taskMasterId) {
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
                                                          builder: (BuildContext
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

                                        // Complaints Tab (can be customized as needed)
                                        if (settingsprovider
                                                .menuIsViewMap[14] ==
                                            1)
                                          if (sideprovider.name != 'Lead /')
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
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          //chips
                                                          AppStyles.isWebScreen(
                                                                  context)
                                                              ? Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFEFF2F5),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child: Wrap(
                                                                      spacing:
                                                                          8.0, // Space between chips
                                                                      runSpacing:
                                                                          4.0, // Space between rows
                                                                      children: [
                                                                        _buildServiceChip(
                                                                            'All Complaints',
                                                                            null), // All tasks (no filter)
                                                                        _buildServiceChip(
                                                                            'Completed',
                                                                            2), // Task Type Id 1
                                                                        _buildServiceChip(
                                                                            'Pending',
                                                                            1), // Task Type Id 2
                                                                        // _buildServiceChip(
                                                                        //     'In Progress',
                                                                        //     2), // Task Type Id 3
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          30),
                                                                ),
                                                          if (settingsprovider
                                                                      .menuIsSaveMap[
                                                                  14] ==
                                                              1)
                                                            ElevatedButton.icon(
                                                              onPressed: () {
                                                                customerDetailsProvider
                                                                        .customerId =
                                                                    widget
                                                                        .customerId;
                                                                customerDetailsProvider
                                                                    .clearServiceDetails();
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  barrierDismissible:
                                                                      false,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return ServiceCreationWidget(
                                                                        taskId:
                                                                            '0',
                                                                        isEdit:
                                                                            false,
                                                                        customerId:
                                                                            widget.customerId);
                                                                  },
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                  Icons.add),
                                                              label: const Text(
                                                                  'Add Complaint'),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryBlue,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: AppStyles
                                                                        .isWebScreen(
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
                                                        ],
                                                      ),
                                                      // Display filtered task list
                                                      _buildFilteredServiceList(
                                                        onTap: (serviceId) {
                                                          leadProvider.setCutomerId(
                                                              int.parse(widget
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
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return ServiceDetailsWidget(
                                                                customerId: widget
                                                                    .customerId,
                                                                serviceId: serviceId
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
                                            customerDetailsProvider.isLoading
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
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: const Color(
                                                                        0xFFEFF2F5),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            4.0),
                                                                    child: Wrap(
                                                                      spacing:
                                                                          8.0, // Space between chips
                                                                      runSpacing:
                                                                          4.0, // Space between rows
                                                                      children: [
                                                                        _buildAMCChip(
                                                                            'All Periodic Service',
                                                                            null), // All tasks (no filter)
                                                                        Wrap(
                                                                          spacing:
                                                                              8.0, // Space between chips
                                                                          runSpacing:
                                                                              4.0,
                                                                          children: dropDownProvider
                                                                              .amcStatus
                                                                              .map((task) {
                                                                            return _buildAMCChip(task.amcStatusName,
                                                                                task.amcStatusId);
                                                                          }).toList(),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )
                                                              : Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          30),
                                                                ),
                                                          const Spacer(),
                                                          if (settingsprovider
                                                                      .menuIsSaveMap[
                                                                  15] ==
                                                              1)
                                                            ElevatedButton.icon(
                                                              onPressed: () {
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
                                                                        amcId:
                                                                            '0',
                                                                        customerId:
                                                                            widget
                                                                                .customerId,
                                                                        isEdit:
                                                                            false);
                                                                  },
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                  Icons.add),
                                                              label: const Text(
                                                                  'Add Periodic Service'),
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryBlue,
                                                                foregroundColor:
                                                                    Colors
                                                                        .white,
                                                                padding: AppStyles
                                                                        .isWebScreen(
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
                                                            toDate) {
                                                          leadProvider.setCutomerId(
                                                              int.parse(widget
                                                                  .customerId));
                                                          print(
                                                              'Task ID: $taskId');

                                                          showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AmcWidget(
                                                                onPressed: () {
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
                                                                          amcId: amcId
                                                                              .toString(),
                                                                          amcAmountController:
                                                                              amount,
                                                                          amcDescriptionController:
                                                                              description,
                                                                          amcProductNameController:
                                                                              productName,
                                                                          amcServiceController:
                                                                              service,
                                                                          fromDateController:
                                                                              fromDate,
                                                                          toDateController:
                                                                              toDate,
                                                                          customerId: widget
                                                                              .customerId,
                                                                          isEdit:
                                                                              true);
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
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Display 4 Chips based on Task_Type_Id filter
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        //chips
                                                        AppStyles.isWebScreen(
                                                                context)
                                                            ? Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: const Color(
                                                                      0xFFEFF2F5),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          4.0),
                                                                  child: Wrap(
                                                                    spacing:
                                                                        8.0, // Space between chips
                                                                    runSpacing:
                                                                        4.0, // Space between rows
                                                                    children: [
                                                                      _buildQuatationChip(
                                                                          'All Quotations',
                                                                          null), // All tasks (no filter)
                                                                      _buildQuatationChip(
                                                                          'Approved',
                                                                          2), // Task Type Id 1
                                                                      _buildQuatationChip(
                                                                          'Rejected',
                                                                          3), // Task Type Id 2
                                                                      _buildQuatationChip(
                                                                          'Pending',
                                                                          1), // Task Type Id 2
                                                                      // _buildServiceChip(
                                                                      //     'In Progress',
                                                                      //     2), // Task Type Id 3
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        30),
                                                              ),
                                                        if (settingsprovider
                                                                    .menuIsSaveMap[
                                                                16] ==
                                                            1)
                                                          ElevatedButton.icon(
                                                            onPressed: () {
                                                              customerDetailsProvider
                                                                      .customerId =
                                                                  widget
                                                                      .customerId;
                                                              customerDetailsProvider
                                                                  .qsubsidyAmountController
                                                                  .text = '0';
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return QuotationCreationWidget(
                                                                      quotationId:
                                                                          '0',
                                                                      isEdit:
                                                                          false,
                                                                      customerId:
                                                                          widget
                                                                              .customerId);
                                                                },
                                                              );
                                                            },
                                                            icon: const Icon(
                                                                Icons.add),
                                                            label: const Text(
                                                                'Quotation Detail'),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .primaryBlue,
                                                              foregroundColor:
                                                                  Colors.white,
                                                              padding: AppStyles
                                                                      .isWebScreen(
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
                                                      ],
                                                    ),
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
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return QuotationDetailsWidget(
                                                              customerId: widget
                                                                  .customerId,
                                                              serviceId:
                                                                  quatationId
                                                                      .toString(),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      quatationId:
                                                          selectedQuotationStatusId,
                                                    )
                                                  ],
                                                ),

                                        //Images Tab
                                        if (settingsprovider
                                                .menuIsViewMap[19] ==
                                            1)
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (settingsprovider
                                                        .menuIsSaveMap[19] ==
                                                    1)
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        context: context,
                                                        builder: (context) =>
                                                            ImageUploadAlert(
                                                                customerId: widget
                                                                    .customerId),
                                                      );
                                                    },
                                                    child: Image.asset(
                                                      'assets/images/add_photo.png',
                                                      height: 50,
                                                    ),
                                                  ),
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
                                                      List<ImageDetail> images =
                                                          userData.imageDetails;

                                                      return ExpansionTile(
                                                        enabled: false,
                                                        initiallyExpanded: true,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.zero,
                                                        ),
                                                        title: Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          runSpacing: 10,
                                                          children: [
                                                            const Icon(
                                                                Icons.person),
                                                            Text(
                                                              '  Uploaded By ',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textGrey4),
                                                            ),
                                                            Text(
                                                              userData.userName,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        children: [
                                                          MouseRegion(
                                                            cursor:
                                                                SystemMouseCursors
                                                                    .click,
                                                            child: SizedBox(
                                                              height: 140,
                                                              child: Scrollbar(
                                                                controller:
                                                                    customerDetailsProvider
                                                                        .imageScrollController,
                                                                thumbVisibility:
                                                                    true,
                                                                child: ListView
                                                                    .separated(
                                                                  controller:
                                                                      customerDetailsProvider
                                                                          .imageScrollController,
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  separatorBuilder: (context,
                                                                          index) =>
                                                                      const SizedBox(
                                                                          width:
                                                                              10),
                                                                  physics:
                                                                      const ClampingScrollPhysics(),
                                                                  itemCount:
                                                                      images
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    final image =
                                                                        images[
                                                                            index];
                                                                    return Column(
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
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  child: Image.network(
                                                                                    image.filePath,
                                                                                    width: 100,
                                                                                    height: 100,
                                                                                    fit: BoxFit.fill,
                                                                                    // Display a loading indicator while the image is loading
                                                                                    loadingBuilder: (context, child, loadingProgress) {
                                                                                      if (loadingProgress == null) {
                                                                                        return child; // Image is fully loaded
                                                                                      }
                                                                                      return SizedBox(
                                                                                        height: 100,
                                                                                        width: 100,
                                                                                        child: Center(
                                                                                          child: CircularProgressIndicator(
                                                                                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                    // Display an error image if the image fails to load
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
                                                                                          width: 100,
                                                                                          height: 100,
                                                                                          child: const Column(
                                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                                            children: [
                                                                                              Icon(
                                                                                                Icons.picture_as_pdf,
                                                                                                color: Colors.red,
                                                                                                size: 50,
                                                                                              ),
                                                                                              SizedBox(height: 8),
                                                                                              Text(
                                                                                                'Open PDF',
                                                                                                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (settingsprovider.menuIsDeleteMap[19] ==
                                                                                1)
                                                                              Positioned(
                                                                                top: 5,
                                                                                right: 5,
                                                                                child: GestureDetector(
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
                                                                                    radius: 15,
                                                                                    backgroundColor: Colors.grey,
                                                                                    child: Icon(
                                                                                      Icons.delete,
                                                                                      size: 18,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        Text(
                                                                          image
                                                                              .documentTypeName,
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: AppColors.textBlack),
                                                                        ),
                                                                        Text(
                                                                          DateFormat('dd/MM/yyyy h:mm a')
                                                                              .format(DateTime.parse(image.entryDate)),
                                                                          style: TextStyle(
                                                                              fontSize: 10,
                                                                              color: AppColors.textGrey4),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        //Reciepts Tab
                                        if (settingsprovider
                                                .menuIsViewMap[18] ==
                                            1)
                                          if (sideprovider.name != 'Lead /')
                                            ReceiptScreen(widget.customerId),

                                        //Task Documents
                                        // if (settingsprovider
                                        //         .menuIsViewMap[30] ==
                                        //     1)
                                        // Padding(
                                        //   padding: const EdgeInsets.all(16.0),
                                        //   child: Column(
                                        //     crossAxisAlignment:
                                        //         CrossAxisAlignment.start,
                                        //     children: [
                                        //       Expanded(
                                        //         child: ListView.builder(
                                        //           itemCount:
                                        //               customerDetailsProvider
                                        //                   .taskDocuments
                                        //                   .length,
                                        //           itemBuilder:
                                        //               (context, index) {
                                        //             var userData =
                                        //                 customerDetailsProvider
                                        //                         .taskDocuments[
                                        //                     index];
                                        //             List<DocumentList>
                                        //                 images =
                                        //                 userData.documents;

                                        //             return ExpansionTile(
                                        //               shape:
                                        //                   const RoundedRectangleBorder(
                                        //                 borderRadius:
                                        //                     BorderRadius.zero,
                                        //               ),
                                        //               initiallyExpanded: true,
                                        //               title: Wrap(
                                        //                 crossAxisAlignment:
                                        //                     WrapCrossAlignment
                                        //                         .center,
                                        //                 runSpacing: 10,
                                        //                 children: [
                                        //                   const Icon(
                                        //                       Icons.person),
                                        //                   Text(
                                        //                     '  Uploaded By ',
                                        //                     style: TextStyle(
                                        //                         fontWeight:
                                        //                             FontWeight
                                        //                                 .bold,
                                        //                         fontSize: 14,
                                        //                         color: AppColors
                                        //                             .textGrey4),
                                        //                   ),
                                        //                   Text(
                                        //                     userData
                                        //                         .toUserName,
                                        //                     style:
                                        //                         const TextStyle(
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .bold,
                                        //                       fontSize: 14,
                                        //                     ),
                                        //                   ),
                                        //                   const SizedBox(
                                        //                     width: 20,
                                        //                   ),
                                        //                   Text(
                                        //                     userData
                                        //                         .taskTypeName,
                                        //                     style:
                                        //                         const TextStyle(
                                        //                       fontWeight:
                                        //                           FontWeight
                                        //                               .w600,
                                        //                       fontSize: 14,
                                        //                     ),
                                        //                   ),
                                        //                   const SizedBox(
                                        //                     width: 20,
                                        //                   ),
                                        //                   Text(
                                        //                     userData.taskDate,
                                        //                     style: const TextStyle(
                                        //                         fontWeight:
                                        //                             FontWeight
                                        //                                 .w500,
                                        //                         fontSize: 14,
                                        //                         color: Colors
                                        //                             .grey),
                                        //                   ),
                                        //                 ],
                                        //               ),
                                        //               children: [
                                        //                 MouseRegion(
                                        //                   cursor:
                                        //                       SystemMouseCursors
                                        //                           .click,
                                        //                   child: SizedBox(
                                        //                     height: 140,
                                        //                     child: Scrollbar(
                                        //                       controller:
                                        //                           customerDetailsProvider
                                        //                               .taskScrollController,
                                        //                       thumbVisibility:
                                        //                           true,
                                        //                       child: ListView
                                        //                           .separated(
                                        //                         controller:
                                        //                             customerDetailsProvider
                                        //                                 .taskScrollController,
                                        //                         scrollDirection:
                                        //                             Axis.horizontal,
                                        //                         separatorBuilder: (context,
                                        //                                 index) =>
                                        //                             const SizedBox(
                                        //                                 width:
                                        //                                     10),
                                        //                         physics:
                                        //                             const ClampingScrollPhysics(),
                                        //                         itemCount:
                                        //                             images
                                        //                                 .length,
                                        //                         itemBuilder:
                                        //                             (context,
                                        //                                 index) {
                                        //                           final image =
                                        //                               images[
                                        //                                   index];
                                        //                           return Column(
                                        //                             children: [
                                        //                               Stack(
                                        //                                 children: [
                                        //                                   Center(
                                        //                                     child: InkWell(
                                        //                                       onTap: () {
                                        //                                         int currentIndex = index;
                                        //                                         _showFullScreenImage(context, currentIndex, images, false);
                                        //                                       },
                                        //                                       child: ClipRRect(
                                        //                                         borderRadius: BorderRadius.circular(8),
                                        //                                         child: Image.network(
                                        //                                           HttpUrls.imgBaseUrl + image.filePath,
                                        //                                           width: 100,
                                        //                                           height: 100,
                                        //                                           fit: BoxFit.fill,
                                        //                                           // Display a loading indicator while the image is loading
                                        //                                           loadingBuilder: (context, child, loadingProgress) {
                                        //                                             if (loadingProgress == null) {
                                        //                                               return child; // Image is fully loaded
                                        //                                             }
                                        //                                             return SizedBox(
                                        //                                               height: 100,
                                        //                                               width: 100,
                                        //                                               child: Center(
                                        //                                                 child: CircularProgressIndicator(
                                        //                                                   value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                        //                                                 ),
                                        //                                               ),
                                        //                                             );
                                        //                                           },
                                        //                                           // Display an error image if the image fails to load
                                        //                                           errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                        //                                             return Container(
                                        //                                               decoration: BoxDecoration(
                                        //                                                 color: const Color(0xFFEFF2F5),
                                        //                                                 borderRadius: BorderRadius.circular(8),
                                        //                                               ),
                                        //                                               width: 100,
                                        //                                               height: 100,
                                        //                                               child: const Icon(
                                        //                                                 Icons.image,
                                        //                                                 color: Colors.grey,
                                        //                                                 size: 50,
                                        //                                               ),
                                        //                                             );
                                        //                                           },
                                        //                                         ),
                                        //                                       ),
                                        //                                     ),
                                        //                                   ),
                                        //                                 ],
                                        //                               ),
                                        //                               const SizedBox(
                                        //                                 height:
                                        //                                     5,
                                        //                               ),
                                        //                             ],
                                        //                           );
                                        //                         },
                                        //                       ),
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //               ],
                                        //             );
                                        //           },
                                        //         ),
                                        //       ),
                                        //     ],
                                        //   ),
                                        // ),

                                        if (settingsprovider
                                                .menuIsViewMap[37] ==
                                            1)
                                          if (sideprovider.name != 'Lead /')
                                            CheckListManagementWidget(
                                                customerId: widget.customerId),

                                        if (settingsprovider
                                                .menuIsViewMap[37] ==
                                            1)
                                          if (sideprovider.name != 'Lead /')
                                            RefundFormPage(widget.customerId),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

//service
  Widget _buildServiceChip(String label, int? serviceStatusId) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold, // Make text bold
          color: selectedServiceStatusId == serviceStatusId
              ? AppColors.primaryBlue
              : const Color(0xFF607085),
        ),
      ),
      selected: selectedServiceStatusId == serviceStatusId,
      onSelected: (bool selected) {
        setState(() {
          selectedServiceStatusId = selected
              ? serviceStatusId
              : null; // Update the selectedServiceStatusId
        });
      },
      backgroundColor:
          const Color(0xFFEFF2F5), // Color when the chip is selected
      selectedColor: Colors.white, // Color when the chip is unselected
      showCheckmark: false, // Removes the tick mark
      shape: RoundedRectangleBorder(
        // Removes the border by making it flat
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none, // Ensures no border is displayed
      elevation: 0, // Removes the elevation
    );
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
  Widget _buildAMCChip(String label, int? taskTypeId) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold, // Make text bold
          color: selectedAmcStatusId == taskTypeId
              ? AppColors.primaryBlue
              : const Color(0xFF607085),
        ),
      ),
      selected: selectedAmcStatusId == taskTypeId,
      onSelected: (bool selected) {
        setState(() {
          selectedAmcStatusId =
              selected ? taskTypeId : null; // Update the selectedTaskTypeId
        });
      },
      backgroundColor:
          const Color(0xFFEFF2F5), // Color when the chip is selected
      selectedColor: Colors.white, // Color when the chip is unselected
      showCheckmark: false, // Removes the tick mark
      shape: RoundedRectangleBorder(
        // Removes the border by making it flat
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none, // Ensures no border is displayed
      elevation: 0, // Removes the elevation
    );
  }

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
      )? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    var filteredAmcList = amcId == null
        ? customerDetailsProvider.amcList
        : customerDetailsProvider.amcList
            .where((task) => task.amcStatusId == amcId)
            .toList();
    return Expanded(
      child: ListView.builder(
        itemCount: filteredAmcList.length,
        itemBuilder: (context, taskIndex) {
          var amc = filteredAmcList[taskIndex];
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
                    DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(amc.fromDate.toString())),
                    DateFormat('dd-MM-yyyy')
                        .format(DateTime.parse(amc.toDate.toString())));
              }
            },
            child: AmcCardWidget(
              onPressed: () {
                customerDetailsProvider.customerId = widget.customerId;
                customerDetailsProvider.setAmcDropDown(
                    amc.amcStatusId, amc.amcStatusName);

                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AmcCreationWidget(
                        amcId: amc.amcId.toString(),
                        amcAmountController: amc.amount,
                        amcDescriptionController: amc.description,
                        amcProductNameController: amc.productName,
                        amcServiceController: amc.serviceName,
                        fromDateController: DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(amc.fromDate.toString())),
                        toDateController: DateFormat('dd-MM-yyyy')
                            .format(DateTime.parse(amc.toDate.toString())),
                        customerId: widget.customerId,
                        isEdit: true);
                  },
                );
              },
              amcId: amc.amcId.toString(),
              customerId: widget.customerId,
              category: "4",
              title: amc.serviceName,
              productName: amc.productName,
              servicename: amc.serviceName,
              productNo: amc.amcNo,
              date: DateFormat('MMM d, yyyy')
                  .format(DateTime.parse(amc.date.toString())),
              status: amc.amcStatusName,
              posted: DateFormat('MMM d, yyyy')
                  .format(DateTime.parse(amc.fromDate.toString())),
              description: amc.description,
              price: "₹${double.parse(amc.amount)}",
            ),
          );
        },
      ),
    );
  }

//task
  Widget _buildTaskChip(String label, int? taskTypeId) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.normal, // Make text bold
          color: selectedTaskTypeId == taskTypeId
              ? AppColors.primaryBlue
              : const Color(0xFF607085),
        ),
      ),
      selected: selectedTaskTypeId == taskTypeId,
      onSelected: (bool selected) {
        setState(() {
          selectedTaskTypeId =
              selected ? taskTypeId : null; // Update the selectedTaskTypeId
        });
      },
      backgroundColor:
          const Color(0xFFEFF2F5), // Color when the chip is selected
      selectedColor: Colors.white, // Color when the chip is unselected
      showCheckmark: false, // Removes the tick mark
      shape: RoundedRectangleBorder(
        // Removes the border by making it flat
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none, // Ensures no border is displayed
      elevation: 0, // Removes the elevation
    );
  }

// Method to build filtered task list based on task type ID
  Widget _buildFilteredTaskList({int? taskTypeId, void Function(int)? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    var filteredTasks = taskTypeId == null
        ? customerDetailsProvider.taskList
        : customerDetailsProvider.taskList
            .where((task) => task.taskTypeId == taskTypeId)
            .toList();

    return filteredTasks.isEmpty
        ? const Center(child: Text("No tasks available."))
        : Expanded(
            child: ListView.builder(
              itemCount: filteredTasks.length,
              itemBuilder: (context, taskIndex) {
                var task = filteredTasks[taskIndex];
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
                      customerDetailsProvider.taskDescriptionController.text =
                          task.description.toString();
                      customerDetailsProvider.taskChoosedateController
                          .text = task.taskDate.toString() != 'null' &&
                              task.taskDate.toString().isNotEmpty
                          ? DateFormat('dd MMM yyyy')
                              .format(DateTime.parse(task.taskDate.toString()))
                          : '';
                      customerDetailsProvider.taskChoosetimeController.text =
                          task.taskTime.toString();
                    }
                  },
                  child: TaskCard(
                      taskId: task.taskId.toString(),
                      taskMasterId: task.taskMasterId.toString(),
                      customerId: widget.customerId.toString(),
                      category: task.taskTypeId.toString(),
                      title: task.description,
                      toUser: task.toUsername,
                      assignedTo: task.taskStatusName,
                      date: task.taskDate.toString(),
                      time: task.taskTime.toString(),
                      status: task.taskStatusName,
                      posted: task.entryDate.toString(),
                      task: task),
                );
              },
            ),
          );
  }

  //quatations
  Widget _buildQuatationChip(String label, int? serviceStatusId) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold, // Make text bold
          color: selectedQuotationStatusId == serviceStatusId
              ? AppColors.primaryBlue
              : const Color(0xFF607085),
        ),
      ),
      selected: selectedQuotationStatusId == serviceStatusId,
      onSelected: (bool selected) {
        setState(() {
          selectedQuotationStatusId = selected
              ? serviceStatusId
              : null; // Update the selectedServiceStatusId
        });
      },
      backgroundColor:
          const Color(0xFFEFF2F5), // Color when the chip is selected
      selectedColor: Colors.white, // Color when the chip is unselected
      showCheckmark: false, // Removes the tick mark
      shape: RoundedRectangleBorder(
        // Removes the border by making it flat
        borderRadius: BorderRadius.circular(8),
      ),
      side: BorderSide.none, // Ensures no border is displayed
      elevation: 0, // Removes the elevation
    );
  }

  Widget _buildFilteredQuatationList(
      {int? quatationId, void Function(int)? onTap}) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    var filteredService = quatationId == null
        ? customerDetailsProvider.quotationList
        : customerDetailsProvider.quotationList
            .where((task) => task.quotationStatusId == quatationId)
            .toList();

    return filteredService.isEmpty
        ? const Center(child: Text("No Quotations available."))
        : Expanded(
            child: ListView.builder(
              itemCount: filteredService.length,
              itemBuilder: (context, taskIndex) {
                var task = filteredService[taskIndex];
                return GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap(task.quotationMasterId);
                      // customerDetailsProvider.setServiceEditDropDown(
                      //     task.serviceTypeId,
                      //     task.serviceTypeName,
                      //     task.serviceStatusId,
                      //     task.serviceStatusName);
                      // customerDetailsProvider.taskDescriptionController.text =
                      //     task.description.toString();
                      // customerDetailsProvider.serviceController.text =
                      //     task.serviceName.toString();

                      // customerDetailsProvider.qproductnameController.text =
                      //     task.productName.toString();
                      // customerDetailsProvider.qsubsidyAmountController.text =
                      //     task.subsidyAmount.toString();
                      // customerDetailsProvider.qwarrentyController.text =
                      //     task.warranty.toString();
                      // customerDetailsProvider.qtermsConditionsController.text =
                      //     task.termsAndConditions.toString();
                    }
                  },
                  child: QuotationCard(
                      productionChartModel: task.productionChartModel ?? [],
                      category: "0",
                      advancePercentage: task.advancePercentage,
                      completionPercentage: task.workCompletionPercentage,
                      deliveryPercentage: task.onDeliveryPercentage,
                      taskId: task.quotationMasterId.toString(),
                      title: task.productName.toString(),
                      servicename: task.totalAmount.toString(),
                      statusId: task.quotationStatusId.toString(),
                      createdBy: task.createdByName.toString(),
                      status: task.quotationStatusName.toString(),
                      posted: task.orderDate.toString(),
                      customerId: widget.customerId.toString(),
                      warranty: task.warranty,
                      terms: task.termsAndConditions,
                      subsidy: task.subsidyAmount,
                      quotation_details: task.quotationDetails ?? [],
                      bill_of_materials: task.billOfMaterials ?? []),
                );
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
                          borderRadius: BorderRadius.circular(15),
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
                                  borderRadius: BorderRadius.circular(8),
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
