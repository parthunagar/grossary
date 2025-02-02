import 'package:flutter/material.dart';
import 'package:vendor/Theme/colors.dart';

class EntryFieldProfile extends StatefulWidget {
  final TextEditingController controller;
  final String label,image,initialValue,hint;
  final bool readOnly,isdence;
  final TextInputType keyboardType;
  final int maxLength,maxLines;
  final IconData suffixIcon;
  final Function onTap,onSuffixPressed;
  final TextCapitalization textCapitalization;
  final double horizontalPadding,verticalPadding,labelFontSize;
  final FontWeight labelFontWeight;
  final Color underlineColor;
  final TextStyle hintStyle;
  final onSubmit,autofocus;
  final TextInputAction textInputAction;

  EntryFieldProfile({
    this.onSubmit, this.controller, this.label,
    this.image, this.initialValue, this.readOnly, this.isdence, this.keyboardType,
    this.maxLength, this.hint, this.suffixIcon, this.maxLines, this.onTap,
    this.textCapitalization, this.onSuffixPressed, this.horizontalPadding, this.verticalPadding, this.labelFontWeight,
    this.labelFontSize, this.underlineColor, this.hintStyle, this.autofocus,this.textInputAction
  });

  @override
  _EntryFieldProfileState createState() => _EntryFieldProfileState();
}

class _EntryFieldProfileState extends State<EntryFieldProfile> {
  bool showShadow = false;
  bool showBorder = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: widget.horizontalPadding ?? 10.0,
          vertical: widget.verticalPadding ?? 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(widget.label ?? '',
            style: Theme.of(context).textTheme.headline6.copyWith(
              color: kEntryFieldLable,
              fontWeight: widget.labelFontWeight ?? FontWeight.normal,
              fontSize: widget.labelFontSize ?? 18)),
          TextField(
            textCapitalization: widget.textCapitalization ?? TextCapitalization.sentences,
            cursorColor: kMainColor1,
            autofocus: widget.autofocus ?? false,
            onSubmitted: (_) {
              final FocusScopeNode currentScope = FocusScope.of(context);
              if (!currentScope.hasPrimaryFocus && currentScope.hasFocus) {
                // FocusManager.instance.primaryFocus.unfocus();
                FocusScope.of(context).nextFocus();
              }
            },

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
                // showShadow = true;
                // showBorder = true;
              });
            },

            textInputAction: widget.textInputAction ??  TextInputAction.done,

            controller: widget.controller,
            readOnly: widget.readOnly ?? false,
            keyboardType: widget.keyboardType,
            minLines: 1,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines ?? 1,
            decoration: InputDecoration(
              isDense: widget.isdence??false,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.underlineColor ?? Colors.grey[200])),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: widget.underlineColor ?? kTextBlack)),
              suffixIcon: IconButton(
                icon: Icon(widget.suffixIcon, size: 40.0, color: Theme.of(context).backgroundColor),
                onPressed: widget.onSuffixPressed ?? null,
              ),
              counterText: "",
              hintText: widget.hint,
              hintStyle: widget.hintStyle ?? Theme.of(context).textTheme.subtitle1.copyWith(color: kHintColor, fontSize: 14)),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
