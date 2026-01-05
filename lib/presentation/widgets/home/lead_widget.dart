import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

class LeadCard extends StatelessWidget {
  final SearchLeadModel lead;
  final bool isExpanded;
  final bool isLead;

  final VoidCallback onTap;

  const LeadCard({
    super.key,
    required this.lead,
    required this.isLead,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
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

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(color: AppColors.whiteColor),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stack(
                          //   children: [
                          //     SizedBox(
                          //       width: 35,
                          //       height: 35,
                          //       child: Container(
                          //         width: 30,
                          //         height: 30,
                          //         decoration: BoxDecoration(
                          //           color: getAvatarColor(lead.customerName),
                          //           borderRadius: BorderRadius.circular(100),
                          //         ),
                          //         child: Center(
                          //           child: Text(
                          //             lead.customerName
                          //                 .substring(0, 1)
                          //                 .toUpperCase(),
                          //             style: const TextStyle(
                          //               fontSize: 12,
                          //               color: Colors.white,
                          //               fontWeight: FontWeight.w600,
                          //             ),
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //     Positioned(
                          //       right: 0,
                          //       top: 0,
                          //       child: Container(
                          //         width: 12,
                          //         height: 12,
                          //         decoration: BoxDecoration(
                          //           color: lead.lateFollowUp == '0'
                          //               ? AppColors.darkGreen
                          //               : AppColors.textRed,
                          //           border: Border.all(
                          //             color: AppColors.whiteColor,
                          //             width: 1.5,
                          //           ),
                          //           borderRadius: BorderRadius.circular(100),
                          //         ),
                          //       ),
                          //     )
                          //   ],
                          // ),
                          Container(
                            height: 62,
                            width: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: getAvatarColor(lead.customerName)
                                  .withOpacity(.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lead.customerName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textBlack),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  lead.statusName,
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          AppColors.parseColor(lead.colorCode)),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  lead.remark,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textGrey4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  // Icon(
                                  //   Icons.calendar_month_outlined,
                                  //   size: 12,
                                  //   color: AppColors.textGrey3,
                                  // ),
                                  // const SizedBox(width: 4),
                                  Text(
                                    lead.nextFollowUpDate.toFormattedDate(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: lead.lateFollowUp == 0
                                          ? AppColors.statusGreen
                                          : AppColors.btnRed,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up_outlined
                                    : Icons.keyboard_arrow_down_outlined,
                                color: AppColors.textGrey3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // if (isExpanded) const SizedBox(height: 12),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ------------------------------------------------------------------
                // NEW UPDATED WHATSAPP LOGIC — PRIORITY:
                // 1. WhatsApp Business
                // 2. Normal WhatsApp
                // 3. WhatsApp Web
                // ------------------------------------------------------------------
                CustomActionButton(
                  imageColor: AppColors.textGreen,
                  onTap: () async {
                    String phone =
                        lead.contactNumber.replaceAll(RegExp(r'[^\d+]'), '');

                    // Add +91 if missing
                    if (!phone.startsWith('+')) {
                      phone = '+91$phone';
                    }

                    Uri waBusiness =
                        Uri.parse("whatsapp-business://send?phone=$phone");
                    Uri waNormal =
                        Uri.parse("whatsapp://send?phone=$phone");
                    Uri waWeb = Uri.parse(
                        "https://api.whatsapp.com/send?phone=$phone");

                    try {
                      // 1️⃣ USER has WhatsApp Business → open Business first
                      if (await canLaunchUrl(waBusiness)) {
                        await launchUrl(waBusiness,
                            mode: LaunchMode.externalApplication);
                        return;
                      }

                      // 2️⃣ USER has normal WhatsApp → open it
                      if (await canLaunchUrl(waNormal)) {
                        await launchUrl(waNormal,
                            mode: LaunchMode.externalApplication);
                        return;
                      }

                      // 3️⃣ Open WhatsApp Web if no app installed
                      await launchUrl(waWeb,
                          mode: LaunchMode.externalApplication);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Unable to open WhatsApp"),
                          ),
                        );
                      }
                    }
                  },
                  imagePath: "assets/images/lead_icon_1.png",
                  text: 'Chat',
                ),
                // ------------------------------------------------------------------

                const SizedBox(width: 15),
                CustomActionButton(
                  imageColor: AppColors.appViolet,
                  onTap: isLead
                      ? () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerDetailPageMobile(
                                      fromLead: true,
                                      customerId: lead.customerId,
                                      lead: lead,
                                    )),
                          );
                        }
                      : () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CustomerDetailPageMobile(
                                      fromLead: false,
                                      customerId: lead.customerId,
                                      lead: lead,
                                    )),
                          );
                        },
                  imagePath: 'assets/images/lead_icon_3.png',
                  text: 'View',
                  // imageColor: AppColors.violet,
                ),
                const SizedBox(width: 15),
                CustomActionButton(
                  onTap: () {
                    leadsProvider.statusController.clear();
                    leadsProvider.searchUserController.clear();
                    leadsProvider.messageController.clear();
                    leadsProvider.nextFollowUpDateController.clear();
                    try {
                      final dropDownProvider =
                          Provider.of<DropDownProvider>(context, listen: false);
                      dropDownProvider.selectedStatusId =
                          int.parse(lead.statusId.toString());
                      leadsProvider.statusController.text = lead.statusName;
                      print('status id ${lead.statusId}');
                      print('status name ${lead.statusName}');
                      dropDownProvider.selectedUserId =
                          int.parse(lead.toUserId.toString());
                      leadsProvider.searchUserController.text = lead.toUserName;
                      print('assign to ${lead.toUserName}');
                      print('assign to id ${lead.toUserId}');
                      leadsProvider.setCutomerId(lead.customerId);
                      leadsProvider.branchController.text = lead.branchName;
                      settingsProvider.selectedBranchId = lead.branchId;
                      print('branch ${lead.branchId}');
                      print('branch name ${lead.branchName}');
                      leadsProvider.departmentController.text =
                          lead.departmentName;
                      settingsProvider.selectedDepartmentId =
                          int.tryParse(lead.departmentId.toString()) ?? 0;
                      print('department id ${lead.departmentId}');
                      print('department name ${lead.departmentName}');

                      leadsProvider.nextFollowUpDateController.text =
                          lead.nextFollowUpDate.isNotEmpty
                              ? _formatDateSafely(lead.nextFollowUpDate)
                              : '';
                      leadsProvider.messageController.clear();
                      dropDownProvider.filterStaffByBranchAndDepartment(
                        branchId: lead.branchId,
                        departmentId:
                            int.tryParse(lead.departmentId.toString()) ?? 0,
                      );
                    } catch (e) {}
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return AddFollowupDialog(
                          customerName: lead.customerName,
                        );
                      },
                    ));
                    // showDialog(
                    //   barrierDismissible: true,
                    //   context: context,
                    //   builder: (BuildContext context) => AddFollowupDialog(
                    //     customerName: '- ${lead.customerName}',
                    //   ),
                    // );
                  },
                  imageColor: lead.lateFollowUp == 0
                      ? AppColors.darkGreen
                      : AppColors.textRed,
                  imagePath: lead.lateFollowUp == 0
                      ? 'assets/images/lead_icon_4.png'
                      : 'assets/images/lead_icon_4.png',
                  text: 'Note',
                ),
                const SizedBox(width: 15),
                CustomActionButton(
                  imageColor: AppColors.bluebutton,
                  onTap: () async {
                    final Uri phoneUri = Uri(
                      scheme: 'tel',
                      path: lead.contactNumber,
                    );
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      print('Could not launch phone app');
                    }
                  },
                  imagePath: "assets/images/lead_icon_2.png",
                  text: 'Call',
                ),
              ],
            ),
          ),
        if (isExpanded) const SizedBox(height: 12),
      ],
    );
  }

  void _showWhatsAppOptionsDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Choose WhatsApp'),
          content: const Text('Select which WhatsApp to open:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Try to open Normal WhatsApp
                final Uri normalWhatsappUri =
                    Uri.parse('whatsapp://send?phone=$phone');
                try {
                  if (await canLaunchUrl(normalWhatsappUri)) {
                    await launchUrl(normalWhatsappUri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Normal WhatsApp is not installed'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open Normal WhatsApp'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Normal WhatsApp'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                // Try to open WhatsApp Business
                final Uri businessWhatsappUri =
                    Uri.parse('whatsapp://send?phone=$phone');
                // For WhatsApp Business, the scheme might be different on some platforms
                // On Android, it's typically: intent://send?phone=$phone#Intent;package=com.whatsapp.w4b;end
                // But url_launcher handles this differently, so we'll use the web API as fallback
                final Uri webWhatsapp =
                    Uri.parse('https://api.whatsapp.com/send?phone=$phone');

                try {
                  // Try web WhatsApp which works for both
                  if (await canLaunchUrl(webWhatsapp)) {
                    await launchUrl(webWhatsapp,
                        mode: LaunchMode.externalApplication);
                  } else if (await canLaunchUrl(businessWhatsappUri)) {
                    await launchUrl(businessWhatsappUri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('WhatsApp Business is not installed'),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not open WhatsApp Business'),
                      ),
                    );
                  }
                }
              },
              child: const Text('WhatsApp Business'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

String _formatDateSafely(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    return ''; // Return an empty string if parsing fails
  }
}
