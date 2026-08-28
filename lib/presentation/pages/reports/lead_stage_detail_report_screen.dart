import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/lead_stage_detail_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/common/common_empty_state.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_text_widget.dart';
import 'package:vidyanexis/presentation/widgets/reports/common_report_widgets.dart';
import 'package:vidyanexis/utils/csv_function.dart';
import 'package:vidyanexis/presentation/pages/home/customer_detail_page_mobile.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';

class LeadStageDetailReportScreen extends StatefulWidget {
  final int stageId;
  final String stageName;

  const LeadStageDetailReportScreen({
    super.key,
    required this.stageId,
    required this.stageName,
  });

  @override
  State<LeadStageDetailReportScreen> createState() =>
      _LeadStageDetailReportScreenState();
}

class _LeadStageDetailReportScreenState
    extends State<LeadStageDetailReportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LeadStageDetailReportProvider>(context, listen: false)
          .fetchReportData(context, widget.stageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Consumer<LeadStageDetailReportProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(AppStyles.isWebScreen(context) ? 24.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, provider),
                const SizedBox(height: 24),
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.reportData.isEmpty
                          ? const CommonEmptyState(
                              message: 'No leads found for this stage')
                          : _buildTableCard(provider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, LeadStageDetailReportProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back,
              size: 24, color: Color(0xFF152D70)),
        ),
        const SizedBox(width: 8),
        CustomText(
          '${widget.stageName} Leads',
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlack,
        ),
        const Spacer(),
        if (provider.reportData.isNotEmpty)
          CommonReportExportButton(
            onPressed: () {
              exportToExcel(
                headers: [
                  'Customer Name',
                  'Phone Number',
                  'Entry Date',
                  'Stage',
                  'Enquiry For',
                  'Source',
                  'Category',
                  'Assigned Staff'
                ],
                data: provider.reportData.map((item) {
                  return {
                    'Customer Name': item.customerName ?? "",
                    'Phone Number': item.phoneNumber ?? "",
                    'Entry Date': item.entryDate ?? "",
                    'Stage': item.stageName ?? "",
                    'Enquiry For': item.enquiryForName ?? "",
                    'Source': item.enquirySourceName ?? "",
                    'Category': item.sourceCategoryName ?? "",
                    'Assigned Staff': item.staffName ?? "",
                  };
                }).toList(),
                fileName: '${widget.stageName}_Leads',
              );
            },
            label: 'Export to Excel',
          ),
      ],
    );
  }

  Widget _buildTableCard(LeadStageDetailReportProvider provider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomText('Leads Summary',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textBlack),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - (AppStyles.isWebScreen(context) ? 48 : 32),
                  ),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    headingRowHeight: 56,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    horizontalMargin: 24,
                    columnSpacing: 24,
                    columns: [
                      _dataColumn('Customer Name'),
                      _dataColumn('Phone Number'),
                      _dataColumn('Entry Date'),
                      _dataColumn('Enquiry For'),
                      _dataColumn('Source'),
                      _dataColumn('Category'),
                      _dataColumn('Assigned Staff'),
                    ],
                    rows: provider.reportData.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(item.customerName ?? '-',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primaryBlue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primaryBlue)),
                            onTap: () {
                              if (item.customerId != null) {
                                if (AppStyles.isWebScreen(context)) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerDetailsScreen(
                                                customerId:
                                                    item.customerId.toString(),
                                                report: "false"),
                                      ));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CustomerDetailPageMobile(
                                          customerId: item.customerId!,
                                          fromLead: true,
                                        ),
                                      ));
                                }
                              }
                            },
                          ),
                          DataCell(Text(item.phoneNumber ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                          DataCell(Text(item.entryDate ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                          DataCell(Text(item.enquiryForName ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                          DataCell(Text(item.enquirySourceName ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                          DataCell(Text(item.sourceCategoryName ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                          DataCell(Text(item.staffName ?? '-',
                              style: const TextStyle(fontSize: 14, color: AppColors.textBlack))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataColumn _dataColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}
