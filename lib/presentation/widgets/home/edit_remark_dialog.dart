import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/lead_details_provider.dart';

class EditRemarkDialog extends StatefulWidget {
  final String customerId;
  final String followUpId;
  final String initialRemark;
  final int? statusId;
  final String? statusName;
  final int? toUserId;
  final String? toUserName;
  final String? followUpDate;

  const EditRemarkDialog({
    super.key,
    required this.customerId,
    required this.followUpId,
    required this.initialRemark,
    this.statusId,
    this.statusName,
    this.toUserId,
    this.toUserName,
    this.followUpDate,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String customerId,
    required String followUpId,
    required String initialRemark,
    int? statusId,
    String? statusName,
    int? toUserId,
    String? toUserName,
    String? followUpDate,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => EditRemarkDialog(
        customerId: customerId,
        followUpId: followUpId,
        initialRemark: initialRemark,
        statusId: statusId,
        statusName: statusName,
        toUserId: toUserId,
        toUserName: toUserName,
        followUpDate: followUpDate,
      ),
    );
  }

  @override
  State<EditRemarkDialog> createState() => _EditRemarkDialogState();
}

class _EditRemarkDialogState extends State<EditRemarkDialog> {
  late TextEditingController _remarkController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.initialRemark);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final text = _remarkController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Remark cannot be empty.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final leadDetailsProvider =
          Provider.of<LeadDetailsProvider>(context, listen: false);
      final customerDetailsProvider =
          Provider.of<CustomerDetailsProvider>(context, listen: false);

      final success = await leadDetailsProvider.updateRemark(
        context: context,
        customerId: widget.customerId,
        followUpId: widget.followUpId,
        updatedRemark: text,
        statusId: widget.statusId,
        statusName: widget.statusName,
        toUserId: widget.toUserId,
        toUserName: widget.toUserName,
        followUpDate: widget.followUpDate,
      );

      if (success) {
        // Also refresh customer details follow up history if customerId is present
        if (widget.customerId.isNotEmpty) {
          try {
            await customerDetailsProvider.getFollowUpHistory(
              widget.customerId,
              context,
            );
          } catch (_) {}
        }

        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to update remark. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = isWeb ? 480.0 : screenWidth * 0.92;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: isWeb ? 40.0 : 16.0,
        vertical: 24.0,
      ),
      child: Container(
        width: dialogWidth,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Remark',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Modify saved remark content',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textGrey3,
                    splashRadius: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),

              // Remark Input Label
              Text(
                'Remark',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),

              // Text Field
              TextFormField(
                controller: _remarkController,
                enabled: !_isLoading,
                maxLines: 5,
                minLines: 3,
                autofocus: true,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textBlack,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Remark...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textGrey3,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                onChanged: (val) {
                  if (_errorMessage != null && val.trim().isNotEmpty) {
                    setState(() {
                      _errorMessage = null;
                    });
                  }
                },
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 14, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Update Remark Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Update Remark',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
