import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/models/get_user_model.dart';
import 'package:vidyanexis/controller/models/user_enquiry_source_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_button_widget.dart';

class AssignEnquirySourceWidget extends StatefulWidget {
  const AssignEnquirySourceWidget({super.key, required this.userModel});
  final GetUserModel userModel;

  @override
  _AssignEnquirySourceWidgetState createState() =>
      _AssignEnquirySourceWidgetState();
}

class _AssignEnquirySourceWidgetState extends State<AssignEnquirySourceWidget> {
  bool _isLoading = true;
  bool _selectAll = false;
  List<UserEnquirySourceModel> _items = [];
  List<int> _initialStates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      final loadedList = await settingsProvider.getUserEnquirySource(
          widget.userModel.userDetailsId.toString(), context);
      setState(() {
        _items = loadedList;
        _initialStates = loadedList.map((e) => e.isview).toList();
        _selectAll =
            _items.isNotEmpty && _items.every((item) => item.isview == 1);
        _isLoading = false;
      });
    });
  }

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll;
      for (var item in _items) {
        item.isview = _selectAll ? 1 : 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    Expanded(
                      child: Text(
                        'Manage Enquiry Source of ${widget.userModel.userDetailsName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Loader or Content
                if (_isLoading)
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  // Table Header
                  if (constraints.maxWidth > 600)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                              width: 48, child: Center(child: Text('No.'))),
                          const Expanded(child: Text('Enquiry Source')),
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

                  // List of options
                  if (_items.isNotEmpty)
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: const [
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
                                      child:
                                          Center(child: Text('${index + 1}'))),
                                  Expanded(
                                      child: Text(
                                          item.enquirySourceName ?? 'Unknown')),
                                  Checkbox(
                                    value: item.isview == 1,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        item.isview = (value == true) ? 1 : 0;
                                        _selectAll = _items.every(
                                            (selected) => selected.isview == 1);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 100,
                      child: Center(
                        child: Text('No options available'),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomElevatedButton(
                        buttonText: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        radius: 12,
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFFE2E8F0),
                        textColor: const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 12),
                      CustomElevatedButton(
                        isLoading: settingsProvider.isSavingUserEnquirySource,
                        onPressed: () async {
                          await settingsProvider.saveUserEnquirySourceList(
                            context: context,
                            userId: widget.userModel.userDetailsId.toString(),
                            updatedList: _items,
                          );
                        },
                        radius: 12,
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: Colors.white,
                        buttonText: 'Save',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
