import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/dashboard/lead_data_page.dart';

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
        'Upcoming_Followup',
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
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 2; // Default to 2 for mobile
          if (constraints.maxWidth > 800) {
            crossAxisCount = 4;
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 3;
          }

          final double spacing = 12.0;
          final double availableWidth =
              constraints.maxWidth - (spacing * (crossAxisCount - 1));
          final double itemWidth = availableWidth / crossAxisCount;
          // Target height to match the premium design (taller than before)
          final double itemHeight = 120.0;
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
              final theme = _getCardTheme(index);

              return _DashboardCard(
                keyword: keyword,
                count: count,
                theme: theme,
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

  _CardTheme _getCardTheme(int index) {
    final themes = [
      _CardTheme(const Color(0xFFE9EAFB), const Color(0xFF7B61FF)), // Purple
      _CardTheme(const Color(0xFFFFF1E8), const Color(0xFFFF9D6E)), // Orange
      _CardTheme(const Color(0xFFE6F5FF), const Color(0xFF63B3ED)), // Blue
      _CardTheme(const Color(0xFFEDF7ED), const Color(0xFF48BB78)), // Green
      _CardTheme(const Color(0xFFFCE4EC), const Color(0xFFF06292)), // Rose
      _CardTheme(const Color(0xFFFFF9C4), const Color(0xFFFBC02D)), // Amber
    ];
    return themes[index % themes.length];
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
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
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
  final Color background;
  final Color accent;
  _CardTheme(this.background, this.accent);
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

  @override
  Widget build(BuildContext context) {
    final String displayTitle = widget.keyword
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
        .join(' ');

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.background,
              borderRadius: BorderRadius.circular(4),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.theme.accent.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Wave Graphic
                Positioned(
                  right: -10,
                  top: 20,
                  bottom: 20,
                  width: 60,
                  child: CustomPaint(
                    painter: _WavePainter(color: widget.theme.accent),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.count.toString(),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.black.withOpacity(0.3),
                          size: 24,
                        ),
                      ),
                    ],
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

class _WavePainter extends CustomPainter {
  final Color color;
  _WavePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    double midY = size.height / 2;
    double amplitude = 15;
    double frequency = 0.1;

    path.moveTo(0, midY);
    for (double x = 0; x <= size.width; x++) {
      double y = midY +
          amplitude *
              1.5 *
              (0.5 * (1 + (x / size.width))) *
              (x / size.width % 0.5 == 0 ? 1 : 0.8);
      // Let's draw a more "organic" wave like in the image
      y = midY +
          amplitude *
              ((x < size.width * 0.2)
                  ? (x / (size.width * 0.2))
                  : (x < size.width * 0.5)
                      ? (1 - (x - size.width * 0.2) / (size.width * 0.3))
                      : (x < size.width * 0.8)
                          ? (-(x - size.width * 0.5) / (size.width * 0.3))
                          : (-1 + (x - size.width * 0.8) / (size.width * 0.2)));
      // Wait, simple sine is better
    }

    // Drawing a stylized wave line
    path.reset();
    path.moveTo(0, midY);
    path.cubicTo(size.width * 0.25, midY - amplitude, size.width * 0.5,
        midY + amplitude, size.width * 0.75, midY - amplitude * 0.5);
    path.quadraticBezierTo(
        size.width, midY + amplitude * 0.2, size.width, midY);

    canvas.drawPath(path, paint);

    // Draw a second wave for more detail
    final paint2 = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path2 = Path();
    path2.moveTo(0, midY + 5);
    path2.cubicTo(size.width * 0.3, midY + 5 - amplitude, size.width * 0.6,
        midY + 5 + amplitude, size.width * 0.9, midY + 5 - amplitude * 0.3);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
