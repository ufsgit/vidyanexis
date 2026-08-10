import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/controller/models/travel_allowance_model.dart';
import 'package:vidyanexis/controller/travel_allowance_provider.dart';

class AddTADialog extends StatefulWidget {
  final TravelAllowanceModel? editModel;
  const AddTADialog({super.key, this.editModel});

  @override
  State<AddTADialog> createState() => _AddTADialogState();
}

class _AddTADialogState extends State<AddTADialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  final List<String> travelModes = [
    'Bike',
    'Car',
    'Bus',
    'Train',
    'Flight',
    'Auto',
    'Taxi',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taProvider = Provider.of<TravelAllowanceProvider>(context, listen: false);
      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);
      
      dropDownProvider.getUserDetails(context);

      if (widget.editModel != null) {
        taProvider.populateFormForEdit(widget.editModel!);
      } else {
        taProvider.resetForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taProvider = Provider.of<TravelAllowanceProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);
    final bool isAdmin = taProvider.currentUserType == '1';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 650,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.directions_car_rounded,
                          color: AppColors.secondaryBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.editModel != null ? 'Edit Travel Entry' : 'New Travel Entry',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 24),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Staff Name Field
                      if (isAdmin && dropDownProvider.searchUserDetails.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Staff Name',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[50],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  value: dropDownProvider.searchUserDetails.any((u) => u.userDetailsId == taProvider.selectedStaffId)
                                      ? taProvider.selectedStaffId
                                      : dropDownProvider.searchUserDetails.first.userDetailsId,
                                  isExpanded: true,
                                  icon: const Icon(Icons.person_outline_rounded),
                                  items: dropDownProvider.searchUserDetails.map((user) {
                                    return DropdownMenuItem<int>(
                                      value: user.userDetailsId,
                                      child: Text(
                                        user.userDetailsName,
                                        style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (selectedId) {
                                    if (selectedId != null) {
                                      final matched = dropDownProvider.searchUserDetails
                                          .firstWhere((u) => u.userDetailsId == selectedId);
                                      taProvider.setSelectedStaff(matched.userDetailsId, matched.userDetailsName);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        _buildTextField(
                          controller: TextEditingController(text: taProvider.selectedStaffName ?? taProvider.currentUserName),
                          label: 'Staff Name',
                          hint: 'Staff Name',
                          readOnly: true,
                          prefixIcon: Icons.person_rounded,
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 2. Travel Date & Travel Mode Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.dateController,
                              label: 'Travel Date *',
                              hint: 'yyyy-MM-dd',
                              readOnly: true,
                              prefixIcon: Icons.calendar_today_rounded,
                              validator: (val) => val == null || val.trim().isEmpty ? 'Travel Date is required' : null,
                              onTap: () async {
                                final now = DateTime.now();
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: now,
                                  firstDate: DateTime(2020),
                                  lastDate: now, // Restrict future dates
                                );
                                if (picked != null) {
                                  taProvider.dateController.text =
                                      DateFormat('yyyy-MM-dd').format(picked);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Travel Mode',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[50],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: travelModes.contains(taProvider.travelModeController.text)
                                          ? taProvider.travelModeController.text
                                          : 'Bike',
                                      isExpanded: true,
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                                      items: travelModes.map((String mode) {
                                        return DropdownMenuItem<String>(
                                          value: mode,
                                          child: Text(
                                            mode,
                                            style: GoogleFonts.plusJakartaSans(fontSize: 13),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          taProvider.travelModeController.text = val;
                                          taProvider.recalculateTotals();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 3. From Location & 4. To Location Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.fromLocationController,
                              label: 'From Location *',
                              hint: 'e.g. Office / Starting Point',
                              prefixIcon: Icons.my_location_rounded,
                              validator: (val) => val == null || val.trim().isEmpty ? 'From Location is required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.toLocationController,
                              label: 'To Location *',
                              hint: 'e.g. Client Site / Destination',
                              prefixIcon: Icons.location_on_rounded,
                              validator: (val) => val == null || val.trim().isEmpty ? 'To Location is required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. Purpose of Visit
                      _buildTextField(
                        controller: taProvider.purposeController,
                        label: 'Purpose of Visit *',
                        hint: 'Enter purpose of visit, client details, or travel objectives...',
                        maxLines: 2,
                        validator: (val) => val == null || val.trim().isEmpty ? 'Purpose of Visit is required' : null,
                      ),
                      const SizedBox(height: 16),

                      // 6. Distance Travelled & Odometer Readings Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.speed_rounded, size: 18, color: AppColors.secondaryBlue),
                                const SizedBox(width: 8),
                                Text(
                                  'Distance & Odometer Breakdown',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: taProvider.startOdometerController,
                                    label: 'Start Odometer',
                                    hint: 'e.g. 12500',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => taProvider.recalculateTotals(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: taProvider.endOdometerController,
                                    label: 'End Odometer',
                                    hint: 'e.g. 12545',
                                    keyboardType: TextInputType.number,
                                    onChanged: (_) => taProvider.recalculateTotals(),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    controller: taProvider.totalKmController,
                                    label: 'Distance Travelled (KM) *',
                                    hint: '0.0 KM',
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) return 'Distance is required';
                                      final d = double.tryParse(val.trim());
                                      if (d == null) return 'Enter a valid number';
                                      if (d < 0) return 'Distance cannot be negative';
                                      return null;
                                    },
                                    onChanged: (_) => taProvider.recalculateTotals(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. TA Amount & Expense Calculations Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.ratePerKmController,
                              label: 'Rate / KM (₹)',
                              hint: 'e.g. 3.5',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => taProvider.recalculateTotals(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.otherExpensesController,
                              label: 'Other Expenses (₹)',
                              hint: 'Toll/Parking/Food',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => taProvider.recalculateTotals(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildTextField(
                              controller: taProvider.totalAmountController,
                              label: 'TA Amount (₹) *',
                              hint: '₹ 0.00',
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) return 'TA Amount is required';
                                final a = double.tryParse(val.trim());
                                if (a == null) return 'Enter a valid number';
                                if (a < 0) return 'TA Amount cannot be negative';
                                return null;
                              },
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _buildTextField(
                        controller: taProvider.otherExpenseRemarkController,
                        label: 'Other Expense Breakdown / Remarks',
                        hint: 'e.g. Toll fare ₹50, Parking ticket ₹30',
                      ),
                      const SizedBox(height: 16),

                      // 8. Approval Status (Read-only for submission)
                      Row(
                        children: [
                          Text(
                            'Approval Status: ',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFFD97706)),
                                const SizedBox(width: 6),
                                Text(
                                  widget.editModel != null ? (widget.editModel!.status ?? 'PENDING') : 'PENDING',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Receipt Attachment Option
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt / Bill Attachment (Optional)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: taProvider.isUploadingFile
                                    ? null
                                    : () => taProvider.pickAndUploadAttachment(context),
                                icon: taProvider.isUploadingFile
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.upload_file_rounded, size: 18),
                                label: Text(
                                  taProvider.isUploadingFile ? 'Uploading...' : 'Upload Receipt',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  foregroundColor: AppColors.secondaryBlue,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (taProvider.attachmentUrl.isNotEmpty) ...[
                                const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 20),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Receipt Attached',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF16A34A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => taProvider.clearAttachment(),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(height: 24),

            // Action Buttons Footer: [Submit Travel Entry]
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Cancel', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isSubmitting = true);
                            try {
                              final success = await taProvider.saveTAClaim(
                                context,
                                editId: widget.editModel?.taId,
                              );
                              if (success && mounted) {
                                Navigator.of(context).pop();
                              }
                            } finally {
                              if (mounted) setState(() => _isSubmitting = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.editModel != null ? 'Update Travel Entry' : 'Submit Travel Entry',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? prefixIcon,
    bool readOnly = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
    Function(String)? onChanged,
    String? Function(String?)? validator,
    TextStyle? style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          style: style ?? GoogleFonts.plusJakartaSans(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey[400]),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 18, color: Colors.grey[500]) : null,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.secondaryBlue, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
