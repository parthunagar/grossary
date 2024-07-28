import 'package:date_picker_timeline/date_widget.dart';
import 'package:date_picker_timeline/extra/color.dart';
import 'package:date_picker_timeline/extra/style.dart';
import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vendor/Components/custom_date_widget.dart';
import 'package:vendor/Theme/colors.dart';

class CustomDatePicker extends StatefulWidget {
  final DateTime startDate,initialSelectedDate;
  final double width,height;
  final CustomDatePickerController customController;
  final Color selectedTextColor,selectionColor,deactivatedColor;
  final TextStyle monthTextStyle,dayTextStyle,dateTextStyle;
  final List<DateTime> inactiveDates,activeDates;
  final DateChangeListener onDateChange;
  final int daysCount;
  final String locale;

  CustomDatePicker(
    this.startDate, {
    Key key,
    this.width = 60,
    this.height = 80,
    this.customController,
    this.monthTextStyle = defaultMonthTextStyle,
    this.dayTextStyle = defaultDayTextStyle,
    this.dateTextStyle = defaultDateTextStyle,
    this.selectedTextColor = Colors.white,
    this.selectionColor = AppColors.defaultSelectionColor,
    this.deactivatedColor = AppColors.defaultDeactivatedColor,
    this.initialSelectedDate,
    this.activeDates,
    this.inactiveDates,
    this.daysCount = 500,
    this.onDateChange,
    this.locale = "en_US",
  }) : assert(
      activeDates == null || inactiveDates == null,
      "Can't "
      "provide both activated and deactivated dates List at the same time.");

  @override
  State<StatefulWidget> createState() => new _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _currentDate;
  ScrollController _controller = ScrollController();
  TextStyle selectedDateStyle,selectedMonthStyle,selectedDayStyle,deactivatedDateStyle,deactivatedMonthStyle,deactivatedDayStyle;

  @override
  void initState() {
    initializeDateFormatting(widget.locale, null);
    _currentDate = widget.initialSelectedDate;

    if (widget.customController != null) {
      widget.customController.setDatePickerState(this);
    }

    this.selectedDateStyle = createTextStyle(TextStyle(color: kWhiteColor,fontSize: 24,fontWeight: FontWeight.w700), null);
    this.selectedMonthStyle = createTextStyle(TextStyle(color: kWhiteColor,fontSize: 12,fontWeight: FontWeight.w700), null);
    this.selectedDayStyle = createTextStyle(TextStyle(color: kTextBlack,fontSize: 12,fontWeight: FontWeight.w700), null);
    this.deactivatedDateStyle = createTextStyle(widget.dateTextStyle, widget.deactivatedColor);
    this.deactivatedMonthStyle = createTextStyle(widget.monthTextStyle, widget.deactivatedColor);
    this.deactivatedDayStyle = createTextStyle(widget.dayTextStyle, widget.deactivatedColor);

    super.initState();
  }

  TextStyle createTextStyle(TextStyle style, Color color) {
    if (color != null) {
      return TextStyle(color: color, fontSize: style.fontSize, fontWeight: style.fontWeight, fontFamily: style.fontFamily, letterSpacing: style.letterSpacing);
    } else {
      return style;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: ListView.builder(
        itemCount: widget.daysCount,
        scrollDirection: Axis.horizontal,
        controller: _controller,
        itemBuilder: (context, index) {
          DateTime date;
          DateTime _date = widget.startDate.add(Duration(days: index));
          date = new DateTime(_date.year, _date.month, _date.day);
          bool isDeactivated = false;
          if (widget.inactiveDates != null) {
            for (DateTime inactiveDate in widget.inactiveDates) {
              if (_compareDate(date, inactiveDate)) {
                isDeactivated = true;
                break;
              }
            }
          }
          if (widget.activeDates != null) {
            isDeactivated = true;
            for (DateTime activateDate in widget.activeDates) {
              if (_compareDate(date, activateDate)) {
                isDeactivated = false;
                break;
              }
            }
          }
          bool isSelected = _currentDate != null ? _compareDate(date, _currentDate) : false;
          return CustomDateWidget(
            date: date,
            monthTextStyle: isDeactivated ? deactivatedMonthStyle : isSelected ? selectedMonthStyle : widget.monthTextStyle,
            dateTextStyle: isDeactivated ? deactivatedDateStyle : isSelected ? selectedDateStyle : widget.dateTextStyle,
            dayTextStyle: isDeactivated ? deactivatedDayStyle : isSelected ? selectedDayStyle : widget.dayTextStyle,
            width: widget.width,
            locale: widget.locale,
            selectionColor: isSelected ? widget.selectionColor : Colors.transparent,
            onDateSelected: (selectedDate) {
              if (isDeactivated) return;
              if (widget.onDateChange != null ) {
                widget.onDateChange(selectedDate);
              }
              setState(() {
                _currentDate = selectedDate;
              });
            },
          );
        },
      ),
    );
  }

  bool _compareDate(DateTime date1, DateTime date2) {
    return date1.day == date2.day && date1.month == date2.month && date1.year == date2.year;
  }
}

class CustomDatePickerController {
  _CustomDatePickerState _datePickerState;

  void setDatePickerState(_CustomDatePickerState state) {
    _datePickerState = state;
  }

  void jumpToSelection() {
    assert(_datePickerState != null, 'DatePickerController is not attached to any DatePicker View.');
    _datePickerState._controller.jumpTo(_calculateDateOffset(_datePickerState._currentDate));
  }

  void animateToSelection({duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null, 'DatePickerController is not attached to any DatePicker View.');
    _datePickerState._controller.animateTo(_calculateDateOffset(_datePickerState._currentDate), duration: duration, curve: curve);
  }

  void animateToDate(DateTime date, {duration = const Duration(milliseconds: 500), curve = Curves.linear}) {
    assert(_datePickerState != null, 'DatePickerController is not attached to any DatePicker View.');

    _datePickerState._controller.animateTo(_calculateDateOffset(date), duration: duration, curve: curve);
  }

  double _calculateDateOffset(DateTime date) {
    final startDate = new DateTime(
      _datePickerState.widget.startDate.year,
      _datePickerState.widget.startDate.month,
      _datePickerState.widget.startDate.day);

    int offset = date.difference(startDate).inDays;
    return (offset * _datePickerState.widget.width) + (offset * 6);
  }
}
