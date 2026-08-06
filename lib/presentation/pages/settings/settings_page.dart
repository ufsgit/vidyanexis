import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/settings/designation_content.dart';
import 'package:vidyanexis/presentation/pages/settings/warrenty_terms_page.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_category_page.dart';
import 'package:vidyanexis/presentation/pages/settings/checklist_item_page.dart';
import 'package:vidyanexis/presentation/pages/settings/campaign_content.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/presentation/widgets/home/side_drawer_mobile.dart';
import 'package:vidyanexis/presentation/pages/settings/form_content.dart';
import 'package:vidyanexis/controller/models/form_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/side_bar_provider.dart';
import 'package:vidyanexis/presentation/pages/home/bulk_importing_screen.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
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
import 'package:vidyanexis/presentation/pages/settings/source_category_page.dart';
import 'package:vidyanexis/presentation/pages/settings/stage_page.dart';
import 'package:vidyanexis/presentation/pages/settings/task_type.dart';
import 'package:vidyanexis/presentation/pages/settings/user_content_page.dart';
import 'package:vidyanexis/presentation/pages/settings/target_enquiry_source_page.dart';
import 'package:vidyanexis/presentation/pages/settings/priority_page.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(SettingsProvider provider, String query) {
    final activeMenu = provider.selectedMenu;
    switch (activeMenu) {
      case 'Users':
        provider.getUserDetails(query, context);
        break;
      case 'Status':
        provider.getSearchLeadStatus(
            query, provider.viewInId.toString(), context);
        break;
      case 'Enquiry Source':
        provider.searchEnquiryStatusData(query, context);
        break;
      case 'Enquiry For':
        provider.searchEnquiryForData(query, context);
        break;
      case 'Document Type':
        provider.searchDocumentType(query, context);
        break;
      case 'Task Type':
        provider.searchTaskType(query, context,
            enquiryForId:
                provider.selectedTaskTypeFilterEnquiryForId.toString());
        break;
      case 'Department':
        provider.searchDepartment(query, context);
        break;
      case 'Branch':
        provider.searchBranch(context, query: query);
        break;
      case 'Stage':
        provider.searchStageData(query, context);
        break;
      case 'Source Category':
        provider.searchsourceCategoryData(query, context);
        break;
      case 'ExpenseType':
        provider.getExpenseType(query, context);
        break;
      case 'Location':
        provider.searchLocation(query, context);
        break;
      case 'Custom Field':
        provider.searchCustomField(query);
        break;
      case 'Forms':
        Provider.of<FormProvider>(context, listen: false).setSearchQuery(query);
        break;
      case 'Campaign':
        provider.searchCampaignData(query, context);
        break;
      case 'Priority Management':
        provider.getPriorities(context);
        break;
      case 'Checklist Item':
      case 'Checklist Category':
        setState(
            () {}); // The page itself will rebuild with the updated _searchController.text
        break;
      case 'Checklist Type':
        provider.searchCheckList(query, context);
        break;
    }
  }

  void _showFilterBottomSheet(
      BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filters',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBlue800,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (settingsProvider.selectedMenu == 'Users') ...[
                    Text(
                      'Branch',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: settingsProvider.selectedFilterBranchId ?? 0,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text("All Branches"),
                            ),
                            ...settingsProvider.branchModel.map((branch) {
                              return DropdownMenuItem(
                                value: branch.branchId,
                                child: Text(branch.branchName ?? "",
                                    overflow: TextOverflow.ellipsis),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              settingsProvider.selectedFilterBranchId = value;
                            });
                            settingsProvider.getUserDetails(
                              _searchController.text,
                              context,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Department',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value:
                              settingsProvider.selectedFilterDepartmentId ?? 0,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text("All Depts"),
                            ),
                            ...settingsProvider.departmentModel.map((dept) {
                              return DropdownMenuItem(
                                value: dept.departmentId,
                                child: Text(dept.departmentName,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              settingsProvider.selectedFilterDepartmentId =
                                  value;
                            });
                            settingsProvider.getUserDetails(
                              _searchController.text,
                              context,
                            );
                          },
                        ),
                      ),
                    ),
                  ] else if (settingsProvider.selectedMenu == 'Status') ...[
                    Text(
                      'View Status In',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: settingsProvider.viewInId,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('All')),
                            DropdownMenuItem(value: 1, child: Text('Lead')),
                            DropdownMenuItem(value: 2, child: Text('Customer')),
                            DropdownMenuItem(value: 3, child: Text('Task')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                settingsProvider.setViewInId(value);
                              });
                              settingsProvider.getSearchLeadStatus(
                                _searchController.text,
                                value.toString(),
                                context,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ] else if (settingsProvider.selectedMenu == 'Task Type') ...[
                    Text(
                      'Enquiry For',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: settingsProvider
                                  .selectedTaskTypeFilterEnquiryForId ??
                              0,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(
                              value: 0,
                              child: Text("All Enquiry For"),
                            ),
                            ...settingsProvider.searchEnquiryFor.map((item) {
                              return DropdownMenuItem(
                                value: item.enquiryForId,
                                child: Text(item.enquiryForName,
                                    overflow: TextOverflow.ellipsis),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              settingsProvider
                                  .selectedTaskTypeFilterEnquiryForId = value;
                            });
                            settingsProvider.searchTaskType(
                              _searchController.text,
                              context,
                              enquiryForId: value.toString(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        'Apply Filters',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWebHeader(SettingsProvider settingsProvider) {
    if (settingsProvider.selectedMenu == 'Company Details' ||
        settingsProvider.selectedMenu == 'Excel Import' ||
        settingsProvider.selectedMenu == 'Version' ||
        settingsProvider.selectedMenu == 'Terms & Warranty') {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Row(
            children: [
              Text(
                settingsProvider.selectedMenu,
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
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    _triggerSearch(settingsProvider, query);
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
              if (settingsProvider.onAddPressed != null)
                CustomOutlinedSvgButton(
                  onPressed: settingsProvider.onAddPressed!,
                  svgPath: 'assets/images/Plus.svg',
                  label: 'New ${settingsProvider.selectedMenu}',
                  breakpoint: 860,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.secondaryBlue,
                  borderSide: const BorderSide(color: AppColors.secondaryBlue),
                ),
              if (settingsProvider.onAddPressed != null)
                const SizedBox(width: 16),
            ],
          ),
        ),
        if (settingsProvider.selectedMenu == 'Status') ...[
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
                    offset: const Offset(0, 2)),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: settingsProvider.viewInId,
                hint: Text("View",
                    style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey, size: 20),
                items: const [
                  DropdownMenuItem(value: 0, child: Text("All")),
                  DropdownMenuItem(value: 1, child: Text("Lead")),
                  DropdownMenuItem(value: 2, child: Text("Customer")),
                  DropdownMenuItem(value: 3, child: Text("Task")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      settingsProvider.setViewInId(value);
                    });
                    settingsProvider.getSearchLeadStatus(
                      _searchController.text,
                      value.toString(),
                      context,
                    );
                  }
                },
              ),
            ),
          ),
        ],
        if (settingsProvider.selectedMenu == 'Task Type') ...[
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
                    offset: const Offset(0, 2)),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: settingsProvider.selectedTaskTypeFilterEnquiryForId ?? 0,
                hint: Text("Enquiry For",
                    style: GoogleFonts.plusJakartaSans(fontSize: 14)),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey, size: 20),
                items: [
                  const DropdownMenuItem(
                      value: 0, child: Text("All Enquiry For")),
                  ...settingsProvider.searchEnquiryFor
                      .map((item) => DropdownMenuItem(
                            value: item.enquiryForId,
                            child: Text(item.enquiryForName,
                                overflow: TextOverflow.ellipsis),
                          )),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      settingsProvider.selectedTaskTypeFilterEnquiryForId =
                          value;
                    });
                    settingsProvider.searchTaskType(
                      _searchController.text,
                      context,
                      enquiryForId: value.toString(),
                    );
                  }
                },
              ),
            ),
          ),
        ],
        if (settingsProvider.selectedMenu == 'Users') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 200,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: settingsProvider.selectedFilterBranchId ?? 0,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey, size: 20),
                    items: [
                      const DropdownMenuItem(
                          value: 0, child: Text("All Branches")),
                      ...settingsProvider.branchModel.map((branch) =>
                          DropdownMenuItem(
                              value: branch.branchId,
                              child: Text(branch.branchName ?? "",
                                  overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        settingsProvider.selectedFilterBranchId = value;
                      });
                      settingsProvider.getUserDetails(
                          _searchController.text, context);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 200,
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border:
                      Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: settingsProvider.selectedFilterDepartmentId ?? 0,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey, size: 20),
                    items: [
                      const DropdownMenuItem(
                          value: 0, child: Text("All Depts")),
                      ...settingsProvider.departmentModel.map((dept) =>
                          DropdownMenuItem(
                              value: dept.departmentId,
                              child: Text(dept.departmentName,
                                  overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (value) {
                      setState(() {
                        settingsProvider.selectedFilterDepartmentId = value;
                      });
                      settingsProvider.getUserDetails(
                          _searchController.text, context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

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
          ? CustomAppBar(
              title: settingsProvider.selectedMenu,
              showSearch: true,
              searchController: _searchController,
              onSearchTap: () {
                Provider.of<SidebarProvider>(context, listen: false)
                    .startSearch();
              },
              onClearTap: () {
                Provider.of<SidebarProvider>(context, listen: false)
                    .stopSearch();
                _searchController.clear();
                _triggerSearch(settingsProvider, '');
                setState(() {});
              },
              onSearch: (query) {
                _triggerSearch(settingsProvider, query);
                setState(() {});
              },
              onChanged: (query) {
                _triggerSearch(settingsProvider, query);
                setState(() {});
              },
              showFilterIcon: settingsProvider.selectedMenu == 'Users' ||
                  settingsProvider.selectedMenu == 'Status' ||
                  settingsProvider.selectedMenu == 'Task Type',
              onFilterTap: () {
                _showFilterBottomSheet(context, settingsProvider);
              },
              showAddIcon: settingsProvider.onAddPressed != null,
              onAddTap: settingsProvider.onAddPressed,
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
                        Builder(
                          builder: (context) => IconButton(
                            onPressed: () {
                              ScaffoldState? parent;
                              context.visitAncestorElements((element) {
                                if (element is StatefulElement &&
                                    element.state is ScaffoldState) {
                                  ScaffoldState scaffold =
                                      element.state as ScaffoldState;
                                  if (scaffold.hasDrawer) {
                                    parent = scaffold;
                                    return false;
                                  }
                                }
                                return true;
                              });
                              parent?.openDrawer();
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.sort,
                                size: 20,
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                      children: tabBar(settingsProvider, isMobile: false),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      height: 38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: tabBar(settingsProvider, isMobile: true),
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: isMobile
                        ? const EdgeInsets.only(
                            top: 4, left: 16, right: 16, bottom: 16)
                        : const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMobile) _buildWebHeader(settingsProvider),
                        _buildContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon,
      {required bool isMobile}) {
    final settings = Provider.of<SettingsProvider>(context);
    final isSelected = settings.selectedMenu == title;

    if (isMobile) {
      return GestureDetector(
        onTap: () {
          settings.setSelectedMenu(title);
          Provider.of<SidebarProvider>(context, listen: false).stopSearch();
          _searchController.clear();
          _triggerSearch(settings, '');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: isSelected
              ? const EdgeInsets.symmetric(vertical: 4, horizontal: 2)
              : const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected ? Colors.white : Colors.transparent,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AppColors.secondaryBlue
                  : const Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => settings.setSelectedMenu(title),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isSelected
                ? AppColors.secondaryBlue.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected
                      ? AppColors.secondaryBlue
                      : const Color(0xFF64748B),
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
        return CheckListItemPage(searchQuery: _searchController.text);
      case 'Checklist Category':
        return CheckListCategoryPage(searchQuery: _searchController.text);
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
      case 'Priority Management':
        return const PriorityPage();
      case 'Target Enquiry Source':
        return const TargetEnquirySourcePage();
      case 'Terms & Warranty':
        return const TermsWarrantyContent();
      case 'Designation':
        return const DesignationContent();
      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> tabBar(SettingsProvider settingsProvider,
      {required bool isMobile}) {
    return [
      if (settingsProvider.menuIsViewMap[1].toString() == '1')
        _buildMenuItem(context, 'Users', Icons.people, isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[5].toString() == '1')
        _buildMenuItem(context, 'Status', Icons.trending_up,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[6].toString() == '1')
        _buildMenuItem(context, 'Enquiry Source', Icons.trending_up,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[17].toString() == '1')
        _buildMenuItem(context, 'Enquiry For', Icons.trending_up,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[23].toString() == '1')
        _buildMenuItem(context, 'Document Type', Icons.trending_up,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[41].toString() == '1')
        _buildMenuItem(context, 'Task Type', Icons.trending_up,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[20].toString() == '1')
        _buildMenuItem(context, 'Excel Import', Icons.document_scanner,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[27].toString() == '1')
        _buildMenuItem(context, 'Company Details', Icons.document_scanner,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[42].toString() == '1')
        _buildMenuItem(context, 'Department', Icons.document_scanner,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[57].toString() == '1')
        _buildMenuItem(context, 'Branch', Icons.category, isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[58].toString() == '1')
        _buildMenuItem(context, 'Stage', Icons.category, isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[59].toString() == '1')
        _buildMenuItem(context, 'Source Category', Icons.category,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[38].toString() == '1')
        _buildMenuItem(context, 'Checklist Item', Icons.category,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[39].toString() == '1')
        _buildMenuItem(context, 'Checklist Category', Icons.category,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[60].toString() == '1')
        _buildMenuItem(context, 'Custom Field', Icons.category,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[64].toString() == '1')
        _buildMenuItem(context, 'ExpenseType', Icons.category,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[86].toString() == '1')
        _buildMenuItem(context, 'Location', Icons.location_on,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[85].toString() == '1')
        _buildMenuItem(context, 'Forms', Icons.format_list_bulleted,
            isMobile: isMobile),
      _buildMenuItem(context, 'Campaign', Icons.campaign, isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[170].toString() == '1')
        _buildMenuItem(context, 'Priority Management', Icons.low_priority,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[155].toString() == '1')
        _buildMenuItem(context, 'Target Enquiry Source', Icons.track_changes,
            isMobile: isMobile),
      if (settingsProvider.menuIsViewMap[161].toString() == '1')
        _buildMenuItem(context, 'Terms & Warranty', Icons.description,
            isMobile: isMobile), //new
      if (settingsProvider.menuIsViewMap[174].toString() == '1')
        _buildMenuItem(context, 'Designation', Icons.category, isMobile: isMobile),
    ];
  }
}
