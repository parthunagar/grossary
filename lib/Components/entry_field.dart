import 'package:flutter/material.dart';
import 'package:vendor/Theme/colors.dart';

class EntryField extends StatefulWidget {
  final TextEditingController controller;
  final String label,image,hint;
  final String initialValue;
  final bool readOnly;
  final TextInputType keyboardType;
  final int maxLength,maxLines;
  final IconData suffixIcon;
  final Function onTap,onSuffixPressed;
  final TextCapitalization textCapitalization;
  final double horizontalPadding,verticalPadding,labelFontSize;
  final FontWeight labelFontWeight;
  final Color underlineColor;
  final TextStyle hintStyle;
  final TextInputAction textInputAction;

  EntryField({
    this.controller, this.label, this.image, this.initialValue,
    this.readOnly, this.keyboardType, this.maxLength,
    this.hint, this.suffixIcon, this.maxLines,
    this.onTap, this.textCapitalization, this.onSuffixPressed,
    this.horizontalPadding, this.verticalPadding, this.labelFontWeight,
    this.labelFontSize, this.underlineColor, this.hintStyle,this.textInputAction
  });

  @override
  _EntryFieldState createState() => _EntryFieldState();
}

class _EntryFieldState extends State<EntryField> {
  bool showShadow = false;
  bool showBorder = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding ?? 10.0, vertical: widget.verticalPadding ?? 1.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/et_border.png"), fit: BoxFit.fill)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextField(
                        textInputAction: widget.textInputAction ??  TextInputAction.done,
                        textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
                        cursorColor: kMainColor,
                        autofocus: false,
                        onSubmitted: (_) => FocusScope.of(context).unfocus(),
                        onEditingComplete: () {
                          setState(() {
                            showShadow = false;
                          });
                        },
                        onTap: () {
                          if (widget.onTap != null) {
                            widget.onTap();
                          }
                          setState(() {
                            showShadow = true;
                            showBorder = true;
                          });
                        },
                        controller: widget.controller,
                        readOnly: widget.readOnly ?? false,
                        keyboardType: widget.keyboardType,
                        minLines: 1,
                        maxLength: widget.maxLength,
                        maxLines: widget.maxLines ?? 1,
                        decoration: InputDecoration(
                          // enabledBorder: UnderlineInputBorder(
                          //   borderSide: BorderSide(
                          //       color: widget.underlineColor ?? Colors.grey[200]),
                          // ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(widget.suffixIcon, size: 40.0, color: Theme.of(context).backgroundColor),
                            onPressed: widget.onSuffixPressed ?? null,
                          ),
                          contentPadding: EdgeInsets.all(10.0),
                          counterText: "",
                          hintText: widget.hint,
                          hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.subtitle1.copyWith(color: kHintColor, fontSize: 18.3)),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Container(
                  color: kWhiteColor,
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 2),
                  child: Text(widget.label ?? '',
                    style: Theme.of(context).textTheme.headline6.copyWith(
                      color: kLightTextColor,
                      fontWeight: widget.labelFontWeight ?? FontWeight.normal,
                      fontSize: widget.labelFontSize ?? 14)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.0),
      ],
    );
  }
}
