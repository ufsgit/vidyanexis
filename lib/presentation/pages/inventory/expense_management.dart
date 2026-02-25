import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_details_provider.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/models/expense_management_model.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/http/http_urls.dart';
import 'package:vidyanexis/main.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_expense_management.dart';
import 'package:vidyanexis/presentation/widgets/inventory/purchase_widget.dart';

class ExpenseManagement extends StatefulWidget {
  const ExpenseManagement({super.key});

  @override
  State<ExpenseManagement> createState() => _ExpenseManagementState();
}

class _ExpenseManagementState extends State<ExpenseManagement> {
  late ExpenseProvider expenseProvider;
  late SettingsProvider settingsProvider;
  final customerDetailsProvider = Provider.of<CustomerDetailsProvider>(
      navigatorKey.currentState!.context,
      listen: false);

  @override
  void initState() {
    super.initState();
    expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);

    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      expenseProvider.searchExpenseController.clear();
      expenseProvider.searchExpense('', context);
      settingsProvider.getUserDetails(
        '',
        context,
      );
      // Load filter dropdown data
      expenseProvider.getClientList(context);
      settingsProvider.searchProjectTypes('', context);
      expenseProvider.getExpenseType(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Helper method to determine screen size categories
  bool _isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  bool _isMediumScreen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1200;
  }

  bool _isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  // Get responsive padding
  EdgeInsets _getResponsivePadding(BuildContext context) {
    if (_isSmallScreen(context)) {
      return const EdgeInsets.all(16);
    } else if (_isMediumScreen(context)) {
      return const EdgeInsets.all(20);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  // Get responsive font size
  double _getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (_isSmallScreen(context)) {
      return baseFontSize * 0.9;
    } else if (_isMediumScreen(context)) {
      return baseFontSize;
    } else {
      return baseFontSize * 1.1;
    }
  }

  // Get search field width
  double _getSearchFieldWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (_isSmallScreen(context)) {
      return screenWidth * 0.6; // 60% on mobile
    } else if (_isMediumScreen(context)) {
      return screenWidth * 0.4; // 40% on tablet
    } else {
      return screenWidth / 3.5; // Original desktop size
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery directly instead of LayoutBuilder to avoid layout cycles
    // final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = _isSmallScreen(context);
    final responsivePadding = _getResponsivePadding(context);

    return Scaffold(
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: responsivePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppStyles.isWebScreen(context)
                    ? SizedBox()
                    : Container(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            context.pop();
                          },
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppColors.textGrey4,
                          ),
                          iconSize: 24,
                        ),
                      ),
                // Header section - responsive layout
                _buildResponsiveHeader(context, isSmallScreen),
                SizedBox(height: isSmallScreen ? 16 : 24),
                if (provider.isFilter)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                    child: _buildFilterSection(context),
                  ),

                // Table section
                _buildResponsiveTable(context, provider, isSmallScreen),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResponsiveHeader(BuildContext context, bool isSmallScreen) {
    if (isSmallScreen) {
      // Mobile layout - stacked vertically
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expense Management',
            style: GoogleFonts.plusJakartaSans(
              fontSize: _getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
              color: AppColors.textBlue800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSearchField(context)),
              const SizedBox(width: 12),
              _buildFilterButton(),
              const SizedBox(width: 8),
              if (settingsProvider.menuIsSaveMap[48] == 1)
                _buildAddButton(context, isCompact: true),
            ],
          ),
        ],
      );
    } else {
      // Desktop/Tablet layout - horizontal
      return Row(
        children: [
          const Text(
            'Expense Management',
            style: TextStyle(
              fontSize: 24,
              color: Color(0xFF152D70),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          _buildSearchField(context),
          const SizedBox(width: 16),
          _buildFilterButton(),
          const SizedBox(width: 8),
          if (settingsProvider.menuIsSaveMap[48] == 1) _buildAddButton(context),
        ],
      );
    }
  }

  Widget _buildFilterButton() {
    return OutlinedButton.icon(
      onPressed: () => expenseProvider.toggleFilter(),
      icon: const Icon(Icons.filter_list),
      label: Text(AppStyles.isWebScreen(context) ? 'Filter' : ''),
      style: OutlinedButton.styleFrom(
        foregroundColor:
            expenseProvider.isFilter ? Colors.white : AppColors.primaryBlue,
        backgroundColor:
            expenseProvider.isFilter ? const Color(0xFF5499D9) : Colors.white,
        side: BorderSide(
          color: expenseProvider.isFilter
              ? const Color(0xFF5499D9)
              : AppColors.primaryBlue,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      width: _getSearchFieldWidth(context),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: expenseProvider.searchExpenseController,
              onSubmitted: (query) {
                if (kDebugMode) {
                  print(query);
                }
                expenseProvider.searchExpense(query, context);
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
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              onPressed: () {
                final query = expenseProvider.searchExpenseController.text;
                if (kDebugMode) {
                  print(query);
                }
                expenseProvider.searchExpense(query, context);
              },
              icon: const Icon(Icons.search),
              iconSize: 20,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, {bool isCompact = false}) {
    return CustomOutlinedSvgButton(
      onPressed: () async {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AddExpenseManagement(
              expenseModel: ExpenseModel(),
              isEdit: false,
            );
          },
        );
      }, //ggg
      svgPath: 'assets/images/Plus.svg',
      label: isCompact ? 'Add' : 'Add Expense Management',
      breakpoint: 860,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryBlue,
      borderSide: BorderSide(color: AppColors.primaryBlue),
    );
  }

  Widget _buildResponsiveTable(
      BuildContext context, ExpenseProvider provider, bool isSmallScreen) {
    if (isSmallScreen) {
      // Mobile: Card-based layout
      return _buildMobileCardList(context, provider);
    } else {
      // Desktop/Tablet: Traditional table
      return _buildDesktopTable(context, provider);
    }
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        runSpacing: 10,
        spacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _buildAssignedToFilter(expenseProvider),
          _buildClientFilter(expenseProvider),
          _buildProjectTypeFilter(expenseProvider),
          _buildExpenseTypeFilter(expenseProvider),
          TextButton(
            onPressed: () {
              expenseProvider.clearUserFilter();
              expenseProvider.clearClientFilter();
              expenseProvider.clearProjectTypeFilter();
              expenseProvider.clearExpenseTypeFilter();
              // Call API after reset
              expenseProvider.searchExpense(
                expenseProvider.searchExpenseController.text,
                context,
              );
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.red),
            ),
          )
        ],
      ),
    );
  }

  // Filters (no date): User, Client, Project Type, Expense Type
  Widget _buildAssignedToFilter(ExpenseProvider expenseProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Get current user details from SharedPreferences
        return FutureBuilder<Map<String, dynamic>>(
          future: _getCurrentUserDetailsWithAdmin(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text('Loading...'),
              );
            }

            final userData = snapshot.data!;
            bool isAdmin = userData['isAdmin'] as bool;
            int? currentUserId = userData['userId'] as int?;
            String? currentUserName = userData['userName'] as String?;

            // Build dropdown items based on user role
            List<DropdownMenuItem<int>> dropdownItems;
            int dropdownValue;

            if (isAdmin) {
              // Admin: Show all users with "All" option
              dropdownItems = [
                const DropdownMenuItem<int>(
                  value: 0,
                  child: Text('All', style: TextStyle(fontSize: 14)),
                ),
                ...settingsProvider.searchUserDetails
                    .map((user) => DropdownMenuItem<int>(
                          value: user.userDetailsId,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              user.userDetailsName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                    .toList(),
              ];
              // For admin, use the selected value from provider
              dropdownValue = expenseProvider.selectedUser ?? 0;
            } else {
              // Non-admin staff: Show only their own name
              dropdownItems = [
                DropdownMenuItem<int>(
                  value: currentUserId ?? 0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      currentUserName ?? 'Current User',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ];
              // For non-admin, always use their own ID
              dropdownValue = currentUserId ?? 0;
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: (expenseProvider.selectedUser != null &&
                          expenseProvider.selectedUser != 0)
                      ? AppColors.primaryBlue
                      : Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Assigned to: '),
                  DropdownButton<int>(
                    value: dropdownValue,
                    items: dropdownItems,
                    onChanged: isAdmin
                        ? (int? newValue) {
                            // Admin can change the filter
                            if (newValue == null || newValue == 0) {
                              expenseProvider.clearUserFilter();
                            } else {
                              expenseProvider.setUserFilter(newValue);
                            }

                            // Call API after filter change
                            expenseProvider.searchExpense(
                              expenseProvider.searchExpenseController.text,
                              context,
                            );
                          }
                        : null, // Disable dropdown for non-admin users
                    underline: Container(),
                    isDense: true,
                    iconSize: 18,
                    disabledHint: Text(
                      currentUserName ?? 'Current User',
                      style:
                          const TextStyle(fontSize: 14, color: Colors.black87),
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

  Widget _buildClientFilter(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (expenseProvider.selectedClient != null &&
                  expenseProvider.selectedClient != 0)
              ? AppColors.primaryBlue
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Client: '),
          DropdownButton<int>(
            value: expenseProvider.selectedClient ?? 0,
            hint: const Text('All'),
            items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('All', style: TextStyle(fontSize: 14)),
                  ),
                ] +
                expenseProvider.clientList
                    .map((client) => DropdownMenuItem<int>(
                          value: int.tryParse(client.customerId) ?? 0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              client.customerName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                    .toList(),
            onChanged: (int? newValue) {
              if (newValue == null || newValue == 0) {
                expenseProvider.clearClientFilter();
              } else {
                expenseProvider.setClientFilter(newValue);
              }

              // Call API after filter change
              expenseProvider.searchExpense(
                expenseProvider.searchExpenseController.text,
                context,
              );
            },
            underline: Container(),
            isDense: true,
            iconSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTypeFilter(ExpenseProvider expenseProvider) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final list = settingsProvider.projectTypeList;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (expenseProvider.selectedProjectTypeId != null &&
                      expenseProvider.selectedProjectTypeId != 0)
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Project Type: '),
              DropdownButton<int>(
                value: expenseProvider.selectedProjectTypeId ?? 0,
                hint: const Text('All'),
                items: [
                      const DropdownMenuItem<int>(
                        value: 0,
                        child: Text('All', style: TextStyle(fontSize: 14)),
                      ),
                    ] +
                    list
                        .map((item) => DropdownMenuItem<int>(
                              value: item.projectTypeId ?? 0,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 150),
                                child: Text(
                                  item.projectTypeName ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ))
                        .toList(),
                onChanged: (int? newValue) {
                  if (newValue == null || newValue == 0) {
                    expenseProvider.clearProjectTypeFilter();
                  } else {
                    expenseProvider.setProjectTypeFilter(newValue);
                  }

                  // Call API after filter change
                  expenseProvider.searchExpense(
                    expenseProvider.searchExpenseController.text,
                    context,
                  );
                },
                underline: Container(),
                isDense: true,
                iconSize: 18,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpenseTypeFilter(ExpenseProvider expenseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (expenseProvider.selectedExpenseTypeId != null &&
                  expenseProvider.selectedExpenseTypeId != 0)
              ? AppColors.primaryBlue
              : Colors.grey[300]!,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Expense Type: '),
          DropdownButton<int>(
            value: expenseProvider.selectedExpenseTypeId ?? 0,
            hint: const Text('All'),
            items: [
                  const DropdownMenuItem<int>(
                    value: 0,
                    child: Text('All', style: TextStyle(fontSize: 14)),
                  ),
                ] +
                expenseProvider.expenseTypeList
                    .map((item) => DropdownMenuItem<int>(
                          value: item.expenseTypeId ?? 0,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Text(
                              item.expenseTypeName ?? '',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ))
                    .toList(),
            onChanged: (int? newValue) {
              if (newValue == null || newValue == 0) {
                expenseProvider.clearExpenseTypeFilter();
              } else {
                expenseProvider.setSelectedExpenseTypeId(newValue);
              }

              // Call API after filter change
              expenseProvider.searchExpense(
                expenseProvider.searchExpenseController.text,
                context,
              );
            },
            underline: Container(),
            isDense: true,
            iconSize: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCardList(BuildContext context, ExpenseProvider provider) {
    if (provider.expenseModelList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('No expenses found'),
        ),
      );
    }

    return Column(
      children: provider.expenseModelList.map((expenseModel) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Expense Head - Primary info
                // Text(
                //   expenseModel.expenseHead.toString(),
                //   style: GoogleFonts.inter(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w600,
                //     color: AppColors.primaryBlue,
                //   ),
                // ),
                Text(
                  expenseModel.expenseHead ?? '', // Safe fallback
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),

                const SizedBox(height: 8),

                // Key information in grid
                _buildInfoGrid([
                  _InfoItem(
                      'Customer Name',
                      expenseModel.userName?.trim().isNotEmpty == true
                          ? expenseModel.userName!
                          : ""),
                  _InfoItem(
                      'Expense Type',
                      expenseModel.expenseTypeName?.trim().isNotEmpty == true
                          ? expenseModel.expenseTypeName!
                          : ""),
                  _InfoItem(
                      'Date',
                      expenseModel.entryDate != null
                          ? formatPurchaseDate(expenseModel.entryDate!)
                          : ""),
                  _InfoItem('Tax', '${expenseModel.gstPercentage ?? 0}%'),

                  // _InfoItem('User', expenseModel.userName ?? "NA"),
                  // _InfoItem('Type', expenseModel.expenseTypeName.toString()),
                  // _InfoItem(
                  //     'Date', formatPurchaseDate(expenseModel.entryDate!)),
                  // _InfoItem('Tax', '${expenseModel.gstPercentage ?? 0}%'),
                ]),

                const SizedBox(height: 12),

                // Amount prominently displayed
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Amount: ${expenseModel.amount?.toString() ?? '0'}',

                    // 'Amount: ${expenseModel.amount.toString()}',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (settingsProvider.menuIsEditMap[48] == 1)
                      _buildMobileActionButton(
                        'Edit',
                        AppColors.primaryBlue,
                        () => _showEditDialog(context, expenseModel),
                      ),
                    const SizedBox(width: 8),
                    if (settingsProvider.menuIsDeleteMap[48] == 1)
                      _buildMobileActionButton(
                        'Delete',
                        AppColors.textRed,
                        () => _showDeleteDialog(context, expenseModel),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoGrid(List<_InfoItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMobileActionButton(
      String text, Color color, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildDesktopTable(BuildContext context, ExpenseProvider provider) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width - 48,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Table Header
            _buildTableHeader(context),
            // Table Body
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.expenseModelList.length,
              separatorBuilder: (context, index) => Divider(
                color: Colors.grey[200],
                height: 1,
              ),
              itemBuilder: (context, index) {
                ExpenseModel expenseModel = provider.expenseModelList[index];
                return _buildTableRow(context, expenseModel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isSmallScreen(context) ? 16 : 24,
        vertical: 16,
      ),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Expense head',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Customer Name',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Expense Type',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Expense Date',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: _getResponsiveFontSize(context, 14),
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Tax Perc',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Total Amount',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          SizedBox(
            width: _isLargeScreen(context) ? 150 : 120,
            child: Center(
              child: Text(
                'Actions',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'View File',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: _getResponsiveFontSize(context, 14),
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(BuildContext context, ExpenseModel expenseModel) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _isSmallScreen(context) ? 16 : 24,
        vertical: 16,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              // expenseModel.expenseHead.toString(),
              expenseModel.expenseHead ?? '',
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 14),
                color: AppColors.primaryBlue,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              expenseModel.userName ?? "",
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              // expenseModel.expenseTypeName.toString(),
              expenseModel.expenseTypeName ?? '',
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              // formatPurchaseDate(expenseModel.entryDate!),
              expenseModel.entryDate != null
                  ? formatPurchaseDate(expenseModel.entryDate!)
                  : 'NA',
              style: GoogleFonts.inter(
                fontSize: _getResponsiveFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "${expenseModel.gstPercentage ?? 0} %",
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(context, 14),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                expenseModel.amount?.toString() ?? '0',
                style: GoogleFonts.inter(
                  fontSize: _getResponsiveFontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(
            width: _isLargeScreen(context) ? 150 : 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (settingsProvider.menuIsEditMap[48] == 1)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () => _showEditDialog(context, expenseModel),
                      child: Text(
                        'Edit',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: _getResponsiveFontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                if (settingsProvider.menuIsDeleteMap[48] == 1)
                  InkWell(
                    onTap: () => _showDeleteDialog(context, expenseModel),
                    child: Text(
                      'Delete',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: _getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppColors.textRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: (expenseModel.filePath ?? '') != ''
                ? Center(
                    child: TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(HttpUrls.imgBaseUrl +
                            (expenseModel.filePath ?? ''));
                        try {
                          await launchUrl(url,
                              mode: LaunchMode.externalApplication);
                        } catch (e) {
                          print('Could not launch $url: $e');
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'View File',
                        style: GoogleFonts.inter(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: _getResponsiveFontSize(context, 13),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, ExpenseModel expenseModel) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AddExpenseManagement(
          expenseModel: expenseModel.copyWith(),
          isEdit: true,
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ExpenseModel expenseModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this expense?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await expenseProvider.deleteExpense(
                    context, expenseModel.expenseManagementId!);
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
  }
}

// Helper method to get current user details from SharedPreferences
Future<Map<String, dynamic>> _getCurrentUserDetailsWithAdmin() async {
  final preferences = await SharedPreferences.getInstance();

  // Get user type from SharedPreferences
  // Usually admin user type is 1, but check your backend logic
  String userType = preferences.getString('userType') ?? '0';

  return {
    'userId': int.tryParse(preferences.getString('userId') ?? '0'),
    'userName': preferences.getString('userName') ?? 'Current User',
    'isAdmin':
        userType == '1', // Adjust this based on your admin user type value
  };
}

// Helper class for mobile info items
class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
