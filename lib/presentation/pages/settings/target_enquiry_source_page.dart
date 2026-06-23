import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/target_enquiry_source_model.dart';
import 'package:vidyanexis/controller/target_enquiry_source_provider.dart';
import 'package:vidyanexis/controller/models/enquiry_settings_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

class TargetEnquirySourcePage extends StatefulWidget {
  const TargetEnquirySourcePage({super.key});

  @override
  State<TargetEnquirySourcePage> createState() =>
      _TargetEnquirySourcePageState();
}

class _TargetEnquirySourcePageState extends State<TargetEnquirySourcePage> {
  late TargetEnquirySourceProvider _provider;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _provider =
        Provider.of<TargetEnquirySourceProvider>(context, listen: false);
    _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchEnquirySources(context);
      _provider.fetchTargetList(context);
      // Only register the "New" button on the web header if user has Save permission
      if (_settingsProvider.menuIsSaveMap[155] == 1) {
        _settingsProvider.setOnAddPressed(_openAddDialog);
      }
    });
  }

  @override
  void dispose() {
    if (_settingsProvider.onAddPressed == _openAddDialog) {
      _settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  void _openAddDialog() {
    _openDialog();
  }

  void _openDialog({TargetEnquirySourceModel? editModel}) {
    if (editModel != null) {
      _provider.populateForEdit(editModel);
    } else {
      _provider.resetForm();
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => _AddTargetDialog(
        editModel: editModel,
      ),
    ).then((refreshed) {
      if (refreshed == true) {
        _provider.fetchTargetList(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    final provider = Provider.of<TargetEnquirySourceProvider>(context);
    const double minWidth = 800.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minWidth
                  ? minWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with "New Target" button (mobile – Save permission)
              if (!isWeb &&
                  Provider.of<SettingsProvider>(context, listen: false)
                          .menuIsSaveMap[155] ==
                      1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openDialog(),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(
                          'New Target',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Table header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBlue.withOpacity(0.08),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
                child: Row(
                  children: [
                    _headerCell('Enquiry Source', flex: 2),
                    _headerCell('Target From', flex: 2),
                    _headerCell('Target To', flex: 2),
                    _headerCell('Duration From', flex: 2),
                    _headerCell('Duration To', flex: 2),
                    _headerCell('Actions', flex: 2, alignRight: true),
                  ],
                ),
              ),

              // List
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4),
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: provider.targetList.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No targets found',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: AppColors.textGrey3,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, thickness: 0.5),
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: provider.targetList.length,
                        itemBuilder: (_, index) {
                          final item = provider.targetList[index];
                          return Container(
                            color: AppColors.whiteColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                _dataCell(item.enquirySourceName, flex: 2),
                                _dataCell(_formatDisplay(item.targetFrom),
                                    flex: 2),
                                _dataCell(_formatDisplay(item.targetTo),
                                    flex: 2),
                                _dataCell(_formatDisplay(item.durationFrom),
                                    flex: 2),
                                _dataCell(_formatDisplay(item.durationTo),
                                    flex: 2),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (Provider.of<SettingsProvider>(context,
                                                  listen: false)
                                              .menuIsEditMap[155] ==
                                          1)
                                        TextButton(
                                          onPressed: () =>
                                              _openDialog(editModel: item),
                                          child: Text(
                                            'Edit',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      if (Provider.of<SettingsProvider>(context,
                                                  listen: false)
                                              .menuIsDeleteMap[155] ==
                                          1)
                                        TextButton(
                                          onPressed: () =>
                                              _confirmDelete(context, item),
                                          child: Text(
                                            'Delete',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textRed,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );

        if (isWeb) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: content,
          );
        }
        return content;
      },
    );
  }

  void _confirmDelete(BuildContext context, TargetEnquirySourceModel item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this target?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _provider.deleteTarget(context, item.targetEnquirySourceId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {int flex = 1, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlue800,
          ),
        ),
      ),
    );
  }

  Widget _dataCell(String value, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        value.isEmpty ? '—' : value,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textBlack,
        ),
      ),
    );
  }

  String _formatDisplay(String value) {
    if (value.isEmpty) return '';
    try {
      final dt = DateTime.parse(value);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return value;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dialog for Add / Edit
// ─────────────────────────────────────────────────────────────────────────────

class _AddTargetDialog extends StatefulWidget {
  final TargetEnquirySourceModel? editModel;

  const _AddTargetDialog({this.editModel});

  @override
  State<_AddTargetDialog> createState() => _AddTargetDialogState();
}

class _AddTargetDialogState extends State<_AddTargetDialog> {
  late TargetEnquirySourceProvider _provider;
  String _enquirySearchQuery = '';

  @override
  void initState() {
    super.initState();
    _provider =
        Provider.of<TargetEnquirySourceProvider>(context, listen: false);
    // Ensure enquiry sources are loaded
    if (_provider.enquirySources.isEmpty) {
      _provider.fetchEnquirySources(context);
    }
  }

  Future<void> _pickDate(
    void Function(DateTime) setter,
    DateTime? initial,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setter(picked);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.editModel != null;
    final provider = Provider.of<TargetEnquirySourceProvider>(context);

    // Filter enquiry sources by search query
    final filteredSources = provider.enquirySources
        .where((s) => s.enquirySourceName
            .toLowerCase()
            .contains(_enquirySearchQuery.toLowerCase()))
        .toList();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Row(
                children: [
                  Text(
                    isEdit ? 'Edit Target' : 'New Target – Enquiry Source',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlue800,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Enquiry Source Dropdown with search
              _label('Enquiry Source'),
              const SizedBox(height: 6),
              _buildEnquirySourceDropdown(provider, filteredSources),
              const SizedBox(height: 16),

              // Target From & To
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Target From'),
                        const SizedBox(height: 6),
                        _DatePickerField(
                          label: provider.displayTargetFrom.isEmpty
                              ? 'Select date'
                              : provider.displayTargetFrom,
                          onTap: () => _pickDate(
                              provider.setTargetFrom, provider.targetFrom),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Target To'),
                        const SizedBox(height: 6),
                        _DatePickerField(
                          label: provider.displayTargetTo.isEmpty
                              ? 'Select date'
                              : provider.displayTargetTo,
                          onTap: () => _pickDate(
                              provider.setTargetTo, provider.targetTo),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration From & To
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Duration From'),
                        const SizedBox(height: 6),
                        _DatePickerField(
                          label: provider.displayDurationFrom.isEmpty
                              ? 'Select date'
                              : provider.displayDurationFrom,
                          onTap: () => _pickDate(
                              provider.setDurationFrom, provider.durationFrom),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Duration To'),
                        const SizedBox(height: 6),
                        _DatePickerField(
                          label: provider.displayDurationTo.isEmpty
                              ? 'Select date'
                              : provider.displayDurationTo,
                          onTap: () => _pickDate(
                              provider.setDurationTo, provider.durationTo),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textGrey3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => provider.saveTarget(
                      context,
                      editId: widget.editModel?.targetEnquirySourceId ?? 0,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      isEdit ? 'Update' : 'Save',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnquirySourceDropdown(
    TargetEnquirySourceProvider provider,
    List<EnquirySourceModel> filteredSources,
  ) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EnquirySourceModel>(
          isExpanded: true,
          value: provider.selectedEnquirySource != null &&
                  provider.enquirySources.any((s) =>
                      s.enquirySourceId ==
                      provider.selectedEnquirySource!.enquirySourceId)
              ? provider.enquirySources.firstWhere((s) =>
                  s.enquirySourceId ==
                  provider.selectedEnquirySource!.enquirySourceId)
              : null,
          hint: Text(
            'Select Enquiry Source',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textGrey3,
            ),
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.grey, size: 20),
          items: provider.enquirySources.map((source) {
            return DropdownMenuItem<EnquirySourceModel>(
              value: source,
              child: Text(
                source.enquirySourceName,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
            );
          }).toList(),
          onChanged: (val) => provider.setSelectedEnquirySource(val),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textBlue800,
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: label == 'Select date'
                      ? AppColors.textGrey3
                      : AppColors.textBlack,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
