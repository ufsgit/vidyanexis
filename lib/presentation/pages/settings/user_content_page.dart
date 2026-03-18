import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/models/get_user_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/permission_handling_user_widget.dart';
import 'package:vidyanexis/presentation/widgets/settings/settings_add_user_widget.dart';

import '../../widgets/settings/add_team_widget.dart';

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  _UsersContentState createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);

      settingsProvider.getUserDetails(
        '',
        context,
      );
      settingsProvider.searchDepartment('', context);
      settingsProvider.searchController.clear();
    });
    super.initState();
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
            // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Text(
                    'Users',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textBlue800),
                  ),
                  const Spacer(),
                  Container(
                    width: AppStyles.isWebScreen(context)
                        ? 350
                        : MediaQuery.of(context).size.width / 3.5,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: settingsProvider.searchController,
                      onChanged: (query) {
                        settingsProvider.getUserDetails(query, context);
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
                  if (settingsProvider.menuIsSaveMap[1] == 1)
                    CustomOutlinedSvgButton(
                      onPressed: () async {
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
                      },
                      svgPath: 'assets/images/Plus.svg',
                      label: 'New User',
                      breakpoint: 860,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.primaryBlue,
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(height: 24),

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
                          color: AppColors.techityfyGrey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            // Table header with fixed widths
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Text(
                                      'No',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      'User name',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: Text(
                                      'Department',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 120,
                                    child: Text(
                                      'Branch',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                    child: Center(
                                      child: Text(
                                        'Edit',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey1),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(width: 32),
                                  SizedBox(
                                    width: 60,
                                    child: Center(
                                      child: Text(
                                        'Delete',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey1),
                                      ),
                                    ),
                                  ),
                                  // const SizedBox(width: 32),
                                  SizedBox(
                                    width: 110,
                                    child: Center(
                                      child: Text(
                                        'Team',
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textGrey1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 80,
                                    child: Text(
                                      'Status',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'View details',
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey1),
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
                                  color: index.isEven
                                      ? Colors.white
                                      : AppColors.surfaceGrey,
                                  child: Padding(
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
                                              const CircleAvatar(
                                                radius: 12,
                                                child: Icon(
                                                    Icons.person_outline,
                                                    size: 16,
                                                    color: Colors.grey),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  settingsProvider
                                                      .searchUserDetails[index]
                                                      .userDetailsName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
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
                                                            color:
                                                                Colors.purple,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Flexible(
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .blue.shade50,
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
                                              child: IconButton(
                                                onPressed: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return SettingsAddUserWidget(
                                                          appLogin: settingsProvider
                                                                      .searchUserDetails[
                                                                          index]
                                                                      .allowAppLogin ==
                                                                  1
                                                              ? true
                                                              : false,
                                                          userType: settingsProvider
                                                              .searchUserDetails[
                                                                  index]
                                                              .userType
                                                              .toString(),
                                                          userStatusId:
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .workingStatus
                                                                  .toString(),
                                                          departmentId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[index]
                                                                  .departmentId),
                                                          branchId: int.parse(settingsProvider.searchUserDetails[index].branchId),
                                                          userId: settingsProvider.searchUserDetails[index].userDetailsId.toString(),
                                                          email: settingsProvider.searchUserDetails[index].email,
                                                          userName: settingsProvider.searchUserDetails[index].userDetailsName,
                                                          password: settingsProvider.searchUserDetails[index].password,
                                                          newPassword: settingsProvider.searchUserDetails[index].password,
                                                          mobileNo: settingsProvider.searchUserDetails[index].mobile,
                                                          empCode: settingsProvider.searchUserDetails[index].empCode,
                                                          designation: settingsProvider.searchUserDetails[index].designation,
                                                          doj: settingsProvider.searchUserDetails[index].doj,
                                                          isEdit: true);
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppColors.primaryBlue,
                                                  size: 20,
                                                ),
                                                tooltip: 'Edit',
                                              ),
                                            ),
                                          ),
                                        if (settingsProvider
                                                .menuIsDeleteMap[1] ==
                                            1)
                                          SizedBox(
                                            width: 60,
                                            child: Center(
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
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: AppColors.textRed,
                                                  size: 20,
                                                ),
                                                tooltip: 'Delete',
                                              ),
                                            ),
                                          ),
                                        SizedBox(
                                          width: 110,
                                          child: Center(
                                            child: ActionChip(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15),
                                                        ),
                                                        side: BorderSide(
                                                            color: Colors
                                                                .transparent)),
                                                color: WidgetStateProperty.all(
                                                    Colors.blue[50]),
                                                onPressed: () =>
                                                    assignTeamDialogue(
                                                        context,
                                                        settingsProvider
                                                                .searchUserDetails[
                                                            index]),
                                                avatar: const CircleAvatar(
                                                  radius: 16,
                                                  child: Icon(
                                                      Icons.person_add_outlined,
                                                      size: 12,
                                                      color: Colors.grey),
                                                ),
                                                label: Text(
                                                  'Team',
                                                  style: GoogleFonts
                                                      .plusJakartaSans(
                                                          fontWeight:
                                                              FontWeight.w400),
                                                )),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        SizedBox(
                                          width: 80,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: settingsProvider
                                                          .searchUserDetails[
                                                               index]
                                                          .workingStatus ==
                                                      '1'
                                                  ? Colors.green.shade50
                                                  : Colors.red.shade50,
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
                                              style: TextStyle(
                                                color: settingsProvider
                                                            .searchUserDetails[
                                                                index]
                                                            .workingStatus ==
                                                        '1'
                                                    ? Colors.green.shade700
                                                    : Colors.red.shade700,
                                                fontSize: 13,
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
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return PermissionHandlingUserWidget(
                                                    userId: settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .userDetailsId
                                                        .toString(),
                                                    userName: settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .userDetailsName,
                                                  );
                                                },
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
                        //   borderRadius: BorderRadius.circular(8),
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
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // User info header
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 20,
                                              child: Icon(Icons.person_outline,
                                                  size: 24, color: Colors.grey),
                                            ),
                                            const SizedBox(width: 12),
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
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppColors.textBlack,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Department : " +
                                                        settingsProvider
                                                            .searchUserDetails[
                                                                index]
                                                            .departmentName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .textGrey1),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Branch : " +
                                                        settingsProvider
                                                            .searchUserDetails[
                                                                index]
                                                            .branchName,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: AppColors
                                                                .textGrey1),
                                                  ),
                                                  Text(
                                                    user.email,
                                                    style: GoogleFonts
                                                        .plusJakartaSans(
                                                      fontSize: 14,
                                                      color:
                                                          AppColors.textGrey1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Status indicator
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: user.workingStatus == '1'
                                                    ? Colors.green.shade50
                                                    : Colors.red.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                user.workingStatus == '1'
                                                    ? 'Active'
                                                    : 'Inactive',
                                                style: TextStyle(
                                                  color: user.workingStatus ==
                                                          '1'
                                                      ? Colors.green.shade700
                                                      : Colors.red.shade700,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 0),

                                        // Action buttons
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            if (settingsProvider
                                                    .menuIsEditMap[1] ==
                                                1)
                                              IconButton(
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
                                                          appLogin:
                                                              settingsProvider.searchUserDetails[index].allowAppLogin == 1
                                                                  ? true
                                                                  : false,
                                                          userType: settingsProvider
                                                              .searchUserDetails[
                                                                  index]
                                                              .userType
                                                              .toString(),
                                                          departmentId: int.parse(
                                                              settingsProvider
                                                                  .searchUserDetails[
                                                                      index]
                                                                  .departmentId),
                                                          userStatusId:
                                                              settingsProvider
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
                                                          isEdit: true);
                                                    },
                                                  );
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppColors.primaryBlue,
                                                  size: 20,
                                                ),
                                                tooltip: 'Edit',
                                              ),
                                            if (settingsProvider
                                                    .menuIsDeleteMap[1] ==
                                                1)
                                              IconButton(
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
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: AppColors.textRed,
                                                  size: 20,
                                                ),
                                                tooltip: 'Delete',
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ActionChip(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(15),
                                                topRight: Radius.circular(15),
                                              ),
                                              side: BorderSide(
                                                  color: Colors.transparent)),
                                          color: WidgetStateProperty.all(
                                              Colors.blue[50]),
                                          onPressed: () => assignTeamDialogue(
                                              context,
                                              settingsProvider
                                                  .searchUserDetails[index]),
                                          avatar: const CircleAvatar(
                                            radius: 16,
                                            child: Icon(
                                                Icons.person_add_outlined,
                                                size: 12,
                                                color: Colors.grey),
                                          ),
                                          label: Text(
                                            'Team',
                                            style: GoogleFonts.plusJakartaSans(
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        SizedBox(
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
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return PermissionHandlingUserWidget(
                                                    userId: settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .userDetailsId
                                                        .toString(),
                                                    userName: settingsProvider
                                                        .searchUserDetails[
                                                            index]
                                                        .userDetailsName,
                                                  );
                                                },
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
                                      ],
                                    ),
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

  assignTeamDialogue(BuildContext context, GetUserModel searchUserDetail) {
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
}
