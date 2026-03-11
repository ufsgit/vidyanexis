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
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_detail_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/lead_details_page_phone.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/utils/util_functions.dart';

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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                const SizedBox(width: 6),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Text(
                                    'ID ${lead.customerId}',
                                    style: TextStyle(
                                      color: AppColors.textGrey3,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
                                Text(
                                  'Created By ${lead.createdByName}',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textBlack),
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
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ------------------------------------------------------------------
                  const SizedBox(width: 10),
                  CustomActionButton(
                    imageColor: AppColors.btnRed,
                    onTap: () async {
                      final customerDetailsProvider =
                          Provider.of<CustomerDetailsProvider>(context,
                              listen: false);
                      customerDetailsProvider.customerId =
                          lead.customerId.toString();
                      customerDetailsProvider.clearTaskDetails();
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return AddTaskMobile(
                            isEdit: false,
                            taskId: '0',
                          );
                        },
                      ));
                    },
                    icon: Icons.task,
                    text: 'Add Task',
                  ),

                  // ------------------------------------------------------------------
                  // ------------------------------------------------------------------
                  // NEW UPDATED WHATSAPP LOGIC — PRIORITY:
                  // formatIndianNumber Safe Implementation
                  // ------------------------------------------------------------------
                  const SizedBox(width: 10),
                  CustomActionButton(
                    imageColor: AppColors.textGreen,
                    onTap: () async {
                      String formatted = formatIndianPhoneNumber(
                          lead.contactNumber.toString());

                      if (formatted.isNotEmpty) {
                        final url = 'https://wa.me/$formatted';
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Invalid Indian mobile number')),
                        );
                      }
                    },
                    icon: Icons.chat_bubble_outline,
                    text: 'Chat',
                  ),
                  // ------------------------------------------------------------------

                  const SizedBox(width: 10),
                  CustomActionButton(
                    imageColor: AppColors.appViolet,
                    onTap: isLead
                        ? () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CustomerDetailPageMobile(
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
                                  builder: (context) =>
                                      CustomerDetailPageMobile(
                                        fromLead: false,
                                        customerId: lead.customerId,
                                        lead: lead,
                                      )),
                            );
                          },
                    icon: Icons.visibility_outlined,
                    text: 'View',
                    // imageColor: AppColors.violet,
                  ),
                  const SizedBox(width: 10),
                  CustomActionButton(
                    onTap: () {
                      leadsProvider.statusController.clear();
                      leadsProvider.searchUserController.clear();
                      leadsProvider.messageController.clear();
                      leadsProvider.nextFollowUpDateController.clear();
                      try {
                        final dropDownProvider = Provider.of<DropDownProvider>(
                            context,
                            listen: false);
                        dropDownProvider.selectedStatusId =
                            int.parse(lead.statusId.toString());
                        leadsProvider.statusController.text = lead.statusName;
                        print('status id ${lead.statusId}');
                        print('status name ${lead.statusName}');
                        dropDownProvider.selectedUserId =
                            int.parse(lead.toUserId.toString());
                        leadsProvider.searchUserController.text =
                            lead.toUserName;
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
                    icon: Icons.note_add_outlined,
                    text: 'Note',
                  ),
                  const SizedBox(width: 10),
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
                    icon: Icons.call,
                    text: 'Call',
                  ),
                  const SizedBox(width: 10),
                  Consumer<LeadCheckInProvider>(
                    builder: (context, checkInProvider, child) {
                      final isCheckedIn =
                          checkInProvider.isCheckedIn(lead.customerId);

                      return isCheckedIn
                          ? CustomActionButton(
                              onTap: () {
                                checkInProvider.saveLeadCheckIn(
                                  context: context,
                                  customerId: lead.customerId,
                                  isCheckIn: false,
                                  leadName: lead.customerName,
                                );
                              },
                              icon: Icons.location_off_outlined,
                              text: 'Check Out',
                              imageColor: Colors.red,
                            )
                          : CustomActionButton(
                              onTap: () {
                                checkInProvider.saveLeadCheckIn(
                                  context: context,
                                  customerId: lead.customerId,
                                  isCheckIn: true,
                                  leadName: lead.customerName,
                                );
                              },
                              icon: Icons.location_on_outlined,
                              text: 'Check In',
                              imageColor: Colors.green,
                            );
                    },
                  ),
                ],
              ),
            ),
          ),
        if (isExpanded) const SizedBox(height: 12),
      ],
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
