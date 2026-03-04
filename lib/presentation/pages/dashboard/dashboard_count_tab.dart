import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_data_page.dart';

class DashboardCountTab extends StatelessWidget {
  final DashboardProvider dashBoardProvider;

  const DashboardCountTab({
    super.key,
    required this.dashBoardProvider,
  });

  Color _colorForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('new_leads')) return const Color(0xFFBAC5D0);
    if (t.contains('followup')) return const Color(0xFF90A1D6);
    if (t.contains('closed')) return const Color(0xFF9CC9BF);
    if (t.contains('called')) return const Color(0xFF8699C9);
    if (t.contains('transferred')) return const Color(0xFF9ABDE2);
    if (t.contains('missed')) return const Color(0xFFDEB0B9);
    return Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    if (dashBoardProvider.isDashBoardLoading) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (dashBoardProvider.leadCountMap.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    // Only render the required keys if they exist in the map
    final allowedKeys = [
      'New_Leads',
      'Missed_Leads',
      'Pending_Followups',
      'Transferred_Leads'
    ];
    final items = dashBoardProvider.leadCountMap.entries
        .where((e) => allowedKeys.contains(e.key))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2; // Default to 2 for mobile
          if (constraints.maxWidth > 800) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          final double spacing = 16.0;
          final double availableWidth =
              constraints.maxWidth - (spacing * (crossAxisCount - 1));
          final double itemWidth = availableWidth / crossAxisCount;
          // Target height to prevent overflow while keeping the design clean
          final double itemHeight = 140.0;
          final double aspectRatio = itemWidth / itemHeight;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: aspectRatio,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              final String keyword = item.key;
              final int count = item.value;
              final color = _colorForTitle(keyword);

              final displayTitle = keyword
                  .replaceAll('_', ' ')
                  .split(' ')
                  .map((w) =>
                      w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
                  .join(' ');

              String apiKeyword = keyword.toLowerCase();
              if (keyword == 'Pending_Followups') {
                apiKeyword = 'pending_followup';
              } else if (keyword == 'Transferred_Leads') {
                apiKeyword = 'transffered_leads';
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadDataPage(
                        source: apiKeyword,
                        fromDate: dashBoardProvider.formattedFromDate,
                        toDate: dashBoardProvider.formattedToDate,
                        user: dashBoardProvider.selectedUser,
                      ),
                    ),
                  );
                },
                child: Container(
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
                              displayTitle,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
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
                        count.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "View Leads",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
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
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.analytics_outlined,
                                size: 18, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
