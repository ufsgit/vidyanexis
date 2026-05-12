import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/task_report_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:vidyanexis/utils/chat_launcher.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/leads_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';

class TaskCard extends StatefulWidget {
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
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String userType = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      // userId = int.tryParse(preferences.getString('userId') ?? "0") ?? 0;
      // userName = preferences.getString('userName') ?? "";
      userType = preferences.getString('userType') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final mappedEnquiryForName = dropDownProvider.getEnquiryForNameById(
        widget.task.enquiryForId, widget.task.enquiryForName);



    return Column(
      children: [
        InkWell(
          onTap: () => widget.showStatusUpdate(context, widget.task),
          child: Container(
            width: MediaQuery.sizeOf(context).width,
            color: AppColors.whiteColor,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: getAvatarColor(widget.task.customerName)
                          .withOpacity(.4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.task.customerName,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlack,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ID ${widget.task.customerId}',
                              style: TextStyle(
                                color: AppColors.textGrey3,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.task.taskTypeName,
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: (widget.task.colorCode ??
                                        AppColors.primaryBlue)
                                    .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.task.taskStatusName.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: widget.task.colorCode ??
                                      AppColors.primaryBlue,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (userType == "1") ...[
                          const SizedBox(height: 4),
                          Text(
                            'To ${widget.task.toUserName}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textBlack,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.task.taskDate.toFormattedDate(),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Icon(
                          widget.isExpanded
                              ? Icons.keyboard_arrow_up_outlined
                              : Icons.keyboard_arrow_down_outlined,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mappedEnquiryForName.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        "Enquiry For",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mappedEnquiryForName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.task.description.isNotEmpty) ...[
                  Row(
                    children: [
                      Text(
                        "Description",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.task.description,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textGrey3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (widget.task.nextFollowupDate != null &&
                    widget.task.nextFollowupDate!.isNotEmpty) ...[
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
                    widget.task.nextFollowupDate!.toFormattedDate(),
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
                        if (settingsProvider.menuIsViewMap[91] == 1)
                          Expanded(child: _buildChatButton(context)),
                        const SizedBox(width: 4),
                        if (settingsProvider.menuIsViewMap[95] == 1)
                          Expanded(child: _buildViewButton(context)),
                        const SizedBox(width: 4),
                        if (settingsProvider.menuIsViewMap[92] == 1)
                          Expanded(child: _buildCallButton(context)),
                        const Expanded(
                            child: SizedBox()), // Placeholder to match spacing
                        const Expanded(
                            child: SizedBox()), // Placeholder to match spacing
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (settingsProvider.menuIsSaveMap[13] == 1)
                          Expanded(child: _buildTaskButton(context)),
                        const SizedBox(width: 4),
                        if (settingsProvider.menuIsSaveMap[19] == 1)
                          Expanded(child: _buildDocsButton(context)),
                        const SizedBox(width: 4),
                        if (settingsProvider.menuIsEditMap[13] == 1)
                          Expanded(child: _buildEditButton(context)),
                        const SizedBox(width: 4),
                        if (settingsProvider.menuIsSaveMap[16] == 1)
                          Expanded(child: _buildQuoteButton(context)),
                        const Expanded(
                            child: SizedBox()), // Placeholder to match spacing
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
        String phone = widget.task.mobile;

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
                .fetchLeadDetailsNoContext(widget.task.customerId.toString());

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
            builder: (context) => CustomerDetailPageMobile(
              customerId: widget.task.customerId,
              fromLead: true,
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
        final Uri phoneUri = Uri(scheme: 'tel', path: widget.task.mobile);
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
        customerDetailsProvider.customerId = widget.task.customerId.toString();
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
        customerDetailsProvider.customerId = widget.task.customerId.toString();
        Navigator.push(context, MaterialPageRoute(
          builder: (context) {
            return AddDocumentPhone(
                customerId: widget.task.customerId.toString());
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
            widget.task.customerId.toString(), context);

        final leadsProvider =
            Provider.of<LeadsProvider>(context, listen: false);
        leadsProvider.setCutomerId(widget.task.customerId);
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
              customerId: widget.task.customerId.toString(),
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
