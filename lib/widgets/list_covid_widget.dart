import 'package:flutter/material.dart';
import 'package:flutter_challenger/model/covid_tile.dart';
import 'package:flutter_challenger/utils/style.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class ListCovidWidget extends StatefulWidget {
  final double height;
  final double width;
  final CovidTile covidTile;
  final String language;
  final EdgeInsets margin;

  const ListCovidWidget(
      {Key key,
      this.height,
      this.width,
      this.covidTile,
      this.language,
      this.margin})
      : super(key: key);
  @override
  _ListCovidWidgetState createState() => _ListCovidWidgetState();
}

class _ListCovidWidgetState extends State<ListCovidWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      margin: widget.margin,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Image.asset(
                    widget.covidTile.imageUrl,
                    height: 50,
                    width: 50,
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: widget.width - 20 - 50 - 23.4,
                    child: Text(
                      widget.language == "en"
                          ? widget.covidTile.en
                          : widget.covidTile.vi,
                      style: GoogleFonts.rokkitt(
                        fontSize: 17,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              SimpleLineIcons.arrow_right_circle,
              color: AppColors.black,
              size: 23.4,
            ),
          ],
        ),
      ),
    );
  }
}
