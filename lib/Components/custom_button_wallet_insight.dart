import 'package:flutter/material.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';

class CustomButtonWalletInsight extends StatefulWidget {
  final String label,label2,imageAssets;
  final Widget onPress,prefixIcon;
  final double width,iconGap,height;
  final Function onTap,action;
  final Color color,borderColor,textColor;

  CustomButtonWalletInsight({
    this.label, this.label2, this.onPress, this.imageAssets,
    this.width, this.prefixIcon, this.iconGap, this.height, this.onTap,
    this.color, this.borderColor, this.textColor, this.action,
  });

  @override
  _CustomButtonWalletInsightState createState() => _CustomButtonWalletInsightState();
}

class _CustomButtonWalletInsightState extends State<CustomButtonWalletInsight> {
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context);
    return GestureDetector(
      // onTap: widget.onTap ??
      //     () {
      //       Navigator.push(context,
      //               MaterialPageRoute(builder: (context) => widget.onPress))
      //           .then((value) {
      //         widget.action();
      //       });
      //     },
      child: Container(
        width: widget.width!=null ? MediaQuery.of(context).size.width/3.5 : widget.width,
        height: widget.height,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor, style: BorderStyle.solid, width: 1.0),
          color: widget.color ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // widget.prefixIcon != null ? widget.prefixIcon : SizedBox.shrink(),
            Container(
              height: 24,
              width: 24,
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kRoundButtonInButton2,
                borderRadius: BorderRadius.all(Radius.circular(45))),
              child: Image(image: AssetImage(widget.imageAssets ?? 'assets/icon_feather_save.png'))),
            Spacer(),
            // SizedBox(width: widget.iconGap??8),
            Column(
              children: [
                Text(
                  widget.label ?? locale.continueText,
                  textAlign: TextAlign.justify,
                  maxLines: 1,
                  style: TextStyle(fontSize: 10, color: widget.textColor, letterSpacing: 0, fontWeight: FontWeight.normal),
                ),
                Text(
                  widget.label2 ?? locale.continueText,
                  textAlign: TextAlign.justify,
                  maxLines: 1,
                  style: TextStyle(fontSize: 10, color: widget.textColor, letterSpacing: 0, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Spacer()
            // SizedBox(width: widget.iconGap),
          ],
        ),
      ),
    );
  }
}
