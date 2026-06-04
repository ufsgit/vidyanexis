import 'package:vidyanexis/presentation/widgets/common/custom_filter_button.dart';
import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_outstanding_report_provider.dart';
import 'package:vidyanexis/presentation/pages/reports/customer_outstanding_report_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';

class CustomerOutstandingReportPage extends StatefulWidget {
  static String route = '/customer_outstanding_report';
  const CustomerOutstandingReportPage({super.key});

  @override
  State<CustomerOutstandingReportPage> createState() =>
      _CustomerOutstandingReportPageState();
}

class _CustomerOutstandingReportPageState
    extends State<CustomerOutstandingReportPage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNodeWeb = FocusNode();
  final FocusNode searchFocusNodeMobile = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CustomerOutstandingReportProvider>(context,
          listen: false);
      provider.getReport(context);
      Provider.of<DropDownProvider>(context, listen: false)
          .getEnquirySource(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!AppStyles.isWebScreen(context)) {
      return const CustomerOutstandingReportMobile();
    }

    final provider = Provider.of<CustomerOutstandingReportProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
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
                    Text(
                      'Customer Outstanding Report',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textBlack,
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
    onSubmitted: (val) => provider.getReport(context),
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
        onTap: () { provider.getReport(context); },
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
                    ElevatedButton(
                      onPressed: () {
                        exportToExcel(
                          headers: [
                            'Customer Name',
                            'Enquiry Source',
                            'Phone no',
                            'Project Cost',
                            'Received',
                            'Balance',
                          ],
                          data: provider.reportData.map((item) {
                            return {
                              'Customer Name': item.customerName,
                              'Enquiry Source': item.enquirySource,
                              'Phone no': item.phone,
                              'Project Cost': item.projectCost,
                              'Received': item.received,
                              'Balance': item.balance,
                            };
                          }).toList(),
                          fileName: 'Customer_Outstanding_Report',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1C40F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text('Export to Excel',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (provider.isFilter) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      CommonReportDateFilter(
                        fromDate: provider.fromDate?.toString(),
                        toDate: provider.toDate?.toString(),
                        formattedFromDate: provider.formattedFromDate,
                        formattedToDate: provider.formattedToDate,
                        onTap: () => _onClickDateRange(context),
                      ),
                      const SizedBox(width: 16),
                      _buildEnquirySourceDropdown(context, provider),
                      const Spacer(),
                      CommonReportResetButton(
                        onReset: () => provider.resetFilters(context),
                        label: 'Clear All',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // Table section
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 1200
                      ? MediaQuery.of(context).size.width
                      : 1200,
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
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
                            _buildTableHeader('Customer Name', flex: 3),
                            _buildTableHeader('Enquiry Source', flex: 2),
                            _buildTableHeader('Phone no', flex: 3),
                            _buildTableHeader('Project Cost', flex: 3),
                            _buildTableHeader('Received', flex: 3),
                            _buildTableHeader('Balance', flex: 3),
                          ],
                        ),
                      ),
                      // Table Body
                      Expanded(
                        child: provider.reportData.isEmpty
                            ? const CommonEmptyState(message: 'No data found')
                            : ListView.separated(
                                itemCount: provider.reportData.length,
                                separatorBuilder: (context, index) =>
                                    Divider(height: 1, color: Colors.grey[100]),
                                itemBuilder: (context, index) {
                                  final item = provider.reportData[index];
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 24),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text('${index + 1}',
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CustomerDetailsScreen(
                                                    customerId: item.customerId
                                                        .toString(),
                                                    report: 'true',
                                                  ),
                                                ),
                                              );
                                            },
                                            focusColor: Colors.transparent,
                                            hoverColor: Colors.transparent,
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircleAvatar(
                                                  radius: 14,
                                                  backgroundColor: AppColors
                                                      .primaryBlue
                                                      .withOpacity(0.1),
                                                  child: Icon(Icons.person,
                                                      size: 16,
                                                      color: AppColors
                                                          .primaryBlue),
                                                ),
                                                const SizedBox(width: 10),
                                                Flexible(
                                                  child: Text(
                                                    item.customerName,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Icon(Icons.chevron_right,
                                                    size: 18,
                                                    color:
                                                        AppColors.primaryBlue),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: Text(item.enquirySource,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        Expanded(
                                            flex: 3,
                                            child: Text(item.phone,
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        Expanded(
                                            flex: 3,
                                            child: Text('₹${item.projectCost}',
                                                style: const TextStyle(
                                                    fontSize: 13))),
                                        Expanded(
                                            flex: 3,
                                            child: Text('₹${item.received}',
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.green))),
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            '₹${item.balance}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      // Table Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          border:
                              Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Expanded(flex: 1, child: SizedBox()),
                            const Expanded(
                                flex: 5,
                                child: Text('TOTAL',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            const Expanded(flex: 3, child: SizedBox()),
                            Expanded(
                                flex: 3,
                                child: Text('₹${provider.totalProjectCost}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                flex: 3,
                                child: Text('₹${provider.totalReceived}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green))),
                            Expanded(
                                flex: 3,
                                child: Text('₹${provider.totalBalance}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red))),
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

  Widget _buildEnquirySourceDropdown(
      BuildContext context, CustomerOutstandingReportProvider provider) {
    return Consumer<DropDownProvider>(
      builder: (context, dropDownProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: provider.selectedEnquirySourceId != null
                  ? AppColors.primaryBlue
                  : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Source: ',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              DropdownButton<int>(
                value: provider.selectedEnquirySourceId,
                hint: const Text('All',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('All',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                  ...dropDownProvider.enquiryData.map((source) {
                    return DropdownMenuItem<int>(
                      value: source.enquirySourceId,
                      child: Text(source.enquirySourceName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13)),
                    );
                  }),
                ],
                onChanged: (value) {
                  provider.setEnquirySource(value);
                  provider.getReport(context);
                },
                icon: const Icon(Icons.arrow_drop_down_outlined,
                    color: Colors.black45, size: 20),
              ),
            ],
          ),
        );
      },
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

  void _onClickDateRange(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CustomerOutstandingReportProvider>(
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
                        onPressed: () => provider.selectDateFilterOption(i),
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
                  provider.getReport(context);
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
