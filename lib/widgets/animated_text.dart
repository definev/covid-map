import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:covid_map/utils/style.dart';

class AnimatedText extends StatefulWidget {
  final int oldNumber;
  final int newNumber;
  final Duration duration;
  final Color color;

  const AnimatedText({
    Key key,
    this.oldNumber,
    this.newNumber,
    this.duration,
    this.color,
  }) : super(key: key);

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: widget.oldNumber, end: widget.newNumber),
      duration: widget.duration,
      curve: Curves.decelerate,
      onEnd: () => print("ENDDDD"),
      builder: (_, val, __) {
        return Text(
          "${val.format}",
          style: GoogleFonts.rokkitt(
            color: widget.color,
            fontSize: 17,
          ),
        );
      },
    );
  }
}
