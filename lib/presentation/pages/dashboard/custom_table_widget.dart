import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/pages/home/customer_details_page.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class CustomTableWidget extends StatelessWidget {
  const CustomTableWidget({
    super.key,
    required this.dashboardProvider,
  });
  final DashboardProvider dashboardProvider;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 700;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isDesktop ? _buildDesktopHeader() : _buildMobileHeader(),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dashboardProvider.searchCustomer.length,
                itemBuilder: (context, index) {
                  var lead = dashboardProvider.searchCustomer[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.white
                          : const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isDesktop
                        ? _buildDesktopRow(context, index, lead)
                        : _buildMobileRow(context, index, lead),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopHeader() {
    return const Row(
      children: [
        TableWidget(flex: 1, title: 'Sl no.', color: Color(0xFF607185)),
        TableWidget(flex: 2, title: 'Customer Name', color: Color(0xFF607185)),
        TableWidget(flex: 2, title: 'Status', color: Color(0xFF607185)),
        TableWidget(flex: 2, title: 'Added Date', color: Color(0xFF607185)),
        TableWidget(flex: 2, title: 'Action', color: Color(0xFF607185)),
      ],
    );
  }

  Widget _buildMobileHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Customer Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF607185),
            ),
          ),
          Text(
            'Action',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF607185),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopRow(BuildContext context, int index, dynamic lead) {
    return Row(
      children: [
        TableWidget(
          flex: 1,
          data: Text('${index + 1}'),
        ),
        TableWidget(
          flex: 2,
          data: Text(
            lead.customerName.length > 20
                ? '${lead.customerName.substring(0, 20)}...'
                : lead.customerName,
          ),
        ),
        TableWidget(
          flex: 2,
          data: Text(lead.statusName),
        ),
        TableWidget(flex: 2, title: lead.entryDate),
        TableWidget(
          flex: 2,
          data: _buildActionButton(context, lead),
        ),
      ],
    );
  }

  Widget _buildMobileRow(BuildContext context, int index, dynamic lead) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.customerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Text(
                  lead.statusName,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lead.entryDate,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildActionButton(context, lead),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, dynamic lead) {
    return ActionChip(
      onPressed: () {
        context.push(
            '${CustomerDetailsScreen.route}${lead.customerId.toString()}/${'true'}');
      },
      side: BorderSide(
        color: AppColors.primaryBlue,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      label: Text(
        AppStyles.isWebScreen(context) ? 'View Details' : 'View',
        style: AppStyles.getBodyTextStyle(
            fontSize: 12, fontColor: AppColors.primaryBlue),
      ),
    );
  }
}

List title = ["Sl No.", "Customer name", "Status", "Added date", "Action"];

List<Map<String, dynamic>> tData = [
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "1",
    "cus_name": "John Williams",
    "status": "Not Started",
    "date": "26 OCT 2024",
    "act": ""
  },
  {
    "#": "2",
    "cus_name": "Jane Doe",
    "status": "In Progress",
    "date": "27 OCT 2024",
    "act": ""
  },
  {
    "#": "3",
    "cus_name": "Bob Smith",
    "status": "Completed",
    "date": "28 OCT 2024",
    "act": ""
  },
  {
    "#": "4",
    "cus_name": "Alice Johnson",
    "status": "Not Started",
    "date": "29 OCT 2024",
    "act": ""
  },
  {
    "#": "5",
    "cus_name": "Mike Brown",
    "status": "In Progress",
    "date": "30 OCT 2024",
    "act": ""
  },
  {
    "#": "6",
    "cus_name": "Emily Davis",
    "status": "Completed",
    "date": "31 OCT 2024",
    "act": ""
  },
  {
    "#": "7",
    "cus_name": "David Lee",
    "status": "Not Started",
    "date": "01 NOV 2024",
    "act": ""
  },
  {
    "#": "8",
    "cus_name": "Sophia Taylor",
    "status": "In Progress",
    "date": "02 NOV 2024",
    "act": ""
  },
  {
    "#": "9",
    "cus_name": "Oliver Martin",
    "status": "Completed",
    "date": "03 NOV 2024",
    "act": ""
  },
  {
    "#": "10",
    "cus_name": "Ava White",
    "status": "Not Started",
    "date": "04 NOV 2024",
    "act": ""
  },
];

class CustomTable extends StatelessWidget {
  CustomTable(
      {super.key,
      required this.titles,
      required this.tableData,
      this.tabWidth,
      required this.child});
  final List<String> titles;
  final List tableData;
  List<int>? tabWidth;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    tabWidth ??= List.generate(titles.length, (i) => 1);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Header Row (Table Column Titles)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF2F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: titles
                        .asMap()
                        .entries
                        .map(
                          (e) => TableWidget(
                              flex: tabWidth![e.key],
                              title: e.value,
                              color: const Color(0xFF607185)),
                        )
                        .toList()),
              ),
              // Data Rows
              ListView.builder(
                shrinkWrap:
                    true, // To avoid scrolling issues when inside a parent widget
                physics:
                    const NeverScrollableScrollPhysics(), // Disable scrolling here, as parent scroll handles it
                itemCount: tData.length, // Number of leads
                itemBuilder: (context, index) {
                  var item = tableData[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: index % 2 == 0
                          ? Colors.white
                          : const Color(0xFFF6F7F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    // Alternate row colors
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: item.map((e) => TableWidget(
                            flex: tabWidth![index],
                            data: child,
                          )),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
