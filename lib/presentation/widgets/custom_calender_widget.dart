import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vidyanexis/utils/extensions.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({
    super.key,
    required this.onApplyDateTapped,
    this.onCancelDateTapped,
    required this.startYear,
    required this.endYear,
    this.isMultiSelectEnabled = true,
    this.decoration,
  });
  final Function(dynamic date) onApplyDateTapped;
  final Function()? onCancelDateTapped;
  final int startYear;
  final int endYear;
  final bool isMultiSelectEnabled;
  final CustomCalenderDecoration? decoration;
  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late PageController _pageController;
  late DateTime _currentMonth;
  DateTime? _firstSelectedDate;
  DateTime? _secondSelectedDate;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  int selectedOptionIndex = -1;
  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
    int initialPage =
        (_currentMonth.year - widget.startYear) * 12 + _currentMonth.month - 1;
    _pageController = PageController(initialPage: initialPage);
  }

  List<String> optionButtons = ['Today', 'This week', 'This Month', 'Custom'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose date',
              style: AppStyles.getBoldTextStyle(
                  fontSize: 12, fontColor: AppColors.textGrey4),
            ),
            SizedBox(height: 8),
            if (widget.isMultiSelectEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  optionButtons.length,
                  (index) => InkWell(
                    onTap: () => _handleOptionSelection(index),
                    child: Container(
                      margin: const EdgeInsets.only(right: 7),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: selectedOptionIndex == index
                            ? AppColors.buttonBackgroundColor.withOpacity(0.5)
                            : Colors.transparent,
                        border: Border.all(
                          color: selectedOptionIndex == index
                              ? AppColors.buttonBackgroundColor
                              : AppColors.grey,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        optionButtons[index],
                        style: AppStyles.getBoldTextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.isMultiSelectEnabled || _firstSelectedDate != null)
              SizedBox(height: 16),
            if (widget.isMultiSelectEnabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_firstSelectedDate != null)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          _firstSelectedDate.toString().toDayMonthYearFormat(),
                          style: AppStyles.getBoldTextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  SizedBox(width: 8),
                  if (_secondSelectedDate != null)
                    SvgPicture.asset('assets/icons/arrow_right.svg'),
                  SizedBox(width: 8),
                  if (_secondSelectedDate != null)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.grey300,
                            borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          _secondSelectedDate.toString().toDayMonthYearFormat(),
                          style: AppStyles.getBoldTextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              )
            else if (_firstSelectedDate != null)
              Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(
                  _firstSelectedDate.toString().toDayMonthYearFormat(),
                  style: AppStyles.getBoldTextStyle(fontSize: 14),
                ),
              ),
            SizedBox(height: 12),
            _buildHeader(),
            _buildWeeks(),
            AspectRatio(
              aspectRatio: 1.5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    int year = widget.startYear + index ~/ 12;
                    int month = (index % 12) + 1;
                    _currentMonth = DateTime(year, month, 1);
                  });
                },
                itemCount: (widget.endYear - widget.startYear + 1) * 12,
                itemBuilder: (context, pageIndex) {
                  int year = widget.startYear + pageIndex ~/ 12;
                  int month = (pageIndex % 12) + 1;
                  return buildCalendar(DateTime(year, month, 1));
                },
              ),
            ),
            SizedBox(height: 8),
            Divider(color: AppColors.grey),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(
                          color: AppColors.grey,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () => widget.onCancelDateTapped,
                    child: Text(
                      'Cancel',
                      style: AppStyles.getBoldTextStyle(fontSize: 12),
                    )),
                SizedBox(width: 10),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.bluebutton,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    onPressed: () {
                      if (widget.isMultiSelectEnabled) {
                        widget.onApplyDateTapped
                            .call([_firstSelectedDate, _secondSelectedDate]);
                      } else {
                        widget.onApplyDateTapped.call(_firstSelectedDate);
                      }
                    },
                    child: Text('Apply'))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: SvgPicture.asset('assets/icons/arrow_left.svg'),
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
          GestureDetector(
            onTap: () => onClickMonthAndYear(),
            child: Text(
              DateFormat('MMMM yyyy').format(_currentMonth),
              style: AppStyles.getBodyTextStyle(fontSize: 12),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/arrow_right.svg'),
            onPressed: () {
              _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeeks() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
            .map((day) =>
                Text(day, style: AppStyles.getBoldTextStyle(fontSize: 12)))
            .toList(),
      ),
    );
  }

  Widget buildCalendar(DateTime month) {
    int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    DateTime firstDayOfMonth = DateTime(month.year, month.month, 1);
    int weekdayOfFirstDay =
        firstDayOfMonth.weekday % 7; // Now Sunday = 0, Monday = 1

    int totalCells = daysInMonth + weekdayOfFirstDay;

    return GridView.builder(
      // padding: EdgeInsets.zero,
      shrinkWrap: true,
      addRepaintBoundaries: false,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.3,
        crossAxisSpacing: 0,
        mainAxisSpacing: 3,
      ),
      itemCount: totalCells,
      itemBuilder: (context, index) {
        if (index < weekdayOfFirstDay) {
          return const SizedBox();
        }

        DateTime date =
            DateTime(month.year, month.month, index - weekdayOfFirstDay + 1);
        bool isSelected = (_firstSelectedDate != null &&
                isSameDate(_firstSelectedDate!, date)) ||
            (_secondSelectedDate != null &&
                isSameDate(_secondSelectedDate!, date));

        bool isBetween = _firstSelectedDate != null &&
            _secondSelectedDate != null &&
            date.isAfter(_firstSelectedDate!) &&
            date.isBefore(_secondSelectedDate!);

        bool isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        return InkWell(
          onTap: () {
            setState(() {
              if (!widget.isMultiSelectEnabled) {
                _firstSelectedDate = date;
                _secondSelectedDate = null;
              } else {
                if (_firstSelectedDate == null || _secondSelectedDate != null) {
                  _firstSelectedDate = date;
                  _secondSelectedDate = null;
                } else {
                  _secondSelectedDate = date.isAfter(_firstSelectedDate!)
                      ? date
                      : _firstSelectedDate;
                  _firstSelectedDate = date.isAfter(_firstSelectedDate!)
                      ? _firstSelectedDate
                      : date;
                }
              }
            });
          },
          child: Container(
            // margin: !isBetween ? null : const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isBetween
                  ? 0
                  : widget.decoration?.selectedDateBorderRadius ?? 4),
              color: isSelected
                  ? widget.decoration?.selectedDateColor ?? Colors.blue
                  : isBetween
                      ? widget.decoration?.trackColor ?? Colors.lightBlueAccent
                      : Colors.white,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: AppStyles.getBoldTextStyle(
                    fontSize: 12,
                    fontColor: isSelected ? Colors.white : Colors.black,
                  ),
                ),
                if (isToday)
                  Container(
                    height: 3,
                    width: 5,
                    decoration: BoxDecoration(
                        color:
                            widget.decoration?.currentDateColor ?? Colors.black,
                        shape: BoxShape.circle),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  onClickMonthAndYear() {
    _selectedMonth = _currentMonth.month;
    _selectedYear = _currentMonth.year;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (c, set) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: "Month"),
                          Tab(text: "Year"),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 5,
                                children: List.generate(
                                  12,
                                  (index) => ActionChip(
                                    backgroundColor: _selectedMonth == index + 1
                                        ? AppColors.darkBlue
                                        : AppColors.buttonBackgroundColor
                                            .withOpacity(0.1),
                                    surfaceTintColor: Colors.white,
                                    side: BorderSide.none,
                                    onPressed: () =>
                                        set(() => _selectedMonth = index + 1),
                                    label: Text(
                                      DateFormat.MMMM().format(
                                        DateTime(0, index + 1),
                                      ),
                                      style: AppStyles.getBoldTextStyle(
                                          fontSize: 13,
                                          fontColor: _selectedMonth == index + 1
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: SingleChildScrollView(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 5,
                                  children: List.generate(
                                      widget.endYear - widget.startYear + 1,
                                      (index) {
                                    int year = widget.startYear + index;
                                    return ActionChip(
                                      backgroundColor: _selectedYear == year
                                          ? AppColors.darkBlue
                                          : AppColors.buttonBackgroundColor
                                              .withOpacity(0.1),
                                      surfaceTintColor: Colors.white,
                                      side: BorderSide.none,
                                      label: Text(
                                        "$year",
                                        style: AppStyles.getBoldTextStyle(
                                            fontSize: 13,
                                            fontColor: _selectedYear == year
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                      onPressed: () =>
                                          set(() => _selectedYear = year),
                                    );
                                  }),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentMonth = DateTime(_selectedYear, _selectedMonth, 1);
                  int newPage = (_selectedYear - widget.startYear) * 12 +
                      _selectedMonth -
                      1;
                  _pageController.jumpToPage(newPage);
                });
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      }),
    );
  }

  void _handleOptionSelection(int index) {
    DateTime now = DateTime.now();

    // 🔹 Ensure the week starts on Sunday
    DateTime firstDayOfWeek = now.subtract(Duration(days: now.weekday % 7));
    DateTime lastDayOfWeek = firstDayOfWeek.add(const Duration(days: 6));

    // 🔹 Correct first and last day of the month
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    setState(() {
      selectedOptionIndex = index;
      DateTime targetDate = now;

      switch (index) {
        case 0: // Today
          _firstSelectedDate = now;
          _secondSelectedDate = null;
          targetDate = now;
          break;

        case 1: // This Week (Fix: Ensure full Sunday-Saturday selection)
          _firstSelectedDate = firstDayOfWeek;
          _secondSelectedDate = lastDayOfWeek;
          targetDate = firstDayOfWeek;
          break;

        case 2: // This Month
          _firstSelectedDate = firstDayOfMonth;
          _secondSelectedDate = lastDayOfMonth;
          targetDate = firstDayOfMonth;
          break;

        case 3: // Custom
          _firstSelectedDate = null;
          _secondSelectedDate = null;
          return;
      }

      // 🔹 Jump to the correct month
      int pageIndex =
          (targetDate.year - widget.startYear) * 12 + targetDate.month - 1;
      _pageController.jumpToPage(pageIndex);
    });

    // 🔹 Notify callback with both dates correctly
    // if (widget.isMultiSelectEnabled) {
    //   widget.onDateTapped?.call([_firstSelectedDate!, _secondSelectedDate!]);
    // } else {
    //   widget.onDateTapped?.call(_firstSelectedDate!);
    // }
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
// Example Usage
/*CustomCalendarWidget(
          decoration: CustomCalenderDecoration(
            selectedDateColor: AppColors.primaryBlue,
            trackColor: AppColors.lightBlueColor2
          ),
          onApplyDateTapped: (date){
            print(date);
          },
          startYear: 2000,
          endYear: 2050,
        )); */

class CustomCalenderDecoration {
  final Color? selectedDateColor;
  final Color? trackColor;
  final Color? currentDateColor;
  final double? selectedDateBorderRadius;

  CustomCalenderDecoration({
    this.selectedDateColor,
    this.trackColor,
    this.currentDateColor,
    this.selectedDateBorderRadius,
  });
}
