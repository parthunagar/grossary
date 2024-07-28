import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';

class ProgressBarIndicator extends StatefulWidget {
  const ProgressBarIndicator({Key key}) : super(key: key);

  @override
  _ProgressBarIndicatorState createState() => _ProgressBarIndicatorState();
}

class _ProgressBarIndicatorState extends State<ProgressBarIndicator> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 40,
        width: 40,
        child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(kRedColor),)),
    );
  }
}

