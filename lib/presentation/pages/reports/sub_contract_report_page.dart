import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/sub_contract_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/sub_contract_report_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class SubContractReportPage extends StatefulWidget {
  const SubContractReportPage({super.key});

  @override
  State<SubContractReportPage> createState() => _SubContractReportPageState();
}

class _SubContractReportPageState extends State<SubContractReportPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<SubContractReportProvider>(context, listen: false);
      final dropDownProvider =
          Provider.of<DropDownProvider>(context, listen: false);
      dropDownProvider.getUserDetails(context);
      dropDownProvider.getEnquiryFor(context);
      provider.getSubContractReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const SubContractReportMobile();
    }

    final provider = Provider.of<SubContractReportProvider>(context);

    return Scaffold(
      backgroundColor:
          AppStyles.isWebScreen(context) ? null : AppColors.whiteColor,
      body: Container(
        color: AppStyles.isWebScreen(context)
            ? Colors.grey[50]
            : AppColors.whiteColor,
        child: Column(
          children: [
            Padding(
              padding: AppStyles.isWebScreen(context)
                  ? const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 4.0)
                  : EdgeInsets.zero,
              child: Column(
                children: [
                  Row(
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
                      const Text(
                        'Sub Contract Reports',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color(0xFF152D70),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
  width: 280,
  height: 38,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: TextField(
    controller: searchController,
    focusNode: searchFocusNodeWeb,
    textAlignVertical: TextAlignVertical.center,
    onTap: () {
      Future.microtask(() {
        if (searchController.text.isNotEmpty &&
            searchController.selection.baseOffset == 0 &&
            searchController.selection.extentOffset == searchController.text.length) {
          searchController.selection = TextSelection.collapsed(offset: searchController.text.length);
        }
      });
    },
    onSubmitted: (val) {
                            provider.setSearch(val);
                            provider.getSubContractReport(context);
                          },
    decoration: InputDecoration(
      hintText: 'Search here....',
      hintStyle: GoogleFonts.plusJakartaSans(
        color: const Color(0xFF94A3B8),
        fontSize: 13,
      ),
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      suffixIcon: GestureDetector(
        onTap: () {
                            provider.setSearch(searchController.text);
                            provider.getSubContractReport(context);
                          },
        child: const Icon(Icons.search, color: Color(0xFF64748B), size: 18),
      ),
    ),
  ),
),
                      const SizedBox(width: 16),
                      CustomFilterButton(
                        onPressed: () => provider.toggleFilter(),
                        isFilter: provider.isFilter,
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          exportToExcel(
                            headers: [
                              'Lead Name',
                              'Task Type',
                              'Task Status',
                              'To User Name',
                              'Date',
                              'Amount',
                            ],
                            data: provider.subContractReport.map((item) {
                              return {
                                'Lead Name': item.customerName,
                                'Task Type': item.taskTypeName,
                                'Task Status': item.taskStatusName,
                                'To User Name': item.toUserName,
                                'Date': item.entryDate,
                                'Amount': item.commission,
                              };
                            }).toList(),
                            fileName: 'Sub_Contract_Report',
                          );
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Export',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                  if (provider.isFilter) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          CommonReportDateFilter(
                            fromDate: provider.fromDate?.toString(),
                            toDate: provider.toDate?.toString(),
                            formattedFromDate: provider.formattedFromDate,
                            formattedToDate: provider.formattedToDate,
                            onTap: () => _onClickDateRange(context),
                          ),
                          _buildDropDownFilter(
                            context,
                            'Staff',
                            context
                                .read<DropDownProvider>()
                                .searchUserDetails
                                .map((u) => {
                                      'id': u.userDetailsId,
                                      'name': u.userDetailsName
                                    })
                                .toList(),
                            provider.selectedUserId,
                            (val) {
                              provider.setUserId(val!);
                              provider.getSubContractReport(context);
                            },
                          ),
                          _buildDropDownFilter(
                            context,
                            'Enquiry For',
                            context
                                .read<DropDownProvider>()
                                .enquiryForList
                                .map((e) => {
                                      'id': e.enquiryForId,
                                      'name': e.enquiryForName
                                    })
                                .toList(),
                            provider.selectedEnquiryForId,
                            (val) {
                              provider.setEnquiryForId(val!);
                              provider.getSubContractReport(context);
                            },
                          ),
                          CommonReportResetButton(
                            onReset: () {
                              searchController.clear();
                              provider.resetFilters(context);
                            },
                            label: 'Reset',
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textRed,
                              elevation: 0,
                              side: BorderSide(color: AppColors.textRed),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: AppStyles.isWebScreen(context)
                    ? const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 4.0)
                    : EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppStyles.isWebScreen(context)
                        ? BorderRadius.circular(4)
                        : BorderRadius.zero,
                  ),
                  child: Padding(
                    padding: AppStyles.isWebScreen(context)
                        ? const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0)
                        : EdgeInsets.zero,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width -
                                      (AppStyles.isWebScreen(context)
                                          ? 48
                                          : 0)),
                              child: SizedBox(
                                width: 1200,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(8),
                                          topRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildTableHeader('No.', flex: 1),
                                          _buildTableHeader('Lead Name',
                                              flex: 4),
                                          _buildTableHeader('Task Type',
                                              flex: 3),
                                          _buildTableHeader('Task Status',
                                              flex: 2, center: true),
                                          _buildTableHeader('To User Name',
                                              flex: 3),
                                          _buildTableHeader('Date', flex: 3),
                                          _buildTableHeader('Amount', flex: 2),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: provider.subContractReport.isEmpty
                                          ? const CommonEmptyState(message: 'No sub contract reports found')
                                          : ListView.separated(
                                              itemCount: provider
                                                  .subContractReport.length,
                                              separatorBuilder: (context,
                                                      index) =>
                                                  const Divider(
                                                      height: 0,
                                                      color:
                                                          Colors.transparent),
                                              itemBuilder: (context, index) {
                                                final item = provider
                                                    .subContractReport[index];
                                                final isEven = index % 2 == 0;
                                                return Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10,
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                    color: isEven
                                                        ? Colors.white
                                                        : const Color(
                                                            0xFFF8FAFC),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                              '${index + 1}',
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]))),
                                                      Expanded(
                                                        flex: 4,
                                                        child: InkWell(
                                                          onTap: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CustomerDetailsScreen(
                                                                  customerId: item
                                                                      .customerId
                                                                      .toString(),
                                                                  report:
                                                                      'true',
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          focusColor: Colors
                                                              .transparent,
                                                          hoverColor: Colors
                                                              .transparent,
                                                          splashColor: Colors
                                                              .transparent,
                                                          highlightColor: Colors
                                                              .transparent,
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 4,
                                                                backgroundColor:
                                                                    AppColors
                                                                        .primaryBlue
                                                                        .withOpacity(
                                                                            0.1),
                                                                child: Icon(
                                                                    Icons
                                                                        .person,
                                                                    size: 14,
                                                                    color: AppColors
                                                                        .primaryBlue),
                                                              ),
                                                              const SizedBox(
                                                                  width: 8),
                                                              Flexible(
                                                                child: Text(
                                                                  item.customerName,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          13,
                                                                      color: Colors
                                                                              .grey[
                                                                          800]),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Icon(
                                                                  Icons
                                                                      .chevron_right,
                                                                  size: 16,
                                                                  color: Colors
                                                                          .grey[
                                                                      400]),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              item.taskTypeName,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]))),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Center(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        4),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: const Color(
                                                                  0xFFE0F2F1),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                  color: const Color(
                                                                      0xFFB2DFDB)),
                                                            ),
                                                            child: Text(
                                                              item.taskStatusName
                                                                      .isEmpty
                                                                  ? 'Pending'
                                                                  : item
                                                                      .taskStatusName,
                                                              style: const TextStyle(
                                                                  color: Color(
                                                                      0xFF00897B),
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              item.toUserName,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]))),
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              item.entryDate,
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  color: Colors
                                                                          .grey[
                                                                      700]))),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          '₹${item.commission}',
                                                          style:
                                                              const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .green,
                                                                  fontSize: 13),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14, horizontal: 16),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(
                                            top: BorderSide(
                                                color: Color(0xFFE2E8F0))),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Expanded(
                                              flex: 1, child: SizedBox()),
                                          const Expanded(
                                              flex: 4,
                                              child: Text('TOTAL',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold))),
                                          const Expanded(
                                              flex: 3, child: SizedBox()),
                                          const Expanded(
                                              flex: 2, child: SizedBox()),
                                          const Expanded(
                                              flex: 3, child: SizedBox()),
                                          const Expanded(
                                              flex: 3, child: SizedBox()),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                  '₹${provider.totalCommission}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.green))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title,
      {int? flex, double? width, bool center = false}) {
    final child = Text(
      title.toUpperCase(),
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[600],
        letterSpacing: 0.5,
      ),
    );
    return flex != null
        ? Expanded(flex: flex, child: child)
        : SizedBox(
            width: width,
            child: center ? Center(child: child) : child,
          );
  }

  Widget _buildFilterItem(BuildContext context, String label, String value,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text('$label: ',
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDownFilter(
      BuildContext context,
      String label,
      List<Map<String, dynamic>> items,
      int selectedValue,
      Function(int?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(width: 4),
          DropdownButton<int>(
            value: selectedValue == 0
                ? null
                : (items.any((i) => i['id'] == selectedValue)
                    ? selectedValue
                    : null),
            hint: const Text('All', style: TextStyle(fontSize: 13)),
            underline: const SizedBox(),
            onChanged: onChanged,
            items: [
              const DropdownMenuItem(
                  value: 0, child: Text('All', style: TextStyle(fontSize: 13))),
              ...items.map((i) => DropdownMenuItem(
                    value: i['id'],
                    child:
                        Text(i['name'], style: const TextStyle(fontSize: 13)),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  void _onClickDateRange(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<SubContractReportProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Select Date Range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < 5; i++)
                      ActionChip(
                        label: Text([
                          'Yesterday',
                          'Today',
                          'Tomorrow',
                          'This Week',
                          'This Month'
                        ][i]),
                        onPressed: () {
                          provider.selectDateFilterOption(i);
                        },
                        backgroundColor: provider.selectedDateFilterIndex == i
                            ? AppColors.primaryBlue
                            : null,
                        labelStyle: TextStyle(
                            color: provider.selectedDateFilterIndex == i
                                ? Colors.white
                                : null),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.selectDate(context, true),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(provider.fromDate != null
                            ? provider.formattedFromDate
                            : 'From Date'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => provider.selectDate(context, false),
                        icon: const Icon(Icons.calendar_today, size: 16),
                        label: Text(provider.toDate != null
                            ? provider.formattedToDate
                            : 'To Date'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  provider.getSubContractReport(context);
                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}
