import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/custom_form_filler_view.dart';

class FormsTabWidget extends StatefulWidget {
  final String customerId;
  const FormsTabWidget({super.key, required this.customerId});

  @override
  State<FormsTabWidget> createState() => _FormsTabWidgetState();
}

class _FormsTabWidgetState extends State<FormsTabWidget> {
  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  void _fetchForms() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FormProvider>(context, listen: false)
          .getFormDataByCustomer(widget.customerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<FormProvider>(context);
    final bool isLoading = formProvider.isFetchingCustomerForms;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Light grey background
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.bluebutton,
              ),
            )
          : formProvider.customerForms.isEmpty
              ? _buildEmptyState()
              : _buildFormsList(formProvider.customerForms),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            "No forms submitted yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormsList(List<FormModel> forms) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: forms.length,
      itemBuilder: (context, index) {
        final form = forms[index];
        return _buildFormCard(form, index + 1);
      },
    );
  }

  Widget _buildFormCard(FormModel form, int serialNum) {
    final formProvider = Provider.of<FormProvider>(context);
    final settingsprovider = Provider.of<SettingsProvider>(context);
    
    // Format date string safely
    String dateStr = "N/A";
    if (form.createdDate != null) {
        dateStr = form.createdDate!.split('T')[0];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Serial Number / Badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  serialNum.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    form.name.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        "User: ${form.createdUser ?? "N/A"}",
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                if (settingsprovider.menuIsEditMap[85] == 1)
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Color(0xFF2563EB)),
                    onPressed: () => _showEditDialog(form),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(height: 8),
                IconButton(
                  icon: formProvider.isPrinting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.print_outlined, color: Color(0xFFF59E0B)),
                  onPressed: () {
                    if (form.instanceId != null) {
                      formProvider.fetchAndPrintFormPdf(
                        context: context,
                        customerId: widget.customerId,
                        formDataDetailsId: form.instanceId!,
                        taskId: form.taskId,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Print not available for this record')),
                      );
                    }
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: const Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildDataCell(String text, {int flex = 1, bool isBold = false, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
            fontSize: 12,
            color: const Color(0xFF1E293B),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex, child: child);
  }

  Widget _buildWidgetCell({required Widget child, int flex = 1, double? width}) {
    const borderColor = Color(0xFFE9EDF1);
    Widget cellChild = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: borderColor),
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: child,
    );

    if (width != null) return SizedBox(width: width, child: cellChild);
    return Expanded(flex: flex, child: cellChild);
  }

  void _showEditDialog(FormModel form) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: CustomFormFillerView(
            form: form,
            taskId: form.taskId ?? 0,
            customerId: int.tryParse(widget.customerId) ?? form.customerId ?? 0,
            taskTypeId: form.taskTypeId?.toString() ?? "",
            formDataDetailsId: form.instanceId?.toString(),
            onSaved: () {
              _fetchForms();
            },
          ),
        ),
      ),
    );
  }
}

