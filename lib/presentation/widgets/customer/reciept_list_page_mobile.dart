import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techtify/constants/app_colors.dart';
import 'package:techtify/controller/customer_details_provider.dart';
import 'package:techtify/presentation/widgets/customer/add_invoice_phone.dart';
import 'package:techtify/presentation/widgets/customer/add_receipt_page_phone.dart';
import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
import 'package:techtify/presentation/widgets/home/custom_text_widget.dart';
import 'package:techtify/utils/extensions.dart';

class BillingDetailsPagePhone extends StatefulWidget {
  final String customerId;
  const BillingDetailsPagePhone({super.key, required this.customerId});

  @override
  State<BillingDetailsPagePhone> createState() =>
      _BillingDetailsPagePhoneState();
}

class _BillingDetailsPagePhoneState extends State<BillingDetailsPagePhone> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getRecieptListApi(widget.customerId, context);
      customerDetailsProvider.getInvoiceListApi(widget.customerId, context);
      customerDetailsProvider.getInvoiceRecieptTotal(
          widget.customerId, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpansionTile(
                initiallyExpanded: true,
                enabled: false,
                showTrailingIcon: false,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero),
                backgroundColor: AppColors.whiteColor,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      "Total Amount",
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: AppColors.textGrey4,
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    CustomText(
                      "₹${customerDetailsProvider.balanceTotal}",
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                      fontSize: 16,
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
                children: [
                  Container(
                    height: 54,
                    decoration: BoxDecoration(color: AppColors.scaffoldColor),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: Column(
                        children: [
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
                                "₹${customerDetailsProvider.invoiceTotal}",
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
                                "₹${customerDetailsProvider.recieptTotal}",
                                fontWeight: FontWeight.w500,
                                color: AppColors.textBlack,
                                fontSize: 12,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),

              // Tab containers in a row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // First Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 0;
                        });
                      },
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0
                              ? AppColors.grey300
                              : AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: CustomText(
                              "Invoices",
                              color: _selectedTabIndex == 0
                                  ? AppColors.textBlack
                                  : AppColors.textGrey4,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    // Second Tab
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = 1;
                        });
                      },
                      child: Container(
                        height: 28,
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1
                              ? AppColors.grey300
                              : AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: CustomText(
                              "Receipts",
                              color: _selectedTabIndex == 1
                                  ? AppColors.textBlack
                                  : AppColors.textGrey4,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _selectedTabIndex == 0
                  ? _buildInvoicesContent()
                  : _buildPaymentsContent(),
            ],
          ),
        ),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: _selectedTabIndex == 0 ? 'Add Invoice' : 'Add Payment',
          onPressed: _selectedTabIndex == 0
              ? () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return AddPaymentPhone(
                          invoiceId: "0",
                          isEdit: false,
                          customerId: widget.customerId);
                    },
                  ));
                }
              : () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return AddReceiptPagePhone(
                          recieptId: "0",
                          isEdit: false,
                          customerId: widget.customerId);
                    },
                  ));
                },
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }

  // Invoices tab content
  Widget _buildInvoicesContent() {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                "Invoices (${customerDetailsProvider.invoiceList.length})",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey4,
              ),
              CustomText(
                "Total ₹${customerDetailsProvider.invoiceTotal}",
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey4,
                fontSize: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: customerDetailsProvider.invoiceList.length,
          separatorBuilder: (context, index) =>
              Divider(thickness: 0.8, color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            var invoice = customerDetailsProvider.invoiceList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 24,
                      width: 24,
                      child: Image.asset('assets/images/invoice_icon.png')),
                  SizedBox(
                    width: 8,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        invoice.invoiceDescription,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textBlack,
                        fontSize: 14,
                      ),
                      CustomText(
                        "By ${invoice.byUserName} on ${invoice.entryDate.toDayMonthYearFormat()}",
                        fontWeight: FontWeight.w400,
                        color: AppColors.textGrey4,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  Spacer(),
                  CustomText(
                    "₹${invoice.invoiceAmount}",
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
    );
  }

  // Payments tab content
  Widget _buildPaymentsContent() {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomText(
                "Payments (${customerDetailsProvider.receiptList.length})",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey4,
              ),
              CustomText(
                "Total ₹${customerDetailsProvider.recieptTotal}",
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey4,
                fontSize: 12,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: customerDetailsProvider.receiptList.length,
          separatorBuilder: (context, index) =>
              Divider(thickness: 0.8, color: Colors.grey.shade300),
          itemBuilder: (context, index) {
            var payment = customerDetailsProvider.receiptList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 24,
                      width: 24,
                      child: Image.asset('assets/images/payment_rupees.png')),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomText(
                          payment.description,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textBlack,
                          fontSize: 14,
                          maxLine: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        CustomText(
                          "By ${payment.byUserName} on ${payment.entryDate.toDayMonthYearFormat()}",
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey4,
                          fontSize: 12,
                        ),
                      ],
                    ),
                  ),
                  CustomText(
                    "+₹${payment.amount}",
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF48A365),
                    fontSize: 12,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:techtify/constants/app_colors.dart';
// import 'package:techtify/controller/customer_details_provider.dart';
// import 'package:techtify/controller/leads_provider.dart';
// import 'package:techtify/presentation/widgets/customer/add_receipt_page_phone.dart';
// import 'package:techtify/presentation/widgets/customer/add_task.dart';
// import 'package:techtify/presentation/widgets/customer/add_task_mobile.dart';
// import 'package:techtify/presentation/widgets/customer/receipt_details_page_phone.dart';
// import 'package:techtify/presentation/widgets/customer/task_details_page_phone.dart';
// import 'package:techtify/presentation/widgets/home/custom_button_widget.dart';
// import 'package:techtify/presentation/widgets/home/lead_widget.dart';
// import 'package:techtify/utils/extensions.dart';

// class RecieptListPageMobile extends StatefulWidget {
//   final String customerId;

//   const RecieptListPageMobile({
//     super.key,
//     required this.customerId,
//   });

//   @override
//   State<RecieptListPageMobile> createState() => _RecieptListPageMobileState();
// }

// class _RecieptListPageMobileState extends State<RecieptListPageMobile> {
//   @override
//   void initState() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final customerDetailsProvider =
//           Provider.of<CustomerDetailsProvider>(context, listen: false);
//       customerDetailsProvider.getRecieptListApi(widget.customerId, context);
//     });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final customerDetailsProvider =
//         Provider.of<CustomerDetailsProvider>(context);

//     return Scaffold(
//         backgroundColor: AppColors.whiteColor,
//         body: customerDetailsProvider.isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : customerDetailsProvider.receiptList.isEmpty
//                 ? Center(
//                     child: Column(
//                       children: [
//                         const SizedBox(
//                           height: 80,
//                         ),
//                         Text(
//                           'No receipts found.',
//                           style: GoogleFonts.plusJakartaSans(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.textBlack),
//                         ),
//                         const SizedBox(
//                           height: 4,
//                         ),
//                         Text(
//                           'Start by creating a new receipt.',
//                           style: GoogleFonts.plusJakartaSans(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.textGrey3),
//                         ),
//                       ],
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         ListView.separated(
//                           separatorBuilder: (context, index) {
//                             return Divider(
//                               height: 2,
//                               color: AppColors.grey,
//                             );
//                           },
//                           itemCount: customerDetailsProvider.receiptList.length,
//                           shrinkWrap: true,
//                           physics: const ClampingScrollPhysics(),
//                           itemBuilder: (context, index) {
//                             final reciept =
//                                 customerDetailsProvider.receiptList[index];

//                             return InkWell(
//                               onTap: () {
//                                 // context.push(
//                                 //     '${TaskDetailsPagePhone.route}${task.taskMasterId}');
//                                 Navigator.push(context, MaterialPageRoute(
//                                   builder: (context) {
//                                     return ReceiptDetailsPagePhone(
//                                         reciept: reciept);
//                                   },
//                                 ));
//                               },
//                               child: Container(
//                                 width: MediaQuery.sizeOf(context).width,
//                                 decoration:
//                                     BoxDecoration(color: AppColors.whiteColor),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 16, vertical: 12),
//                                   child: Column(
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Container(
//                                               height: 22,
//                                               width: 3,
//                                               decoration: BoxDecoration(
//                                                   color: AppColors.appViolet,
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           16))),
//                                           const SizedBox(
//                                             width: 8,
//                                           ),
//                                           Text(
//                                             'Receipt Name',
//                                             style: GoogleFonts.plusJakartaSans(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.textBlack),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 12,
//                                       ),
//                                       Align(
//                                         alignment: Alignment.topLeft,
//                                         child: Text(
//                                           reciept.description,
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: GoogleFonts.plusJakartaSans(
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w400,
//                                               color: AppColors.textGrey3),
//                                         ),
//                                       ),
//                                       const SizedBox(
//                                         height: 12,
//                                       ),
//                                       Row(
//                                         children: [
//                                           Text(
//                                             "₹${reciept.amount}",
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: GoogleFonts.plusJakartaSans(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.textGrey3),
//                                           ),
//                                           // Padding(
//                                           //   padding:
//                                           //       const EdgeInsets.symmetric(horizontal: 5),
//                                           //   child: Text(
//                                           //     '•',
//                                           //     style: GoogleFonts.plusJakartaSans(
//                                           //         fontSize: 10,
//                                           //         fontWeight: FontWeight.w500,
//                                           //         color: AppColors.textGrey3),
//                                           //   ),
//                                           // ),
//                                           // Container(
//                                           //   height: 20,
//                                           //   width: 20,
//                                           //   decoration: BoxDecoration(
//                                           //       borderRadius: BorderRadius.circular(100),
//                                           //       color: AppColors.textRed),
//                                           // ),
//                                           // const SizedBox(width: 4),
//                                           // Text(
//                                           //   'David',
//                                           //   style: GoogleFonts.plusJakartaSans(
//                                           //       fontSize: 14,
//                                           //       fontWeight: FontWeight.w500,
//                                           //       color: AppColors.textGrey3),
//                                           // ),
//                                           const Spacer(),
//                                           Text(
//                                             reciept.entryDate
//                                                 .toString()
//                                                 .toTimeAgo(),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.ellipsis,
//                                             style: GoogleFonts.plusJakartaSans(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: AppColors.textGrey3),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         )
//                       ],
//                     ),
//                   ),
//         floatingActionButton: CustomElevatedButton(
//           prefixIcon: Icons.add,
//           radius: 32,
//           buttonText: 'Add receipt',
//           onPressed: () {
//             final customerDetailsProvider =
//                 Provider.of<CustomerDetailsProvider>(context, listen: false);
//             customerDetailsProvider.customerId = widget.customerId;
//             customerDetailsProvider.clearTaskDetails();
//             Navigator.push(context, MaterialPageRoute(
//               builder: (context) {
//                 return AddReceiptPagePhone(
//                   isEdit: false,
//                   recieptId: '0',
//                   customerId: widget.customerId,
//                 );
//               },
//             ));
//             // showModalBottomSheet(
//             //   context: context,
//             //   isScrollControlled: true,
//             //   showDragHandle: false,
//             //   isDismissible: false,
//             //   backgroundColor: Colors.transparent,
//             //   builder: (BuildContext context) {
//             //     return Padding(
//             //       padding: EdgeInsets.only(
//             //           bottom: MediaQuery.of(context).viewInsets.bottom),
//             //       child: Wrap(
//             //         children: [
//             //           AddReceiptPagePhone(
//             //             isEdit: false,
//             //             recieptId: '0',
//             //             customerId: widget.customerId,
//             //           ),
//             //         ],
//             //       ),
//             //     );
//             //   },
//             // );
//           },
//           backgroundColor: AppColors.bluebutton,
//           borderColor: AppColors.bluebutton,
//           textColor: AppColors.whiteColor,
//         ));
//   }
// }