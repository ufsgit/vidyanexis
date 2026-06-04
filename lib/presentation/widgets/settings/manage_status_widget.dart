import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class ManageStatusWidget extends StatefulWidget {
  const ManageStatusWidget({super.key});
  @override
  _ManageStatusWidgetState createState() => _ManageStatusWidgetState();
}

class _ManageStatusWidgetState extends State<ManageStatusWidget> {
  final List<bool> _selectedUsers = List.generate(40, (index) => false);
  bool _selectAll = false;

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (int i = 0; i < _selectedUsers.length; i++) {
        _selectedUsers[i] = _selectAll;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width:
                constraints.maxWidth > 600 ? 800 : constraints.maxWidth * 0.9,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manage Status',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Table Header
                if (constraints.maxWidth > 600)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 48, child: const Center(child: Text('No.'))),
                        Expanded(child: Text('User')),
                        SizedBox(
                          width: 48,
                          child: Center(
                            child: Checkbox(
                              value: _selectAll,
                              onChanged: (value) => _toggleSelectAll(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // List of users
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: 40,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 48,
                                child: Center(child: Text('${index + 1}'))),
                            Expanded(child: Text('User ${index + 1}')),
                            Checkbox(
                              value: _selectedUsers[index],
                              onChanged: (bool? value) {
                                setState(() {
                                  _selectedUsers[index] = value ?? false;
                                  _selectAll = _selectedUsers
                                      .every((selected) => selected);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Action Buttons
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomElevatedButton(
                      buttonText: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      radius: 4,
                      backgroundColor: Colors.white,
                      borderColor: const Color(0xFFE2E8F0),
                      textColor: const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 12),
                    CustomElevatedButton(
                      onPressed: () {
                        // Handle save action
                      },
                      radius: 4,
                      backgroundColor: AppColors.secondaryBlue,
                      borderColor: AppColors.secondaryBlue,
                      textColor: Colors.white,
                      buttonText: 'Save',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
