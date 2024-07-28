import 'package:flutter/material.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';

class CustomButton extends StatefulWidget {
  final String label,imageAssets;
  final double width,iconGap,height;
  final Widget prefixIcon,onPress;
  final Color color;
  final Function action,onTap;

  CustomButton({
    this.label, this.onPress, this.imageAssets, this.width,
    this.prefixIcon, this.iconGap, this.height,
    this.onTap, this.color, this.action,
  });

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
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
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: widget.color ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(45)),),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.prefixIcon != null ? widget.prefixIcon : SizedBox.shrink(),
            SizedBox(width: widget.iconGap),
            Text(
              widget.label ?? locale.continueText,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Theme.of(context).scaffoldBackgroundColor, letterSpacing: 1, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: widget.iconGap),
            Container(
              height: 26,
              width: 26,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(color: kRoundButtonInButton, borderRadius: BorderRadius.all(Radius.circular(45))),
              child: Image(image: AssetImage(widget.imageAssets ?? 'assets/icon_feather_save.png')),
            )
          ],
        ),
      ),
    );
  }
}
