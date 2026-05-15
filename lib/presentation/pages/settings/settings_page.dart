import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_category_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_item_page.dart';
import 'package:vidyanexis/presentation/pages/settings/campaign_content.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/pages/settings/form_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/presentation/pages/settings/branch_page.dart';
import 'package:vidyanexis/presentation/pages/settings/company_details.dart';
import 'package:vidyanexis/presentation/pages/settings/custom_field.dart';
import 'package:vidyanexis/presentation/pages/settings/department_page.dart';
import 'package:vidyanexis/presentation/pages/settings/document_type.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_for_content.dart';
import 'package:vidyanexis/presentation/pages/settings/enquiry_source_content.dart';
import 'package:vidyanexis/presentation/pages/settings/expense_type.dart';
import 'package:vidyanexis/presentation/pages/settings/location_page.dart';
import 'package:vidyanexis/presentation/pages/settings/lead_users_content.dart';
import 'package:vidyanexis/presentation/pages/settings/source_cateGory_page.dart';
import 'package:vidyanexis/presentation/pages/settings/stage_page.dart';
import 'package:vidyanexis/presentation/pages/settings/task_type.dart';
import 'package:vidyanexis/presentation/pages/settings/user_content_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsPageBody();
  }
}

class SettingsPageBody extends StatefulWidget {
  const SettingsPageBody({super.key});

  @override
  State<SettingsPageBody> createState() => _SettingsPageBodyState();
}

class _SettingsPageBodyState extends State<SettingsPageBody> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final preferences = await SharedPreferences.getInstance();
      String userId = preferences.getString('userId') ?? "0";
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
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
    final isMobile = !AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldColor,
      drawer: isMobile ? const SidebarDrawer() : null,
      appBar: isMobile
          ? AppBar(
              surfaceTintColor: AppColors.scaffoldColor,
              backgroundColor: AppColors.whiteColor,
              leadingWidth: 56,
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.sort,
                      size: 20,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Settings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textBlue800,
                ),
              ),
            )
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left sidebar for Web
          if (!isMobile)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  right: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            color: AppColors.textBlue800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: tabBar(settingsProvider),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Column(
              children: [
                if (isMobile)
                  Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(children: tabBar(settingsProvider)),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSelected = settings.selectedMenu == title;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => settings.setSelectedMenu(title),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.secondaryBlue.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? AppColors.secondaryBlue : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final settings = Provider.of<SettingsProvider>(context);
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
      case 'Task Type':
        return const TaskTypeContent();
      case 'Excel Import':
        return const BulkImportScreen();
      case 'Company Details':
        return const CompanyDetails();
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
      case 'Location':
        return const LocationPage();
      case 'Forms':
        return const FormContent();
      case 'Campaign':
        return const CampaignContent();
      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> tabBar(SettingsProvider settingsProvider) {
    return [
      if (settingsProvider.menuIsViewMap[1].toString() == '1')
        _buildMenuItem(context, 'Users', Icons.people),
      if (settingsProvider.menuIsViewMap[5].toString() == '1')
        _buildMenuItem(context, 'Status', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[6].toString() == '1')
        _buildMenuItem(context, 'Enquiry Source', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[17].toString() == '1')
        _buildMenuItem(context, 'Enquiry For', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[23].toString() == '1')
        _buildMenuItem(context, 'Document Type', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[41].toString() == '1')
        _buildMenuItem(context, 'Task Type', Icons.trending_up),
      if (settingsProvider.menuIsViewMap[20].toString() == '1')
        _buildMenuItem(context, 'Excel Import', Icons.document_scanner),
      if (settingsProvider.menuIsViewMap[27].toString() == '1')
        _buildMenuItem(context, 'Company Details', Icons.document_scanner),
      if (settingsProvider.menuIsViewMap[42].toString() == '1')
        _buildMenuItem(context, 'Department', Icons.document_scanner),
      if (settingsProvider.menuIsViewMap[57].toString() == '1')
        _buildMenuItem(context, 'Branch', Icons.category),
      if (settingsProvider.menuIsViewMap[58].toString() == '1')
        _buildMenuItem(context, 'Stage', Icons.category),
      if (settingsProvider.menuIsViewMap[59].toString() == '1')
        _buildMenuItem(context, 'Source Category', Icons.category),
      if (settingsProvider.menuIsViewMap[38].toString() == '1')
        _buildMenuItem(context, 'Checklist Item', Icons.category),
      if (settingsProvider.menuIsViewMap[39].toString() == '1')
        _buildMenuItem(context, 'Checklist Category', Icons.category),
      if (settingsProvider.menuIsViewMap[60].toString() == '1')
        _buildMenuItem(context, 'Custom Field', Icons.category),
      if (settingsProvider.menuIsViewMap[64].toString() == '1')
        _buildMenuItem(context, 'ExpenseType', Icons.category),
      if (settingsProvider.menuIsViewMap[86].toString() == '1')
        _buildMenuItem(context, 'Location', Icons.location_on),
      if (settingsProvider.menuIsViewMap[85].toString() == '1')
        _buildMenuItem(context, 'Forms', Icons.format_list_bulleted),
      _buildMenuItem(context, 'Campaign', Icons.campaign),
    ];
  }
}
