import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:driver/Locale/locales.dart';

class CustomButton extends StatefulWidget {
  final String label;
  final Widget onPress,prefixIcon;
  final double width,iconGap,height,border;
  final Function onTap;
  final Color color,textColor;

  CustomButton({
    this.label, this.onPress, this.width,
    this.prefixIcon,this.iconGap, this.height,
    this.onTap, this.color, this.border, this.textColor});

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height ?? 56,
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(widget.border ?? 0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.prefixIcon ?? SizedBox.shrink(),
            SizedBox(width: widget.iconGap),
            Center(
              child: Text(
                widget.label ?? locale.continueText.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.textColor ?? Theme.of(context).scaffoldBackgroundColor,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRedButton extends StatefulWidget {
  final String label;
  final Widget onPress,prefixIcon;
  final double width,iconGap,height,border,fontSize;
  final Function onTap;
  final Color color,textColor;
  EdgeInsetsGeometry margin,padding;
  final fontFamily;

  CustomRedButton({
    this.label, this.onPress, this.width, this.prefixIcon, this.iconGap,
    this.height, this.onTap, this.color, this.border, this.margin,
    this.textColor, this.padding,this.fontFamily,this.fontSize
  });

  @override
  _CustomRedButtonState createState() => _CustomRedButtonState();
}

class _CustomRedButtonState extends State<CustomRedButton> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        // alignment: Alignment.center,
        // width: widget.width,
        height: widget.height ?? 56,
        margin: widget.margin ?? EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: widget.color ?? kRoundButton,
          borderRadius: BorderRadius.circular(widget.border ?? 50),
        ),
        padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Center(
                child: Text(
                  widget.label ?? locale.continueText,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:  widget.fontSize ?? 16,
                    fontFamily: widget.fontFamily,
                    color: widget.textColor ?? Theme.of(context).scaffoldBackgroundColor,
                    // letterSpacing: 1,
                    fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(width: 10),
            widget.prefixIcon ?? SizedBox.shrink(),
            // SizedBox(width: widget.iconGap),
            // Image.asset("assets/images/bgupdate_info.png")
          ],
        ),
      ),
    );
  }
}
