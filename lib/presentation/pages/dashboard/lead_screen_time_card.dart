import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/constants/app_colors.dart';

class LeadScreenTimeCard<T> extends StatefulWidget {
  final List<T> data;
  final String title;
  final num Function(T) valueExtractor;
  final String Function(T) nameExtractor;

  const LeadScreenTimeCard({
    super.key,
    required this.data,
    this.title = 'Lead Graph',
    required this.valueExtractor,
    required this.nameExtractor,
  });

  @override
  State<LeadScreenTimeCard<T>> createState() => _LeadScreenTimeCardState<T>();
}

class _LeadScreenTimeCardState<T> extends State<LeadScreenTimeCard<T>> {
  bool _showAll = false;

  num get _maxCount {
    if (widget.data.isEmpty) return 1;
    return widget.data
        .map((e) => widget.valueExtractor(e))
        .reduce((a, b) => a > b ? a : b);
  }

  Color _getColorForIndex(int index) {
    final List<Color> colors = [
      const Color(0xFF4285F4), // Blue
      const Color(0xFF34A853), // Green
      const Color(0xFFFBBC05), // Yellow
      const Color(0xFFEA4335), // Red
      const Color(0xFF8E24AA), // Purple
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFFF4511E), // Deep Orange
      const Color(0xFF3949AB), // Indigo
    ];
    return colors[index % colors.length];
  }


  Widget _buildIcon(String name, Color color) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort descending by valueExtractor
    final sortedData = List<T>.from(widget.data)
      ..sort((a, b) => widget.valueExtractor(b).compareTo(widget.valueExtractor(a)));

    final itemCount = _showAll ? sortedData.length : (sortedData.length > 5 ? 5 : sortedData.length);
    final maxValue = _maxCount.toDouble();

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.title,
                    style: AppStyles.getBodyTextStyle(
                        fontSize: 14, fontColor: AppColors.textGrey3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(left: 56.0),
                child: Divider(color: Colors.grey.shade200, height: 1),
              ),
              itemBuilder: (context, index) {
                final item = sortedData[index];
                final name = widget.nameExtractor(item);
                final count = widget.valueExtractor(item);
                final percentage = maxValue > 0 ? (count / maxValue).clamp(0.0, 1.0) : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: _getColorForIndex(index).withOpacity(0.1),
                          child: _buildIcon(name, _getColorForIndex(index)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.isEmpty ? 'Unknown' : name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: percentage,
                                      minHeight: 6,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(_getColorForIndex(index)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (sortedData.length > 5) ...[
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    _showAll = !_showAll;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    _showAll ? 'Show Less' : 'Show More',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
