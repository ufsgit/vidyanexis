import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_provider.dart';
import 'package:techtify/controller/inovoice_report_provider.dart';
import 'package:techtify/controller/leads_provider.dart';
import 'package:techtify/controller/side_bar_provider.dart';
import 'package:techtify/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';

class BillingAndpaymentsReportScreen extends StatefulWidget {
  const BillingAndpaymentsReportScreen({super.key});

  @override
  State<BillingAndpaymentsReportScreen> createState() =>
      _BillingAndpaymentsReportScreenState();
}

class _BillingAndpaymentsReportScreenState
    extends State<BillingAndpaymentsReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider =
          Provider.of<SidebarProvider>(context, listen: false);
      final reportsProvider =
          Provider.of<InvoiceReportProvider>(context, listen: false);
      reportsProvider.setTaskSearchCriteria('', '', '', '', '', "", "");
      reportsProvider.getBillandPaymentsReport(context);
      searchProvider.stopSearch();
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = TextEditingController();
    final reportsProvider = Provider.of<InvoiceReportProvider>(context);
    final searchProvider = Provider.of<SidebarProvider>(context);
    final customerProvider = Provider.of<CustomerProvider>(context);
    final leadProvider = Provider.of<LeadsProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: CustomAppBar(
        onSearchTap: () {
          searchProvider.startSearch();
        },
        leadingWidth: 40,
        leadingWidget: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () {
              searchProvider.stopSearch();
              customerProvider.setFilter(false);
              leadProvider.setFilter(false);
              context.pop();
            },
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.textGrey4,
            ),
            iconSize: 24,
          ),
        ),
        title: 'Billing & Payments Report',
        titleStyle: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textBlack),
        searchHintText: 'Search Reports...',
        onFilterTap: () {},
        onClearTap: () {
          searchController.clear();
          searchProvider.stopSearch();
          reportsProvider.setTaskSearchCriteria(
            '',
            '',
            '',
            '',
            '',
            "",
            "",
          );
          reportsProvider.getBillandPaymentsReport(context);
        },
        onSearch: (query) {
          reportsProvider.setTaskSearchCriteria(
              query,
              reportsProvider.fromDateS,
              reportsProvider.toDateS,
              reportsProvider.Status,
              reportsProvider.AssignedTo,
              reportsProvider.enquiryFor,
              reportsProvider.enquirySource);
          reportsProvider.getBillandPaymentsReport(context);
        },
        searchController: searchController,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFF2F7FF),
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        "Total Balance",
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.textBlack,
                      ),
                      CustomText(
                        "₹${43}",
                        fontWeight: FontWeight.w600,
                        color: AppColors.bluebutton,
                        fontSize: 16,
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            'Total Invoiced',
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey4,
                            fontSize: 12,
                          ),
                          CustomText(
                            "₹1223",
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            fontSize: 12,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            'Total Payments Recieved',
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey4,
                            fontSize: 12,
                          ),
                          CustomText(
                            "₹127823",
                            fontWeight: FontWeight.w500,
                            color: AppColors.textBlack,
                            fontSize: 12,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomText(
                'Billing Summary',
                fontWeight: FontWeight.w500,
                color: AppColors.textBlack,
                fontSize: 14,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.grey300,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: SizedBox(
                            height: 18,
                            width: 18,
                            child: Image.asset('assets/images/task-02.png')),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomText(
                              "Partial Payment for Mounting & asasa",
                              fontWeight: FontWeight.w400,
                              color: AppColors.textBlack,
                              fontSize: 14,
                              softWrap: true,
                            ),
                            InkWell(
                              onTap: () {},
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Mathe thomasws',
                                      style: GoogleFonts.plusJakartaSans(
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.bluebutton,
                                          decorationThickness: 1.5,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppColors.textBlack,
                                    size: 18,
                                  )
                                ],
                              ),
                            ),
                            CustomText(
                              "By Sara on 10 Ap 2024",
                              fontWeight: FontWeight.w400,
                              color: AppColors.textGrey4,
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        "₹ 1273",
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack,
                        fontSize: 12,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
