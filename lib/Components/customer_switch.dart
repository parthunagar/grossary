import 'package:driver/Theme/colors.dart';
import 'package:flutter/material.dart';

class CustomSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const CustomSwitch({Key key, this.value, this.onChanged, this.activeColor})
      : super(key: key);

  @override
  _CustomSwitchState createState() => _CustomSwitchState();
}

class _CustomSwitchState extends State<CustomSwitch>
    with SingleTickerProviderStateMixin {
  Animation _circleAnimation;
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 60));
    _circleAnimation = AlignmentTween(
      begin: widget.value ? Alignment.centerRight : Alignment.centerLeft,
      end: widget.value ? Alignment.centerLeft : Alignment.centerRight)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.linear));
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            if (_animationController.isCompleted) {
              _animationController.reverse();
            } else {
              _animationController.forward();
            }
            widget.value == false ? widget.onChanged(true) : widget.onChanged(false);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: _circleAnimation.value == Alignment.centerLeft ? kRatingStarNull : widget.activeColor),
            margin: EdgeInsets.only(right: 20),
            child: Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 4.0, right: 0.0, left: 0.0),
              child: Row(
                children: <Widget>[
                  _circleAnimation.value == Alignment.centerRight
                  ? Text('On', style: TextStyle(color: kTransparentColor, fontWeight: FontWeight.w900, fontSize: 16.0))
                  : Container(),
                  Align(
                    alignment: _circleAnimation.value,
                    child: Container(
                      width: 25.0,
                      height: 25.0,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                  ),
                  _circleAnimation.value == Alignment.centerLeft
                  ? Text('Off', style: TextStyle(color: kTransparentColor, fontWeight: FontWeight.w900, fontSize: 16.0))
                  : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
