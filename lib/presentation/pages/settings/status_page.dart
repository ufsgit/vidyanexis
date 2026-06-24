import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/pages/settings/add_status.dart';

import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../controller/settings_provider.dart';
import '../../widgets/home/custom_outlined_icon_button_widget.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchStatus(context, '0');
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
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return const AddStatus(
          isEdit: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final content = SizedBox(
          width: isWeb
              ? (constraints.maxWidth < minContentWidth
                  ? minContentWidth
                  : constraints.maxWidth)
              : double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 12,
                    );
                  },
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: settingsProvider.status.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                    color: AppColors.surfaceGrey,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Text(
                                  settingsProvider.status[index].statusName,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                              onPressed: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddStatus(
                                      status: settingsProvider.status[index],
                                      isEdit: true,
                                    );
                                  },
                                );
                              },
                              child: Text(
                                'Edit',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryBlue),
                              )),
                          TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            settingsProvider.deleteStatus(
                                                context,
                                                settingsProvider
                                                    .status[index].statusId);
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
                              child: Text(
                                'Delete',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textRed),
                              ))
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
        } else {
          return content;
        }
      },
    );
  }
}
