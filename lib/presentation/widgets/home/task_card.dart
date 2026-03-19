import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/widgets/customer/task_details_page_phone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/chat_launcher.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';

class TaskCard extends StatelessWidget {
  final TaskReportModel task;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(BuildContext, TaskReportModel) showStatusUpdate;

  const TaskCard({
    super.key,
    required this.task,
    required this.isExpanded,
    required this.onTap,
    required this.showStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    Color getStatusColor(String statusName) {
      statusName = statusName.toUpperCase();
      if (statusName.contains('FOLLOW-UP')) return Colors.blue;
      if (statusName.contains('NEW')) return Colors.green;
      if (statusName.contains('AMC')) return Colors.grey;
      if (statusName.contains('HOT')) return Colors.red;
      // Default to task.colorCode if available, else primaryBlue
      return task.colorCode ?? AppColors.primaryBlue;
    }

    final statusColor = getStatusColor(task.taskStatusName);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // FIRST LINE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.customerName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Text(
                          task.taskDate.toFormattedDate(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textGrey3,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: AppColors.textGrey3,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // SECOND LINE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        task.taskTypeName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // STATUS BADGE
                    GestureDetector(
                      onTap: () => showStatusUpdate(context, task),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          task.taskStatusName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description.isNotEmpty) ...[
                  Text(
                    "Description",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (task.nextFollowupDate != null &&
                    task.nextFollowupDate!.isNotEmpty) ...[
                  Text(
                    "Next Follow-up",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.nextFollowupDate!.toFormattedDate(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGrey3,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildChatButton(context)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildViewButton(context)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildCallButton(context)),
                        const Expanded(child: SizedBox()), // Placeholder to match spacing
                        const Expanded(child: SizedBox()), // Placeholder to match spacing
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: _buildTaskButton(context)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildDocsButton(context)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildEditButton(context)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildQuoteButton(context)),
                        const Expanded(child: SizedBox()), // Placeholder to match spacing
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return CustomActionButton(
      onTap: () async {
        String phone = task.mobile;

        if (phone.isEmpty) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            final leadDetailsProvider =
                Provider.of<LeadDetailsProvider>(context, listen: false);
            await leadDetailsProvider
                .fetchLeadDetailsNoContext(task.customerId.toString());

            if (leadDetailsProvider.leadDetails != null &&
                leadDetailsProvider.leadDetails!.isNotEmpty) {
              phone = leadDetailsProvider.leadDetails![0].contactNumber;
            }
          } catch (e) {
            print("Error fetching fallback phone: $e");
          } finally {
            if (context.mounted) {
              Navigator.pop(context);
            }
          }
        }

        if (phone.isNotEmpty) {
          ChatLauncher.handleChat(context, phone);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Mobile number not found for this customer')),
          );
        }
      },
      imageColor: AppColors.textGreen,
      icon: FontAwesomeIcons.whatsapp,
      text: 'Chat',
      height: 38,
    );
  }

  Widget _buildViewButton(BuildContext context) {
    return CustomActionButton(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsPagePhone(
              taskId: task.taskId.toString(),
              taskMasterId: task.taskMasterId.toString(),
              customerId: task.customerId.toString(),
            ),
          ),
        );
      },
      imageColor: AppColors.appViolet,
      icon: Icons.visibility_outlined,
      text: 'View',
      height: 38,
    );
  }

  Widget _buildCallButton(BuildContext context) {
    return CustomActionButton(
      onTap: () async {
        final Uri phoneUri = Uri(scheme: 'tel', path: task.mobile);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
      },
      imageColor: AppColors.bluebutton,
      icon: Icons.call,
      text: 'Call',
      height: 38,
    );
  }

  Widget _buildTaskButton(BuildContext context) {
    return CustomActionButton(
      imageColor: AppColors.btnRed,
      onTap: () async {
        final customerDetailsProvider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        customerDetailsProvider.customerId = task.customerId.toString();
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
    );
  }

  Widget _buildDocsButton(BuildContext context) {
    return CustomActionButton(
      imageColor: AppColors.appViolet,
      onTap: () {
        final customerDetailsProvider =
            Provider.of<CustomerDetailsProvider>(context, listen: false);
        customerDetailsProvider.customerId = task.customerId.toString();
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return AddDocumentPhone(customerId: task.customerId.toString());
          },
        ));
      },
      icon: Icons.upload_file,
      text: 'Docs',
      height: 38,
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return CustomActionButton(
      imageColor: AppColors.secondaryBlue,
      onTap: () async {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        final leadDetailsProvider =
            Provider.of<LeadDetailsProvider>(context, listen: false);
        await leadDetailsProvider.fetchLeadDetails(
            task.customerId.toString(), context);

        final leadsProvider =
            Provider.of<LeadsProvider>(context, listen: false);
        leadsProvider.setCutomerId(task.customerId);
        final dropDownProvider =
            Provider.of<DropDownProvider>(context, listen: false);
        final leadDetails = leadDetailsProvider.leadDetails![0];
        leadsProvider.enquirySourceController.text =
            leadDetails.enquirySourceName.toString();

        dropDownProvider.selectedEnquirySourceId = leadDetails.enquirySourceId;
        await leadsProvider.getLeadDropdowns(context);
        if (context.mounted) {
          Navigator.pop(context); // Close loading dialog
        }

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return const NewLeadDrawerWidget(
                isEdit: true,
              );
            },
          );
        }
      },
      icon: Icons.edit_outlined,
      text: 'Edit',
      height: 38,
    );
  }

  Widget _buildQuoteButton(BuildContext context) {
    return CustomActionButton(
      imageColor: AppColors.bluebutton,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => QuotationCreationWidget(
              customerId: task.customerId.toString(),
              quotationId: '0',
              isEdit: false,
            ),
          ),
        );
      },
      icon: Icons.request_quote_outlined,
      text: 'Quote',
      height: 38,
    );
  }
}
