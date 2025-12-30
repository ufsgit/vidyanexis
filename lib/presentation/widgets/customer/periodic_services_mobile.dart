import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/common_widgets.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_periodic_service_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/periodic_service_details_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/utils/extensions.dart';
// import 'package:vidyanexis/presentation/widgets/customer/add_periodic_service_mobile.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../controller/customer_details_provider.dart';

class PeriodicServicesMobile extends StatefulWidget {
  const PeriodicServicesMobile({super.key, required this.customerId});
  final String customerId;

  @override
  State<PeriodicServicesMobile> createState() => _PeriodicServicesMobileState();
}

class _PeriodicServicesMobileState extends State<PeriodicServicesMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .getAmc(widget.customerId, '0', context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<CustomerDetailsProvider>(
            builder: (context, customerDetailsProvider, child) {
          if (customerDetailsProvider.isAmcListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (customerDetailsProvider.amcList.isEmpty) {
            return Center(
              child: Column(
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  Text(
                    'No periodic services found.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlack),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Start by creating a new Periodic service.',
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
            separatorBuilder: (_, __) => const Divider(),
            padding: const EdgeInsets.all(16),
            itemCount: customerDetailsProvider.amcList.length,
            itemBuilder: (context, index) {
              final item = customerDetailsProvider.amcList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return PeriodicServiceDetailsPageMobile(item: item);
                    },
                  ));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 32,
                          color: StatusUtils.getStatusMobileColor(
                                  item.amcStatusName)
                              .withOpacity(.4),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: AppStyles.getBoldTextStyle(
                                    fontSize: 12, fontColor: Color(0xff7D8B9B)),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                item.serviceName,
                                style: AppStyles.getBoldTextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 7),
                          decoration: BoxDecoration(
                            color: StatusUtils.getStatusMobileColor(
                                    item.amcStatusName)
                                .withOpacity(.1),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Text(
                            item.amcStatusName,
                            style: AppStyles.getBoldTextStyle(
                              fontSize: 12,
                              fontColor: StatusUtils.getStatusMobileColor(
                                  item.amcStatusName),
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
                          '₹ ${item.amount}',
                          style: AppStyles.getBodyTextStyle(
                              fontSize: 14, fontColor: Colors.grey.shade800),
                        ),
                        const SizedBox(width: 5),
                        const Text('•',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                        const SizedBox(width: 5),
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Color(0xffF6F7F9),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                              child: Text(
                                style: AppStyles.getBoldTextStyle(fontSize: 12),
                                '${item.fromDate.toDayMonthYearFormat()} - ${item.toDate.toDayMonthYearFormat()}',
                              ),
                            ),
                          ),
                        ),
                        // Spacer(),
                        // const SizedBox(width: 5),
                        // Text(
                        //   timeAgo(item.date ?? DateTime.now()),
                        //   style: AppStyles.getBoldTextStyle(
                        //       fontSize: 12, fontColor: Colors.grey),
                        // )
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        }),
        floatingActionButton: CustomElevatedButton(
          prefixIcon: Icons.add,
          radius: 32,
          buttonText: 'Add Periodic service',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => AddPeriodicServiceMobile(
                  amcId: '0', customerId: widget.customerId, isEdit: false),
            ),
          ),
          backgroundColor: AppColors.bluebutton,
          borderColor: AppColors.bluebutton,
          textColor: AppColors.whiteColor,
        ));
  }

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
