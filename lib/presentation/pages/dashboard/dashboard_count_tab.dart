import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_data_page.dart';
import 'package:vidyanexis/presentation/pages/dashboard/task_data_page.dart';

class DashboardCountTab extends StatelessWidget {
  final DashboardProvider dashBoardProvider;

  const DashboardCountTab({
    super.key,
    required this.dashBoardProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (dashBoardProvider.leadCountMap.isEmpty &&
        dashBoardProvider.isDashBoardLoading) {
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
      if (settingsProvider.menuIsViewMap[130] == 1 ||
          settingsProvider.menuIsViewMap[139] == 1)
        'Total_Leads',
      if (settingsProvider.menuIsViewMap[131] == 1 ||
          settingsProvider.menuIsViewMap[140] == 1)
        'Fresh_Leads',
      if (settingsProvider.menuIsViewMap[132] == 1 ||
          settingsProvider.menuIsViewMap[141] == 1)
        settingsProvider.newDashboardCount == 1
            ? 'Confirmed_Leads' // only for comorin
            : 'Upcoming_Followup',
      if (settingsProvider.menuIsViewMap[124] == 1 ||
          settingsProvider.menuIsViewMap[133] == 1)
        'New_Leads',
      if (settingsProvider.menuIsViewMap[125] == 1 ||
          settingsProvider.menuIsViewMap[134] == 1)
        'Missed_Leads',
      if (settingsProvider.menuIsViewMap[126] == 1 ||
          settingsProvider.menuIsViewMap[135] == 1)
        'Followup_Leads',
      if (settingsProvider.menuIsViewMap[127] == 1 ||
          settingsProvider.menuIsViewMap[136] == 1)
        'Not_Interested',
      if (settingsProvider.menuIsViewMap[128] == 1 ||
          settingsProvider.menuIsViewMap[137] == 1)
        'Transferred_Leads',
      if (settingsProvider.menuIsViewMap[129] == 1 ||
          settingsProvider.menuIsViewMap[138] == 1)
        'Completed_Leads',
      if (settingsProvider.menuIsViewMap[187] == 1) 'Total_Task',
    ];
    final items = dashBoardProvider.leadCountMap.entries
        .where((e) => allowedKeys.contains(e.key))
        .toList();

    return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2; // Mobile gets 2 cards per row
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4; // 4 cards per row for large screens (4, 4, 1)
          } else if (constraints.maxWidth > 900) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          final double spacing = 24.0;
          final double availableWidth =
              constraints.maxWidth - (spacing * (crossAxisCount - 1));
          final double itemWidth = availableWidth / crossAxisCount;
          
          final double aspectRatio = 2.4;

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
              final theme = _getCardThemeForKeyword(keyword);

              return _DashboardCard(
                keyword: keyword,
                count: count,
                theme: theme,
                onTap: () {
                  if (keyword == 'Total_Task') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TotalTaskDataPage(
                          fromDate: dashBoardProvider.formattedFromDate,
                          toDate: dashBoardProvider.formattedToDate,
                          user: dashBoardProvider.selectedUser,
                        ),
                      ),
                    );
                  } else {
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
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  _CardTheme _getCardThemeForKeyword(String keyword) {
    final purple = [const Color(0xFF7A5CFA), const Color(0xFF9070FF)];
    final emerald = [const Color(0xFF14A46B), const Color(0xFF26B87D)];
    final cyan = [const Color(0xFF009FD6), const Color(0xFF00BBEA)];
    final orange = [const Color(0xFFFF6D00), const Color(0xFFFF8E3C)];
    final red = [
      const Color(0xFFE11D48),
      const Color(0xFFF43F5E)
    ]; // Vibrant red for SLA critical

    switch (keyword) {
      case 'Total_Leads':
        return _CardTheme(purple, Icons.group_outlined);
      case 'Fresh_Leads':
        return _CardTheme(orange, Icons.bolt_outlined);
      case 'Missed_Leads':
        return _CardTheme(red, Icons.error_outline);
      case 'Completed_Leads':
        return _CardTheme(emerald, Icons.check_circle_outline);
      case 'Followup_Leads':
        return _CardTheme(cyan, Icons.calendar_today_outlined);
      case 'Upcoming_Followup':
        return _CardTheme(purple, Icons.access_time_outlined);
      case 'New_Leads':
        return _CardTheme(emerald, Icons.fiber_new_outlined);
      case 'Not_Interested':
        return _CardTheme(cyan, Icons.block_outlined);
      case 'Transferred_Leads':
        return _CardTheme(purple, Icons.swap_horiz_outlined);
      default:
        return _CardTheme(purple, Icons.insert_chart_outlined);
    }
  }

  Widget _buildSkeleton(BuildContext context) {
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
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

class _CardTheme {
  final List<Color> gradientColors;
  final IconData icon;
  _CardTheme(this.gradientColors, this.icon);
}

class _DashboardCard extends StatefulWidget {
  final String keyword;
  final int count;
  final _CardTheme theme;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.keyword,
    required this.count,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final String displayTitle =
        widget.keyword.replaceAll('_', ' ').toUpperCase();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : (_isHovered ? 1.05 : 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.theme.gradientColors,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.gradientColors.first.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary Metric
                    Text(
                      widget.count.toString(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Title
                    Text(
                      displayTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // Top-Right Icon Badge
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      widget.theme.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
