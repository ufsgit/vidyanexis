import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/get_user_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/pages/settings/permission_handling_page.dart';
import 'package:vidyanexis/presentation/widgets/settings/settings_add_user_widget.dart';

import '../../widgets/settings/add_team_widget.dart';
import '../../widgets/settings/assign_enquiry_for_widget.dart';
import '../../widgets/settings/assign_enquiry_source_widget.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  _UsersContentState createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  late SettingsProvider settingsProvider;

  @override
  void initState() {
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      settingsProvider.getUserDetails(
        '',
        context,
      );
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchController.clear();
      settingsProvider.selectedFilterDepartmentId = 0;
      settingsProvider.selectedFilterBranchId = 0;
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
    settingsProvider.resetStates();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SettingsAddUserWidget(
          isEdit: false,
          userId: '0',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    const double minContentWidth = 1300.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // Table section
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: AppStyles.isWebScreen(context)
                    ? constraints.maxWidth < minContentWidth
                        ? minContentWidth
                        : constraints.maxWidth
                    : MediaQuery.of(context).size.width - 30,
                child: AppStyles.isWebScreen(context)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Table header with fixed widths
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      'User name',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: Text(
                                      'Department',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      'Branch',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        'Team',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 120,
                                    child: Center(
                                      child: Text(
                                        'Enquiry For',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 130,
                                    child: Center(
                                      child: Text(
                                        'Enquiry Source',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF475569)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Status',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'View details',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF475569)),
                                    ),
                                  ),
                                  const Expanded(child: SizedBox()),
                                ],
                              ),
                            ),

                            // Table rows
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  settingsProvider.searchUserDetails.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: index.isEven
                                        ? Colors.white
                                        : const Color(0xFFF8FAFC),
                                    border: Border(
                                      bottom: BorderSide(
                                        color: index ==
                                                settingsProvider
                                                        .searchUserDetails
                                                        .length -
                                                    1
                                            ? Colors.transparent
                                            : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: Text(
                                          (index + 1).toString(),
                                          style: GoogleFonts.plusJakartaSans(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textBlack),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 180,
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 14,
                                              backgroundColor: getAvatarColor(
                                                  settingsProvider
                                                      .searchUserDetails[index]
                                                      .userDetailsName),
                                              child: Text(
                                                () {
                                                  final nameStr =
                                                      settingsProvider
                                                          .searchUserDetails[
                                                              index]
                                                          .userDetailsName
                                                          .trim();
                                                  if (nameStr.isEmpty) {
                                                    return 'U';
                                                  }
                                                  final words = nameStr
                                                      .split(RegExp(r'\s+'));
                                                  if (words.length > 1) {
                                                    return (words[0][0] +
                                                            words[1][0])
                                                        .toUpperCase();
                                                  }
                                                  return nameStr.length > 1
                                                      ? nameStr
                                                          .substring(0, 2)
                                                          .toUpperCase()
                                                      : nameStr[0]
                                                          .toUpperCase();
                                                }(),
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                settingsProvider
                                                    .searchUserDetails[index]
                                                    .userDetailsName,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors
                                                            .textBlack),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 140,
                                        child: (settingsProvider
                                                    .searchUserDetails[index]
                                                    .departmentName !=
                                                null)
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .purple.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        settingsProvider
                                                                .searchUserDetails[
                                                                    index]
                                                                .departmentName ??
                                                            "",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.purple,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        child: (settingsProvider
                                                    .searchUserDetails[index]
                                                    .branchName !=
                                                null)
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.blue.shade50,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                        settingsProvider
                                                                .searchUserDetails[
                                                                    index]
                                                                .branchName ??
                                                            "",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: GoogleFonts
                                                            .plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.blue,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : const SizedBox(),
                                      ),
                                      if (settingsProvider.menuIsEditMap[1] ==
                                          1)
                                        SizedBox(
                                          width: 50,
                                          child: Center(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFEFF6FF),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return SettingsAddUserWidget(
                                                          appLogin:
                                                              settingsProvider.searchUserDetails[index].allowAppLogin ==
                                                                  '1',
                                                          userType:
                                                              settingsProvider.searchUserDetails[index].userType
                                                                  .toString(),
                                                          userStatusId:
                                                              settingsProvider.searchUserDetails[index].workingStatus
                                                                  .toString(),
                                                          departmentId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .departmentId),
                                                          branchId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .branchId),
                                                          userId: settingsProvider
                                                              .searchUserDetails[index]
                                                              .userDetailsId
                                                              .toString(),
                                                          email: settingsProvider.searchUserDetails[index].email,
                                                          userName: settingsProvider.searchUserDetails[index].userDetailsName,
                                                          password: settingsProvider.searchUserDetails[index].password,
                                                          newPassword: settingsProvider.searchUserDetails[index].password,
                                                          mobileNo: settingsProvider.searchUserDetails[index].mobile,
                                                          empCode: settingsProvider.searchUserDetails[index].empCode,
                                                          designation: settingsProvider.searchUserDetails[index].designation,
                                                          doj: settingsProvider.searchUserDetails[index].doj,
                                                          transferDepartments: settingsProvider.searchUserDetails[index].transferDepartments,
                                                          isEdit: true);
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.edit_rounded,
                                                  color: AppColors.primaryBlue,
                                                  size: 18,
                                                ),
                                                constraints:
                                                    const BoxConstraints(),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                tooltip: 'Edit User',
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (settingsProvider.menuIsDeleteMap[1] ==
                                          1)
                                        SizedBox(
                                          width: 60,
                                          child: Center(
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFEF2F2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        contextx) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Confirm Delete'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this user?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              String userId =
                                                                  settingsProvider
                                                                      .searchUserDetails[
                                                                          index]
                                                                      .userDetailsId
                                                                      .toString();
                                                              settingsProvider
                                                                  .deleteUserContent(
                                                                      context,
                                                                      userId);
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: Color(0xFFEF4444),
                                                  size: 18,
                                                ),
                                                constraints:
                                                    const BoxConstraints(),
                                                padding:
                                                    const EdgeInsets.all(8),
                                                tooltip: 'Delete User',
                                              ),
                                            ),
                                          ),
                                        ),
                                      SizedBox(
                                        width: 110,
                                        child: Center(
                                          child: ActionChip(
                                            onPressed: () => assignTeamDialogue(
                                                context,
                                                settingsProvider
                                                    .searchUserDetails[index]),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            backgroundColor:
                                                const Color(0xFFEFF6FF),
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            avatar: Icon(
                                              Icons.group_add_rounded,
                                              size: 14,
                                              color: AppColors.primaryBlue,
                                            ),
                                            label: Text(
                                              'Team',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 120,
                                        child: Center(
                                          child: ActionChip(
                                            onPressed: () => assignEnquiryForDialogue(
                                                context,
                                                settingsProvider
                                                    .searchUserDetails[index]),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            backgroundColor:
                                                const Color(0xFFF5F3FF),
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            avatar: const Icon(
                                              Icons.assignment_rounded,
                                              size: 14,
                                              color: Color(0xFF6D28D9),
                                            ),
                                            label: Text(
                                              'Enquiry For',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF6D28D9),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 130,
                                        child: Center(
                                          child: ActionChip(
                                            onPressed: () => assignEnquirySourceDialogue(
                                                context,
                                                settingsProvider
                                                    .searchUserDetails[index]),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            backgroundColor:
                                                const Color(0xFFECFDF5),
                                            side: BorderSide.none,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            avatar: const Icon(
                                              Icons.campaign_rounded,
                                              size: 14,
                                              color: Color(0xFF059669),
                                            ),
                                            label: Text(
                                              'Enquiry Source',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF059669),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 80,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .workingStatus ==
                                                    '1'
                                                ? const Color(0xFFE8F8EE)
                                                : const Color(0xFFFDECEB),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .workingStatus ==
                                                    '1'
                                                ? 'Active'
                                                : 'Inactive',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: settingsProvider
                                                          .searchUserDetails[
                                                              index]
                                                          .workingStatus ==
                                                      '1'
                                                  ? const Color(0xFF1B7C3D)
                                                  : const Color(0xFFC53030),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SizedBox(
                                        width: 200,
                                        child: CustomOutlinedSvgButton(
                                          showIcon: false,
                                          onPressed: () async {
                                            log(settingsProvider
                                                .searchUserDetails[index]
                                                .userDetailsId
                                                .toString());
                                            await settingsProvider
                                                .getMenuPermissionData(
                                                    settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .userDetailsId
                                                        .toString(),
                                                    context);
                                            settingsProvider
                                                .searchPermission(context);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PermissionHandlingPage(
                                                  userId: settingsProvider
                                                      .searchUserDetails[index]
                                                      .userDetailsId
                                                      .toString(),
                                                  userName: settingsProvider
                                                      .searchUserDetails[index]
                                                      .userDetailsName,
                                                ),
                                              ),
                                            );
                                          },
                                          svgPath: 'assets/images/Print.svg',
                                          label: 'Permissions',
                                          breakpoint: 860,
                                          foregroundColor:
                                              AppColors.primaryBlue,
                                          backgroundColor: Colors.white,
                                          borderSide: BorderSide(
                                              color: AppColors.primaryBlue),
                                        ),
                                      ),
                                      const Expanded(child: SizedBox()),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : Container(
                        // decoration: BoxDecoration(
                        //   color: AppColors.surfaceGrey,
                        //   borderRadius: BorderRadius.circular(4),
                        // ),
                        child: Column(
                          children: [
                            // User cards
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount:
                                  settingsProvider.searchUserDetails.length,
                              itemBuilder: (context, index) {
                                final user =
                                    settingsProvider.searchUserDetails[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Row: Avatar + Details + Status
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Circular Initials Avatar
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: getAvatarColor(
                                                user.userDetailsName),
                                            child: Text(
                                              () {
                                                final nameStr =
                                                    user.userDetailsName.trim();
                                                if (nameStr.isEmpty) return 'U';
                                                final words = nameStr
                                                    .split(RegExp(r'\s+'));
                                                if (words.length > 1) {
                                                  return (words[0][0] +
                                                          words[1][0])
                                                      .toUpperCase();
                                                }
                                                return nameStr.length > 1
                                                    ? nameStr
                                                        .substring(0, 2)
                                                        .toUpperCase()
                                                    : nameStr[0].toUpperCase();
                                              }(),
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Details: Name & Email
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.userDetailsName,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.textBlack,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  user.email,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                    fontSize: 13,
                                                    color: AppColors.textGrey3,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Status Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: user.workingStatus == '1'
                                                  ? const Color(0xFFE8F8EE)
                                                  : const Color(0xFFFDECEB),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              user.workingStatus == '1'
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                color: user.workingStatus == '1'
                                                    ? const Color(0xFF1B7C3D)
                                                    : const Color(0xFFC53030),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Metadata Row: Dept & Branch Badges
                                      Row(
                                        children: [
                                          // Dept Badge
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0)),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.work_outline_rounded,
                                                    size: 14,
                                                    color: AppColors.textGrey3,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      user.departmentName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.textGrey3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Branch Badge
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                border: Border.all(
                                                    color: const Color(
                                                        0xFFE2E8F0)),
                                              ),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: AppColors.textGrey3,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      user.branchName,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .plusJakartaSans(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            AppColors.textGrey3,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Actions Row: Edit & Delete (Left) + Team & Permissions (Right)
                                      Row(
                                        children: [
                                          // Left: Edit
                                          if (settingsProvider
                                                  .menuIsEditMap[1] ==
                                              1) ...[
                                            Container(
                                              height: 36,
                                              width: 36,
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryBlue
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      log(settingsProvider
                                                          .searchUserDetails[
                                                              index]
                                                          .departmentId
                                                          .toString());

                                                      return SettingsAddUserWidget(
                                                          appLogin: settingsProvider.searchUserDetails[index].allowAppLogin ==
                                                              '1',
                                                          userType: settingsProvider.searchUserDetails[index].userType
                                                              .toString(),
                                                          departmentId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .departmentId),
                                                          branchId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .branchId),
                                                          userStatusId: settingsProvider
                                                              .searchUserDetails[
                                                                  index]
                                                              .workingStatus
                                                              .toString(),
                                                          userId: settingsProvider
                                                              .searchUserDetails[index]
                                                              .userDetailsId
                                                              .toString(),
                                                          email: settingsProvider.searchUserDetails[index].email,
                                                          userName: settingsProvider.searchUserDetails[index].userDetailsName,
                                                          password: settingsProvider.searchUserDetails[index].password,
                                                          newPassword: settingsProvider.searchUserDetails[index].password,
                                                          mobileNo: settingsProvider.searchUserDetails[index].mobile,
                                                          empCode: settingsProvider.searchUserDetails[index].empCode,
                                                          designation: settingsProvider.searchUserDetails[index].designation,
                                                          doj: settingsProvider.searchUserDetails[index].doj,
                                                          transferDepartments: settingsProvider.searchUserDetails[index].transferDepartments,
                                                          isEdit: true);
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.edit_rounded,
                                                  color: AppColors.primaryBlue,
                                                  size: 18,
                                                ),
                                                tooltip: 'Edit',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                          ],
                                          // Left: Delete
                                          if (settingsProvider
                                                  .menuIsDeleteMap[1] ==
                                              1) ...[
                                            Container(
                                              height: 36,
                                              width: 36,
                                              decoration: BoxDecoration(
                                                color: AppColors.textRed
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: IconButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                        contextx) {
                                                      return AlertDialog(
                                                        title: const Text(
                                                            'Confirm Delete'),
                                                        content: const Text(
                                                            'Are you sure you want to delete this user?'),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Text(
                                                                'Cancel'),
                                                          ),
                                                          TextButton(
                                                            onPressed:
                                                                () async {
                                                              String userId =
                                                                  settingsProvider
                                                                      .searchUserDetails[
                                                                          index]
                                                                      .userDetailsId
                                                                      .toString();
                                                              settingsProvider
                                                                  .deleteUserContent(
                                                                      context,
                                                                      userId);
                                                              Navigator.pop(
                                                                  context);
                                                              print(userId);
                                                            },
                                                            child: const Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline_rounded,
                                                  color: AppColors.textRed,
                                                  size: 18,
                                                ),
                                                tooltip: 'Delete',
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.end,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                side: BorderSide(
                                                    color: AppColors.primaryBlue
                                                        .withOpacity(0.2)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(4)),
                                                backgroundColor: AppColors
                                                    .primaryBlue
                                                    .withOpacity(0.05),
                                              ),
                                              onPressed: () => assignTeamDialogue(
                                                  context,
                                                  settingsProvider
                                                      .searchUserDetails[index]),
                                              icon: const Icon(
                                                  Icons.group_add_rounded,
                                                  size: 15,
                                                  color: AppColors.primaryBlue),
                                              label: Text(
                                                'Team',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                side: BorderSide(
                                                    color: const Color(0xFF6D28D9)
                                                        .withOpacity(0.2)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(4)),
                                                backgroundColor: const Color(0xFF6D28D9)
                                                    .withOpacity(0.05),
                                              ),
                                              onPressed: () => assignEnquiryForDialogue(
                                                  context,
                                                  settingsProvider
                                                      .searchUserDetails[index]),
                                              icon: const Icon(
                                                  Icons.assignment_rounded,
                                                  size: 15,
                                                  color: Color(0xFF6D28D9)),
                                              label: Text(
                                                'Enquiry For',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF6D28D9),
                                                ),
                                              ),
                                            ),
                                            OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                side: BorderSide(
                                                    color: const Color(0xFF059669)
                                                        .withOpacity(0.2)),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(4)),
                                                backgroundColor: const Color(0xFF059669)
                                                    .withOpacity(0.05),
                                              ),
                                              onPressed: () => assignEnquirySourceDialogue(
                                                  context,
                                                  settingsProvider
                                                      .searchUserDetails[index]),
                                              icon: const Icon(
                                                  Icons.campaign_rounded,
                                                  size: 15,
                                                  color: Color(0xFF059669)),
                                              label: Text(
                                                'Enquiry Src',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF059669),
                                                ),
                                              ),
                                            ),
                                            OutlinedButton(
                                              style: OutlinedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                minimumSize: Size.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                side: const BorderSide(
                                                    color: AppColors.primaryBlue),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(4)),
                                                backgroundColor: Colors.white,
                                              ),
                                              onPressed: () async {
                                                log(settingsProvider
                                                    .searchUserDetails[index]
                                                    .userDetailsId
                                                    .toString());
                                                await settingsProvider
                                                    .getMenuPermissionData(
                                                        settingsProvider
                                                            .searchUserDetails[
                                                                index]
                                                            .userDetailsId
                                                            .toString(),
                                                        context);
                                                settingsProvider
                                                    .searchPermission(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PermissionHandlingPage(
                                                      userId: settingsProvider
                                                          .searchUserDetails[
                                                              index]
                                                          .userDetailsId
                                                          .toString(),
                                                      userName: settingsProvider
                                                          .searchUserDetails[
                                                              index]
                                                          .userDetailsName,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                'Permissions',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryBlue,
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
                          ],
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> assignTeamDialogue(
      BuildContext context, GetUserModel searchUserDetail) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AssignTeamWidget(
          userModel: searchUserDetail,
        );
      },
    );
  }

  Future<dynamic> assignEnquiryForDialogue(
      BuildContext context, GetUserModel searchUserDetail) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AssignEnquiryForWidget(
          userModel: searchUserDetail,
        );
      },
    );
  }

  Future<dynamic> assignEnquirySourceDialogue(
      BuildContext context, GetUserModel searchUserDetail) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AssignEnquirySourceWidget(
          userModel: searchUserDetail,
        );
      },
    );
  }
}
