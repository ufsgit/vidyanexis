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
import 'package:vidyanexis/presentation/widgets/customer/add_task_mobile.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_action_widget.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/utils/extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/controller/lead_check_in_provider.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_document_phone.dart';
import 'package:vidyanexis/presentation/widgets/customer/add_quotation.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/new_drawer_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:vidyanexis/controller/models/search_user_details_model.dart';

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
  bool _isInternalMoreExpanded = false;

  @override
  void didUpdateWidget(covariant LeadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded && oldWidget.isExpanded) {
      if (mounted) {
        setState(() {
          _isInternalMoreExpanded = false;
        });
      }
    } else if (widget.isExpanded && !oldWidget.isExpanded) {
      _initializeNoteData();
    }
  }

  void _initializeNoteData() {
    final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);
    final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    try {
      dropDownProvider.selectedStatusId = int.parse(widget.lead.statusId.toString());
      leadsProvider.statusController.text = widget.lead.statusName;
      dropDownProvider.selectedUserId = int.parse(widget.lead.toUserId.toString());
      leadsProvider.searchUserController.text = widget.lead.toUserName;
      leadsProvider.branchController.text = widget.lead.branchName;
      settingsProvider.selectedBranchId = widget.lead.branchId;
      leadsProvider.departmentController.text = widget.lead.departmentName;
      settingsProvider.selectedDepartmentId = int.tryParse(widget.lead.departmentId.toString()) ?? 0;
      leadsProvider.nextFollowUpDateController.text = widget.lead.nextFollowUpDate.isNotEmpty ? _formatDateSafely(widget.lead.nextFollowUpDate) : '';
      leadsProvider.messageController.clear();
      dropDownProvider.filterStaffByBranchAndDepartment(
        branchId: widget.lead.branchId,
        departmentId: int.tryParse(widget.lead.departmentId.toString()) ?? 0,
      );
    } catch (e) {}
  }

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
                Navigator.pop(context);
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
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

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
        Container(
          width: MediaQuery.sizeOf(context).width,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.whiteColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header Section
              GestureDetector(
                onTap: widget.onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 62,
                        width: 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: getAvatarColor(widget.lead.customerName).withOpacity(.4),
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
                                    widget.lead.customerName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textBlack),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ID ${widget.lead.customerId}',
                                  style: TextStyle(
                                    color: AppColors.textGrey3,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.lead.statusName,
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.parseColor(widget.lead.colorCode)),
                                  ),
                                  TextSpan(
                                    text: ' , Created By ${widget.lead.createdByName}',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textBlack),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            if (widget.lead.remark.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.lead.remark,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textGrey4),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.lead.nextFollowUpDate.toFormattedDate(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: widget.lead.lateFollowUp == 0
                                  ? AppColors.statusGreen
                                  : AppColors.btnRed,
                            ),
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
                ),
              ),

              // Expanded Content
              if (widget.isExpanded)
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Column(
                    children: [
                      // Toggleable Note Section
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Consumer<DropDownProvider>(
                              builder: (context, dropDownProvider, child) {
                                return Column(
                                  children: [
                                    // Status Selection Chips
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: dropDownProvider.followUpData.map((status) {
                                          final isSelected = dropDownProvider.selectedStatusId == status.statusId;
                                          return GestureDetector(
                                            onTap: () {
                                              dropDownProvider.setSelectedStatusId(status.statusId ?? 0);
                                              leadsProvider.getCustomFieldsByStatusId(
                                                  context,
                                                  leadId: leadsProvider.customerId,
                                                  statusId: status.statusId ?? 0);
                                              leadsProvider.statusController.text = status.statusName ?? '';
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: isSelected ? AppColors.bluebutton.withOpacity(0.1) : Colors.grey[100],
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: isSelected ? AppColors.bluebutton : Colors.transparent),
                                              ),
                                              child: Text(
                                                status.statusName?.toUpperCase() ?? '',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 11,
                                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                                  color: isSelected ? AppColors.bluebutton : Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),

                                    if (_isInternalMoreExpanded) ...[
                                      const SizedBox(height: 8),
                                      // Branch Selection Chips
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Branch*', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: settingsProvider.branchModel.map((branch) {
                                              final isSelected = settingsProvider.selectedBranchId == branch.branchId;
                                              return GestureDetector(
                                                onTap: () {
                                                  settingsProvider.selectedBranchId = branch.branchId;
                                                  leadsProvider.branchController.text = branch.branchName ?? '';
                                                  settingsProvider.setSelectedDepartmentId(0);
                                                  leadsProvider.departmentController.clear();
                                                  dropDownProvider.setSelectedUserId(0);
                                                  leadsProvider.searchUserController.clear();
                                                  dropDownProvider.filterStaffByBranchAndDepartment(
                                                    branchId: branch.branchId,
                                                    departmentId: null,
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.bluebutton.withOpacity(0.1) : Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isSelected ? AppColors.bluebutton : Colors.transparent),
                                                  ),
                                                  child: Text(
                                                    branch.branchName?.toUpperCase() ?? '',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? AppColors.bluebutton : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Department Selection Chips
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Department', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              const Expanded(child: Divider(thickness: 1, color: Color(0xFFEEEEEE))),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: settingsProvider.departmentModel.map((dept) {
                                              final isSelected = settingsProvider.selectedDepartmentId == dept.departmentId;
                                              return GestureDetector(
                                                onTap: () {
                                                  settingsProvider.setSelectedDepartmentId(dept.departmentId);
                                                  leadsProvider.departmentController.text = dept.departmentName;
                                                  dropDownProvider.setSelectedUserId(0);
                                                  leadsProvider.searchUserController.clear();
                                                  dropDownProvider.filterStaffByBranchAndDepartment(
                                                    branchId: settingsProvider.selectedBranchId,
                                                    departmentId: dept.departmentId,
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.bluebutton.withOpacity(0.1) : Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isSelected ? AppColors.bluebutton : Colors.transparent),
                                                  ),
                                                  child: Text(
                                                    dept.departmentName.toUpperCase(),
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? AppColors.bluebutton : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      // Staff Selection Chips
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text('Assigned Staff*', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold)),
                                              const SizedBox(width: 8),
                                              const Expanded(child: Divider(thickness: 1, color: Color(0xFFEEEEEE))),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: dropDownProvider.filteredStaffData.map((user) {
                                              final isSelected = dropDownProvider.selectedUserId == user.userDetailsId;
                                              return GestureDetector(
                                                onTap: () {
                                                  dropDownProvider.setSelectedUserId(user.userDetailsId);
                                                  leadsProvider.searchUserController.text = user.userDetailsName;
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.bluebutton.withOpacity(0.1) : Colors.grey[100],
                                                    borderRadius: BorderRadius.circular(8),
                                                    border: Border.all(color: isSelected ? AppColors.bluebutton : Colors.transparent),
                                                  ),
                                                  child: Text(
                                                    user.userDetailsName?.toUpperCase() ?? '',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 11,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                      color: isSelected ? AppColors.bluebutton : Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      CustomTextField(
                                        readOnly: true,
                                        controller: leadsProvider.nextFollowUpDateController,
                                        hintText: 'Next Follow-up Date*',
                                        onTap: () async {
                                          final date = await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime(2100));
                                          if (date != null) {
                                            leadsProvider.nextFollowUpDateController.text =
                                                DateFormat('yyyy-MM-dd').format(date);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      CustomTextField(
                                        controller: leadsProvider.messageController,
                                        hintText: 'Remarks',
                                        maxLines: 3,
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () => setState(() => _isInternalMoreExpanded = !_isInternalMoreExpanded),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _isInternalMoreExpanded ? 'Less' : 'More',
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.bluebutton,
                                                ),
                                              ),
                                              Icon(
                                                _isInternalMoreExpanded
                                                    ? Icons.keyboard_arrow_up_outlined
                                                    : Icons.keyboard_arrow_down_outlined,
                                                color: AppColors.bluebutton,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 90,
                                          height: 32,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              final selectedUser = dropDownProvider.filteredStaffData.firstWhere(
                                                (u) => u.userDetailsId == dropDownProvider.selectedUserId,
                                                orElse: () => SearchUserDetails(userDetailsId: 0, userDetailsName: ''),
                                              );
                                              await leadsProvider.saveFollowUp(
                                                statusId: dropDownProvider.selectedStatusId ?? 0,
                                                statusName: leadsProvider.statusController.text,
                                                branchId: settingsProvider.selectedBranchId ?? 0,
                                                branchName: leadsProvider.branchController.text,
                                                departmentId: settingsProvider.selectedDepartmentId,
                                                departmentName: leadsProvider.departmentController.text,
                                                context: context,
                                                toUserId: dropDownProvider.selectedUserId ?? 0,
                                                toUserName: selectedUser.userDetailsName,
                                                followUpDate: leadsProvider.nextFollowUpDateController.text,
                                                custId: int.parse(widget.lead.customerId.toString()),
                                                followUp: leadsProvider.nextFollowUpDateController.text.isNotEmpty ? 1 : 0,
                                                message: leadsProvider.messageController.text,
                                                audioFiles: [],
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.bluebutton,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            child: Text('Save', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                                );
                              },
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      // Action Buttons Row 1
                      Row(
                        children: [
                          _buildActionButton(
                            onTap: () async {
                              final url = 'https://wa.me/91${widget.lead.contactNumber}';
                              if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
                            },
                            icon: Icons.chat_bubble_outline,
                            text: 'Chat',
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => CustomerDetailPageMobile(
                                fromLead: widget.isLead,
                                customerId: widget.lead.customerId,
                                lead: widget.lead,
                              ),
                            )),
                            icon: Icons.visibility_outlined,
                            text: 'View',
                            color: AppColors.appViolet,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: () async {
                              final url = 'tel:${widget.lead.contactNumber}';
                              if (await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url));
                            },
                            icon: Icons.call,
                            text: 'Call',
                            color: AppColors.bluebutton,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Consumer<LeadCheckInProvider>(
                              builder: (context, checkInProvider, child) {
                                final isCheckedIn = checkInProvider.isCheckedIn(widget.lead.customerId);
                                return CustomActionButton(
                                  onTap: () {
                                    checkInProvider.saveLeadCheckIn(
                                      context: context,
                                      customerId: widget.lead.customerId,
                                      isCheckIn: !isCheckedIn,
                                      leadName: widget.lead.customerName,
                                    );
                                  },
                                  icon: isCheckedIn ? Icons.location_off_outlined : Icons.location_on_outlined,
                                  text: 'In/Out',
                                  imageColor: isCheckedIn ? Colors.red : Colors.green,
                                  height: 38,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Action Buttons Row 2
                      Row(
                        children: [
                          _buildActionButton(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AddTaskMobile(isEdit: false, taskId: '0'),
                            )),
                            icon: Icons.task,
                            text: 'Task',
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (context) => AddDocumentPhone(customerId: widget.lead.customerId.toString()),
                            )),
                            icon: Icons.upload_file,
                            text: 'Docs',
                            color: AppColors.appViolet,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: () async {
                              showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                              final leadDetailsProvider = Provider.of<LeadDetailsProvider>(context, listen: false);
                              await leadDetailsProvider.fetchLeadDetails(widget.lead.customerId.toString(), context);
                              final leadsProvider = Provider.of<LeadsProvider>(context, listen: false);
                              leadsProvider.setCutomerId(int.tryParse(widget.lead.customerId.toString()) ?? 0);
                              final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);
                              final leadDetails = leadDetailsProvider.leadDetails![0];
                              leadsProvider.enquirySourceController.text = leadDetails.enquirySourceName.toString();
                              dropDownProvider.selectedEnquirySourceId = leadDetails.enquirySourceId;
                              await leadsProvider.getLeadDropdowns(context);
                              Navigator.pop(context);
                              showDialog(context: context, builder: (_) => const NewLeadDrawerWidget(isEdit: true));
                            },
                            icon: Icons.edit_outlined,
                            text: 'Edit',
                            color: AppColors.secondaryBlue,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: () => Navigator.push(context, MaterialPageRoute(
                              builder: (c) => QuotationCreationWidget(
                                customerId: widget.lead.customerId.toString(),
                                quotationId: '0',
                                isEdit: false,
                              ),
                            )),
                            icon: Icons.request_quote_outlined,
                            text: 'Quote',
                            color: AppColors.bluebutton,
                          ),
                          const SizedBox(width: 4),
                          _buildActionButton(
                            onTap: _showConvertDialog,
                            icon: Icons.change_circle_outlined,
                            text: 'Convert',
                            color: Colors.green,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (widget.isExpanded) const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildActionButton({required VoidCallback onTap, required IconData icon, required String text, required Color color}) {
    return Expanded(
      child: CustomActionButton(
        onTap: onTap,
        icon: icon,
        text: text,
        imageColor: color,
        height: 38,
      ),
    );
  }

  String _formatDateSafely(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '';
    }
  }
}
