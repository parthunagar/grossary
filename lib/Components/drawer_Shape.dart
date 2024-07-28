import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';
// import 'dart:ui';
// import 'dart:math';

class RPSCustomPainter extends CustomPainter {

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint_0 = new Paint()
      ..color = kWhiteColor// kRoundButtonInButton
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2450000, size.height  * -0.0060000);
    path_0.quadraticBezierTo(size.width * 0.2600000, size.height * 0.0170000,
        size.width * 0.2600000, size.height * 0.1000000);
    path_0.cubicTo(
        size.width * 0.3525000,
        size.height * 0.2640000,
        size.width * 0.8975000,
        size.height * 0.2360000,
        size.width,
        size.height * 0.4980000);
    path_0.cubicTo(
        size.width * 0.9275000,
        size.height * 0.7490000,
        size.width * 0.3625000,
        size.height * 0.7510000,
        size.width * 0.2450000,
        size.height * 0.9000000);
    path_0.quadraticBezierTo(size.width *  0.2362500, size.height * 1.0775000,
        size.width * 0.2450000, size.height);
    path_0.lineTo(0, size.height);
    path_0.lineTo(0, size.height * -0.0060000);
    path_0.lineTo(size.width * 0.2450000, size.height * -0.0060000);
    path_0.close();

    canvas.drawPath(path_0, paint_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}