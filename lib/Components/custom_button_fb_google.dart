import 'package:flutter/material.dart';
import 'package:groshop/Locale/locales.dart';
import 'package:groshop/Theme/colors.dart';

class CustomButtonFbGoogle extends StatefulWidget {
  final String label;
  final String imageAsset;
  final String imageBackground;
  final Widget onPress;
  final double width;
  final Widget prefixIcon;
  final double iconGap;
  final double height;
  final Function onTap;
  final Color color;
  final Function action;

  CustomButtonFbGoogle({
    this.label,
    this.imageAsset,
    this.imageBackground,
    this.onPress,
    this.width,
    this.prefixIcon,
    this.iconGap,
    this.height,
    this.onTap,
    this.color,
    this.action,
  });

  @override
  _CustomButtonFbGoogleState createState() => _CustomButtonFbGoogleState();
}

class _CustomButtonFbGoogleState extends State<CustomButtonFbGoogle> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: widget.onTap ??
          () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (context) => widget.onPress))
                .then((value) {
              widget.action();
            });
          },
      child: Container(
        width: widget.width,
        height: widget.height,
        // color: widget.color ?? Theme.of(context).primaryColor,
        padding: EdgeInsets.all(10),
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage(widget.imageBackground),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.prefixIcon != null ? widget.prefixIcon : SizedBox.shrink(),
            SizedBox(width: widget.iconGap),
            Image(

              fit:BoxFit.cover,
              image: AssetImage(widget.imageBackground),
            height: 40,
              width: 150,
            ),
            // Text(
            //   widget.label ?? locale.continueText,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //       fontSize: 16,
            //       color: Theme.of(context).scaffoldBackgroundColor,
            //       letterSpacing: 1,
            //       fontWeight: FontWeight.w700),
            // ),
          ],
        ),
      ),
    );
  }
}
