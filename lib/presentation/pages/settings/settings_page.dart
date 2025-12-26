import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/models/menu_model.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_category_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_item_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/presentation/pages/settings/branch_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_type.dart';
import 'package:vidyanexis/presentation/pages/settings/company_details.dart';
import 'package:vidyanexis/presentation/pages/settings/custom_field.dart';
import 'package:vidyanexis/presentation/pages/settings/department_page.dart';
import 'package:vidyanexis/presentation/pages/settings/document_type.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_for_content.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_source_content.dart';
import 'package:vidyanexis/presentation/pages/settings/expense_type.dart';
import 'package:vidyanexis/presentation/pages/settings/lead_users_content.dart';
import 'package:vidyanexis/presentation/pages/settings/source_cateGory_page.dart';
import 'package:vidyanexis/presentation/pages/settings/stage_page.dart';
import 'package:vidyanexis/presentation/pages/settings/task_type.dart';
import 'package:vidyanexis/presentation/pages/settings/user_content_page.dart';
import 'package:vidyanexis/presentation/pages/settings/version_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      // settingsProvider.getUserDetails(
      //   '',
      //   context,
      // );
      settingsProvider.searchUserTypeDetails(context);
      settingsProvider.searchWorkingStatusData(context);
      settingsProvider.searchEnquiryStatusData('', context);
      settingsProvider.getSearchLeadStatus('', "0", context);
      settingsProvider.searchBranch(context);
      settingsProvider.searchStageData('', context);
      settingsProvider.searchsourceCategoryData('', context);
      settingsProvider.getMenuPermissionData(userId, context);
      settingsProvider.getCustomField(context);
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final sidebarProvider = Provider.of<SidebarProvider>(context);
    return Scaffold(
      appBar: !AppStyles.isWebScreen(context)
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              title: Text(
                'Settings',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar
          if (AppStyles.isWebScreen(context))
            Container(
              width: 250,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: ListView(children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF152D70),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                ...tabBar(settingsProvider),
              ]),
            ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (!AppStyles.isWebScreen(context))
                    SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: tabBar(settingsProvider))),
                  SizedBox(
                    height: AppStyles.isWebScreen(context) ? 72 : 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isSelected = settings.selectedMenu == title;

        return InkWell(
          onTap: () {
            settings.setSelectedMenu(title);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? const Color(0xFFE5F0FF) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Icon(
                    //   icon,
                    //   color: isSelected ? AppColors.primaryBlue : Colors.grey,
                    //   size: 20,
                    // ),
                    // const SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryBlue : Colors.grey,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        switch (settings.selectedMenu) {
          case 'Users':
            return const UsersContent();
          case 'Status':
            return const LeadUsersContent();
          case 'Enquiry Source':
            return const EnquirySourceContent();
          case 'Enquiry For':
            return const EnquiryForContent();
          case 'Document Type':
            return const DocumentTypeContent();
          // case 'CheckList Type':
          //   return const CheckListContent();
          case 'Task Type':
            return const TaskTypeContent();

          case 'Excel Import':
            return const BulkImportScreen();
          case 'Company Details':
            return const CompanyDetails();
          // case 'Version':
          //   return const VersionPage();
          case 'Department':
            return const DepartmentPage();
          case 'Branch':
            return const BranchPage();
          case 'Stage':
            return const StagePage();
          case 'Source Category':
            return const SourceCategoryPage();
          case 'Checklist Item':
            return const CheckListItemPage();
          case 'Checklist Category':
            return const CheckListCategoryPage();
          case 'Custom Field':
            return const CustomField();
          case 'ExpenseType':
            return const ExpenseType();

          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  List<Widget> tabBar(SettingsProvider settingsProvider) {
    return [
      if (settingsProvider.menuIsViewMap[1].toString() == '1')
        _buildMenuItem(
          context,
          'Users',
          Icons.people,
        ),
      if (settingsProvider.menuIsViewMap[5].toString() == '1')
        _buildMenuItem(
          context,
          'Status',
          Icons.trending_up,
        ),
      if (settingsProvider.menuIsViewMap[6].toString() == '1')
        _buildMenuItem(
          context,
          'Enquiry Source',
          Icons.trending_up,
        ),
      if (settingsProvider.menuIsViewMap[17].toString() == '1')
        _buildMenuItem(
          context,
          'Enquiry For',
          Icons.trending_up,
        ),
      if (settingsProvider.menuIsViewMap[23].toString() == '1')
        _buildMenuItem(
          context,
          'Document Type',
          Icons.trending_up,
        ),
      // if (settingsProvider.menuIsViewMap[22].toString() == '1')
      //   _buildMenuItem(
      //     context,
      //     'CheckList Type',
      //     Icons.trending_up,
      //   ),
      if (settingsProvider.menuIsViewMap[41].toString() == '1')
        _buildMenuItem(
          context,
          'Task Type',
          Icons.trending_up,
        ),
      // _buildMenuItem(context, 'Status', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[20].toString() == '1')
        _buildMenuItem(
          context,
          'Excel Import',
          Icons.document_scanner,
        ),
      if (settingsProvider.menuIsViewMap[27].toString() == '1')
        _buildMenuItem(
          context,
          'Company Details',
          Icons.document_scanner,
        ),
      // if (settingsProvider.menuIsViewMap[28].toString() == '1')
      //   _buildMenuItem(
      //     context,
      //     'Version',
      //     Icons.document_scanner,
      //   ),
      if (settingsProvider.menuIsViewMap[42].toString() == '1')
        _buildMenuItem(
          context,
          'Department',
          Icons.document_scanner,
        ),
      if (settingsProvider.menuIsViewMap[57].toString() == '1')
        _buildMenuItem(
          context,
          'Branch',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[58].toString() == '1')
        _buildMenuItem(
          context,
          'Stage',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[59].toString() == '1')
        _buildMenuItem(
          context,
          'Source Category',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[38].toString() == '1')
        _buildMenuItem(
          context,
          'Checklist Item',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[39].toString() == '1')
        _buildMenuItem(
          context,
          'Checklist Category',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[60].toString() == '1')
        _buildMenuItem(
          context,
          'Custom Field',
          Icons.category,
        ),
      if (settingsProvider.menuIsViewMap[64].toString() == '1')
        _buildMenuItem(
          context,
          'ExpenseType',
          Icons.category,
        ),
      // if (settingsProvider.menuIsViewMap[28].toString() == '1')
      //   _buildMenuItem(context, 'Branch', Icons.document_scanner),
    ];
  }
}
