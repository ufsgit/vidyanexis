// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
// import 'package:techtify/constants/app_colors.dart';
// import 'package:techtify/controller/models/custom_field_by_status.dart';
// import 'package:techtify/controller/models/custom_field_enquiry_for_model.dart'
//     as enq;
// import 'package:techtify/controller/models/field_value_model.dart';
// import 'package:techtify/presentation/widgets/home/custom_dropdown_widget.dart';
// import 'package:techtify/presentation/widgets/home/custom_text_field.dart';
// import 'package:techtify/presentation/widgets/home/new_drawer_widget.dart';

// class UnifiedCustomFieldsSection extends StatefulWidget {
//   // For enquiry for fields
//   final List<enq.CustomFieldEnquiryForModel>? enquiryForFields;

//   // For follow-up status fields
//   final List<CustomFieldByStatusId>? followUpFields;

//   // Common properties
//   final Map<int, dynamic>? initialValues;
//   final List<FieldValueModel>? initialFieldValues;
//   final Function(Map<int, dynamic>)? onValuesChanged;
//   final Function(List<FieldValueModel>)? onFieldValuesChanged;
//   final bool showValidation;

//   const UnifiedCustomFieldsSection({
//     Key? key,
//     this.enquiryForFields,
//     this.followUpFields,
//     this.initialValues,
//     this.initialFieldValues,
//     this.onValuesChanged,
//     this.onFieldValuesChanged,
//     this.showValidation = false,
//   })  : assert((enquiryForFields != null) != (followUpFields != null),
//             'Provide either enquiryForFields or followUpFields, not both'),
//         super(key: key);

//   @override
//   State<UnifiedCustomFieldsSection> createState() =>
//       _UnifiedCustomFieldsSectionState();
// }

// class _UnifiedCustomFieldsSectionState
//     extends State<UnifiedCustomFieldsSection> {
//   final Map<int, dynamic> _fieldValues = {};
//   final Map<int, TextEditingController> _controllers = {};
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     _initializeValues();
//   }

//   void _initializeValues() {
//     if (widget.initialFieldValues != null) {
//       for (var fieldValue in widget.initialFieldValues!) {
//         if (fieldValue.customFieldId != null) {
//           _fieldValues[fieldValue.customFieldId!] = fieldValue.value;
//         }
//       }
//     } else if (widget.initialValues != null) {
//       _fieldValues.addAll(widget.initialValues!);
//     }
//   }

//   void _updateFieldValue(int fieldId, dynamic value) {
//     setState(() {
//       _fieldValues[fieldId] = value;
//     });

//     // Notify parent with both formats for backward compatibility
//     widget.onValuesChanged?.call(_fieldValues);

//     final fieldValueList = _fieldValues.entries
//         .map((e) =>
//             FieldValueModel(customFieldId: e.key, value: e.value?.toString()))
//         .toList();
//     widget.onFieldValuesChanged?.call(fieldValueList);
//   }

//   TextEditingController _getController(int fieldId, String? initialValue) {
//     if (!_controllers.containsKey(fieldId)) {
//       _controllers[fieldId] = TextEditingController(text: initialValue ?? '');
//     } else if (initialValue != null &&
//         _controllers[fieldId]!.text != initialValue) {
//       _controllers[fieldId]!.text = initialValue;
//     }
//     return _controllers[fieldId]!;
//   }

//   @override
//   void dispose() {
//     for (var controller in _controllers.values) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Determine which fields to render
//     if (widget.enquiryForFields?.isNotEmpty == true) {
//       return _buildEnquiryForFields();
//     } else if (widget.followUpFields?.isNotEmpty == true) {
//       return _buildFollowUpFields();
//     }
//     return const SizedBox.shrink();
//   }

//   Widget _buildEnquiryForFields() {
//     if (widget.enquiryForFields?.isEmpty == true)
//       return const SizedBox.shrink();

//     return Form(
//       key: _formKey,
//       child: Wrap(
//         spacing: 5,
//         runSpacing: 5,
//         children: widget.enquiryForFields!
//             .map((field) => _buildEnquiryForField(field))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildFollowUpFields() {
//     if (widget.followUpFields?.isEmpty == true) return const SizedBox.shrink();

//     return Form(
//       key: _formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(height: 20),
//           LayoutBuilder(
//             builder: (context, constraints) {
//               if (constraints.maxWidth > 600) {
//                 return Wrap(
//                   spacing: 16,
//                   runSpacing: 8,
//                   children: widget.followUpFields!.map((field) {
//                     return SizedBox(
//                       width: (constraints.maxWidth - 16) / 2,
//                       child: _buildFollowUpField(field),
//                     );
//                   }).toList(),
//                 );
//               } else {
//                 return Column(
//                   children: widget.followUpFields!
//                       .map((field) => _buildFollowUpField(field))
//                       .toList(),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnquiryForField(enq.CustomFieldEnquiryForModel field) {
//     final fieldId = field.customFieldId ?? 0;
//     final isRequired = field.isMandatory == 1;
//     final fieldName = field.customFieldName ?? 'Field';
//     final labelText = '$fieldName${isRequired ? ' *' : ''}';
//     final initialValue = (_fieldValues[fieldId] ?? '').toString();

//     switch (field.customFieldTypeId) {
//       case 1: // number
//       case 2: // text
//         final controller = _getController(fieldId, initialValue);
//         return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 300),
//           child: CustomTextField(
//             controller: controller,
//             height: 54,
//             labelText: '',
//             hintText: labelText,
//             keyboardType: field.customFieldTypeId == 1
//                 ? TextInputType.number
//                 : TextInputType.text,
//             inputFormatters: field.customFieldTypeId == 1
//                 ? [FilteringTextInputFormatter.digitsOnly]
//                 : null,
//             onChanged: (v) => _updateFieldValue(fieldId, v),
//           ),
//         );

//       case 3: // dropdown
//         return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 300),
//           child: CommonDropdown<int>(
//             hintText: labelText,
//             items: (field.dropdownValues ?? [])
//                 .map((d) => DropdownItem<int>(
//                       id: d.dropdownId ?? 0,
//                       name: d.dropdownValue ?? '',
//                     ))
//                 .toList(),
//             controller: TextEditingController(),
//             onItemSelected: (v) => _updateFieldValue(fieldId, v),
//             selectedValue: _fieldValues[fieldId] as int?,
//           ),
//         );

//       case 4: // date
//         final controller = _getController(fieldId, initialValue);
//         return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 300),
//           child: CustomTextField(
//             onTap: () => _showDatePicker(fieldId, controller),
//             readOnly: true,
//             controller: controller,
//             height: 54,
//             labelText: '',
//             hintText: labelText,
//             suffixIcon: IconButton(
//               icon: const Icon(Icons.calendar_today),
//               onPressed: () => _showDatePicker(fieldId, controller),
//             ),
//           ),
//         );

//       case 5: // checkbox list
//         final initial = _fieldValues[fieldId];
//         final Set<String> current = initial is List
//             ? initial.map((e) => e.toString()).toSet()
//             : <String>{};

//         return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 620),
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   labelText,
//                   style: GoogleFonts.plusJakartaSans(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textGrey3,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 4,
//                   children: (field.checkboxValues ?? [])
//                       .map((c) => FilterChip(
//                             label: Text(c.checkBoxValues ?? ''),
//                             selected: current.contains(c.checkBoxValues ?? ''),
//                             onSelected: (val) {
//                               final next = Set<String>.from(current);
//                               final label = c.checkBoxValues ?? '';
//                               if (val) {
//                                 next.add(label);
//                               } else {
//                                 next.remove(label);
//                               }
//                               _updateFieldValue(fieldId, next.toList());
//                             },
//                           ))
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         );

//       default:
//         final controller = _getController(fieldId, initialValue);
//         return ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 300),
//           child: CustomTextField(
//             controller: controller,
//             height: 54,
//             labelText: '',
//             hintText: labelText,
//             onChanged: (v) => _updateFieldValue(fieldId, v),
//           ),
//         );
//     }
//   }

//   Widget _buildFollowUpField(CustomFieldByStatusId field) {
//     final fieldId = field.customFieldId ?? 0;
//     final isRequired = field.isMandatory == 1;
//     final fieldName = field.customFieldName ?? 'Field';
//     final labelText = '$fieldName${isRequired ? ' *' : ''}';
//     final initialValue = (_fieldValues[fieldId] ?? '').toString();
//     final fieldType = CustomFieldType.fromValue(field.customFieldTypeId);

//     String? validator(String? value) {
//       if (isRequired && (value == null || value.trim().isEmpty)) {
//         return 'Please enter $fieldName';
//       }
//       return null;
//     }

//     void onChanged(String? value) {
//       _updateFieldValue(fieldId, value);
//     }

//     switch (fieldType) {
//       case CustomFieldType.numberOnly:
//         final controller = _getController(fieldId, initialValue);
//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           child: CustomTextField(
//             keyboardType: const TextInputType.numberWithOptions(decimal: true),
//             inputFormatters: [
//               FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
//             ],
//             validator: validator,
//             controller: controller,
//             hintText: labelText,
//             height: 50,
//             labelText: labelText,
//             onChanged: onChanged,
//           ),
//         );

//       case CustomFieldType.textOnly:
//         final controller = _getController(fieldId, initialValue);
//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           child: CustomTextField(
//             validator: validator,
//             height: 50,
//             hintText: labelText,
//             controller: controller,
//             labelText: labelText,
//             onChanged: onChanged,
//           ),
//         );

//       case CustomFieldType.dropdown:
//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           child: _buildFollowUpDropdownField(field, validator, onChanged),
//         );

//       case CustomFieldType.datePicker:
//         final controller = _getController(fieldId, initialValue);
//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           child: GestureDetector(
//             onTap: () => _showFollowUpDatePicker(field, controller, onChanged),
//             child: AbsorbPointer(
//               child: CustomTextField(
//                 validator: validator,
//                 controller: controller,
//                 height: 50,
//                 hintText: "Select ${fieldName.toLowerCase()}",
//                 labelText: labelText,
//                 suffixIcon: const Icon(Icons.calendar_today),
//                 readOnly: true,
//               ),
//             ),
//           ),
//         );

//       default:
//         final controller = _getController(fieldId, initialValue);
//         return Container(
//           width: double.infinity,
//           margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//           child: CustomTextField(
//             validator: validator,
//             controller: controller,
//             height: 50,
//             labelText: labelText,
//             hintText: labelText,
//             onChanged: onChanged,
//           ),
//         );
//     }
//   }

//   Widget _buildFollowUpDropdownField(
//     CustomFieldByStatusId field,
//     String? Function(String?) validator,
//     Function(String?) onChanged,
//   ) {
//     final fieldId = field.customFieldId ?? 0;
//     final dropdownItems = field.dropdownValues;

//     if (dropdownItems == null || dropdownItems.isEmpty) {
//       return Container(
//         height: 50,
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey.shade300),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Align(
//           alignment: Alignment.centerLeft,
//           child: Text(
//             'No options available',
//             style: TextStyle(color: Colors.grey),
//           ),
//         ),
//       );
//     }

//     DropdownValue? selectedValue;
//     final currentValue = _fieldValues[fieldId]?.toString();

//     if (currentValue != null) {
//       try {
//         selectedValue = dropdownItems.firstWhere(
//           (item) => item.dropdownValue == currentValue,
//         );
//       } catch (e) {
//         selectedValue = null;
//       }
//     }

//     return DropdownButtonFormField<DropdownValue>(
//       decoration: InputDecoration(
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       ),
//       validator: (v) => validator(v?.dropdownValue ?? ""),
//       items: dropdownItems.map((item) {
//         return DropdownMenuItem<DropdownValue>(
//           value: item,
//           child: Text(
//             item.dropdownValue ?? "Unknown",
//             overflow: TextOverflow.ellipsis,
//           ),
//         );
//       }).toList(),
//       hint: Text(field.customFieldName ?? "Select option"),
//       value: selectedValue,
//       onChanged: (value) {
//         onChanged(value?.dropdownValue);
//       },
//     );
//   }

//   Future<void> _showDatePicker(
//       int fieldId, TextEditingController controller) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
//       controller.text = formattedDate;
//       _updateFieldValue(fieldId, formattedDate);
//     }
//   }

//   Future<void> _showFollowUpDatePicker(
//     CustomFieldByStatusId field,
//     TextEditingController controller,
//     Function(String?) onChanged,
//   ) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime(2100),
//     );

//     if (pickedDate != null) {
//       final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
//       controller.text = formattedDate;
//       onChanged(formattedDate);
//     }
//   }

//   // Public methods for validation and data retrieval
//   ValidationResult validateAllFields() {
//     final errors = <String>[];

//     if (widget.enquiryForFields != null) {
//       for (final field in widget.enquiryForFields!) {
//         if (field.isMandatory == 1 && field.customFieldId != null) {
//           final fieldValue = _fieldValues[field.customFieldId!];
//           if (fieldValue == null || fieldValue.toString().trim().isEmpty) {
//             errors.add('${field.customFieldName} is required');
//           }
//         }
//       }
//     }

//     if (widget.followUpFields != null) {
//       for (final field in widget.followUpFields!) {
//         if (field.isMandatory == 1 && field.customFieldId != null) {
//           final fieldValue = _fieldValues[field.customFieldId!];
//           if (fieldValue == null || fieldValue.toString().trim().isEmpty) {
//             errors.add('${field.customFieldName} is required');
//           }
//         }
//       }
//     }

//     final formValid = _formKey.currentState?.validate() ?? true;
//     return ValidationResult(
//         isValid: formValid && errors.isEmpty, errors: errors);
//   }

//   Map<int, dynamic> getAllValues() => Map.from(_fieldValues);

//   List<FieldValueModel> getAllFieldValues() {
//     return _fieldValues.entries
//         .map((e) =>
//             FieldValueModel(customFieldId: e.key, value: e.value?.toString()))
//         .toList();
//   }

//   List<Map<String, dynamic>> getFieldValuesAsJson() {
//     return getAllFieldValues().map((field) => field.toJson()).toList();
//   }

//   List<FieldValueModel> getFilledFieldValues() {
//     return getAllFieldValues()
//         .where((field) => field.value != null && field.value!.trim().isNotEmpty)
//         .toList();
//   }

//   void clearAllValues() {
//     setState(() {
//       _fieldValues.clear();
//       for (var controller in _controllers.values) {
//         controller.clear();
//       }
//     });
//   }
// }
