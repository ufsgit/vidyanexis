import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/models/follow_up_summary_model.dart';
import 'package:vidyanexis/controller/models/lead_conversion_model.dart';
import 'package:vidyanexis/controller/models/lead_progress_model.dart';
import 'package:vidyanexis/controller/models/task_allocation_model.dart';
import 'package:vidyanexis/presentation/pages/dashboard/chart.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_enquiry_for_report_card.dart';
import 'package:vidyanexis/presentation/pages/dashboard/weekly_report_card.dart';
import 'package:vidyanexis/presentation/widgets/home/table_cell.dart';

class LeadsOverViewTab extends StatefulWidget {
  const LeadsOverViewTab({
    super.key,
    required this.leadConversionData,
    required this.pieData,
    required this.countLeadData,
    required this.followUpLeadData,
    required this.taskAllocationData,
    required this.dashBoardProvider,
  });

  final List<LeadCoversionChartModel> leadConversionData;
  final List<CountLeadCoversionChartModel> countLeadData;
  final List<FollowUpSummaryModel> followUpLeadData;
  final List<TaskAllocationSummaryModel> taskAllocationData;
  final DashboardProvider dashBoardProvider;
  final List<LeadProgressReportModel> pieData;

  @override
  State<LeadsOverViewTab> createState() => _LeadsOverViewTabState();
}

class _LeadsOverViewTabState extends State<LeadsOverViewTab> {
  Color _colorForTitle(String title) {
    final t = title.toLowerCase();
    switch (t) {
      case 'new_leads':
        return const Color(0xFFBAC5D0);
      case 'followup_leads':
      case 'pending_followups':
      case 'pending_followup':
        return const Color(0xFF90A1D6);
      case 'closed_leads':
        return const Color(0xFF9CC9BF);
      case 'total_called':
        return const Color(0xFF8699C9);
      case 'transferred_leads':
        return const Color(0xFF9ABDE2);
      case 'missed_leads':
        return const Color(0xFFDEB0B9);
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // show counts grid at top
    final leadCounts = widget.dashBoardProvider.leadDashboardCountData;
    Widget countsGrid = const SizedBox.shrink();
    if (leadCounts.isNotEmpty) {
      countsGrid = Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth > 800) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: leadCounts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.0, // wider rectangles similar to dashboard
              ),
              itemBuilder: (context, index) {
                final item = leadCounts[index];
                final color = _colorForTitle(item.title);
                return Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title.replaceAll('_', ' ').split(' ').map((w) => w.isNotEmpty ?
                                  w[0].toUpperCase() + w.substring(1) : w).join(' '),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.question_mark,
                                size: 12, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.dataCount.toString(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "View Leads",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(Icons.analytics_outlined,
                                size: 20, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    }
    return Wrap(
      runSpacing: 10,
      spacing: 10,
      children: [
        countsGrid,
        LeadGraphBarChart(
          leadData: widget.leadConversionData,
        ),
        ConversionGraphBarChart(
          leadData: widget.leadConversionData,
        ),
        LeadDistributionPieChart(
          leadData: widget.leadConversionData,
        ),
        LeadEnquiryForReportCard(
          dashboardProvider: widget.dashBoardProvider,
        ),

        WeeklyReportCard(
          isLeadOverView: true,
          data: widget.pieData,
          dashboardProvider: widget.dashBoardProvider,
        ),
        // Container(
        //   padding: const EdgeInsets.all(10),
        //   decoration: BoxDecoration(boxShadow: const [
        //     BoxShadow(color: Colors.black12, blurRadius: 5)
        //   ], color: Colors.white, borderRadius: BorderRadius.circular(18)),
        //   constraints: const BoxConstraints(
        //       minWidth: 100, maxWidth: 1650, minHeight: 300, maxHeight: 370),
        //   child: ListView(
        //     children: [
        //       Row(
        //         children: [
        //           Text(
        //             'Follow-Up Summary',
        //             style: AppStyles.getBodyTextStyle(
        //                 fontSize: 14, fontColor: Colors.grey.shade400),
        //           ),
        //           // const Spacer(),
        //           // Expanded(
        //           //   child: TextField(
        //           //     decoration: InputDecoration(
        //           //       border: OutlineInputBorder(
        //           //         borderRadius: BorderRadius.circular(16),
        //           //       ),
        //           //       prefixIcon: const Icon(Icons.search),
        //           //       hintText: "Search here...",
        //           //     ),
        //           //   ),
        //           // ),
        //         ],
        //       ),
        //       // const SizedBox(height: 15),
        //       Padding(
        //         padding: const EdgeInsets.all(16.0),
        //         child: Container(
        //           decoration: BoxDecoration(
        //             color: Colors.white,
        //             borderRadius: BorderRadius.circular(14),
        //           ),
        //           child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: Column(
        //               children: [
        //                 Container(
        //                   decoration: BoxDecoration(
        //                     color: const Color(0xFFEFF2F5),
        //                     borderRadius: BorderRadius.circular(8),
        //                   ),
        //                   child: Row(
        //                     children: [
        //                       if (MediaQuery.of(context).size.width > 700) ...[
        //                         const SizedBox(
        //                           width: 80,
        //                           child: Padding(
        //                             padding: EdgeInsets.symmetric(
        //                                 vertical: 12.0, horizontal: 25.0),
        //                             child: Text('Sl No.',
        //                                 style: TextStyle(
        //                                     fontWeight: FontWeight.bold,
        //                                     color: Color(0xFF607185))),
        //                           ),
        //                         ),
        //                         const TableWidget(
        //                             flex: 3,
        //                             title: 'Employee name',
        //                             color: Color(0xFF607185)),
        //                         const TableWidget(
        //                             flex: 1,
        //                             title: 'Assigned',
        //                             color: Color(0xFF607185)),
        //                         const TableWidget(
        //                             flex: 2,
        //                             title: 'Pending',
        //                             color: Color(0xFF607185)),
        //                         const TableWidget(
        //                             flex: 1,
        //                             title: 'Completed',
        //                             color: Color(0xFF607185)),
        //                         const TableWidget(
        //                             flex: 1,
        //                             title: 'Performance Rate',
        //                             color: Color(0xFF607185)),
        //                       ] else ...[
        //                         const Expanded(
        //                           child: Padding(
        //                             padding: EdgeInsets.all(12.0),
        //                             child: Row(
        //                               mainAxisAlignment:
        //                                   MainAxisAlignment.spaceBetween,
        //                               children: [
        //                                 Text('Employee',
        //                                     style: TextStyle(
        //                                         fontWeight: FontWeight.bold,
        //                                         color: Color(0xFF607185))),
        //                                 Text('Stats',
        //                                     style: TextStyle(
        //                                         fontWeight: FontWeight.bold,
        //                                         color: Color(0xFF607185))),
        //                               ],
        //                             ),
        //                           ),
        //                         ),
        //                       ],
        //                     ],
        //                   ),
        //                 ),
        //                 ListView.builder(
        //                   shrinkWrap: true,
        //                   physics: const NeverScrollableScrollPhysics(),
        //                   itemCount: followUpLeadData.length,
        //                   itemBuilder: (context, index) {
        //                     return Container(
        //                       decoration: BoxDecoration(
        //                         color: index % 2 == 0
        //                             ? Colors.white
        //                             : const Color(0xFFF6F7F9),
        //                         borderRadius: BorderRadius.circular(8),
        //                       ),
        //                       child: MediaQuery.of(context).size.width > 700
        //                           ? _buildDesktopRow(
        //                               context, index, followUpLeadData)
        //                           : _buildMobileRow(
        //                               context, index, followUpLeadData),
        //                     );
        //                   },
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildDesktopRow(BuildContext context, int index,
      List<FollowUpSummaryModel> followUpLeadData) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 25.0),
            child: Text("${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                )),
          ),
        ),
        TableWidget(
          flex: 3,
          data: _buildEmployeeCell(context, index, followUpLeadData),
        ),
        TableWidget(flex: 1, title: followUpLeadData[index].total.toString()),
        TableWidget(
          flex: 2,
          title: followUpLeadData[index].pending,
        ),
        TableWidget(
          flex: 1,
          title: followUpLeadData[index].completed,
        ),
        TableWidget(
          flex: 1,
          title: '${followUpLeadData[index].performanceRate}%',
        ),
      ],
    );
  }

  Widget _buildMobileRow(BuildContext context, int index,
      List<FollowUpSummaryModel> followUpLeadData) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEmployeeCell(context, index, followUpLeadData,
                    isMobile: true),
                const SizedBox(height: 4),
                Text(
                  followUpLeadData[index].toUserName ?? '',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Assigned: ${followUpLeadData[index].total}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Pending: ${followUpLeadData[index].pending}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Rate: ${followUpLeadData[index].performanceRate}%',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCell(BuildContext context, int index,
      List<FollowUpSummaryModel> followUpLeadData,
      {bool isMobile = false}) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF1),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/lead_profile.png',
              width: 15,
              height: 15,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                followUpLeadData[index].toUserName ?? '',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 13 : 14,
                ),
              ),
            ),
            if (!isMobile) ...[
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/forward.png',
                width: 12,
                height: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
