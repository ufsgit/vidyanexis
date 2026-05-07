import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/settings/add_unit_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class UnitPage extends StatefulWidget {
  const UnitPage({super.key});

  @override
  State<UnitPage> createState() => _UnitPageState();
}

class _UnitPageState extends State<UnitPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.searchUnitApi('', context);
      settingsProvider.searchUnitController.clear();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          children: [
            Text(
              'Inventory Units',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlue800),
            ),
            const Spacer(),
            if (settingsProvider.menuIsSaveMap[47] == 1)
              CustomOutlinedSvgButton(
                onPressed: () async {
                  showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return const AddUnitWidget(
                        editId: '0',
                        isEdit: false,
                      );
                    },
                  );
                },
                svgPath: 'assets/images/Plus.svg',
                label: 'New Unit',
                breakpoint: 600,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                foregroundColor: Colors.white,
                backgroundColor: AppColors.primaryBlue,
                borderSide: BorderSide(color: AppColors.primaryBlue),
              ),
          ],
        ),
        const SizedBox(height: 20),
        settingsProvider.searchUnit.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: settingsProvider.searchUnit.length,
                itemBuilder: (context, index) {
                  final unit = settingsProvider.searchUnit[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportListItem(
                      title: unit.unitName,
                      subtitle: 'ID: ${unit.unitId}',
                      description: 'Measurement unit for inventory items.',
                      statusColor: AppColors.primaryBlue,
                      onEdit: settingsProvider.menuIsEditMap[47] == 1
                          ? () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) {
                                  return AddUnitWidget(
                                    editId: unit.unitId.toString(),
                                    isEdit: true,
                                    data: unit,
                                  );
                                },
                              );
                            }
                          : null,
                      onDelete: settingsProvider.menuIsDeleteMap[47] == 1
                          ? () {
                              _showDeleteDialog(context, settingsProvider, unit.unitId);
                            }
                          : null,
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.straighten_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No units found',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SettingsProvider provider, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this unit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                provider.deleteUnit(context, id);
                Navigator.pop(context);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }
}
