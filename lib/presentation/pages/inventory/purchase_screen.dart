import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/controller/expense_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/purchase_widget.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.getPurchaseDataMaster(context);
      final settingsProvider =
          Provider.of<SettingsProvider>(context, listen: false);
      settingsProvider.searchSupplierApi('', context);
    });
    super.initState();
  }

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          child: Padding(
            padding: const EdgeInsets.all(0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Header Section

                AppStyles.isWebScreen(context)
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Text(
                              'Purchase ',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textBlue800),
                            ),
                            Flexible(child: Container()),
                            Container(
                              width: MediaQuery.of(context).size.width / 4,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: searchController,
                                onSubmitted: (query) {
                                  // expenseProvider.selectDateFilterOption(null);
                                  // expenseProvider.removeStatus();
                                  print(query);
                                  expenseProvider.setSearchCriteria(
                                    query,
                                    expenseProvider.fromDateS,
                                    expenseProvider.toDateS,
                                    expenseProvider.status,
                                    expenseProvider.enquiryForS,
                                  );
                                  expenseProvider
                                      .getPurchaseDataMaster(context);
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search here....',
                                  prefixIcon: const Icon(Icons.search),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        String query = searchController.text;
                                        // expenseProvider.selectDateFilterOption(null);
                                        // expenseProvider.removeStatus();
                                        print(query);
                                        if (expenseProvider.search.isNotEmpty) {
                                          searchController.clear();
                                          expenseProvider.setSearchCriteria(
                                            '',
                                            expenseProvider.fromDateS,
                                            expenseProvider.toDateS,
                                            expenseProvider.status,
                                            expenseProvider.enquiryForS,
                                          );
                                          expenseProvider
                                              .getPurchaseDataMaster(context);
                                        } else {
                                          expenseProvider.setSearchCriteria(
                                            query,
                                            expenseProvider.fromDateS,
                                            expenseProvider.toDateS,
                                            expenseProvider.status,
                                            expenseProvider.enquiryForS,
                                          );
                                          expenseProvider
                                              .getPurchaseDataMaster(context);
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.textGrey4,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                          expenseProvider.search.isNotEmpty
                                              ? 'Clear'
                                              : 'Search'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                expenseProvider.toggleFilter();
                                // expenseProvider.selectDateFilterOption(null);
                                // expenseProvider.removeStatus();
                                // expenseProvider.getPurchaseDataMaster('', '', '', '', context);
                                print(expenseProvider.isFilter);
                              },
                              icon: const Icon(Icons.filter_list),
                              label: const Text('Filter '),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: expenseProvider.isFilter
                                    ? Colors.white
                                    : AppColors
                                        .primaryBlue, // Change foreground color
                                backgroundColor: expenseProvider.isFilter
                                    ? const Color(0xFF5499D9)
                                    : Colors.white, // Change background color
                                side: BorderSide(
                                    color: expenseProvider.isFilter
                                        ? const Color(0xFF5499D9)
                                        : AppColors
                                            .primaryBlue), // Change border color
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // New Lead Button
                            if (settingsProvider.menuIsSaveMap[44] == 1)
                            CustomOutlinedSvgButton(
                              onPressed: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PurchaseWidget(
                                      editId: '0',
                                      isEdit: false,
                                    );
                                  },
                                );
                              },
                              svgPath: 'assets/images/Plus.svg',
                              label: 'New Purchase',
                              breakpoint: 860,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: AppColors.primaryBlue,
                              borderSide:
                                  BorderSide(color: AppColors.primaryBlue),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      )
                    : // Mobile version - Stacked layout with responsive design
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title Row
                            Row(
                              children: [
                                Text(
                                  'Purchase',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textBlue800,
                                  ),
                                ),
                                const Spacer(),
                                // New Purchase Button - Always visible on mobile
                                if (settingsProvider.menuIsSaveMap[44] == 1)
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return PurchaseWidget(
                                            editId: '0',
                                            isEdit: false,
                                          );
                                        },
                                      );
                                    },
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('New'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primaryBlue,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Search and Filter Row
                            Row(
                              children: [
                                // Search Field - Takes most space
                                Expanded(
                                  child: Container(
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(22),
                                      border:
                                          Border.all(color: Colors.grey[300]!),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      onSubmitted: (query) {
                                        print(query);
                                        expenseProvider.setSearchCriteria(
                                          query,
                                          expenseProvider.fromDateS,
                                          expenseProvider.toDateS,
                                          expenseProvider.status,
                                          expenseProvider.enquiryForS,
                                        );
                                        expenseProvider
                                            .getPurchaseDataMaster(context);
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search invoices...',
                                        hintStyle: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: Colors.grey[500],
                                          size: 20,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        suffixIcon: expenseProvider
                                                .search.isNotEmpty
                                            ? IconButton(
                                                onPressed: () {
                                                  searchController.clear();
                                                  expenseProvider
                                                      .setSearchCriteria(
                                                    '',
                                                    expenseProvider.fromDateS,
                                                    expenseProvider.toDateS,
                                                    expenseProvider.status,
                                                    expenseProvider.enquiryForS,
                                                  );
                                                  expenseProvider
                                                      .getPurchaseDataMaster(
                                                          context);
                                                },
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: Colors.grey[600],
                                                  size: 20,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Filter Button
                                Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: expenseProvider.isFilter
                                        ? const Color(0xFF5499D9)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: expenseProvider.isFilter
                                          ? const Color(0xFF5499D9)
                                          : Colors.grey[300]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      expenseProvider.toggleFilter();
                                      print(expenseProvider.isFilter);
                                    },
                                    icon: Icon(
                                      Icons.filter_list,
                                      color: expenseProvider.isFilter
                                          ? Colors.white
                                          : AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Search Button Row (only show when there's text)
                            if (searchController.text.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 36,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            String query =
                                                searchController.text;
                                            print(query);
                                            expenseProvider.setSearchCriteria(
                                              query,
                                              expenseProvider.fromDateS,
                                              expenseProvider.toDateS,
                                              expenseProvider.status,
                                              expenseProvider.enquiryForS,
                                            );
                                            expenseProvider
                                                .getPurchaseDataMaster(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.primaryBlue,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                          ),
                                          child: Text(
                                            'Search',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // Active filters indicator
                            if (expenseProvider.search.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            size: 14,
                                            color: AppColors.primaryBlue,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Search: ${expenseProvider.search}',
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          GestureDetector(
                                            onTap: () {
                                              searchController.clear();
                                              expenseProvider.setSearchCriteria(
                                                '',
                                                expenseProvider.fromDateS,
                                                expenseProvider.toDateS,
                                                expenseProvider.status,
                                                expenseProvider.enquiryForS,
                                              );
                                              expenseProvider
                                                  .getPurchaseDataMaster(
                                                      context);
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 14,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                if (expenseProvider.isFilter)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      spacing: 8.0, // Horizontal spacing between items
                      runSpacing:
                          8.0, // Vertical spacing when items wrap to next line
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Supplier dropdown
                        Container(
                          constraints: const BoxConstraints(
                              minWidth: 130, maxWidth: 180),
                          height: 35, // Fixed height for consistency
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: expenseProvider.selectedSupplier !=
                                            null &&
                                        expenseProvider.selectedSupplier != 0
                                    ? AppColors.primaryBlue
                                    : Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Supplier: ',
                                  style: TextStyle(fontSize: 12)),
                              Flexible(
                                child: DropdownButton<int>(
                                  value: expenseProvider.selectedSupplier,
                                  hint: const Text('All',
                                      style: TextStyle(fontSize: 12)),
                                  items: [
                                        const DropdownMenuItem<int>(
                                          value: 0,
                                          child: Text(
                                            'All',
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ] +
                                      settingsProvider.searchSupplier
                                          .map(
                                              (status) => DropdownMenuItem<int>(
                                                    value: status.supplierId,
                                                    child: Text(
                                                      status.supplierName ?? '',
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                          .toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      expenseProvider.setSupplier(newValue);
                                    }
                                    String status = expenseProvider
                                        .selectedSupplier
                                        .toString();
                                    String fromDate =
                                        expenseProvider.formattedFromDate;
                                    String toDate =
                                        expenseProvider.formattedToDate;
                                    print(
                                        'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                                    expenseProvider.setSearchCriteria(
                                      expenseProvider.search,
                                      fromDate,
                                      toDate,
                                      status,
                                      '',
                                    );
                                    expenseProvider
                                        .getPurchaseDataMaster(context);
                                  },
                                  underline: Container(),
                                  isDense: true,
                                  iconSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Date filter
                        GestureDetector(
                          onTap: () {
                            onClickTopButton(context);
                          },
                          child: Container(
                            constraints: const BoxConstraints(
                                minWidth: 130,
                                maxWidth:
                                    300), // Increased max width for date range
                            height:
                                35, // Same fixed height as supplier container
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: expenseProvider.fromDate != null ||
                                          expenseProvider.toDate != null
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Center(
                                    // Center the text vertically
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          if (expenseProvider.fromDate ==
                                                  null &&
                                              expenseProvider.toDate == null)
                                            const Text('Date: All',
                                                style: TextStyle(fontSize: 12)),
                                          if (expenseProvider.fromDate !=
                                                  null &&
                                              expenseProvider.toDate != null)
                                            Text(
                                              'Date: ${expenseProvider.formattedFromDate} - ${expenseProvider.formattedToDate}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                              maxLines: 1, // Ensure single line
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.black45,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Reset button (only show if filters are active)
                        if (expenseProvider.fromDate != null ||
                            expenseProvider.toDate != null ||
                            (expenseProvider.selectedSupplier != null &&
                                expenseProvider.selectedSupplier != 0) ||
                            expenseProvider.search.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              expenseProvider.selectDateFilterOption(null);
                              expenseProvider.removeSupplier();
                              searchController.clear();
                              expenseProvider.setSearchCriteria(
                                  '', '', '', '', '');
                              expenseProvider.getPurchaseDataMaster(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 32),
                            ),
                            child: const Text('Reset',
                                style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                // Table Section
                const SizedBox(height: 10),
                AppStyles.isWebScreen(context)
                    ? Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Table Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Invoice No ',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Supplier Name',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Description',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Invoice Date',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'Total Amount',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '  Actions',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Table Body
                            ListView.separated(
                              shrinkWrap: true,
                              itemCount: expenseProvider.purchaseList.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey[200],
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final purchase =
                                    expenseProvider.purchaseList[index];
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          purchase.invoiceNo.toString(),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          purchase.supplierName.toString(),
                                          style:
                                              GoogleFonts.inter(fontSize: 14),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          purchase.descriptions.toString(),
                                          style:
                                              GoogleFonts.inter(fontSize: 14),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          formatPurchaseDate(
                                              purchase.entryDate),
                                          style:
                                              GoogleFonts.inter(fontSize: 14),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          NumberFormat.currency(
                                            symbol: '₹',
                                            decimalDigits: 2,
                                          ).format(double.parse(
                                              purchase.netTotal.toString())),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          children: [
                                            if (settingsProvider
                                                    .menuIsEditMap[44] ==
                                                1)
                                            TextButton(
                                              onPressed: () async {
                                                await expenseProvider
                                                    .searchPurchaseDetails(
                                                        purchase
                                                            .purchaseMasterId
                                                            .toString(),
                                                        context);
                                                showDialog(
                                                  barrierDismissible: false,
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return PurchaseWidget(
                                                      editId: purchase
                                                          .purchaseMasterId
                                                          .toString(),
                                                      isEdit: true,
                                                      data: purchase,
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'Edit',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryBlue,
                                                ),
                                              ),
                                            ),
                                            if (settingsProvider
                                                    .menuIsDeleteMap[44] ==
                                                1)
                                            TextButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          'Confirm Delete'),
                                                      content: const Text(
                                                        'Are you sure you want to delete this item?',
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            await expenseProvider
                                                                .deletePurchaseItem(
                                                                    context,
                                                                    purchase
                                                                        .purchaseMasterId);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: const Text(
                                                            ' Delete ',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.red),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'Delete',
                                                style:
                                                    GoogleFonts.plusJakartaSans(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textRed,
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
                      )
                    : // Mobile version - Card-based layout
                    Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Purchase Invoices ',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${expenseProvider.purchaseList.length} items',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Card List
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: expenseProvider.purchaseList.length,
                              separatorBuilder: (context, index) => Divider(
                                color: Colors.grey[200],
                                height: 1,
                                indent: 16,
                                endIndent: 16,
                              ),
                              itemBuilder: (context, index) {
                                final purchase =
                                    expenseProvider.purchaseList[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Invoice Number and Amount Row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Invoice #${purchase.invoiceNo}',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primaryBlue,
                                            ),
                                          ),
                                          Text(
                                            NumberFormat.currency(
                                              symbol: '₹',
                                              decimalDigits: 2,
                                            ).format(double.parse(
                                                purchase.netTotal.toString())),
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Supplier Name
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.business,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              purchase.supplierName.toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Description
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.description,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              purchase.descriptions.toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),

                                      // Date
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            formatPurchaseDate(
                                                purchase.entryDate),
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),

                                      // Action Buttons
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (settingsProvider.menuIsEditMap[44] == 1)
                                          TextButton.icon(
                                            onPressed: () async {
                                              await expenseProvider
                                                  .searchPurchaseDetails(
                                                purchase.purchaseMasterId
                                                    .toString(),
                                                context,
                                              );
                                              showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return PurchaseWidget(
                                                    editId: purchase
                                                        .purchaseMasterId
                                                        .toString(),
                                                    isEdit: true,
                                                    data: purchase,
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: AppColors.primaryBlue,
                                            ),
                                            label: Text(
                                              'Edit',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryBlue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (settingsProvider.menuIsDeleteMap[44] == 1)
                                          TextButton.icon(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text(
                                                        'Confirm Delete'),
                                                    content: const Text(
                                                      'Are you sure you want to delete this invoice?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      TextButton(
                                                        onPressed: () async {
                                                          await expenseProvider
                                                              .deletePurchaseItem(
                                                            context,
                                                            purchase
                                                                .purchaseMasterId,
                                                          );
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          'Delete ',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(
                                              Icons.delete,
                                              size: 16,
                                              color: AppColors.textRed,
                                            ),
                                            label: Text(
                                              '  Delete ',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textRed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<ExpenseProvider>(
        builder: (contextx, leadProvider, child) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            contentPadding: const EdgeInsets.all(10),
            content: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Center(
                      child: Text(
                        'Choose Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length,
                          (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            leadProvider.setDateFilter(title);
                            leadProvider.selectDateFilterOption(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor:
                              leadProvider.selectedDateFilterIndex == index
                                  ? AppColors.primaryBlue
                                  : Colors.white,
                          labelStyle: TextStyle(
                            color: leadProvider.selectedDateFilterIndex == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => leadProvider.selectDate(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.fromDate != null
                                  ? '${leadProvider.fromDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () =>
                                leadProvider.selectDate(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.toDate != null
                                  ? '${leadProvider.toDate!.toLocal()}'
                                      .split(' ')[0]
                                  : 'To',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);

                          leadProvider.formatDate();

                          print(leadProvider.formattedFromDate);
                          print(leadProvider.formattedToDate);
                          String status =
                              leadProvider.selectedSupplier.toString();
                          String fromDate = leadProvider.formattedFromDate;
                          String toDate = leadProvider.formattedToDate;

                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            '',
                          );
                          leadProvider.getPurchaseDataMaster(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Apply',
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          leadProvider.selectDateFilterOption(null);
                          String status =
                              leadProvider.selectedSupplier.toString();
                          String fromDate = '';
                          String toDate = '';

                          print(
                              'Selected Status: $status, Selected From Date: $fromDate,Selected To Date: $toDate');
                          leadProvider.setSearchCriteria(
                            leadProvider.search,
                            fromDate,
                            toDate,
                            status,
                            '',
                          );
                          leadProvider.getPurchaseDataMaster(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text(
                          'Clear',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month',
  ];

  String formatPurchaseDate(String purchaseDate) {
    DateTime parsedDate = DateTime.parse(purchaseDate);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }
}
