import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/settings/add_branch.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.searchBranchController.clear();
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
        return const AddBranch(
          editId: '0',
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
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: isWeb
                ? constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth
                : MediaQuery.of(context).size.width - 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      ListView.separated(
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 12,
                          );
                        },
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: settingsProvider.branchModel.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    height: 22,
                                    decoration: BoxDecoration(
                                        color: AppColors.surfaceGrey,
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Text(
                                          settingsProvider.branchModel[index]
                                                  .branchName ??
                                              '',
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (settingsProvider.menuIsEditMap[57] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AddBranch(
                                                editId: settingsProvider
                                                    .branchModel[index].branchId
                                                    .toString(),
                                                branch: settingsProvider
                                                    .branchModel[index],
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
                                  if (settingsProvider.menuIsDeleteMap[57] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
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
                                                      await settingsProvider
                                                          .deleteBranch(
                                                              context,
                                                              settingsProvider
                                                                      .branchModel[
                                                                          index]
                                                                      .branchId ??
                                                                  0);
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      'Delete',
                                                      style: TextStyle(
                                                          color: Colors.red),
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
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
