import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/commission_report_provider.dart';
import 'package:vidyanexis/controller/drop_down_provider.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_app_bar_mobile.dart';
import 'package:vidyanexis/utils/csv_function.dart';

class CommissionReportMobile extends StatefulWidget {
  const CommissionReportMobile({super.key});

  @override
  State<CommissionReportMobile> createState() => _CommissionReportMobileState();
}

class _CommissionReportMobileState extends State<CommissionReportMobile> {
  final TextEditingController searchController = TextEditingController();

  final List<String> dateButtonTitles = [
    'Yesterday',
    'Today',
    'Tomorrow',
    'This Week',
    'This Month'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CommissionReportProvider>(context, listen: false);
      final dropDownProvider = Provider.of<DropDownProvider>(context, listen: false);
      
      dropDownProvider.getEnquirySource(context);
      dropDownProvider.getEnquiryFor(context);
      provider.getCommissionReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CommissionReportProvider>(context);
    final dropDownProvider = Provider.of<DropDownProvider>(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Commission Report',
        onSearchTap: () {
          provider.toggleFilter();
        },
        onFilterTap: () {
          provider.toggleFilter();
        },
        onSearch: (query) {
          provider.getCommissionReport(context);
        },
        searchController: searchController,
        showExcel: true,
        onExcelTap: () {
          exportToExcel(
            headers: [
              'Lead Name',
              'Mobile no',
              'Enquiry For',
              'Enquiry Source',
              'Total Project Cost',
              'Commission',
              'Status',
              'Date',
              'Assigned To'
            ],
            data: provider.commissionReport.map((item) {
              return {
                'Lead Name': item.customerName,
                'Mobile no': item.contactNumber,
                'Enquiry For': item.enquiryFor,
                'Enquiry Source': item.enquirySourceName,
                'Total Project Cost': item.totalProjectCost,
                'Commission': item.commission,
                'Status': item.statusName,
                'Date': item.entryDate,
                'Assigned To': item.toUserName,
              };
            }).toList(),
            fileName: 'Commission_Report',
          );
        },
      ),
      body: Column(
        children: [
          if (provider.isFilter)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showDateFilterDialog(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  provider.fromDate != null
                                      ? '${provider.formattedFromDate} to ${provider.formattedToDate}'
                                      : 'Select Date Range',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<int>(
                            value: dropDownProvider.enquiryData.any((e) => e.enquirySourceId == provider.selectedEnquirySource) ? provider.selectedEnquirySource : 0,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(value: 0, child: Text('All Sources')),
                              ...dropDownProvider.enquiryData.map((e) => DropdownMenuItem(
                                value: e.enquirySourceId,
                                child: Text(e.enquirySourceName),
                              )),
                            ],
                            onChanged: (val) {
                              provider.setEnquirySourceFilter(val);
                              provider.getCommissionReport(context);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<int>(
                            value: dropDownProvider.enquiryForList.any((e) => e.enquiryForId == provider.selectedEnquiryFor) ? provider.selectedEnquiryFor : 0,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: [
                              const DropdownMenuItem(value: 0, child: Text('All Enquiry For')),
                              ...dropDownProvider.enquiryForList.map((e) => DropdownMenuItem(
                                value: e.enquiryForId,
                                child: Text(e.enquiryForName),
                              )),
                            ],
                            onChanged: (val) {
                              provider.setEnquiryForFilter(val);
                              provider.getCommissionReport(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: provider.commissionReport.isEmpty
                ? const Center(child: Text('No data found'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: provider.commissionReport.length,
                          itemBuilder: (context, index) {
                            final item = provider.commissionReport[index];
                            return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[200]!),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.customerName,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item.entryDate,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.contactNumber,
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Source: ${item.enquirySourceName}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const Divider(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Project Cost', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                        Text('₹${item.totalProjectCost}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Commission', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
                                        Text('₹${item.commission}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Cost', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('₹${provider.totalProjectCost}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total Commission', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('₹${provider.totalCommission}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _showDateFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<CommissionReportProvider>(
        builder: (context, provider, child) {
          return AlertDialog(
            title: const Text('Choose Date'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 8,
                  children: List.generate(dateButtonTitles.length, (index) {
                    return ChoiceChip(
                      label: Text(dateButtonTitles[index]),
                      selected: provider.selectedDateFilterIndex == index,
                      onSelected: (selected) {
                        provider.selectDateFilterOption(index);
                      },
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                          child: Text(provider.fromDate != null ? provider.formattedFromDate : 'From'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () => provider.selectDate(context, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                          child: Text(provider.toDate != null ? provider.formattedToDate : 'To'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
              ElevatedButton(
                onPressed: () {
                  provider.getCommissionReport(context);
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
