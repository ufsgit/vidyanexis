import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;
import 'package:vidyanexis/controller/image_upload_provider.dart';
import 'package:vidyanexis/controller/models/form_model.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/http/loader.dart';
import 'package:vidyanexis/presentation/widgets/home/signature_capture_dialog.dart';
import 'package:file_picker/file_picker.dart';

class CustomFormFillerView extends StatefulWidget {
  final FormModel form;
  final int taskId;
  final int customerId;
  final String taskTypeId;
  final int? enquiryForId;
  final String? formDataDetailsId;
  final VoidCallback onSaved;
  final bool isDrawer;

  const CustomFormFillerView({
    super.key,
    required this.form,
    required this.taskId,
    required this.customerId,
    required this.taskTypeId,
    this.enquiryForId,
    this.formDataDetailsId,
    required this.onSaved,
    this.isDrawer = false,
  });

  @override
  State<CustomFormFillerView> createState() => _CustomFormFillerViewState();
}

class _CustomFormFillerViewState extends State<CustomFormFillerView> {
  final Map<String, dynamic> _fieldValues = {};
  final Map<String, TextEditingController> _fieldRemarks = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.form.fields) {
      if (field.type == FieldType.text || field.type == FieldType.number) {
        _fieldValues[field.id] = TextEditingController(text: field.value ?? '');
      } else {
        _fieldValues[field.id] = field.value;
      }

      if (field.type == FieldType.checkbox) {
        _fieldRemarks[field.id] = TextEditingController(text: field.remark ?? '');
      }
    }
  }

  @override
  void dispose() {
    _fieldValues.forEach((key, value) {
      if (value is TextEditingController) {
        value.dispose();
      }
    });
    _fieldRemarks.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  Future<void> _saveForm() async {
    final imageProvider =
        Provider.of<ImageUploadProvider>(context, listen: false);
    final formProvider = Provider.of<FormProvider>(context, listen: false);

    Loader.showLoader(context);

    try {
      List<Map<String, dynamic>> customFieldsPayload = [];

      for (var field in widget.form.fields) {
        dynamic value = _fieldValues[field.id];
        String finalValue = '';

        if (field.type == FieldType.file || field.type == FieldType.signature) {
          if (value is Uint8List) {
            // New upload required
            String mimeType =
                field.type == FieldType.file ? 'image/jpeg' : 'image/png';
            String? path = await imageProvider.saveToAws(
                value, mimeType, widget.taskId.toString(), context);
            if (path != null) {
              finalValue = HttpUrls.imgBaseUrl + path;
            } else {
              throw Exception('Upload failed for ${field.label}');
            }
          } else {
            finalValue = value?.toString() ?? '';
          }
        } else if (field.type == FieldType.text ||
            field.type == FieldType.number) {
          finalValue = (value as TextEditingController).text;
        } else if (field.type == FieldType.checkbox) {
          finalValue = value?.toString() ?? '';
        } else {
          finalValue = value?.toString() ?? '';
        }

        // Mapping FieldType to ID (1: No, 2: Text, 3: Dropdown, 4: Date, 5: Checkbox, 6: File, 7: Signature)
        int typeId = 2; // Default text
        switch (field.type) {
          case FieldType.number:
            typeId = 1;
            break;
          case FieldType.text:
            typeId = 2;
            break;
          case FieldType.dropdown:
            typeId = 3;
            break;
          case FieldType.date:
            typeId = 4;
            break;
          case FieldType.checkbox:
            typeId = 5;
            break;
          case FieldType.file:
            typeId = 6;
            break;
          case FieldType.signature:
            typeId = 7;
            break;
        }

        customFieldsPayload.add({
          "custom_field_id": int.tryParse(field.id) ?? 0,
          "custom_field_name": field.label,
          "custom_field_type_id": typeId,
          "datavalue": finalValue,
          "Remark": (field.type == FieldType.checkbox) 
              ? (_fieldRemarks[field.id]?.text ?? "")
              : "",
        });
      }

      final resultId = await formProvider.saveTaskFormData(
        context: context,
        taskId: widget.taskId,
        formId: int.parse(widget.form.id),
        customerId: widget.customerId,
        taskTypeId: widget.taskTypeId,
        customFields: customFieldsPayload,
      );

      Loader.stopLoader(context);

      if (resultId != null) {
        widget.onSaved();

        // Show print confirmation
        if (mounted) {
          showDialog(
            context: context,
            builder: (confirmContext) => AlertDialog(
              title: const Text("Print Form"),
              content: const Text("Do you want to print this form?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(confirmContext),
                  child: const Text("No"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(confirmContext);
                    formProvider.fetchAndPrintFormPdf(
                      context: context,
                      customerId: widget.customerId.toString(),
                      formDataDetailsId: resultId,
                      taskId: widget.taskId,
                    );
                  },
                  child: const Text("Yes"),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      Loader.stopLoader(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving form: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.form.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A7AE8),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Divider(height: 32),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: widget.form.fields
                    .map((field) => _buildField(field))
                    .toList(),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saveForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7AE8),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('Save Form'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(FieldModel field) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          _buildFieldInput(field),
        ],
      ),
    );
  }

  Widget _buildFieldInput(FieldModel field) {
    switch (field.type) {
      case FieldType.date:
        return _buildDatePicker(field);
      case FieldType.dropdown:
        return _buildDropdown(field);
      case FieldType.checkbox:
        return _buildCheckbox(field);
      case FieldType.file:
        return _buildFileUpload(field);
      case FieldType.signature:
        return _buildSignatureCapture(field);
      case FieldType.number:
        return _buildTextField(field);
      case FieldType.text:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FieldModel field) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: TextFormField(
        controller: _fieldValues[field.id],
        keyboardType: field.type == FieldType.number
            ? TextInputType.number
            : TextInputType.text,
        inputFormatters: field.type == FieldType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          hintText: 'Enter ${field.label}',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildDatePicker(FieldModel field) {
    return InkWell(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() {
            _fieldValues[field.id] = DateFormat('yyyy-MM-dd').format(picked);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _fieldValues[field.id] ?? 'Select Date',
                style: TextStyle(
                  color: _fieldValues[field.id] == null
                      ? const Color(0xFF94A3B8)
                      : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.calendar_today,
                color: Color(0xFF1A7AE8), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(FieldModel field) {
    List<String> options = field.options ?? [];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('Select ${field.label}',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
          value: options.contains(_fieldValues[field.id])
              ? _fieldValues[field.id]
              : null,
          items: options
              .map((opt) => DropdownMenuItem(
                  value: opt,
                  child: Text(opt, style: const TextStyle(fontSize: 14))))
              .toList(),
          onChanged: (val) => setState(() => _fieldValues[field.id] = val),
        ),
      ),
    );
  }

  Widget _buildCheckbox(FieldModel field) {
    if (!_fieldRemarks.containsKey(field.id)) {
      _fieldRemarks[field.id] = TextEditingController(text: field.remark ?? '');
    }

    List<String> options = field.checkBoxOptions ?? [];
    List<String> selected = (_fieldValues[field.id] ?? "")
        .toString()
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...options.map((opt) {
          bool isChecked = selected.contains(opt);
          return CheckboxListTile(
            title: Text(opt, style: const TextStyle(fontSize: 14)),
            value: isChecked,
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  selected.add(opt);
                } else {
                  selected.remove(opt);
                }
                _fieldValues[field.id] = selected.join(',');
              });
            },
          );
        }),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
            ),
            child: TextFormField(
              controller: _fieldRemarks[field.id],
              decoration: const InputDecoration(
                hintText: 'Enter Remark',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ]
      ],
    );
  }

  Widget _buildFileUpload(FieldModel field) {
    dynamic val = _fieldValues[field.id];
    bool hasData = val != null;
    bool isNew = val is Uint8List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasData)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                if (isNew) {
                  showDialog(
                      context: context,
                      builder: (_) => Dialog(child: Image.memory(val)));
                } else {
                  launcher.launchUrl(Uri.parse(val.toString()));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Row(
                  children: [
                    const Icon(Icons.image, size: 20, color: Color(0xFF1A7AE8)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            isNew ? "New File Picked" : "View Uploaded File",
                            style: const TextStyle(
                                color: Color(0xFF1A7AE8), fontSize: 13))),
                    const Icon(Icons.open_in_new,
                        size: 14, color: Color(0xFF1A7AE8)),
                  ],
                ),
              ),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.image);
            if (result != null) {
              setState(() {
                _fieldValues[field.id] = result.files.first.bytes;
              });
            }
          },
          icon: const Icon(Icons.upload_file, size: 18),
          label: const Text("Upload File", style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF475569),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureCapture(FieldModel field) {
    dynamic val = _fieldValues[field.id];
    bool hasData = val != null;
    bool isNew = val is Uint8List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasData)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isNew
                  ? Image.memory(val, fit: BoxFit.contain)
                  : Image.network(val.toString(), fit: BoxFit.contain),
            ),
          ),
        ElevatedButton.icon(
          onPressed: () async {
            final Uint8List? result = await showDialog<Uint8List>(
              context: context,
              builder: (context) => const SignatureCaptureDialog(),
            );
            if (result != null) {
              setState(() {
                _fieldValues[field.id] = result;
              });
            }
          },
          icon: const Icon(Icons.gesture, size: 18),
          label:
              const Text("Capture Signature", style: TextStyle(fontSize: 13)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: const Color(0xFF475569),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}
