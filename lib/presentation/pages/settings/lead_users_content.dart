import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_dropdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/add_new_status_widget.dart';

class LeadUsersContent extends StatefulWidget {
  const LeadUsersContent({super.key});

  @override
  State<LeadUsersContent> createState() => _LeadUsersContentState();
}

class _LeadUsersContentState extends State<LeadUsersContent> {
  final List<DropdownItem<int>> viewInOptions = [
    DropdownItem<int>(id: 0, name: 'All'),
    DropdownItem<int>(id: 1, name: 'Lead'),
    DropdownItem<int>(id: 2, name: 'Customer'),
    DropdownItem<int>(id: 3, name: 'Task'),
  ];
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.setViewInId(0);
      settingsProvider.getSearchLeadStatus('', '0', context);
      settingsProvider.searchStatusController.clear();
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
        return AddNewStatusWidget(
          editId: '0',
          followUp: '',
          isEdit: false,
          status: '',
          isRegister: '',
          colorCode: '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: AppStyles.isWebScreen(context)
                ? constraints.maxWidth < minContentWidth
                    ? minContentWidth
                    : constraints.maxWidth
                : MediaQuery.of(context).size.width - 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header section
                SizedBox(
                  width: double.infinity,
                  child: AppStyles.isWebScreen(context)
                      ? Row(
                          children: [
                            Text(
                              'Status',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlue800),
                            ),
                            const Spacer(),
                            Container(
                              width: MediaQuery.of(context).size.width / 3.5,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller:
                                    settingsProvider.searchStatusController,
                                onChanged: (query) {
                                  print(query);
                                  settingsProvider.getSearchLeadStatus(
                                      query,
                                      settingsProvider.viewInId.toString(),
                                      context);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Search here....',
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (settingsProvider.menuIsSaveMap[5] == 1)
                              CustomOutlinedSvgButton(
                                onPressed: () async {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AddNewStatusWidget(
                                        editId: '0',
                                        followUp: '',
                                        isEdit: false,
                                        status: '',
                                        isRegister: '',
                                        colorCode: '',
                                      );
                                    },
                                  );
                                },
                                svgPath: 'assets/images/Plus.svg',
                                label: 'New Status',
                                breakpoint: 860,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                foregroundColor: Colors.white,
                                backgroundColor: AppColors.secondaryBlue,
                                borderSide:
                                    BorderSide(color: AppColors.secondaryBlue),
                              ),
                            const SizedBox(width: 16),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                if (AppStyles.isWebScreen(context)) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: 200,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: settingsProvider.viewInId,
                        hint: Text("View",
                            style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
                        items: const [
                          DropdownMenuItem(
                            value: 0,
                            child: Text("All"),
                          ),
                          DropdownMenuItem(
                            value: 1,
                            child: Text("Lead"),
                          ),
                          DropdownMenuItem(
                            value: 2,
                            child: Text("Customer"),
                          ),
                          DropdownMenuItem(
                            value: 3,
                            child: Text("Task"),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            settingsProvider.setViewInId(value);
                            settingsProvider.getSearchLeadStatus(
                              settingsProvider.searchStatusController.text,
                              value.toString(),
                              context,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
                if (AppStyles.isWebScreen(context)) const SizedBox(height: 24),
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
                        itemCount: settingsProvider.searchType.length,
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
                                        borderRadius:
                                            BorderRadius.circular(4)),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        child: Text(
                                          settingsProvider.searchType[index]
                                                  .statusName ??
                                              "",
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: parseColor(settingsProvider
                                                      .searchType[index]
                                                      .colorCode ??
                                                  "")),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    settingsProvider
                                            .searchType[index].viewInName ??
                                        '',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (settingsProvider.menuIsEditMap[5] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AddNewStatusWidget(
                                                  editId: settingsProvider
                                                      .searchType[index]
                                                      .statusId
                                                      .toString(),
                                                  status: settingsProvider
                                                          .searchType[index]
                                                          .statusName ??
                                                      "",
                                                  followUp: settingsProvider
                                                      .searchType[index]
                                                      .followup
                                                      .toString(),
                                                  isRegister: settingsProvider
                                                      .searchType[index]
                                                      .isRegistered
                                                      .toString(),
                                                  isEdit: true,
                                                  colorCode: settingsProvider
                                                      .searchType[index]
                                                      .colorCode
                                                      .toString(),
                                                  data: settingsProvider
                                                      .searchType[index]);
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
                                  if (settingsProvider.menuIsDeleteMap[5] == 1)
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this lead?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      settingsProvider.deleteUser(
                                                          context,
                                                          settingsProvider
                                                                  .searchType[
                                                                      index]
                                                                  .statusId ??
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

  Color parseColor(String colorCode) {
    try {
      final hexValue = colorCode.replaceAll("Color(", "").replaceAll(")", "");
      return Color(
          int.parse(hexValue)); // Convert the hex string to a Color object
    } catch (e) {
      return const Color(0xff34c759); // Default green color
    }
  }
}
