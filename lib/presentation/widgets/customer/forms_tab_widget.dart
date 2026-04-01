import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

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
      builder: (context) {
        return EditFormDialog(
          form: form,
          customerId: widget.customerId,
          onSaved: () {
            _fetchForms();
          },
        );
      },
    );
  }
}

class EditFormDialog extends StatefulWidget {
  final FormModel form;
  final String customerId;
  final VoidCallback onSaved;

  const EditFormDialog({
    super.key,
    required this.form,
    required this.customerId,
    required this.onSaved,
  });

  @override
  State<EditFormDialog> createState() => _EditFormDialogState();
}

class _EditFormDialogState extends State<EditFormDialog> {
  final Map<String, dynamic> _fieldValues = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.form.fields) {
      _fieldValues[field.id] = field.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit ${widget.form.name}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: widget.form.fields.map((field) {
                    return _buildFormField(field);
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluebutton,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Save Changes"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(FieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          _buildInput(field),
        ],
      ),
    );
  }

  Widget _buildInput(FieldModel field) {
    if (field.type == FieldType.date) {
      return _buildDatePicker(field);
    } else if (field.type == FieldType.dropdown) {
      return _buildDropdown(field);
    } else {
      return _buildTextField(field);
    }
  }

  Widget _buildTextField(FieldModel field) {
    return TextFormField(
      initialValue: _fieldValues[field.id],
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      onChanged: (val) {
        _fieldValues[field.id] = val;
      },
    );
  }

  Widget _buildDatePicker(FieldModel field) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.tryParse(_fieldValues[field.id] ?? "") ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          setState(() {
            _fieldValues[field.id] = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fieldValues[field.id] ?? "Select Date",
              style: TextStyle(
                color: _fieldValues[field.id] != null ? Colors.black : Colors.grey,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(FieldModel field) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: (field.options?.contains(_fieldValues[field.id]) ?? false) ? _fieldValues[field.id] : null,
          hint: const Text("Select option", style: TextStyle(fontSize: 14)),
          items: (field.options ?? []).map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _fieldValues[field.id] = val;
            });
          },
        ),
      ),
    );
  }

  void _saveForm() {
    final formProvider = Provider.of<FormProvider>(context, listen: false);

    List<Map<String, dynamic>> customFields = widget.form.fields.map((f) {
      return {
        "Custom_Field_Id": int.tryParse(f.id) ?? 0,
        "DataValue": _fieldValues[f.id] ?? "",
      };
    }).toList();

    formProvider.saveTaskFormData(
      context: context,
      taskId: 0,
      formId: int.tryParse(widget.form.id) ?? 0,
      customFields: customFields,
      formDataDetailsId: widget.form.instanceId ?? 0,
      customerId: int.tryParse(widget.customerId) ?? 0,
    ).then((_) {
      widget.onSaved();
      Navigator.pop(context);
    });
  }
}
