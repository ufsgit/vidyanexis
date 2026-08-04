import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_designation.dart';

class DesignationContent extends StatefulWidget {
  const DesignationContent({super.key});

  @override
  State<DesignationContent> createState() => _DesignationContentState();
}

class _DesignationContentState extends State<DesignationContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchDesignation('', context);
      settingsProvider.searchDesignationController.clear();
      settingsProvider.setOnAddPressed(_openAddDialog);
    });
    super.initState();
  }

  @override
  void dispose() {
    if (settingsProvider.onAddPressed == _openAddDialog) {
      settingsProvider.setOnAddPressed(null);
    }
    super.dispose();
  }

  void _openAddDialog() {
    final isWeb = AppStyles.isWebScreen(context);
    if (isWeb) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const AddDesignation(
            editId: '0',
            isEdit: false,
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddDesignation(
            editId: '0',
            isEdit: false,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = AppStyles.isWebScreen(context);
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: SizedBox(
            width: isWeb
                ? (constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth)
                : constraints.maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The List
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: settingsProvider.designationList.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'No Designations found',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: settingsProvider.designationList.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 1,
                            thickness: 1,
                            color: Colors.grey[200]!,
                          ),
                          itemBuilder: (context, index) {
                            final designation =
                                settingsProvider.designationList[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Designation name badge
                                  SizedBox(
                                    width: 220,
                                    child: _buildDesignationBadge(
                                        designation.designationName),
                                  ),
                                  const SizedBox(width: 10),
                                  // Task types count + names
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${designation.taskTypes.length} Task Type${designation.taskTypes.length == 1 ? '' : 's'}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        if (designation.taskTypes.isNotEmpty)
                                          const SizedBox(height: 10),
                                        if (designation.taskTypes.isNotEmpty)
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: designation.taskTypes
                                                .take(4)
                                                .map((tt) {
                                              return Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surfaceGrey,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '${tt.taskTypeName} (D:${tt.dailyCount} / M:${tt.monthlyCount})',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 11,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              );
                                            }).toList()
                                              ..addAll(
                                                designation.taskTypes.length > 4
                                                    ? [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade200,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: Text(
                                                            '+${designation.taskTypes.length - 4} more',
                                                            style: GoogleFonts
                                                                .plusJakartaSans(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        )
                                                      ]
                                                    : [],
                                              ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Action buttons
                                  _buildActionButtons(
                                      context, settingsProvider, index),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesignationBadge(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, SettingsProvider settingsProvider, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (settingsProvider.menuIsEditMap[42] == 1)
          IconButton(
            onPressed: () {
              final isWeb = AppStyles.isWebScreen(context);
              if (isWeb) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) {
                    return AddDesignation(
                      editId: settingsProvider
                          .designationList[index].designationId
                          .toString(),
                      isEdit: true,
                      designation: settingsProvider.designationList[index],
                    );
                  },
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddDesignation(
                      editId: settingsProvider
                          .designationList[index].designationId
                          .toString(),
                      isEdit: true,
                      designation: settingsProvider.designationList[index],
                    ),
                  ),
                );
              }
            },
            icon: Icon(Icons.edit_outlined,
                color: AppColors.primaryBlue, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Edit',
          ),
        const SizedBox(width: 8),
        if (settingsProvider.menuIsDeleteMap[42] == 1)
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text(
                        'Are you sure you want to delete this Designation?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          settingsProvider.deleteDesignation(
                            context,
                            settingsProvider
                                .designationList[index].designationId,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            icon:
                Icon(Icons.delete_outline, color: AppColors.textRed, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
            tooltip: 'Delete',
          ),
      ],
    );
  }
}
