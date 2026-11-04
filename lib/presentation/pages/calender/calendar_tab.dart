import 'package:flutter/material.dart';
import 'package:vidyanexis/constants/app_colors.dart';
import 'package:vidyanexis/constants/app_styles.dart';
import 'package:vidyanexis/controller/calendar_tab_provider.dart';
import 'package:vidyanexis/controller/settings_provider.dart';
import 'package:vidyanexis/presentation/pages/calender/add_calendar_tab.dart';
import 'package:vidyanexis/presentation/widgets/home/confirmation_dialog_widget.dart';
import 'package:vidyanexis/presentation/widgets/home/custom_outlined_icon_button_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalendarTabPage extends StatefulWidget {
  final String customerId;

  const CalendarTabPage({super.key, required this.customerId});

  @override
  State<CalendarTabPage> createState() => _CalendarTabPageState();
}

class _CalendarTabPageState extends State<CalendarTabPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final calendarProvider =
          Provider.of<CalendarTabProvider>(context, listen: false);
      calendarProvider.getCalendarByCustomer(widget.customerId, context);
    });
  }

  String _formatDate(String raw) {
    try {
      final d = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy').format(d);
    } catch (_) {
      return raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = Provider.of<CalendarTabProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isWeb = AppStyles.isWebScreen(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 16 : 10,
          vertical: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Calendar',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const Spacer(),
                if (isWeb && settingsProvider.menuIsSaveMap[234] == 1)
                  CustomOutlinedSvgButton(
                    onPressed: () {
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => AddCalendarTab(
                          isEdit: false,
                          editId: '0',
                          customerId: widget.customerId,
                        ),
                      );
                    },
                    svgPath: 'assets/images/Plus.svg',
                    label: 'Add Calendar',
                    breakpoint: 860,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.white,
                    backgroundColor: AppColors.primaryBlue,
                    borderSide: BorderSide(color: AppColors.primaryBlue),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: calendarProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : calendarProvider.calendarList.isEmpty
                      ? _EmptyState()
                      : ListView.separated(
                          itemCount: calendarProvider.calendarList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = calendarProvider.calendarList[index];
                            return _CalendarCard(
                              name: entry.name,
                              itemCount: entry.items.length,
                              itemsPreview: entry.items
                                  .take(3)
                                  .map((i) =>
                                      '${_formatDate(i.date)} · ${i.description}')
                                  .toList(),
                              onEdit: settingsProvider.menuIsEditMap[234] == 1
                                  ? () {
                                      showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (_) => AddCalendarTab(
                                          isEdit: true,
                                          editId: entry.calendarId,
                                          customerId: widget.customerId,
                                        ),
                                      );
                                    }
                                  : null,
                              onDelete:
                                  settingsProvider.menuIsDeleteMap[234] == 1
                                      ? () {
                                          showConfirmationDialog(
                                            isLoading: false,
                                            context: context,
                                            title: 'Confirm Deletion',
                                            content:
                                                'Are you sure you want to delete this calendar?',
                                            onCancel: () {
                                              Navigator.of(context).pop();
                                            },
                                            onConfirm: () async {
                                              calendarProvider.deleteCalendar(
                                                entry.calendarId,
                                                widget.customerId,
                                                context,
                                              );
                                            },
                                            confirmButtonText: 'Delete',
                                          );
                                        }
                                      : null,
                              onPrint: () async {
                                await calendarProvider.getCalendarItemPdf(
                                    widget.customerId,
                                    entry.calendarId,
                                    context);
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: isWeb
          ? null
          : (settingsProvider.menuIsSaveMap[234] == 1
              ? FloatingActionButton.extended(
                  onPressed: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) => AddCalendarTab(
                        isEdit: false,
                        editId: '0',
                        customerId: widget.customerId,
                      ),
                    );
                  },
                  backgroundColor: AppColors.primaryBlue,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(
                    'Add Calendar',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : null),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final String name;
  final int itemCount;
  final List<String> itemsPreview;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPrint;

  const _CalendarCard({
    required this.name,
    required this.itemCount,
    required this.itemsPreview,
    this.onEdit,
    this.onDelete,
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue,
                        AppColors.primaryBlue.withOpacity(0.75),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.calendar_today_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.inter(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$itemCount item${itemCount == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onPrint != null)
                  IconButton(
                    onPressed: onPrint,
                    icon: Icon(Icons.print,
                        size: 20, color: AppColors.primaryBlue),
                    splashRadius: 20,
                    tooltip: 'Print',
                    visualDensity: VisualDensity.compact,
                  ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.primaryBlue),
                    splashRadius: 20,
                    tooltip: 'Edit',
                    visualDensity: VisualDensity.compact,
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    splashRadius: 20,
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (itemsPreview.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              ...itemsPreview.map((preview) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            preview,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: Colors.grey.shade700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
              if (itemCount > 3)
                Text(
                  '+ ${itemCount - 3} more',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.calendar_month_outlined,
                size: 48, color: AppColors.primaryBlue.withOpacity(0.7)),
          ),
          const SizedBox(height: 20),
          Text(
            'No calendars yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create a calendar for this customer.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
