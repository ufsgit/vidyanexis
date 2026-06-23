import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/models/custom_field_by_status.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_field.dart';

class CommercialCustomFieldsTableWidget extends StatefulWidget {
  const CommercialCustomFieldsTableWidget({super.key});

  @override
  State<CommercialCustomFieldsTableWidget> createState() =>
      _CommercialCustomFieldsTableWidgetState();
}

class _CommercialCustomFieldsTableWidgetState
    extends State<CommercialCustomFieldsTableWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerDetailsProvider>(context, listen: false)
          .initCommercialTableRow();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerDetailsProvider>(
      builder: (context, provider, child) {
        final columns = provider.commercialCustomFields;
        if (columns.isEmpty) return const SizedBox.shrink();

        final rows = provider.commercialTableRows;

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF6F7F9),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Commercial ',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Input Header & Form
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ...columns.map((col) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              col.customFieldName ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            _buildInputField(provider, col),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () {
                          // Basic validation: at least one field must not be empty
                          bool hasData = false;
                          for (var col in columns) {
                            if (col.customFieldTypeId == 3 ||
                                col.customFieldTypeId == 4) {
                              if (provider.commercialTableRowDropdowns[col.customFieldId]?.isNotEmpty == true) {
                                hasData = true;
                              }
                            } else {
                              if (provider.commercialTableRowControllers[col.customFieldId]?.text.isNotEmpty == true) {
                                hasData = true;
                              }
                            }
                          }

                          if (!hasData) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter at least one value to add.'),
                              ),
                            );
                            return;
                          }
                          provider.addCommercialTableRow();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: AppColors.primaryBlue,
                          side: BorderSide(color: AppColors.primaryBlue),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Data Table
              if (rows.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4),
                          ),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      dividerThickness: 1,
                      border: TableBorder(
                        horizontalInside: BorderSide(color: Colors.grey.shade300, width: 1),
                        verticalInside: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                      columns: [
                        ...columns.map(
                          (col) => DataColumn(
                            label: Text(
                              col.customFieldName ?? '',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const DataColumn(
                          label: Text(
                            'Actions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                      rows: List.generate(rows.length, (rowIndex) {
                        final rowData = rows[rowIndex];
                        return DataRow(
                          cells: [
                            ...columns.map((col) {
                              final field = rowData[col.customFieldId];
                              return DataCell(Text(field?.datavalue ?? ''));
                            }),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: AppColors.primaryBlue, size: 20),
                                    onPressed: () {
                                      provider.editCommercialTableRow(rowIndex);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {
                                      provider.deleteCommercialTableRow(rowIndex);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
              if (rows.isNotEmpty) const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: CustomTextField(
                  readOnly: false,
                  minLines: 4,
                  maxLines: 4,
                  controller: provider.commercialDescriptionController,
                  hintText: 'Description',
                  labelText: '',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputField(CustomerDetailsProvider provider, CustomFieldByStatusId col) {
    if (col.customFieldTypeId == 3 || col.customFieldTypeId == 4) {
      final options = col.dropdownValues?.map((e) => e.dropdownValue ?? '').where((e) => e.isNotEmpty).toSet().toList() ?? [];
      String? currentValue = provider.commercialTableRowDropdowns[col.customFieldId];
      if (currentValue != null && !options.contains(currentValue) && currentValue.isNotEmpty) {
        options.add(currentValue);
      }
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            value: (currentValue != null && currentValue.isNotEmpty) ? currentValue : null,
            hint: const Text('Select', style: TextStyle(fontSize: 12)),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
            onChanged: (String? newValue) {
              provider.updateCommercialTableRowDropdown(col.customFieldId!, newValue ?? '');
            },
          ),
        ),
      );
    } else {
      return Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: TextField(
          controller: provider.getCommercialTableRowController(col.customFieldId!),
          decoration: InputDecoration(
            hintText: 'Enter ${col.customFieldName}',
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textBlack,
          ),
        ),
      );
    }
  }
}
