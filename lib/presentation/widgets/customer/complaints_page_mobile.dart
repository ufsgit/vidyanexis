import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_complaint_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/complaints_details_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';

class ComplaintsPageMobile extends StatefulWidget {
  final String customerId;

  const ComplaintsPageMobile({
    super.key,
    required this.customerId,
  });

  @override
  State<ComplaintsPageMobile> createState() => _ComplaintsPageMobileState();
}

class _ComplaintsPageMobileState extends State<ComplaintsPageMobile> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);
      customerDetailsProvider.getServiceList(widget.customerId, context);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final customerDetailsProvider =
        Provider.of<CustomerDetailsProvider>(context);

    return Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: customerDetailsProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Complaints',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            final customerDetailsProvider =
                                Provider.of<CustomerDetailsProvider>(context, listen: false);
                            customerDetailsProvider.customerId = widget.customerId;
                            customerDetailsProvider.clearTaskDetails();

                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) {
                                return AddComplaintMobile(
                                  isEdit: false,
                                  customerId: widget.customerId,
                                  taskId: '0',
                                );
                              },
                            ));
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryBlue,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondaryBlue.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: customerDetailsProvider.serviceList.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 80,
                                ),
                                Text(
                                  'No Complaints found.',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Start by creating a new Complaint.',
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textGrey3),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider(
                                height: 2,
                                color: AppColors.grey,
                              );
                            },
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: customerDetailsProvider.serviceList.length,
                            itemBuilder: (context, index) {
                              final service =
                                  customerDetailsProvider.serviceList[index];

                              Color statusColor =
                                  service.serviceStatusName == "Completed"
                                      ? Colors.green
                                      : service.serviceStatusName == "In Progress"
                                          ? Colors.orange
                                          : Colors.red;
                              return InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ComplaintsDetailsPageMobile(
                                            service: service);
                                      },
                                    ));
                                  },
                                  child: Container(
                                    width: MediaQuery.sizeOf(context).width,
                                    decoration: BoxDecoration(
                                        color: AppColors.whiteColor),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      child: Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start, // Important for proper alignment
                                            children: [
                                              Container(
                                                  height: 34,
                                                  width: 3,
                                                  decoration: BoxDecoration(
                                                      color: statusColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16))),
                                              const SizedBox(width: 8),
                                              const SizedBox(width: 4),
                                              // Wrap the text column with Expanded to prevent overflow
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      service.serviceTypeName,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              color: AppColors
                                                                  .textGrey4),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      service.serviceName,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w500,
                                                              color: AppColors
                                                                  .textBlack),
                                                      maxLines:
                                                          2, // Allow service name to wrap to 2 lines
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(
                                                  width:
                                                      8), // Add some spacing between text and status
                                              // Status container
                                              Container(
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(4),
                                                    color: statusColor
                                                        .withOpacity(.1),
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 2),
                                                      child: Text(
                                                        service.serviceStatusName,
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    statusColor),
                                                      ),
                                                    ),
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              service.description,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: AppColors.textGrey3),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: CustomText(
                                                  "₹${service.amount}",
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textGrey4,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  service.serviceDate
                                                      .toString()
                                                      .toTimeAgo(),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.end,
                                                  style:
                                                      GoogleFonts.plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: AppColors
                                                              .textGrey3),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                            },
                          ),
                  ),
                ],
              ));
  }
}
