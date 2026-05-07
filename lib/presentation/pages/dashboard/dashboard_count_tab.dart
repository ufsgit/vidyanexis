import 'package:flutter/material.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_data_page.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';

class DashboardCountTab extends StatelessWidget {
  final DashboardProvider dashBoardProvider;

  const DashboardCountTab({
    super.key,
    required this.dashBoardProvider,
  });

  Color _colorForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('new_leads')) return const Color(0xFF007AFF); // Blue
    if (t.contains('followup')) return const Color(0xFFFF9500); // Orange
    if (t.contains('closed')) return const Color(0xFF34C759); // Green
    if (t.contains('called')) return const Color(0xFF5856D6); // Indigo
    if (t.contains('transferred')) return const Color(0xFF8E8E93); // Grey
    if (t.contains('missed')) return const Color(0xFFFF3B30); // Red
    if (t.contains('interested')) return const Color(0xFF3A3A3C); // Dark Grey
    if (t.contains('fresh_leads')) return const Color(0xFF5AC8FA); // Cyan
    if (t.contains('total_leads')) return const Color(0xFF5856D6); // Indigo
    if (t.contains('upcoming_followup')) return const Color(0xFFA2845E); // Brownish/Gold
    return Colors.grey.shade300;
  }

  IconData _iconForTitle(String title) {
    final t = title.toLowerCase();
    if (t.contains('total_leads')) return Icons.all_inbox_rounded;
    if (t.contains('fresh_leads')) return Icons.new_releases_rounded;
    if (t.contains('upcoming_followup')) return Icons.event_note_rounded;
    if (t.contains('new_leads')) return Icons.star_rounded;
    if (t.contains('missed_leads')) return Icons.call_missed_rounded;
    if (t.contains('followup_leads')) return Icons.history_rounded;
    if (t.contains('not_interested')) return Icons.thumb_down_rounded;
    if (t.contains('transferred_leads')) return Icons.move_to_inbox_rounded;
    if (t.contains('closed_leads')) return Icons.check_circle_rounded;
    return Icons.dashboard_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (dashBoardProvider.isDashBoardLoading &&
        dashBoardProvider.leadCountMap.isEmpty) {
      return _buildSkeleton(context);
    }

    if (dashBoardProvider.leadCountMap.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    final settingsProvider = Provider.of<SettingsProvider>(context);

    // Only render the required keys if they exist in the map
    final allowedKeys = [
      if (settingsProvider.menuIsViewMap[130] == 1) 'Total_Leads',
      if (settingsProvider.menuIsViewMap[131] == 1) 'Fresh_Leads',
      if (settingsProvider.menuIsViewMap[132] == 1) 'Upcoming_Followup',
      if (settingsProvider.menuIsViewMap[124] == 1) 'New_Leads',
      if (settingsProvider.menuIsViewMap[125] == 1) 'Missed_Leads',
      if (settingsProvider.menuIsViewMap[126] == 1) 'Followup_Leads',
      if (settingsProvider.menuIsViewMap[127] == 1) 'Not_Interested',
      if (settingsProvider.menuIsViewMap[128] == 1) 'Transferred_Leads',
      if (settingsProvider.menuIsViewMap[129] == 1) 'Closed_Leads',
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
          final double itemHeight = 100.0;
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

              return _DashboardCard(
                keyword: keyword,
                count: count,
                color: color,
                icon: _iconForTitle(keyword),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LeadDataPage(
                        source: keyword,
                        fromDate: dashBoardProvider.formattedFromDate,
                        toDate: dashBoardProvider.formattedToDate,
                        user: dashBoardProvider.selectedUser,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatefulWidget {
  final String keyword;
  final int count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.keyword,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final String displayTitle = widget.keyword
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');

    // Text color: White for maximum visibility
    final Color textColor = Colors.white;
    final Color iconBackgroundColor = Colors.white.withValues(alpha: 0.25);
    final Color hoverColor = Color.lerp(widget.color, Colors.black, 0.15)!;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: (_isHovered ? hoverColor : widget.color).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        widget.icon,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.count.toString(),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold, // Increased from w600
                    color: textColor,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
