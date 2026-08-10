import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/travel_allowance_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/travel_allowance_provider.dart';

class TADetailsDialog extends StatefulWidget {
  final TravelAllowanceModel model;
  const TADetailsDialog({super.key, required this.model});

  @override
  State<TADetailsDialog> createState() => _TADetailsDialogState();
}

class _TADetailsDialogState extends State<TADetailsDialog> {
  final TextEditingController remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    remarkController.text = widget.model.adminRemark ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final taProvider = Provider.of<TravelAllowanceProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    // TA Approval is strictly controlled by existing Report Permission (menuIsViewMap 26/201)
    final bool canApprove =
        (settingsProvider.menuIsViewMap[26] ?? 0).toString() == '1' ||
            (settingsProvider.menuIsViewMap[201] ?? 0).toString() == '1';
    final model = widget.model;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: model.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(model.travelModeIcon,
                          color: model.statusColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Claim #${model.taId ?? ''} Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Submitted by ${model.userName ?? 'Employee'} on ${model.formattedTravelDate}',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: model.statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: model.statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    model.status ?? 'Pending',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: model.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Content Grid
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journey Info Section
                    _buildSectionHeader('Journey Details', Icons.map_rounded),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                                'From', model.fromLocation ?? '-'),
                          ),
                          const Icon(Icons.arrow_forward_rounded,
                              color: AppColors.secondaryBlue, size: 20),
                          Expanded(
                            child: _buildInfoItem('To', model.toLocation ?? '-',
                                alignRight: true),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid
                    _buildSectionHeader('Distance & Expenses Breakdown',
                        Icons.calculate_rounded),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildMetricCard(
                          'Start Odometer',
                          '${model.startOdometer ?? 0} KM',
                          Icons.speed_rounded,
                        ),
                        _buildMetricCard(
                          'End Odometer',
                          '${model.endOdometer ?? 0} KM',
                          Icons.speed_rounded,
                        ),
                        _buildMetricCard(
                          'Total Distance',
                          '${model.computedTotalKm.toStringAsFixed(1)} KM',
                          Icons.route_rounded,
                          color: AppColors.secondaryBlue,
                        ),
                        _buildMetricCard(
                          'Rate / KM',
                          '₹${model.ratePerKm ?? 0}',
                          Icons.currency_rupee_rounded,
                        ),
                        _buildMetricCard(
                          'Other Expenses',
                          '₹${model.otherExpenses ?? 0}',
                          Icons.receipt_long_rounded,
                        ),
                        _buildMetricCard(
                          'Total Claim Amount',
                          '₹${model.computedTotalAmount.toStringAsFixed(2)}',
                          Icons.payments_rounded,
                          color: const Color(0xFF16A34A),
                          isBold: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if ((model.otherExpenseRemark ?? '').isNotEmpty) ...[
                      _buildInfoItem(
                          'Other Expense Breakdown', model.otherExpenseRemark!),
                      const SizedBox(height: 12),
                    ],

                    if ((model.purpose ?? '').isNotEmpty) ...[
                      _buildInfoItem('Purpose / Description', model.purpose!),
                      const SizedBox(height: 12),
                    ],

                    // Attachment Link
                    if ((model.attachmentUrl ?? '').isNotEmpty) ...[
                      _buildSectionHeader(
                          'Attached Receipt', Icons.attach_file_rounded),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () async {
                          final uri = Uri.tryParse(model.attachmentUrl!);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBFDBFE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description_rounded,
                                  color: AppColors.secondaryBlue),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'View / Download Attachment Document',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondaryBlue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const Icon(Icons.open_in_new_rounded,
                                  size: 16, color: AppColors.secondaryBlue),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Approval History / Decision Audit Trail
                    if ((model.status ?? '').toLowerCase() == 'approved') ...[
                      const Divider(height: 24),
                      _buildSectionHeader(
                          'Approval History', Icons.verified_user_rounded),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _buildInfoItem(
                                  'Approved By',
                                  (model.approvedBy ?? '').isNotEmpty
                                      ? model.approvedBy!
                                      : 'Admin / Manager')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildInfoItem(
                                  'Approved Date/Time',
                                  (model.approvedAt ?? '').isNotEmpty
                                      ? model.approvedAt!
                                      : (model.createdDate ?? '-'))),
                        ],
                      ),
                      if ((model.adminRemark ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoItem('Approval Remarks', model.adminRemark!),
                      ],
                    ] else if ((model.status ?? '').toLowerCase() ==
                        'rejected') ...[
                      const Divider(height: 24),
                      _buildSectionHeader(
                          'Rejection History', Icons.report_problem_rounded),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                              child: _buildInfoItem(
                                  'Rejected By',
                                  (model.approvedBy ?? '').isNotEmpty
                                      ? model.approvedBy!
                                      : 'Admin / Manager')),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _buildInfoItem(
                                  'Rejected Date/Time',
                                  (model.approvedAt ?? '').isNotEmpty
                                      ? model.approvedAt!
                                      : (model.createdDate ?? '-'))),
                        ],
                      ),
                      if ((model.adminRemark ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildInfoItem('Rejection Reason', model.adminRemark!),
                      ],
                    ],

                    // Approval Action Section (If user has Report Permission)
                    if (canApprove) ...[
                      const Divider(height: 24),
                      _buildSectionHeader('Admin Decision & Remarks',
                          Icons.admin_panel_settings_rounded),
                      const SizedBox(height: 8),
                      TextField(
                        controller: remarkController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText:
                              'Enter approval/rejection remarks or payment reference details...',
                          hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await taProvider.updateTAStatus(
                                  context,
                                  model.taId!,
                                  'Approved',
                                  remark: remarkController.text.trim(),
                                );
                                if (mounted) Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.check_circle_rounded,
                                  size: 18),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final remarkText = remarkController.text.trim();
                                if (remarkText.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please enter a rejection reason in the remarks field.')),
                                  );
                                  return;
                                }
                                await taProvider.updateTAStatus(
                                  context,
                                  model.taId!,
                                  'Rejected',
                                  remark: remarkText,
                                );
                                if (mounted) Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.cancel_rounded, size: 18),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await taProvider.updateTAStatus(
                                  context,
                                  model.taId!,
                                  'Paid',
                                  remark: remarkController.text.trim(),
                                );
                                if (mounted) Navigator.of(context).pop();
                              },
                              icon:
                                  const Icon(Icons.task_alt_rounded, size: 18),
                              label: const Text('Mark Paid'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondaryBlue),
        const SizedBox(width: 6),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon,
      {Color? color, bool isBold = false}) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[700]!).withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: (color ?? Colors.grey[300]!).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color ?? Colors.grey[700]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 11, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
