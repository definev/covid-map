import 'package:flutter/material.dart';

class WidgetShadow extends StatefulWidget {
  final Widget child;
  final Widget shadow;
  final int thickness;

  const WidgetShadow({Key key, this.child, this.thickness, this.shadow})
      : super(key: key);

  @override
  _WidgetShadowState createState() => _WidgetShadowState();
}

class _WidgetShadowState extends State<WidgetShadow> {
  bool onHoldTap = false;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          ...List.generate(
            widget.thickness,
            (index) => AnimatedPositioned(
              duration: Duration(milliseconds: 200),
              bottom: onHoldTap ? 0 : index.toDouble(),
              right: onHoldTap ? 0 : index.toDouble(),
              top: onHoldTap ? index.toDouble() : 0,
              left: onHoldTap ? index.toDouble() : 0,
              child: IgnorePointer(
                ignoring: true,
                child: widget.shadow,
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
