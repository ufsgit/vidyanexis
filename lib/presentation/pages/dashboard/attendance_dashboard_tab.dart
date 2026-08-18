import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:vidyanexis/controller/dashboard_provider.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceDashboardTab extends StatelessWidget {
  final DashboardProvider dashBoardProvider;

  const AttendanceDashboardTab({
    super.key,
    required this.dashBoardProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (dashBoardProvider.attendanceCountMap.isEmpty &&
        dashBoardProvider.isDashBoardLoading) {
      return _buildSkeleton(context);
    }

    if (dashBoardProvider.attendanceCountMap.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(
          child: Text('No data available'),
        ),
      );
    }

    // Keys the user expects based on typical response or requirement:
    // • Present Staff
    // • Absent Staff
    // • Login Status
    // • Late Login Report
    // We will display whatever keys the API returns since attendanceCountMap contains the data.
    final items = dashBoardProvider.attendanceCountMap.entries.toList();
    
    // Move 'login_status' to the front if it exists
    final loginStatusIndex = items.indexWhere((item) => item.key.toLowerCase() == 'login_status');
    if (loginStatusIndex != -1) {
      final loginStatusItem = items.removeAt(loginStatusIndex);
      items.insert(0, loginStatusItem);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      dashBoardProvider.getSearchAdminDashboard(keyword);
                    },
                    isSelected: dashBoardProvider.selectedAttendanceKeyword == keyword,
                  );
                },
              );
            },
          ),
        ),
        if (dashBoardProvider.selectedAttendanceKeyword != null) ...[
          const SizedBox(height: 16),
          _buildDetailsSection(context, dashBoardProvider),
        ],
      ],
    );
  }

  Widget _buildDetailsSection(BuildContext context, DashboardProvider provider) {
    if (provider.isAttendanceDetailsLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final details = provider.attendanceDetails;
    if (details.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
        ),
        child: const Center(child: Text('No details found for selected item.')),
      );
    }

    // Extract columns dynamically from the first item
    final firstItem = details.first as Map<String, dynamic>;
    final columns = firstItem.keys.where((key) => key != 'user_details_id').toList();

    final double calculatedHeight = 56.0 + (details.length * 48.0) + 20.0;
    
    // Calculate max height based on available screen space to eliminate blank space
    final double topOffset = 290.0; // Approximate space taken by header and top cards
    final double availableHeight = MediaQuery.of(context).size.height - topOffset;
    final double maxHeight = availableHeight > 350.0 ? availableHeight : 350.0;
    
    final double tableHeight = calculatedHeight > maxHeight ? maxHeight : calculatedHeight;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.0),
      ),
      height: tableHeight, // Bounded height enables internal scrolling
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: columns.length * 120.0,
        headingRowColor: MaterialStateProperty.all(AppColors.primaryBlue.withOpacity(0.1)),
        headingTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
          fontSize: 13,
        ),
        dataTextStyle: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.black87,
        ),
        columns: columns.map((col) {
          final displayTitle = col
              .replaceAll('_', ' ')
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : w)
              .join(' ');
          return DataColumn2(
            label: Text(displayTitle),
            size: ColumnSize.L,
          );
        }).toList(),
        rows: details.map((item) {
          final mapItem = item as Map<String, dynamic>;
          return DataRow(
            cells: columns.map((col) {
              final val = mapItem[col];
              if (col.toLowerCase() == 'status') {
                return DataCell(_buildStatusBadge(val?.toString() ?? '-', mapItem, provider));
              }
              return DataCell(
                Text(val?.toString() ?? '-'),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(String status, Map<String, dynamic> mapItem, DashboardProvider provider) {
    if (status == '-') return const Text('-');

    Color bgColor;
    Color textColor;

    final s = status.toLowerCase();
    
    bool isLate = false;
    if (s.contains('on time') || s.contains('present')) {
      final userName = (mapItem['Staff'] ?? mapItem['User Details Name'])?.toString().trim().toLowerCase();
      if (userName != null && userName.isNotEmpty && provider.loginStatusDetails.isNotEmpty) {
        final loginRecord = provider.loginStatusDetails.firstWhere(
          (r) {
            if (r is! Map) return false;
            final rName = (r['Staff'] ?? r['User Details Name'])?.toString().trim().toLowerCase();
            return rName == userName;
          },
          orElse: () => null,
        );
        if (loginRecord != null) {
          final originalStatus = loginRecord['Status']?.toString().toLowerCase();
          if (originalStatus != null && originalStatus.contains('late')) {
            isLate = true;
          }
        }
      }
    }

    if (isLate || s.contains('late')|| s.contains('present')) {
      bgColor = const Color(0xFFF4E6F8);
      textColor = const Color(0xFF9E40B5);
    } else if (s.contains('on time') || s.contains('present')) {
      bgColor = const Color(0xFFE5F7ED); 
      textColor = const Color(0xFF16A34A);
    } else if (s.contains('checkout')) {
      bgColor = const Color(0xFFE6F3FE);
      textColor = const Color(0xFF2E95E8);
    } else if (s.contains('absent')) {
      bgColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFEF4444);
    } else {
      bgColor = Colors.grey.shade100;
      textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
        itemCount: 4,
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
  final bool isSelected;

  const _DashboardCard({
    required this.keyword,
    required this.count,
    required this.theme,
    required this.onTap,
    this.isSelected = false,
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
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            decoration: BoxDecoration(
              color: widget.theme.background,
              borderRadius: BorderRadius.circular(4),
              border: widget.isSelected ? Border.all(color: widget.theme.accent, width: 2) : null,
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

    // Drawing a stylized wave line
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
