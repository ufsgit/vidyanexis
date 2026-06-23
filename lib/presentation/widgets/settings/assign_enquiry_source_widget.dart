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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth <= 600;

    if (isMobile) {
      return Dialog.fullscreen(
        backgroundColor: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              // Pinned Header Section
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Manage Enquiry Source of ${widget.userModel.userDetailsName}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textBlack),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Select All action bar for mobile
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select All Options',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Checkbox(
                      value: _selectAll,
                      activeColor: AppColors.secondaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onChanged: (value) => _toggleSelectAll(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Scrollable Content / Options list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _items.isNotEmpty
                        ? ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 12.0),
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 6.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.enquirySourceName ?? 'Unknown',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textBlack,
                                        ),
                                      ),
                                    ),
                                    Checkbox(
                                      value: item.isview == 1,
                                      activeColor: AppColors.secondaryBlue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      onChanged: (bool? value) {
                                        setState(() {
                                          item.isview = (value == true) ? 1 : 0;
                                          _selectAll = _items.every(
                                              (selected) =>
                                                  selected.isview == 1);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              'No options available',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
              ),

              // Bottom Pinned Actions
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        buttonText: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        radius: 4,
                        backgroundColor: Colors.white,
                        borderColor: const Color(0xFFE2E8F0),
                        textColor: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        isLoading: settingsProvider.isSavingUserEnquirySource,
                        onPressed: () async {
                          await settingsProvider.saveUserEnquirySourceList(
                            context: context,
                            userId: widget.userModel.userDetailsId.toString(),
                            updatedList: _items,
                          );
                        },
                        radius: 4,
                        backgroundColor: AppColors.secondaryBlue,
                        borderColor: AppColors.secondaryBlue,
                        textColor: Colors.white,
                        buttonText: 'Save',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
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
                      color: AppColors.textBlack,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textBlack),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: Text(
                          'No.',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Enquiry Source Option',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 48,
                      child: Center(
                        child: Checkbox(
                          value: _selectAll,
                          activeColor: AppColors.secondaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          onChanged: (value) => _toggleSelectAll(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

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
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 48,
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.enquirySourceName ?? 'Unknown',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.textBlack,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: item.isview == 1,
                                activeColor: AppColors.secondaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
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
                SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'No options available',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
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
                    isLoading: settingsProvider.isSavingUserEnquirySource,
                    onPressed: () async {
                      await settingsProvider.saveUserEnquirySourceList(
                        context: context,
                        userId: widget.userModel.userDetailsId.toString(),
                        updatedList: _items,
                      );
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
          ],
        ),
      ),
    );
  }
}
