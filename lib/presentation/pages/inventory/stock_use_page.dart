
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/controller/stock_use_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:vidyanexis/presentation/widgets/inventory/add_stock_use.dart';

class StockUsePage extends StatefulWidget {
  final int customerId;

  const StockUsePage({super.key, required this.customerId});

  @override
  State<StockUsePage> createState() => _StockUsePageState();
}

class _StockUsePageState extends State<StockUsePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final stockuseprovider =
          Provider.of<StockUseProvider>(context, listen: false);

      stockuseprovider.searchItemListStock(context);
      stockuseprovider.searchStockUseList(
          context: context, customerId: widget.customerId.toString());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const double minContentWidth = 800.0;
    final stockuseprovider = Provider.of<StockUseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          children: [
            // Header section
            SizedBox(
              height: 16,
            ),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  // Text(
                  //   'Stock Use',
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
                  //     controller: stockuseprovider.searchitemNameController,
                  //     onChanged: (query) {
                  //       print(query);
                  //       // stockuseprovider.getSearchLeadStatus(
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
                      stockuseprovider.toggleFilter();
                      // stockuseprovider.selectDateFilterOption(null);
                      // stockuseprovider.removeStatus();
                      // stockuseprovider.searchStockUseList('', '', '', '', context);
                      print(stockuseprovider.isFilter);
                    },
                    icon: const Icon(Icons.filter_list),
                    label: const Text('Filter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: stockuseprovider.isFilter
                          ? Colors.white
                          : AppColors.primaryBlue, // Change foreground color
                      backgroundColor: stockuseprovider.isFilter
                          ? const Color(0xFF5499D9)
                          : Colors.white, // Change background color
                      side: BorderSide(
                          color: stockuseprovider.isFilter
                              ? const Color(0xFF5499D9)
                              : AppColors.primaryBlue), // Change border color
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (settingsProvider.menuIsSaveMap[78] == 1)
                    CustomOutlinedSvgButton(
                      onPressed: () async {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return AddStockUseWidget(
                              isEdit: false,
                              editId: 0,
                              customerId: widget.customerId,
                            );
                          },
                        );
                      },
                      svgPath: 'assets/images/Plus.svg',
                      label: 'Add Stock Use',
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
            if (stockuseprovider.isFilter)
              AppStyles.isWebScreen(context)?
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Row(
                      children: [
                        // DATE FILTER
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
                                color: stockuseprovider.fromDate != null ||
                                        stockuseprovider.toDate != null
                                    ? AppColors.primaryBlue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (stockuseprovider.fromDate == null &&
                                    stockuseprovider.toDate == null)
                                  const Text('Date: All'),
                                if (stockuseprovider.fromDate != null &&
                                    stockuseprovider.toDate != null)
                                  Text(
                                      'Date : ${stockuseprovider.formattedFromDate} - ${stockuseprovider.formattedToDate}'),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.black45,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    Spacer(),

                    // RESET BUTTON BELOW
                    
                    if (stockuseprovider.fromDate != null ||
                        stockuseprovider.toDate != null ||
                        (stockuseprovider.selectedSupplier != null &&
                            stockuseprovider.selectedSupplier != 0) ||
                        stockuseprovider.search.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          stockuseprovider.selectDateFilterOption(null);
                          stockuseprovider.removeSupplier();
                          // searchController.clear();
                          stockuseprovider.setSearchCriteria(
                            '',
                            '',
                            '',
                            '',
                            '',
                          );
                          stockuseprovider.searchStockUseList(
                            context: context,
                            customerId: widget.customerId.toString(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textRed,
                          side: BorderSide(color: AppColors.textRed),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Reset'),
                      ),
                  ],
                ),
              ):
               Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // DATE FILTER
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
                                color: stockuseprovider.fromDate != null ||
                                        stockuseprovider.toDate != null
                                    ? AppColors.primaryBlue
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (stockuseprovider.fromDate == null &&
                                    stockuseprovider.toDate == null)
                                  const Text('Date: All'),
                                if (stockuseprovider.fromDate != null &&
                                    stockuseprovider.toDate != null)
                                  Text(
                                      'Date : ${stockuseprovider.formattedFromDate} - ${stockuseprovider.formattedToDate}'),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_drop_down_outlined,
                                  color: Colors.black45,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    // RESET BUTTON BELOW
                    
                    if (stockuseprovider.fromDate != null ||
                        stockuseprovider.toDate != null ||
                        (stockuseprovider.selectedSupplier != null &&
                            stockuseprovider.selectedSupplier != 0) ||
                        stockuseprovider.search.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: ElevatedButton(
                            onPressed: () {
                              stockuseprovider.selectDateFilterOption(null);
                              stockuseprovider.removeSupplier();
                              // searchController.clear();
                              stockuseprovider.setSearchCriteria(
                                '',
                                '',
                                '',
                                '',
                                '',
                              );
                              stockuseprovider.searchStockUseList(
                                context: context,
                                customerId: widget.customerId.toString(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
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
                    itemCount: stockuseprovider.stockUseList.length,
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
                              if (stockuseprovider
                                  .stockUseList[index].description.isNotEmpty)
                                Container(
                                  height: 22,
                                  decoration: BoxDecoration(
                                      color: AppColors.surfaceGrey,
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Text(
                                        stockuseprovider
                                            .stockUseList[index].description,
                                        style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              const Spacer(),
                              Text(
                                stockuseprovider.stockUseList[index].date,
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              if (settingsProvider.menuIsEditMap[78] == 1)
                              TextButton(
                                  onPressed: () async {
                                    // stockuseprovider.getStockUseDetails(
                                    //     stockuseprovider
                                    //         .stockUseList[index].stockUseId,
                                    //     context: context);

                                    stockuseprovider.getStockUseDetails(
                                        context: context,
                                        masterId: stockuseprovider
                                            .stockUseList[index].stockUseId
                                            .toString());
                                    showDialog(
                                      barrierDismissible: false,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AddStockUseWidget(
                                            customerId: widget.customerId,
                                            isEdit: true,
                                            editId: stockuseprovider
                                                .stockUseList[index].stockUseId,
                                            stockUse: stockuseprovider
                                                .stockUseList[index]);
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
                              if (settingsProvider.menuIsDeleteMap[78] == 1)
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
                                                stockuseprovider.deleteStockUse(
                                                    context,
                                                    stockuseprovider
                                                        .stockUseList[index]
                                                        .stockUseId,
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
        );
      },
    );
  }

  void onClickTopButton(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (contextx) => Consumer<StockUseProvider>(
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
                          leadProvider.searchStockUseList(
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
                          leadProvider.searchStockUseList(
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
