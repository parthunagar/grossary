import 'package:flutter/material.dart';
import 'package:vendor/Locale/locales.dart';
import 'package:vendor/Theme/colors.dart';

class CustomButtonWallet extends StatefulWidget {
  final String label,imageAssets;
  final Widget onPress,prefixIcon;
  final double width,iconGap,height;
  final Color color,borderColor,textColor;
  final Function action,onTap;

  CustomButtonWallet({
    this.label, this.onPress, this.imageAssets, this.width,
    this.prefixIcon, this.iconGap, this.height, this.onTap,
    this.color, this.borderColor, this.textColor, this.action,
  });

  @override
  _CustomButtonWalletState createState() => _CustomButtonWalletState();
}

class _CustomButtonWalletState extends State<CustomButtonWallet> {
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
        width: widget.width,
        height: widget.height,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: widget.borderColor, style: BorderStyle.solid, width: 1.0,),
          color: widget.color ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(45)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widget.prefixIcon != null ? widget.prefixIcon : SizedBox.shrink(),
            Container(
              height: 26,
              width: 26,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: kRoundButtonInButton2,
                  borderRadius: BorderRadius.all(Radius.circular(45))),
              child: Image(image: AssetImage(widget.imageAssets ?? 'assets/icon_feather_save.png')),),
            SizedBox(width: widget.iconGap),
            Flexible(
              child: Text(
                widget.label ?? locale.continueText,
                textAlign: TextAlign.justify,
                maxLines: 2,
                style: TextStyle(fontSize: 12, color: widget.textColor, letterSpacing: 0, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(width: widget.iconGap),
          ],
        ),
      ),
    );
  }
}
