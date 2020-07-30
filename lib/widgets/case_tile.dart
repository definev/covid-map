import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:covid_map/widgets/animated_text.dart';
import 'package:google_fonts/google_fonts.dart';

class CaseTile extends StatefulWidget {
  final Color color;
  final Color arrowColor;
  final int oldNumber;
  final int newNumber;
  final int oldIncreaseNumber;
  final int newIncreaseNumber;
  final String type;
  final String state;
  final bool opacity;
  const CaseTile({
    Key key,
    this.color,
    this.arrowColor,
    this.oldNumber,
    this.newNumber,
    this.oldIncreaseNumber,
    this.newIncreaseNumber,
    this.type,
    this.state,
    this.opacity,
  }) : super(key: key);

  @override
  _CaseTileState createState() => _CaseTileState();
}

class _CaseTileState extends State<CaseTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: 90,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 90,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(4),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedText(
                  duration: Duration(milliseconds: 1000),
                  color: widget.color,
                  oldNumber: widget.oldNumber,
                  newNumber: widget.newNumber,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: FlareActor(
                            "assets/flare/arrow.flr",
                            animation: widget.state,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedText(
                          duration: Duration(milliseconds: 1000),
                          color: Color(0xFFA9ACB1),
                          oldNumber: widget.oldIncreaseNumber,
                          newNumber: widget.newIncreaseNumber,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 20,
            width: 90,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(4)),
            ),
            alignment: Alignment.center,
            child: widget.opacity == false
                ? Text(
                    widget.type,
                    style: GoogleFonts.rokkitt(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  )
                : TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (_, val, child) {
                      return Opacity(
                        opacity: val,
                        child: child,
                      );
                    },
                    child: Text(
                      widget.type,
                      style: GoogleFonts.rokkitt(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
