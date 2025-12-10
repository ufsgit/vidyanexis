import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_styles.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/presentation/pages/home/add_quotation_widget_mobile.dart';
import 'package:techtify/presentation/widgets/customer/quotation_details_page_phone.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/utils/extensions.dart';

import '../../../constants/app_colors.dart';

class QuotationMobileView extends StatefulWidget {
  const QuotationMobileView({super.key, required this.customerId});
  final String customerId;

  @override
  State<QuotationMobileView> createState() => _QuotationMobileViewState();
}

class _QuotationMobileViewState extends State<QuotationMobileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getQuatationList(widget.customerId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Consumer<CustomerDetailsProvider>(
          builder: (context, customerDetailsProvider, child) {
            if (customerDetailsProvider.isQuotationListLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (customerDetailsProvider.quotationList.isEmpty) {
              return Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 80,
                    ),
                    Text(
                      'No quotations found.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Start by creating a new quotation.',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              separatorBuilder: (_, __) => Divider(
                thickness: 2,
                color: Colors.grey.shade200,
              ),
              // padding: EdgeInsets.all(16),
              itemCount: customerDetailsProvider.quotationList.length,
              itemBuilder: (context, index) {
                final item = customerDetailsProvider.quotationList[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => QuotationDetailsPagePhone(
                            productiopnChart: item.productionChartModel ?? [],
                            advance: item.advancePercentage.toString(),
                            completion:
                                item.workCompletionPercentage.toString(),
                            onDelivery: item.onDeliveryPercentage.toString(),
                            quotationId: item.quotationMasterId.toString(),
                            category: "0",
                            title: item.productName.toString(),
                            servicename: item.totalAmount.toString(),
                            statusId: item.quotationStatusId.toString(),
                            createdBy: item.createdByName.toString(),
                            status: item.quotationStatusName.toString(),
                            posted: item.orderDate.toString(),
                            customerId: widget.customerId.toString(),
                            warranty: item.warranty,
                            terms: item.termsAndConditions,
                            subsidy: item.subsidyAmount,
                            quotation_details: item.quotationDetails ?? [],
                            bill_of_materials: item.billOfMaterials ?? []),
                      ),
                    );
                    // context.push(
                    //     '${QuotationDetailsPagePhone.route}${item.quotationMasterId}');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 22,
                              color: StatusUtils.getStatusColor(
                                  item.quotationStatusId),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: AppStyles.getBoldTextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 7),
                              decoration: BoxDecoration(
                                color: StatusUtils.getStatusColor(
                                    item.quotationStatusId),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Text(
                                item.quotationStatusName,
                                style: AppStyles.getBoldTextStyle(
                                  fontSize: 12,
                                  fontColor: StatusUtils.getStatusTextColor(
                                      item.quotationStatusId),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.getRegularTextStyle(
                            fontSize: 14,
                            fontColor: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              '₹ ${item.totalAmount}',
                              style: AppStyles.getBodyTextStyle(
                                  fontSize: 14,
                                  fontColor: Colors.grey.shade800),
                            ),
                            const SizedBox(width: 5),
                            const Text('•',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey)),
                            const SizedBox(width: 5),
                            Text(
                              'by',
                              style: AppStyles.getRegularTextStyle(
                                  fontSize: 14,
                                  fontColor: Colors.grey.shade500),
                            ),
                            const SizedBox(width: 5),
                            CircleAvatar(
                              radius: 10,
                              backgroundImage:
                                  AssetImage('assets/images/user-circle1.png'),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              item.createdByName,
                              style: AppStyles.getBodyTextStyle(
                                  fontSize: 14,
                                  fontColor: const Color(0xFF607085)),
                            ),
                            const Spacer(),
                            Text(
                              item.entryDate.toString().toTimeAgo(),
                              style: AppStyles.getRegularTextStyle(
                                  fontColor: Colors.grey.shade500,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Add Quotation',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => AddQuotationWidgetMobile(
                customerId: widget.customerId,
                quotationId: '0',
              ),
            ),
          ),
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }
}
