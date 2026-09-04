import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/customer_outstanding_report_provider.dart';
import 'package:vidyanexis/presentation/widgets/reports/report_list_item.dart';

class CustomerOutstandingDashboardList extends StatefulWidget {
  const CustomerOutstandingDashboardList({super.key});

  @override
  State<CustomerOutstandingDashboardList> createState() =>
      _CustomerOutstandingDashboardListState();
}

class _CustomerOutstandingDashboardListState
    extends State<CustomerOutstandingDashboardList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CustomerOutstandingReportProvider>(context, listen: false)
          .getReport(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomerOutstandingReportProvider>(
      builder: (context, provider, child) {
        if (provider.reportData.isEmpty) {
          return const SizedBox.shrink();
        }

        final isWeb = AppStyles.isWebScreen(context);

        return Container(
          margin: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Customer Outstanding Details',
                  style: AppStyles.getHeadingTextStyle(fontSize: 16),
                ),
              ),
              const Divider(height: 1),
              if (isWeb)
                _buildDesktopTable(provider)
              else
                _buildMobileList(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesktopTable(CustomerOutstandingReportProvider provider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width - 32, // Minus padding
        ),
        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
          columns: const [
            DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Start Date', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Exp. Dur', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Act. Dur', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Diff', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Project Cost', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Received', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Balance', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: provider.reportData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.customerName)),
                DataCell(Text(item.phone)),
                DataCell(Text(item.projectStartDate ?? '-')),
                DataCell(Text('${item.expectedDuration}')),
                DataCell(Text(item.actualDuration?.toString() ?? '-')),
                DataCell(Text(item.difference?.toString() ?? '-')),
                DataCell(Text('₹${item.projectCost}')),
                DataCell(Text('₹${item.received}', style: const TextStyle(color: Colors.green))),
                DataCell(Text('₹${item.balance}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobileList(CustomerOutstandingReportProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: provider.reportData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = provider.reportData[index];
        return ReportListItem(
          title: item.customerName,
          subtitle: item.phone,
          status: item.enquirySource,
          statusColor: AppColors.primaryBlue,
          description:
              'Cost: ₹${item.projectCost} | Recv: ₹${item.received}\nStart: ${item.projectStartDate ?? '-'} | Exp. Dur: ${item.expectedDuration}\nAct. Dur: ${item.actualDuration ?? '-'} | Diff: ${item.difference ?? '-'}',
          descriptionMaxLines: 3,
          bottomRightText: 'Bal: ₹${item.balance}',
          onTap: () {},
        );
      },
    );
  }
}
