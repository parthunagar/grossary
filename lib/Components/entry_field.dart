import 'package:driver/Const/constant.dart';
import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';
//import 'package:shopcart/Theme/colors.dart';

class EntryField extends StatefulWidget {
  final TextEditingController controller;
  final String label,image,initialValue,hint,labelFamily,hintFamily,inputTextFamily;
  final bool readOnly,obsecureText;
  final TextInputType keyboardType;
  final int maxLength,maxLines;
  final IconData suffixIcon;
  final Function onTap,onSuffixPressed;
  final TextCapitalization textCapitalization;
  final double horizontalPadding,verticalPadding,labelFontSize,suffixIconSize,inputTextSize;
  final FontWeight labelFontWeight;
  final Color underlineColor,labelColor,suffixIconColor;
  final TextStyle hintStyle;
  bool autoFocus;
  var onSubmitted;
  // final TextStyle style;
  final EdgeInsetsGeometry contentPadding;
  final TextInputAction textInputAction;

  // final double height;

  EntryField({
    this.controller, this.label, this.image,
    this.initialValue, this.readOnly, this.keyboardType, this.maxLength,
    this.hint, this.suffixIcon, this.maxLines, this.onTap,
    this.textCapitalization, this.onSuffixPressed, this.horizontalPadding, this.verticalPadding,
    this.labelFontWeight, this.labelFontSize, this.labelColor, this.underlineColor,
    this.hintStyle, this.obsecureText, this.suffixIconColor, this.suffixIconSize, this.labelFamily,
    this.hintFamily, this.inputTextFamily,this.inputTextSize,this.contentPadding,this.textInputAction,
    this.autoFocus,this.onSubmitted
    // this.style,
    // this.height

    });

  @override
  _EntryFieldState createState() => _EntryFieldState();
}

class _EntryFieldState extends State<EntryField> {
  // bool showShadow = false;
  bool showBorder = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.horizontalPadding ?? 20.0,
        vertical: widget.verticalPadding ?? 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.label ?? '',
            style: Theme.of(context).textTheme.headline6.copyWith(
              fontFamily: widget.labelFamily,
              color: widget.labelColor ?? Theme.of(context).backgroundColor,
              fontWeight: widget.labelFontWeight ?? FontWeight.w500,
              fontSize: widget.labelFontSize ?? 21.7)),
          // Container(
          //   // color: kRedColor,
          //   // height: widget.height ?? 20.0,
          //   child:
          TextField(
            textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
            cursorColor: Theme.of(context).primaryColor,
            autofocus:  false,
            // onEditingComplete: () {
            //   setState(() { showShadow = false; });
            // },

            onTap: () {
              if (widget.onTap != null) {
                widget.onTap();
              }
              setState(() {
                // showShadow = true;
                showBorder = true;
              });
            },
            textInputAction: widget.textInputAction ??  TextInputAction.done,
            style: TextStyle(fontFamily: widget.inputTextFamily, color: kGreyBlack, fontSize: widget.inputTextSize),
            controller: widget.controller,
            readOnly: widget.readOnly ?? false,
            keyboardType: widget.keyboardType,
            minLines: 1,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines ?? 1,
            onSubmitted: (_) => widget.onSubmitted ??  FocusScope.of(context).nextFocus(),
            obscureText: widget.obsecureText ?? false,
            decoration: InputDecoration(
                // contentPadding: EdgeInsets.all(0.0),
                // contentPadding: widget.contentPadding,   //  <- you can it to 0.0 for no space
                // isDense: true,
                // isCollapsed: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.underlineColor ?? Colors.grey[200])),
                suffixIcon: IconButton(
                  icon: Icon(
                    widget.suffixIcon,
                    size: widget.suffixIconSize ?? 40.0,
                    color: widget.suffixIconColor ?? Theme.of(context).backgroundColor),
                    onPressed: widget.onSuffixPressed ?? null,
                ),
                hintText: widget.hint,
                counterText: '',
                hintStyle: TextStyle(fontSize: 18, fontFamily: widget.hintFamily)),
            // style: widget.style ??  TextStyle(fontWeight: FontWeight.normal),
          ),
          // ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
