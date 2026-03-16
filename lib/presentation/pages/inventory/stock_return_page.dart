import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/stockreturn_provider.dart';

import '../../../constants/app_colors.dart';
import '../../../controller/expense_provider.dart';
import '../../../controller/settings_provider.dart';
import '../../widgets/home/custom_outlined_icon_button_widget.dart';
import '../../widgets/inventory/add_stock_return_page.dart';

class StockReturnPage extends StatefulWidget {
  final int customerId;

  const StockReturnPage({super.key, required this.customerId});

  @override
  State<StockReturnPage> createState() => _StockReturnPageState();
}

class _StockReturnPageState extends State<StockReturnPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final expenseProvider =
          Provider.of<StockreturnProvider>(context, listen: false);

      expenseProvider.searchItemListStock(context);
      expenseProvider.searchStockReturnList(
          context: context, customerId: widget.customerId.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final expenseProvider = Provider.of<StockreturnProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth < minContentWidth
              ? minContentWidth
              : constraints.maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header section
              SizedBox(
                height: 12,
              ),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    // Text(
                    //   'Stock Return',
                    //   style: GoogleFonts.plusJakartaSans(
                    //       fontSize: 16,
                    //       fontWeight: FontWeight.w600,
                    //       color: AppColors.textBlue800),
                    // ),
                    const Spacer(),
                    // Container(
                    //   width: MediaQuery.of(context).size.width / 3.5,
                    //   height: 40,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //     border: Border.all(color: Colors.grey[300]!),
                    //   ),
                    //   child: TextField(
                    //     controller: expenseProvider.searchitemNameController,
                    //     onChanged: (query) {
                    //       print(query);
                    //       // expenseProvider.getSearchLeadStatus(
                    //       //     query, context);
                    //     },
                    //     decoration: const InputDecoration(
                    //       hintText: 'Search here....',
                    //       prefixIcon: Icon(Icons.search),
                    //       border: InputBorder.none,
                    //       contentPadding: EdgeInsets.symmetric(
                    //         horizontal: 16,
                    //         vertical: 4,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    OutlinedButton.icon(
                      onPressed: () {
                        expenseProvider.toggleFilter();
                        // expenseProvider.selectDateFilterOption(null);
                        // expenseProvider.removeStatus();
                        // expenseProvider.searchStockUseList('', '', '', '', context);
                        print(expenseProvider.isFilter);
                      },
                      icon: const Icon(Icons.filter_list),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: expenseProvider.isFilter
                            ? Colors.white
                            : AppColors.primaryBlue, // Change foreground color
                        backgroundColor: expenseProvider.isFilter
                            ? const Color(0xFF5499D9)
                            : Colors.white, // Change background color
                        side: BorderSide(
                            color: expenseProvider.isFilter
                                ? const Color(0xFF5499D9)
                                : AppColors.primaryBlue), // Change border color
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (settingsProvider.menuIsSaveMap[79] == 1)
                      CustomOutlinedSvgButton(
                        onPressed: () async {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return AddStockReturnPage(
                                isEdit: false,
                                customerId: widget.customerId,
                                editId: 0,
                              );
                            },
                          );
                        },
                        svgPath: 'assets/images/Plus.svg',
                        label: 'Add Stock Return',
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
              const SizedBox(height: 12),
              if (expenseProvider.isFilter)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          onClickTopButton(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 1.5),
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
                            children: [
                              if (expenseProvider.fromDate == null &&
                                  expenseProvider.toDate == null)
                                const Text('Date: All'),
                              if (expenseProvider.fromDate != null &&
                                  expenseProvider.toDate != null)
                                Text(
                                    'Date : ${expenseProvider.formattedFromDate} - ${expenseProvider.formattedToDate}'),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.arrow_drop_down_outlined,
                                color: Colors.black45,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Spacer(),
                      if (expenseProvider.fromDate != null ||
                          expenseProvider.toDate != null ||
                          (expenseProvider.selectedSupplier != null &&
                              expenseProvider.selectedSupplier != 0) ||
                          expenseProvider.search.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            expenseProvider.selectDateFilterOption(null);
                            expenseProvider.removeSupplier();
                            // searchController.clear();
                            expenseProvider.setSearchCriteria(
                              '',
                              '',
                              '',
                              '',
                              '',
                            );
                            expenseProvider.searchStockReturnList(
                                context: context,
                                customerId: widget.customerId.toString());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textRed,
                            side: BorderSide(color: AppColors.textRed),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Reset'),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(8),
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
                      itemCount: expenseProvider.stockReturnList.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Container(
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceGrey,
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Text(
                                      expenseProvider.stockReturnList[index]
                                          .description,
                                      style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  expenseProvider
                                      .stockReturnList[index].returnDate,
                                  style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                if (settingsProvider.menuIsEditMap[79] == 1)
                                  TextButton(
                                      onPressed: () async {
                                        // expenseProvider.getStockUseDetails(
                                        //     expenseProvider
                                        //         .stockUseList[index].stockUseId,
                                        //     context: context);
                                        expenseProvider.getStockReturnDetails(
                                            context: context,
                                            masterId: expenseProvider
                                                .stockReturnList[index]
                                                .stockReturnId
                                                .toString());
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AddStockReturnPage(
                                                customerId: widget.customerId,
                                                isEdit: true,
                                                editId: expenseProvider
                                                    .stockReturnList[index]
                                                    .stockReturnId,
                                                stockUse: expenseProvider
                                                    .stockReturnList[index]);
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
                                if (settingsProvider.menuIsDeleteMap[79] == 1)
                                  TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm Delete'),
                                              content: const Text(
                                                  'Are you sure you want to delete this item?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    expenseProvider
                                                        .deleteStockReturn(
                                                            context,
                                                            expenseProvider
                                                                .stockReturnList[
                                                                    index]
                                                                .stockReturnId,
                                                            widget.customerId);
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
        );
      },
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<StockreturnProvider>(
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
                          leadProvider.searchStockReturnList(
                              context: context,
                              customerId: widget.customerId.toString());
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
                          leadProvider.searchStockReturnList(
                              context: context,
                              customerId: widget.customerId.toString());
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
}
