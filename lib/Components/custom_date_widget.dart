/// ***
/// This class consists of the DateWidget that is used in the ListView.builder
///
/// Author: Vivek Kaushik <me@vivekkasuhik.com>
/// github: https://github.com/iamvivekkaushik/
/// ***

import 'package:date_picker_timeline/gestures/tap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vendor/Theme/colors.dart';

class CustomDateWidget extends StatelessWidget {
  final double width;
  final DateTime date;
  final TextStyle monthTextStyle, dayTextStyle, dateTextStyle;
  final Color selectionColor;
  final DateSelectionCallback onDateSelected;
  final String locale;

  CustomDateWidget({
    @required this.date,
    @required this.monthTextStyle,
    @required this.dayTextStyle,
    @required this.dateTextStyle,
    @required this.selectionColor,
    this.width,
    this.onDateSelected,
    this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: width,
        margin: EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
          color: selectionColor,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 2,right: 2,bottom: 2,top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(child: Text(new DateFormat("MMM", locale).format(date).toUpperCase(), style: monthTextStyle)),// Month
              Center(child: Text(date.day.toString(), style: dateTextStyle)),// Date
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6),bottomRight: Radius.circular(6))),
                child: Center(
                  child: Text(new DateFormat("E", locale).format(date).toUpperCase(), // WeekDay
                      style: dayTextStyle)),
              )
            ],
          ),
        ),
      ),
      onTap: () {
        // Check if onDateSelected is not null
        if (onDateSelected != null) {
          // Call the onDateSelected Function
          onDateSelected(this.date);
        }
      },
    );
  }
}
