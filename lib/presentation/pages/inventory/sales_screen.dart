import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/sales_widget.dart';

import '../../../controller/expense_provider.dart';
import '../../../controller/settings_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
      Provider.of<ExpenseProvider>(context, listen: false);
      expenseProvider.getSalesMaster(context);
      await expenseProvider.searchItemListPurchase(context);
      expenseProvider.resetPurchaseItems();
      expenseProvider.clearPurchaseItemFields();
      expenseProvider.resetPurchaseValues();
    });
  }

  @override
  Widget build(BuildContext context) {
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
                AppStyles.isWebScreen(context)
                    ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Sales',
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
                            print(query);
                            expenseProvider.setSearchCriteriaSales(
                              query,
                              expenseProvider.fromDateS,
                              expenseProvider.toDateS,
                              expenseProvider.status,
                              expenseProvider.enquiryForS,
                            );
                            expenseProvider.getSalesMaster(context);
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
                                  print(query);
                                  if (expenseProvider.searchSales.isNotEmpty) {
                                    searchController.clear();
                                    expenseProvider.setSearchCriteriaSales(
                                      '',
                                      expenseProvider.fromDateS,
                                      expenseProvider.toDateS,
                                      expenseProvider.status,
                                      expenseProvider.enquiryForS,
                                    );
                                    expenseProvider.getSalesMaster(context);
                                  } else {
                                    expenseProvider.setSearchCriteriaSales(
                                      query,
                                      expenseProvider.fromDateS,
                                      expenseProvider.toDateS,
                                      expenseProvider.status,
                                      expenseProvider.enquiryForS,
                                    );
                                    expenseProvider.getSalesMaster(context);
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
                                    expenseProvider.searchSales.isNotEmpty
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
                          expenseProvider.toggleFilterSales();
                          print(expenseProvider.isFilterSales);
                        },
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: expenseProvider.isFilterSales
                              ? Colors.white
                              : AppColors.primaryBlue,
                          backgroundColor: expenseProvider.isFilterSales
                              ? const Color(0xFF5499D9)
                              : Colors.white,
                          side: BorderSide(
                              color: expenseProvider.isFilterSales
                                  ? const Color(0xFF5499D9)
                                  : AppColors.primaryBlue),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (settingsProvider.menuIsSaveMap[87] == 1)
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return const SalesWidget(
                                isEdit: false,
                                editId: '0',
                              );
                            },
                          );
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'New Sales',
                        breakpoint: 860,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryBlue,
                        borderSide: BorderSide(color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                )
                    : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sales',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBlue800,
                            ),
                          ),
                          const Spacer(),
                          if (settingsProvider.menuIsSaveMap[87] == 1)
                          SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const SalesWidget(
                                      isEdit: false,
                                      editId: '0',
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
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.grey[300]!),
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
                                  expenseProvider.setSearchCriteriaSales(
                                    query,
                                    expenseProvider.fromDateS,
                                    expenseProvider.toDateS,
                                    expenseProvider.status,
                                    expenseProvider.enquiryForS,
                                  );
                                  expenseProvider.getSalesMaster(context);
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  suffixIcon: expenseProvider.searchSales.isNotEmpty
                                      ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      expenseProvider.setSearchCriteriaSales(
                                        '',
                                        expenseProvider.fromDateS,
                                        expenseProvider.toDateS,
                                        expenseProvider.status,
                                        expenseProvider.enquiryForS,
                                      );
                                      expenseProvider.getSalesMaster(context);
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
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: expenseProvider.isFilterSales
                                  ? const Color(0xFF5499D9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: expenseProvider.isFilterSales
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
                                expenseProvider.toggleFilterSales();
                                print(expenseProvider.isFilterSales);
                              },
                              icon: Icon(
                                Icons.filter_list,
                                color: expenseProvider.isFilterSales
                                    ? Colors.white
                                    : AppColors.primaryBlue,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                      String query = searchController.text;
                                      print(query);
                                      expenseProvider.setSearchCriteriaSales(
                                        query,
                                        expenseProvider.fromDateS,
                                        expenseProvider.toDateS,
                                        expenseProvider.status,
                                        expenseProvider.enquiryForS,
                                      );
                                      expenseProvider.getSalesMaster(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
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
                      if (expenseProvider.searchSales.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withOpacity(0.1),
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
                                      'Search: ${expenseProvider.searchSales}',
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
                                        expenseProvider.setSearchCriteriaSales(
                                          '',
                                          expenseProvider.fromDateS,
                                          expenseProvider.toDateS,
                                          expenseProvider.status,
                                          expenseProvider.enquiryForS,
                                        );
                                        expenseProvider.getSalesMaster(context);
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

                if (expenseProvider.isFilterSales)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            onClickTopButton(context);
                          },
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 130, maxWidth: 300),
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: expenseProvider.fromDateSales != null ||
                                      expenseProvider.toDateSales != null
                                      ? AppColors.primaryBlue
                                      : Colors.grey[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          if (expenseProvider.fromDateSales == null &&
                                              expenseProvider.toDateSales == null)
                                            const Text('Date: All',
                                                style: TextStyle(fontSize: 12)),
                                          if (expenseProvider.fromDateSales != null &&
                                              expenseProvider.toDateSales != null)
                                            Text(
                                              'Date: ${expenseProvider.formattedFromDateSales} - ${expenseProvider.formattedToDateSales}',
                                              style: const TextStyle(fontSize: 12),
                                              maxLines: 1,
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
                        if (expenseProvider.fromDateSales != null ||
                            expenseProvider.toDateSales != null ||
                            expenseProvider.searchSales.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              expenseProvider.selectDateFilterOptionSales(null);
                              searchController.clear();
                              expenseProvider.setSearchCriteriaSales('', '', '', '', '');
                              expenseProvider.getSalesMaster(context);
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
                            child: const Text('Reset', style: TextStyle(fontSize: 12)),
                          ),
                      ],
                    ),
                  ),

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
                                'Invoice No',
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
                                'Customer Name',
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
                      ListView.separated(
                        shrinkWrap: true,
                        itemCount: expenseProvider.salesList.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[200],
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final sale = expenseProvider.salesList[index];
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
                                    sale.invoiceNo.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    sale.customerName.toString(),
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    sale.description.toString(),
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    formatSalesDate(sale.entryDate),
                                    style: GoogleFonts.inter(fontSize: 14),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    NumberFormat.currency(
                                      symbol: '₹',
                                      decimalDigits: 2,
                                    ).format(double.parse(sale.netTotal.toString())),
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
                                      if (settingsProvider.menuIsEditMap[87] == 1)
                                      TextButton(
                                        onPressed: () async {
                                          await expenseProvider.searchSalesDetails(
                                              sale.salesMasterId.toString(), context);
                                          showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return SalesWidget(
                                                editId: sale.salesMasterId.toString(),
                                                isEdit: true,
                                                data: sale,
                                              );
                                            },
                                          );
                                        },
                                        child: Text(
                                          'Edit',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                      if (settingsProvider.menuIsDeleteMap[87] == 1)
                                      TextButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Confirm Delete'),
                                                content: const Text(
                                                  'Are you sure you want to delete this item?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () async {
                                                      await expenseProvider.deleteSalesItem(
                                                          context, sale.salesMasterId);
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
                                        },
                                        child: Text(
                                          'Delete',
                                          style: GoogleFonts.plusJakartaSans(
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
                    : Container(
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Sales Invoices',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.grey[800],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${expenseProvider.salesList.length} items',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: expenseProvider.salesList.length,
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.grey[200],
                          height: 1,
                          indent: 16,
                          endIndent: 16,
                        ),
                        itemBuilder: (context, index) {
                          final sale = expenseProvider.salesList[index];
                          return Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Invoice #${sale.invoiceNo}',
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
                                      ).format(double.parse(sale.netTotal.toString())),
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sale.customerName.toString(),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.description,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        sale.description.toString(),
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
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatSalesDate(sale.entryDate),
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (settingsProvider.menuIsEditMap[87] == 1)
                                    TextButton.icon(
                                      onPressed: () async {
                                        await expenseProvider.searchSalesDetails(
                                            sale.salesMasterId.toString(), context);
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return SalesWidget(
                                              editId: sale.salesMasterId.toString(),
                                              isEdit: true,
                                              data: sale,
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
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (settingsProvider.menuIsDeleteMap[87] == 1)
                                    TextButton.icon(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm Delete'),
                                              content: const Text(
                                                'Are you sure you want to delete this invoice?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    await expenseProvider.deleteSalesItem(
                                                        context, sale.salesMasterId);
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
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: AppColors.textRed,
                                      ),
                                      label: Text(
                                        'Delete',
                                        style: GoogleFonts.plusJakartaSans(
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List<Widget>.generate(dateButtonTitles.length, (index) {
                        String title = dateButtonTitles[index];
                        return ActionChip(
                          onPressed: () {
                            leadProvider.setDateFilterSales(title);
                            leadProvider.selectDateFilterOptionSales(index);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          label: Text(title),
                          backgroundColor: leadProvider.selectedDateFilterIndexSales == index
                              ? AppColors.primaryBlue
                              : Colors.white,
                          labelStyle: TextStyle(
                            color: leadProvider.selectedDateFilterIndexSales == index
                                ? Colors.white
                                : Colors.black,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Pick a date',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => leadProvider.selectDateSales(context, true),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.fromDateSales != null
                                  ? '${leadProvider.fromDateSales!.toLocal()}'.split(' ')[0]
                                  : 'From',
                              suffixIcon: const Icon(Icons.calendar_month),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            onTap: () => leadProvider.selectDateSales(context, false),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              hintText: leadProvider.toDateSales != null
                                  ? '${leadProvider.toDateSales!.toLocal()}'.split(' ')[0]
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
                          leadProvider.formatDateSales();
                          String fromDate = leadProvider.formattedFromDateSales;
                          String toDate = leadProvider.formattedToDateSales;
                          leadProvider.setSearchCriteriaSales(
                            leadProvider.searchSales,
                            fromDate,
                            toDate,
                            '',
                            '',
                          );
                          leadProvider.getSalesMaster(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Apply'),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          leadProvider.selectDateFilterOptionSales(null);
                          leadProvider.setSearchCriteriaSales(
                            leadProvider.searchSales,
                            '',
                            '',
                            '',
                            '',
                          );
                          leadProvider.getSalesMaster(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.textRed.withOpacity(0.1),
                          foregroundColor: AppColors.textRed,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Clear'),
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

  String formatSalesDate(String salesDate) {
    DateTime parsedDate = DateTime.parse(salesDate);
    return DateFormat('dd MMM yyyy').format(parsedDate);
  }
}