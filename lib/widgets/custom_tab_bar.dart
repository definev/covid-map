import 'package:flutter/material.dart';
import 'package:flutter_challenger/generated/locale_base.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTabBar extends StatefulWidget {
  final int initPage;
  final Function(int) onPageChanged;
  final double height;
  final double width;

  const CustomTabBar(
      {Key key, this.initPage, this.onPageChanged, this.height, this.width})
      : super(key: key);

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {
  List<String> _listTab = [];
  LocaleBase loc;

  int _page;

  bool init = false;

  @override
  void initState() {
    super.initState();
    _page = widget.initPage;
  }

  @override
  Widget build(BuildContext context) {
    if (init == false) {
      loc = Localizations.of<LocaleBase>(context, LocaleBase);
      init = true;
    }

    _listTab = [
      loc.covid.symptom,
      loc.covid.prevention,
      loc.covid.whatShouldYouDo,
    ];

    return Stack(
      children: [
        ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: List.generate(
            _listTab.length,
            (index) => InkWell(
              onTap: () {
                setState(() {
                  _page = index;
                  widget.onPageChanged(_page);
                });
              },
              child: Container(
                height: widget.height,
                width: widget.width * 1 / 2,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 1.5),
                        child: Text(
                          _listTab[index],
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rokkitt(fontSize: 16),
                        ),
                      ),
                    ),
                    if (_page == index)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: TweenAnimationBuilder(
                          tween: Tween<double>(begin: 0, end: 1),
                          curve: Curves.bounceOut,
                          duration: Duration(milliseconds: 400),
                          builder: (context, value, child) => Container(
                            height: 1.5 * value,
                            width: widget.width * 0.7 / 2,
                            color: Colors.black,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
