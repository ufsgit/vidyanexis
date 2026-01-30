import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/constants/enums.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/controller/models/field_value_model.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
// File uploads are deferred to Save Lead
import 'package:url_launcher/url_launcher.dart' as launcher;
// io-only in FileDownloader
import 'package:flutter/foundation.dart';
import 'package:vidyanexis/utils/file_downloader.dart';

// Global keys for specific instances
final GlobalKey<_CustomFieldSectionWidgetState> customFieldLeadStatusKey =
    GlobalKey<_CustomFieldSectionWidgetState>();
final GlobalKey<_CustomFieldSectionWidgetState> customFieldEnquirySourceKey =
    GlobalKey<_CustomFieldSectionWidgetState>();
final GlobalKey<_CustomFieldSectionWidgetState> customFieldQuotationKey =
    GlobalKey<_CustomFieldSectionWidgetState>();

class CustomFieldSectionWidget extends StatefulWidget {
  final List<CustomFieldByStatusId> customFields;
  final List<FieldValueModel>? initialFieldValues;
  final Map<int, dynamic>? initialValues; // Backward compatibility
  final Function(List<FieldValueModel>)? onFieldValuesChanged;
  final Function(Map<int, dynamic>)? onValuesChanged; // Backward compatibility
  final bool enabled; // Add enabled state
  final EdgeInsets? padding;
  final double? spacing;
  final String controllerKey;
  const CustomFieldSectionWidget({
    Key? key,
    required this.customFields,
    this.initialFieldValues,
    this.initialValues,
    this.onFieldValuesChanged,
    this.onValuesChanged,
    this.enabled = true,
    this.padding,
    this.spacing,
    required this.controllerKey,
  }) : super(key: key);

  @override
  _CustomFieldSectionWidgetState createState() =>
      _CustomFieldSectionWidgetState();
}

class _CustomFieldSectionWidgetState extends State<CustomFieldSectionWidget> {
  late CustomFieldWidgetBuilder widgetBuilder;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    widgetBuilder = CustomFieldWidgetBuilder(
      context,
      widget.controllerKey,
      onFieldChanged: _onFieldChanged,
      enabled: widget.enabled,
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (_isInitialized) return;

    try {
      if (widget.initialFieldValues != null &&
          widget.initialFieldValues!.isNotEmpty) {
        // Remove the arbitrary delay - use proper async initialization
        widgetBuilder.setInitialFieldValues(widget.initialFieldValues!);
        debugPrint('Initial field values set: ${widget.initialFieldValues}');
      } else if (widget.initialValues != null) {
        widgetBuilder.setInitialValues(widget.initialValues!);
      }

      _isInitialized = true;
      try {
        if (mounted) setState(() {});
      } catch (e) {}
    } catch (e) {
      debugPrint('Error initializing custom fields: $e');
    }
  }

  @override
  void didUpdateWidget(CustomFieldSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle updates to initial values
    if (widget.initialFieldValues != oldWidget.initialFieldValues ||
        widget.initialValues != oldWidget.initialValues) {
      _initializeData();
    }

    // Update enabled state
    if (widget.enabled != oldWidget.enabled) {
      widgetBuilder.updateEnabledState(widget.enabled);
    }
  }

  void _onFieldChanged() {
    if (!mounted) return;

    // Call both callback types for backward compatibility
    widget.onFieldValuesChanged?.call(widgetBuilder.getAllFieldValues());
    widget.onValuesChanged?.call(widgetBuilder.getAllValues());
  }

  @override
  void dispose() {
    // Dispose controllers for this widget's fields only
    for (final field in widget.customFields) {
      if (field.customFieldId != null) {
        String key = '${field.customFieldId} ${widget.controllerKey}';
        CustomFieldWidgetHelper.disposeController(
            key: key, fieldId: field.customFieldId!);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customFields.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final spacing = widget.spacing ?? 16.0;
                // Always single column
                return Column(
                  children: widget.customFields
                      .map((field) => Padding(
                            padding: EdgeInsets.only(bottom: spacing / 2),
                            child: widgetBuilder.buildWidget(field),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Public API methods
  ValidationResult validateForm() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final fieldValidation =
        widgetBuilder.validateAllFields(widget.customFields);

    return ValidationResult(
      isValid: formValid && fieldValidation.isValid,
      errors: fieldValidation.errors,
    );
  }

  List<FieldValueModel> getFieldValues() => widgetBuilder.getAllFieldValues();
  Map<int, dynamic> getValues() => widgetBuilder.getAllValues();
  Map<int, Uint8List> getPendingFileBytes() =>
      widgetBuilder.getPendingFileBytes();
  Map<int, String> getPendingFileContentTypes() =>
      widgetBuilder.getPendingFileContentTypes();

  // Reset form
  void resetForm() {
    _formKey.currentState?.reset();
    widgetBuilder.clearAllValues();
    _onFieldChanged();
  }

  // Update field value programmatically
  void updateFieldValue(int fieldId, String? value) {
    widgetBuilder.updateFieldValue(fieldId, value);
    _onFieldChanged();
  }
}

// Extension for additional helper methods
extension CustomFieldSectionWidgetExtension on _CustomFieldSectionWidgetState {
  List<Map<String, dynamic>> getFieldValuesAsJson() {
    return getFieldValues().map((field) => field.toJson()).toList();
  }

  List<FieldValueModel> getFilledFieldValues() {
    return getFieldValues()
        .where((field) => field.value != null && field.value!.trim().isNotEmpty)
        .toList();
  }

  Map<String, String> getFieldValuesAsMap() {
    final Map<String, String> result = {};
    for (final field in widget.customFields) {
      if (field.customFieldId != null && field.customFieldName != null) {
        final value = widgetBuilder.getFieldValue(field.customFieldId!);
        if (value?.value != null) {
          result[field.customFieldName!] = value!.value!;
        }
      }
    }
    return result;
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;

  ValidationResult({required this.isValid, required this.errors});

  @override
  String toString() => 'ValidationResult(isValid: $isValid, errors: $errors)';
}

class CustomFieldWidgetBuilder {
  final BuildContext context;
  final List<FieldValueModel> fieldValues = <FieldValueModel>[];
  final VoidCallback? onFieldChanged;
  bool enabled;
  final String controllerkey;
  final Map<int, Uint8List> _pendingFileBytes = {};
  final Map<int, String> _pendingFileContentType = {};

  CustomFieldWidgetBuilder(
    this.context,
    this.controllerkey, {
    this.onFieldChanged,
    this.enabled = true,
  });

  Widget buildWidget(CustomFieldByStatusId field) {
    if (field.customFieldId == null) {
      return const SizedBox.shrink();
    }

    // Get existing field value or create new one
    final existingValue = _getFieldValue(field.customFieldId!);
    final fieldType = CustomFieldType.fromValue(field.customFieldTypeId);

    // For checkbox and file upload, we don't need a text controller
    if (fieldType == CustomFieldType.checkbox) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: _buildCheckboxField(field),
      );
    }

    if (fieldType == CustomFieldType.fileUpload) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: _buildFileUploadField(field),
      );
    }

    final initialValue = existingValue?.value ?? '';
    String key = '${field.customFieldId} $controllerkey';
    final controller = CustomFieldWidgetHelper.getController(
      fieldId: field.customFieldId!,
      key: key,
      initialValue: initialValue,
    );

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: _buildFieldWidget(field, controller),
    );
  }

  FieldValueModel? _getFieldValue(int fieldId) {
    try {
      return fieldValues.firstWhere((item) => item.customFieldId == fieldId);
    } catch (e) {
      return null;
    }
  }

  void _setFieldValue(int fieldId, String? value) {
    final existingIndex =
        fieldValues.indexWhere((item) => item.customFieldId == fieldId);

    if (existingIndex != -1) {
      fieldValues[existingIndex] =
          fieldValues[existingIndex].copyWith(value: value);
    } else {
      fieldValues.add(FieldValueModel(
        customFieldId: fieldId,
        value: value,
      ));
    }
  }

  Widget _buildCheckboxField(CustomFieldByStatusId field) {
    final isRequired = field.isMandatory == 1;
    final fieldName = field.customFieldName ?? 'Field';
    final checkboxOptions = field.checkboxValues ?? [];

    return StatefulBuilder(
      builder: (context, setState) {
        final fieldValue = _getFieldValue(field.customFieldId!);

        // Parse selected values - can be comma-separated string like "1,2"
        // Convert to strings for consistent comparison
        List<String> selectedValues = [];
        if (fieldValue?.value != null && fieldValue!.value!.isNotEmpty) {
          selectedValues = fieldValue.value!
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
        }

        return FormField<List<String>>(
          initialValue: selectedValues,
          validator: isRequired
              ? (value) {
                  final currentFieldValue =
                      _getFieldValue(field.customFieldId!);
                  if (currentFieldValue?.value == null ||
                      currentFieldValue!.value!.trim().isEmpty) {
                    return 'Please select at least one option for $fieldName';
                  }
                  final currentSelectedValues = currentFieldValue.value!
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();
                  if (currentSelectedValues.isEmpty) {
                    return 'Please select at least one option for $fieldName';
                  }
                  return null;
                }
              : null,
          builder: (FormFieldState<List<String>> state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field title
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '$fieldName${isRequired ? ' *' : ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),

                // If no checkbox options, show message
                if (checkboxOptions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'No options available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  Wrap(
                    spacing: 16.0,
                    runSpacing: 8.0,
                    children: checkboxOptions.map((option) {
                      // Convert option value to string for consistent comparison
                      final optionValue =
                          option.checkBoxValues?.toString() ?? '';
                      final isSelected = selectedValues.contains(optionValue);

                      return IntrinsicWidth(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: isSelected,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              onChanged: enabled
                                  ? (bool? value) {
                                      setState(() {
                                        // Get current selected values
                                        List<String> currentSelected = [];
                                        final currentFieldValue =
                                            _getFieldValue(
                                                field.customFieldId!);
                                        if (currentFieldValue?.value != null &&
                                            currentFieldValue!
                                                .value!.isNotEmpty) {
                                          currentSelected = currentFieldValue
                                              .value!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList();
                                        }

                                        if (value == true) {
                                          if (!currentSelected
                                              .contains(optionValue)) {
                                            currentSelected.add(optionValue);
                                          }
                                        } else {
                                          currentSelected.remove(optionValue);
                                        }

                                        // Update field value
                                        _setFieldValue(
                                          field.customFieldId!,
                                          currentSelected.isEmpty
                                              ? ""
                                              : currentSelected.join(','),
                                        );

                                        // Update selectedValues for UI
                                        selectedValues = currentSelected;
                                      });
                                      state.didChange(selectedValues);
                                      onFieldChanged?.call();
                                    }
                                  : null,
                            ),
                            GestureDetector(
                              onTap: enabled
                                  ? () {
                                      setState(() {
                                        // Get current selected values
                                        List<String> currentSelected = [];
                                        final currentFieldValue =
                                            _getFieldValue(
                                                field.customFieldId!);
                                        if (currentFieldValue?.value != null &&
                                            currentFieldValue!
                                                .value!.isNotEmpty) {
                                          currentSelected = currentFieldValue
                                              .value!
                                              .split(',')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList();
                                        }

                                        if (isSelected) {
                                          currentSelected.remove(optionValue);
                                        } else {
                                          if (!currentSelected
                                              .contains(optionValue)) {
                                            currentSelected.add(optionValue);
                                          }
                                        }

                                        // Update field value
                                        _setFieldValue(
                                          field.customFieldId!,
                                          currentSelected.isEmpty
                                              ? ""
                                              : currentSelected.join(','),
                                        );

                                        // Update selectedValues for UI
                                        selectedValues = currentSelected;
                                      });
                                      state.didChange(selectedValues);
                                      onFieldChanged?.call();
                                    }
                                  : null,
                              child: Text(
                                '${option.checkBoxValues}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: enabled ? Colors.black87 : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Colors
                            .red, // Changed from AppColors.grey to Colors.red for error
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFileUploadField(CustomFieldByStatusId field) {
    final isRequired = field.isMandatory == 1;
    final fieldName = field.customFieldName ?? 'File';

    return StatefulBuilder(
      builder: (context, setState) {
        final existing = _getFieldValue(field.customFieldId!);
        String? uploadedUrl = existing?.value;
        bool hasPending = _pendingFileBytes.containsKey(field.customFieldId!);

        Future<void> pickFile() async {
          try {
            final result =
                await FilePicker.platform.pickFiles(allowMultiple: false);
            if (result == null) return;
            Uint8List? fileData;
            String? extension;
            if (result.files.isNotEmpty) {
              final file = result.files.first;
              extension = file.extension ?? '';
              fileData = file.bytes;
            }
            if (fileData == null) return;

            String contentType = 'application/octet-stream';
            final ext = (extension ?? '').toLowerCase();
            if (ext == 'jpg' || ext == 'jpeg') contentType = 'image/jpeg';
            if (ext == 'png') contentType = 'image/png';
            if (ext == 'pdf') contentType = 'application/pdf';
            _pendingFileBytes[field.customFieldId!] = fileData;
            _pendingFileContentType[field.customFieldId!] = contentType;
            setState(() {
              hasPending = true;
            });
            onFieldChanged?.call();
          } catch (e) {
            // ignore
          }
        }

        return FormField<String>(
          validator: (v) {
            if (!isRequired) return null;
            final fv = _getFieldValue(field.customFieldId!);
            final pending = _pendingFileBytes.containsKey(field.customFieldId!);
            if ((fv?.value == null || (fv!.value!.trim().isEmpty)) &&
                !pending) {
              return 'Please upload $fieldName';
            }
            return null;
          },
          builder: (state) {
            // download handled by FileDownloader

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    '$fieldName${isRequired ? ' *' : ''}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: enabled ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: enabled ? pickFile : null,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue.withOpacity(0.05),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upload_file, size: 36, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Tap to select file',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasPending ||
                    (uploadedUrl != null && uploadedUrl!.isNotEmpty)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasPending)
                          Builder(builder: (_) {
                            final contentType =
                                _pendingFileContentType[field.customFieldId!] ??
                                    '';
                            final bytes =
                                _pendingFileBytes[field.customFieldId!];
                            final isImage =
                                contentType.toLowerCase().startsWith('image/');
                            return InkWell(
                              onTap: isImage && bytes != null
                                  ? () {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            insetPadding:
                                                const EdgeInsets.all(16),
                                            child: InteractiveViewer(
                                              child: Image.memory(
                                                bytes,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  : null,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: isImage && bytes != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.memory(
                                          bytes,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.insert_drive_file,
                                        size: 28,
                                        color: Colors.blueGrey,
                                      ),
                              ),
                            );
                          })
                        else
                          InkWell(
                            onTap: (uploadedUrl != null &&
                                    uploadedUrl!.isNotEmpty)
                                ? () {
                                    final lower = uploadedUrl!.toLowerCase();
                                    final isPdf = lower.endsWith('.pdf');
                                    if (isPdf) {
                                      launcher.launchUrl(
                                          Uri.parse(uploadedUrl!),
                                          mode: launcher
                                              .LaunchMode.externalApplication);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            insetPadding:
                                                const EdgeInsets.all(16),
                                            child: InteractiveViewer(
                                              child: Image.network(
                                                uploadedUrl!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, e, s) {
                                                  return const SizedBox(
                                                    width: 300,
                                                    height: 300,
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.broken_image,
                                                        size: 64,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                : null,
                            child: Builder(builder: (_) {
                              final lower = (uploadedUrl ?? '').toLowerCase();
                              final isPdf = lower.endsWith('.pdf');
                              return Icon(
                                isPdf
                                    ? Icons.picture_as_pdf
                                    : Icons.insert_drive_file,
                                size: 28,
                                color:
                                    isPdf ? Colors.redAccent : Colors.blueGrey,
                              );
                            }),
                          ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasPending
                                    ? ((_pendingFileContentType[
                                                    field.customFieldId!]
                                                ?.toLowerCase()
                                                .contains('pdf') ==
                                            true)
                                        ? 'PDF selected'
                                        : 'File selected')
                                    : (uploadedUrl ?? ''),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        if (!hasPending &&
                            uploadedUrl != null &&
                            uploadedUrl!.isNotEmpty)
                          IconButton(
                            tooltip: 'Download',
                            icon: const Icon(Icons.download,
                                size: 20, color: Colors.blue),
                            onPressed: () async {
                              try {
                                final saved = await FileDownloader.download(
                                  uploadedUrl!,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Saved to $saved')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Download failed')),
                                );
                              }
                            },
                          ),
                        if (enabled)
                          IconButton(
                            tooltip: 'Remove',
                            icon: const Icon(Icons.delete,
                                size: 20, color: Colors.redAccent),
                            onPressed: () {
                              _setFieldValue(field.customFieldId!, "");
                              _pendingFileBytes.remove(field.customFieldId!);
                              _pendingFileContentType
                                  .remove(field.customFieldId!);
                              setState(() {
                                uploadedUrl = null;
                                hasPending = false;
                              });
                              state.didChange(null);
                              onFieldChanged?.call();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFieldWidget(
      CustomFieldByStatusId field, TextEditingController controller) {
    final fieldType = CustomFieldType.fromValue(field.customFieldTypeId);
    final isRequired = field.isMandatory == 1;
    final fieldName = field.customFieldName ?? 'Field';
    final labelText = '$fieldName${isRequired ? ' *' : ''}';

    String? validator(String? value) {
      if (isRequired && (value == null || value.trim().isEmpty)) {
        return 'Please enter $fieldName';
      }
      return _validateFieldType(fieldType, value);
    }

    void onChanged(String? value) {
      _setFieldValue(field.customFieldId!, value);
      onFieldChanged?.call();
    }

    switch (fieldType) {
      case CustomFieldType.numberOnly:
        return CustomTextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            LengthLimitingTextInputFormatter(15), // Prevent overflow
          ],
          validator: validator,
          controller: controller,
          hintText: labelText,
          height: 50,
          labelText: labelText,
          onChanged: onChanged,
          enabled: enabled,
        );

      case CustomFieldType.textOnly:
        return CustomTextField(
          validator: validator,
          height: 50,
          hintText: labelText,
          controller: controller,
          labelText: labelText,
          onChanged: onChanged,
          enabled: enabled,
          inputFormatters: [
            LengthLimitingTextInputFormatter(255), // Reasonable text limit
          ],
        );

      case CustomFieldType.dropdown:
        return _buildDropdownField(field, validator, onChanged);

      case CustomFieldType.datePicker:
        return GestureDetector(
          onTap: enabled
              ? () => _showDatePicker(field, controller, onChanged)
              : null,
          child: AbsorbPointer(
            child: CustomTextField(
              validator: validator,
              controller: controller,
              height: 50,
              hintText:
                  "Select ${field.customFieldName ?? 'date'} ${isRequired ? '*' : ""}",
              labelText: labelText,
              suffixIcon: const Icon(Icons.calendar_today),
              readOnly: true,
              enabled: enabled,
            ),
          ),
        );

      case CustomFieldType.checkbox:
        // This case should not be reached as it's handled in buildWidget
        return _buildCheckboxField(field);

      default:
        return CustomTextField(
          validator: validator,
          controller: controller,
          height: 50,
          labelText: labelText,
          hintText: labelText,
          onChanged: onChanged,
          enabled: enabled,
        );
    }
  }

  String? _validateFieldType(CustomFieldType fieldType, String? value) {
    if (value == null || value.trim().isEmpty) return null;

    switch (fieldType) {
      case CustomFieldType.numberOnly:
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        break;
      default:
        break;
    }
    return null;
  }

  Widget _buildDropdownField(
    CustomFieldByStatusId field,
    String? Function(String?) validator,
    Function(String?) onChanged,
  ) {
    final dropdownItems = field.dropdownValues;
    final isRequired = field.isMandatory == 1;
    final fieldName = field.customFieldName ?? 'Field';

    if (dropdownItems == null || dropdownItems.isEmpty) {
      return Container(
        height: 50,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
          color: enabled ? null : Colors.grey.shade100,
        ),
        child: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No options available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Get current value
    final currentValue = _getFieldValue(field.customFieldId!);
    DropdownValue? selectedValue;

    if (currentValue?.value != null && currentValue!.value!.isNotEmpty) {
      try {
        selectedValue = dropdownItems.firstWhere(
          (item) => item.dropdownValue == currentValue.value,
        );
      } catch (e) {
        // Value not found in options, clear it
        _setFieldValue(field.customFieldId!, null);
      }
    }

    return DropdownButtonFormField<DropdownValue>(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelText: '$fieldName${isRequired ? ' *' : ''}',
      ),
      validator: (v) => validator(v?.dropdownValue ?? ""),
      items: enabled
          ? dropdownItems.map((item) {
              return DropdownMenuItem<DropdownValue>(
                value: item,
                child: Text(
                  item.dropdownValue ?? "Unknown",
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList()
          : [],
      hint: Text("Select $fieldName"),
      value: selectedValue,
      onChanged: enabled
          ? (value) {
              onChanged(value?.dropdownValue);
            }
          : null,
    );
  }

  Future<void> _showDatePicker(
    CustomFieldByStatusId field,
    TextEditingController controller,
    Function(String?) onChanged,
  ) async {
    DateTime initialDate = DateTime.now();

    // Try to parse existing date
    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      } catch (e) {
        // Keep default initial date if parsing fails
      }
    }

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Select ${field.customFieldName ?? 'date'}',
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      controller.text = formattedDate;
      onChanged(formattedDate);
    }
  }

  // Public methods for external access
  List<FieldValueModel> getAllFieldValues() => List.from(fieldValues);

  Map<int, dynamic> getAllValues() {
    final Map<int, dynamic> result = {};
    for (final field in fieldValues) {
      if (field.customFieldId != null) {
        result[field.customFieldId!] = field.value;
      }
    }
    return result;
  }

  Map<int, Uint8List> getPendingFileBytes() => _pendingFileBytes;
  Map<int, String> getPendingFileContentTypes() => _pendingFileContentType;

  void setInitialValues(Map<int, dynamic> values) {
    fieldValues.clear();
    values.forEach((fieldId, value) {
      fieldValues.add(FieldValueModel(
        customFieldId: fieldId,
        value: value?.toString(),
      ));
    });
    _updateControllers();
  }

  void setInitialFieldValues(List<FieldValueModel> values) {
    fieldValues.clear();
    fieldValues.addAll(values);
    _updateControllers();
  }

  void _updateControllers() {
    // Update text controllers with new values (skip checkboxes)
    for (final fieldValue in fieldValues) {
      if (fieldValue.customFieldId != null && fieldValue.value != null) {
        String key = '${fieldValue.customFieldId} $controllerkey';

        final controller = CustomFieldWidgetHelper.getController(
          key: key,
          fieldId: fieldValue.customFieldId!,
          initialValue: fieldValue.value,
        );
        if (controller.text != fieldValue.value) {
          controller.text = fieldValue.value!;
        }
      }
    }
  }

  void clearAllValues() {
    fieldValues.clear();
    // Clear all controllers
    CustomFieldWidgetHelper.clearAllControllers();
  }

  void updateEnabledState(bool isEnabled) {
    enabled = isEnabled;
  }

  void updateFieldValue(int fieldId, String? value) {
    _setFieldValue(fieldId, value);
    String key = '$fieldId $controllerkey';

    // Update controller if it exists (not for checkbox fields)
    final controller =
        CustomFieldWidgetHelper.getController(fieldId: fieldId, key: key);
    if (controller.text != (value ?? '')) {
      controller.text = value ?? '';
    }
  }

  FieldValueModel? getFieldValue(int fieldId) => _getFieldValue(fieldId);

  ValidationResult validateAllFields(List<CustomFieldByStatusId> fields) {
    final errors = <String>[];

    for (final field in fields) {
      if (field.isMandatory == 1 && field.customFieldId != null) {
        final fieldValue = _getFieldValue(field.customFieldId!);
        final fieldType = CustomFieldType.fromValue(field.customFieldTypeId);

        if (fieldType == CustomFieldType.checkbox) {
          // For checkbox, check if at least one value is selected
          if (fieldValue?.value == null || fieldValue!.value!.trim().isEmpty) {
            errors.add('${field.customFieldName} is required');
          } else {
            // Check if it contains any valid selections
            final selectedValues =
                fieldValue.value!.split(',').map((e) => e.trim()).toList();
            if (selectedValues.isEmpty ||
                (selectedValues.length == 1 && selectedValues[0].isEmpty)) {
              errors.add('${field.customFieldName} is required');
            }
          }
        } else if (fieldType == CustomFieldType.fileUpload) {
          // For file upload, allow either an existing URL value or a pending file selection
          final hasExisting =
              fieldValue?.value != null && fieldValue!.value!.trim().isNotEmpty;
          final hasPending =
              _pendingFileBytes.containsKey(field.customFieldId!);
          if (!hasExisting && !hasPending) {
            errors.add('${field.customFieldName} is required');
          }
        } else {
          // For other fields, check if value is not empty
          if (fieldValue?.value == null || fieldValue!.value!.trim().isEmpty) {
            errors.add('${field.customFieldName} is required');
          }
        }
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }
}

// Enhanced CustomFieldWidgetHelper with better memory management
class CustomFieldWidgetHelper {
  static final Map<String, TextEditingController> _controllers = {};
  static final Map<int, String?> _initialValues = {};

  static TextEditingController getController(
      {required String key, required int fieldId, String? initialValue}) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue ?? '');
      _initialValues[fieldId] = initialValue;
    } else if (initialValue != null && _initialValues[key] != initialValue) {
      _controllers[key]!.text = initialValue;
      _initialValues[fieldId] = initialValue;
    }
    return _controllers[key]!;
  }

  static void disposeController({required int fieldId, required String key}) {
    _controllers[key]?.dispose();
    _controllers.remove(key);
    _initialValues.remove(fieldId);
  }

  static void disposeAllControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initialValues.clear();
  }

  static void clearAllControllers() {
    for (final controller in _controllers.values) {
      controller.clear();
    }
  }

  static bool hasController(int fieldId) => _controllers.containsKey(fieldId);

  static int get activeControllerCount => _controllers.length;
}
