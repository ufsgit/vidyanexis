import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/controller/models/search_leads_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_follow_up_dialog.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/utils/util_functions.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_periodic_service_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';

class LeadCard extends StatefulWidget {
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
  State<LeadCard> createState() => _LeadCardState();
}

class _LeadCardState extends State<LeadCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadCheckInProvider>(context, listen: false)
          .initLocalStatus(widget.lead.customerId);
    });
  }

  void _showConvertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Convert'),
          content: const Text('Are you sure you want to convert this lead?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                final leadsProvider =
                    Provider.of<LeadsProvider>(context, listen: false);
                await leadsProvider.convertLead(
                    context, widget.lead.customerId.toString());
              },
              child: const Text(
                'Convert',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }

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
          onTap: widget.onTap,
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
                          Container(
                            height: 62,
                            width: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: getAvatarColor(widget.lead.customerName)
                                  .withOpacity(.4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.lead.customerName,
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
                                    'ID ${widget.lead.customerId}',
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
                                  widget.lead.statusName,
                                  overflow: TextOverflow.clip,
                                  maxLines: 2,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.parseColor(
                                          widget.lead.colorCode)),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  widget.lead.remark,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.textGrey4),
                                ),
                                Text(
                                  'Created By ${widget.lead.createdByName}',
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
                                  Text(
                                    widget.lead.nextFollowUpDate
                                        .toFormattedDate(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: widget.lead.lateFollowUp == 0
                                          ? AppColors.statusGreen
                                          : AppColors.btnRed,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                widget.isExpanded
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
        // if (widget.isExpanded) const SizedBox(height: 12),
        if (widget.isExpanded) const SizedBox(height: 12),
        if (widget.isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.textGreen,
                        onTap: () async {
                          String formatted = formatIndianPhoneNumber(
                              widget.lead.contactNumber.toString());

                          if (formatted.isNotEmpty) {
                            final url = 'https://wa.me/$formatted';
                            await launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Invalid Indian mobile number')),
                            );
                          }
                        },
                        icon: Icons.chat_bubble_outline,
                        text: 'Chat',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.appViolet,
                        onTap: widget.isLead
                            ? () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerDetailPageMobile(
                                            fromLead: true,
                                            customerId: widget.lead.customerId,
                                            lead: widget.lead,
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
                                            customerId: widget.lead.customerId,
                                            lead: widget.lead,
                                          )),
                                );
                              },
                        icon: Icons.visibility_outlined,
                        text: 'View',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        onTap: () {
                          leadsProvider.statusController.clear();
                          leadsProvider.searchUserController.clear();
                          leadsProvider.messageController.clear();
                          leadsProvider.nextFollowUpDateController.clear();
                          try {
                            final dropDownProvider =
                                Provider.of<DropDownProvider>(context,
                                    listen: false);
                            dropDownProvider.selectedStatusId =
                                int.parse(widget.lead.statusId.toString());
                            leadsProvider.statusController.text =
                                widget.lead.statusName;
                            dropDownProvider.selectedUserId =
                                int.parse(widget.lead.toUserId.toString());
                            leadsProvider.searchUserController.text =
                                widget.lead.toUserName;
                            leadsProvider.setCutomerId(widget.lead.customerId);
                            leadsProvider.branchController.text =
                                widget.lead.branchName;
                            settingsProvider.selectedBranchId =
                                widget.lead.branchId;
                            leadsProvider.departmentController.text =
                                widget.lead.departmentName;
                            settingsProvider.selectedDepartmentId =
                                int.tryParse(
                                        widget.lead.departmentId.toString()) ??
                                    0;

                            leadsProvider.nextFollowUpDateController.text =
                                widget.lead.nextFollowUpDate.isNotEmpty
                                    ? _formatDateSafely(
                                        widget.lead.nextFollowUpDate)
                                    : '';
                            leadsProvider.messageController.clear();
                            dropDownProvider.filterStaffByBranchAndDepartment(
                              branchId: widget.lead.branchId,
                              departmentId: int.tryParse(
                                      widget.lead.departmentId.toString()) ??
                                  0,
                            );
                          } catch (e) {}
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddFollowupDialog(
                                customerName: widget.lead.customerName,
                              );
                            },
                          ));
                        },
                        imageColor: widget.lead.lateFollowUp == 0
                            ? AppColors.darkGreen
                            : AppColors.textRed,
                        icon: Icons.note_add_outlined,
                        text: 'Note',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.bluebutton,
                        onTap: () async {
                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: widget.lead.contactNumber,
                          );
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          } else {
                            print('Could not launch phone app');
                          }
                        },
                        icon: Icons.call,
                        text: 'Call',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Consumer<LeadCheckInProvider>(
                        builder: (context, checkInProvider, child) {
                          final isCheckedIn = checkInProvider
                              .isCheckedIn(widget.lead.customerId);

                          return isCheckedIn
                              ? CustomActionButton(
                                  onTap: () {
                                    checkInProvider.saveLeadCheckIn(
                                      context: context,
                                      customerId: widget.lead.customerId,
                                      isCheckIn: false,
                                      leadName: widget.lead.customerName,
                                    );
                                  },
                                  icon: Icons.location_off_outlined,
                                  text: 'In/Out',
                                  imageColor: Colors.red,
                                  height: 38,
                                )
                              : CustomActionButton(
                                  onTap: () {
                                    checkInProvider.saveLeadCheckIn(
                                      context: context,
                                      customerId: widget.lead.customerId,
                                      isCheckIn: true,
                                      leadName: widget.lead.customerName,
                                    );
                                  },
                                  icon: Icons.location_on_outlined,
                                  text: 'In/Out',
                                  imageColor: Colors.green,
                                  height: 38,
                                );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.btnRed,
                        onTap: () async {
                          final customerDetailsProvider =
                              Provider.of<CustomerDetailsProvider>(context,
                                  listen: false);
                          customerDetailsProvider.customerId =
                              widget.lead.customerId.toString();
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
                        text: 'Task',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.appViolet,
                        onTap: () {
                          final customerDetailsProvider =
                              Provider.of<CustomerDetailsProvider>(context,
                                  listen: false);
                          customerDetailsProvider.customerId =
                              widget.lead.customerId.toString();
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddDocumentPhone(
                                  customerId:
                                      widget.lead.customerId.toString());
                            },
                          ));
                        },
                        icon: Icons.upload_file,
                        text: 'Docs',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.secondaryBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => AddPeriodicServiceMobile(
                                amcId: '0',
                                customerId: widget.lead.customerId.toString(),
                                isEdit: false,
                              ),
                            ),
                          );
                        },
                        icon: Icons.miscellaneous_services,
                        text: 'Service',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: AppColors.bluebutton,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => QuotationCreationWidget(
                                customerId: widget.lead.customerId.toString(),
                                quotationId: '0',
                                isEdit: false,
                              ),
                            ),
                          );
                        },
                        icon: Icons.request_quote_outlined,
                        text: 'Quotation',
                        height: 38,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: CustomActionButton(
                        imageColor: Colors.green,
                        onTap: _showConvertDialog,
                        icon: Icons.change_circle_outlined,
                        text: 'Convert',
                        height: 38,
                      ),
                    ),

                  ],
                ),


              ],
            ),
          ),
        if (widget.isExpanded) const SizedBox(height: 12),
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
