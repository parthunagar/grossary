import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:groshop/Theme/colors.dart';

class EntryField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String image;
  final String initialValue;
  final bool readOnly;
  final bool obscureText;
  final TextInputType keyboardType;
  final int maxLength;
  final int maxLines;
  final String hint;
  final IconData suffixIcon;
  final Function onTap;
  final TextCapitalization textCapitalization;
  final Function onSuffixPressed;
  final double horizontalPadding;
  final double verticalPadding;
  final FontWeight labelFontWeight;
  final double labelFontSize;
  final Color underlineColor;
  final TextStyle hintStyle;

  EntryField({
    this.controller,
    this.label,
    this.image,
    this.initialValue,
    this.readOnly,
    this.obscureText,
    this.keyboardType,
    this.maxLength,
    this.hint,
    this.suffixIcon,
    this.maxLines,
    this.onTap,
    this.textCapitalization,
    this.onSuffixPressed,
    this.horizontalPadding,
    this.verticalPadding,
    this.labelFontWeight,
    this.labelFontSize,
    this.underlineColor,
    this.hintStyle,
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
          padding: EdgeInsets.symmetric(
              horizontal: widget.horizontalPadding ?? 10.0,
              vertical: widget.verticalPadding ?? 1.0),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  // alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(top: 8) ,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/et_border.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: TextField(
                    textCapitalization: widget.textCapitalization ??
                        TextCapitalization.sentences,
                    cursorColor: kMainColor,
                    obscureText: widget.obscureText??false,
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
                          icon: Icon(
                            widget.suffixIcon,
                            size: 40.0,
                            color: Theme.of(context).backgroundColor,
                          ),
                          onPressed: widget.onSuffixPressed ?? null,
                        ),
                        contentPadding: EdgeInsets.all(10.0),
                        counterText: "",
                        hintText: widget.hint,
                        hintStyle: widget.hintStyle ??
                            Theme.of(context).textTheme.subtitle1.copyWith(
                                color: kHintColor, fontSize: 16)),
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
                          color: kLightTextColoEt,
                          fontWeight:
                              widget.labelFontWeight ?? FontWeight.normal,
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
