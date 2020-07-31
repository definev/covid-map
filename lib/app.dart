import 'dart:ui';

import 'package:covid_map/model/covid_marker.dart';
import 'package:covid_map/utils/fluster.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flare_flutter/flare_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:covid_map/cache/flutter_challenge_cache.dart';
import 'package:covid_map/generated/delegate.dart';
import 'package:covid_map/generated/locale_base.dart';
import 'package:covid_map/model/country_covid_data.dart';
import 'package:covid_map/model/covid_data.dart';
import 'package:covid_map/model/covid_tile.dart';
import 'package:covid_map/utils/app_flare_controller.dart';
import 'package:covid_map/utils/style.dart';
import 'package:covid_map/widgets/case_tile.dart';
import 'package:covid_map/widgets/custom_tab_bar.dart';
import 'package:covid_map/widgets/list_covid_widget.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum ExpandState { open, close }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid Map',
      localizationsDelegates: [const LocDelegate()],
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// [Google Maps]
  GoogleMapController mapController;
  Map<String, String> _mapStyle = {
    "dark": null,
    "retro": null,
    "silver": null,
  };
  CameraPosition _currentCameraPosition = CameraPosition(
    target: LatLng(21.028511, 105.804817),
    bearing: 0,
    tilt: 40,
    zoom: 6,
  );
  String mapStyle;

  Set<String> _searchHistoryList = Set<String>();

  String lang = FlutterChallengeCache.covidCache.currentLang;
  bool onChangedLang = false;

  String locText = "Global";

  ScrollController _scrollController = ScrollController();

  /// [Flare] and [Animation logic]
  FlareControls _flareControls = FlareControls();
  String currentAnimation = SearchState.nothing;
  bool openSearch = false;
  bool onLoading = false;
  bool onAnimated = false;
  bool openHistorySearch = false;

  InputDecoration _inputDecoration;

  ExpandState expandState = ExpandState.close;

  /// [MediaQuery]
  double height;
  double width;

  /// [Covid Data]
  CovidData covidData;
  CovidData preCovidData;

  bool init = false;
  bool refresh = false;

  List<double> arrowOpacity = [1, 1];

  TextEditingController _searchController = TextEditingController();
  FocusNode _searchNode;

  LocaleBase loc;

  PageController _pageController = PageController();

  String getArrowAnimation({int preNewCase, int newCase}) {
    if (newCase == 0) {
      if (preNewCase > newCase)
        return "upToNormal";
      else
        return "idle";
    } else {
      return "normalToUp";
    }
  }

  void onSearchTouch(String currentText) {
    if (onLoading == false && onAnimated == false)
      setState(() {
        openSearch = !openSearch;
        onAnimated = true;
        if (openSearch) {
          currentAnimation = SearchState.openSearch;
          Future.delayed(Duration(milliseconds: 600), () {
            setState(() {
              onAnimated = false;
              openHistorySearch = true;

              _searchNode.requestFocus();
            });
          });
        } else {
          if (currentText.isEmpty) {
            currentAnimation = SearchState.closeSearch;
            openSearch = true;
            Future.delayed(Duration(milliseconds: 300), () {
              setState(() {
                openHistorySearch = false;
                Future.delayed(Duration(milliseconds: 400), () {
                  setState(() {
                    openSearch = false;
                    onAnimated = false;
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  });
                });
              });
            });
          } else {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
            currentAnimation = SearchState.onSeach;
            openSearch = true;
            onAnimated = true;
            Future.delayed(Duration(milliseconds: 300), () {
              setState(() {
                openHistorySearch = false;
              });
              Future.delayed(Duration(milliseconds: 400), () {
                setState(() {
                  openSearch = false;
                  onAnimated = false;
                  onLoading = true;

                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                });
              });
            });
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                String country = currentText;

                CountryCovidData countryCovidData = FlutterChallengeCache
                    .covidCache
                    .getCovidDataByName(country);

                if (countryCovidData != null) {
                  preCovidData = covidData;
                  covidData = countryCovidData.getCovidData();
                  locText = countryCovidData.country;

                  LatLng latLng = FlutterChallengeCache.covidCache
                      .getLatLngFromName(country);
                  if (latLng != null) {
                    mapController.animateCamera(
                        CameraUpdate.newCameraPosition(CameraPosition(
                      target: latLng,
                      bearing: 0,
                      tilt: 50,
                      zoom: 1,
                    )));
                    _searchHistoryList.add(countryCovidData.countryCode);
                  }
                }

                _searchController.clear();
                currentAnimation = SearchState.onDoneSearch;

                onAnimated = false;
                onLoading = false;

                setState(() {
                  currentAnimation = SearchState.closeSearch;
                });
              });
            });
          }
        }
      });
  }

  void onMarkerTab(String countryCode, String location) {
    setState(() {
      preCovidData = covidData;
      CountryCovidData countryCovidData =
          FlutterChallengeCache.covidCache.getCovidDataByName(countryCode);
      covidData = countryCovidData.getCovidData();
      countryCode = countryCovidData.countryCode;
      _searchHistoryList.add(countryCode);
      locText = location;
    });
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString("assets/map_theme/retro_theme.txt").then(
          (string) => _mapStyle["retro"] = string,
        );

    _searchNode = FocusNode();
    covidData = FlutterChallengeCache.covidCache.globalCovidData;
    preCovidData = FlutterChallengeCache.covidCache.globalCovidData;
  }

  @override
  Widget build(BuildContext context) {
    if (init == false) {
      loc = Localizations.of<LocaleBase>(context, LocaleBase);
      height = MediaQuery.of(context).size.height;
      width = MediaQuery.of(context).size.width;
      _inputDecoration = InputDecoration(
        hintText: loc.covid.searchHintText,
        hintStyle: GoogleFonts.mavenPro(
          color: Color(0xFFA5A9B1),
          fontSize: 15,
        ),
        border: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Colors.black54,
            width: 1.5,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: Colors.black87,
            width: 2.5,
          ),
        ),
      );
      init = true;
    }
    return Scaffold(
      backgroundColor: AppColors.black,
      resizeToAvoidBottomPadding: false,
      body: SafeArea(
        child: Stack(
          children: [
            // TODO: MAP GOOGLE
            Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                initialCameraPosition: _currentCameraPosition,
                compassEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  mapStyle = _mapStyle["retro"];
                  mapController.setMapStyle(mapStyle);
                },
                onCameraMove: (position) => _currentCameraPosition = position,
                markers:
                    CovidCluster.fluster.clusters([-180, -85, 180, 85], 3).map(
                  (cluster) {
                    CovidMarker modCluster = cluster.copyWith(
                      onMarkerTap: () {
                        onMarkerTab(cluster.countryGeoData.countryCode,
                            cluster.countryGeoData.location);
                      },
                    );
                    return modCluster.toMarker();
                  },
                ).toSet(),
                onCameraIdle: () async {
                  print(_currentCameraPosition.target.toString());
                  print(await mapController.getZoomLevel());
                },
                minMaxZoomPreference:
                    MinMaxZoomPreference(3.8804433345794678, 5.284524917602539),
              ),
            ),
            // TODO: CASE TILE
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: width,
                height: height - 150 - 24,
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: width,
                  height: height - 150 - 80 - 24,
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _numberTile(
                        color: AppColors.yellow,
                        arrowColor: Colors.yellow,
                        oldNumber: preCovidData.totalConfirmed,
                        newNumber: covidData.totalConfirmed,
                        oldIncreaseNumber: preCovidData.newConfirmed,
                        newIncreaseNumber: covidData.newConfirmed,
                        type: loc.covid.confirmed,
                        state: getArrowAnimation(
                          preNewCase: preCovidData.newConfirmed,
                          newCase: covidData.newConfirmed,
                        ),
                      ),
                      _numberTile(
                        color: AppColors.red,
                        arrowColor: Colors.red,
                        oldNumber: preCovidData.totalDeaths,
                        newNumber: covidData.totalDeaths,
                        oldIncreaseNumber: preCovidData.newDeaths,
                        newIncreaseNumber: covidData.newDeaths,
                        type: loc.covid.death,
                        state: getArrowAnimation(
                          preNewCase: preCovidData.newDeaths,
                          newCase: covidData.newDeaths,
                        ),
                      ),
                      _numberTile(
                        color: AppColors.green,
                        arrowColor: Colors.green,
                        oldNumber: preCovidData.totalRecovered,
                        newNumber: covidData.totalRecovered,
                        oldIncreaseNumber: preCovidData.newRecovered,
                        newIncreaseNumber: covidData.newRecovered,
                        type: loc.covid.recovered,
                        state: getArrowAnimation(
                          preNewCase: preCovidData.newRecovered,
                          newCase: covidData.newRecovered,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // TODO: SEARCH BAR
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 350),
                            height: openSearch && onLoading == false ? 60 : 0,
                            width: width - 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            child: !(openSearch && onLoading == false)
                                ? null
                                : TextField(
                                    controller: _searchController,
                                    focusNode: _searchNode,
                                    textAlign: TextAlign.justify,
                                    decoration: _inputDecoration,
                                    selectionHeightStyle: BoxHeightStyle.max,
                                    cursorColor: AppColors.black,
                                    cursorWidth: 1.5,
                                    cursorRadius: Radius.circular(4),
                                    style: GoogleFonts.mavenPro(fontSize: 15),
                                    onSubmitted: (value) =>
                                        onSearchTouch(value),
                                  ),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            height: openHistorySearch ? 200 : 0,
                            width: width - 30 - 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: _searchHistoryList.isEmpty
                                ? Center(
                                    child: Text(
                                      loc.covid.nothing,
                                      style: GoogleFonts.rokkitt(fontSize: 18),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: _searchHistoryList.length,
                                    itemBuilder: (context, index) => InkWell(
                                      onTap: () {
                                        onSearchTouch(_searchHistoryList
                                            .elementAt(index));
                                      },
                                      child: Container(
                                        height: 50,
                                        color: Colors.transparent,
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            height: 30,
                                                            width:
                                                                48.5410196625,
                                                            child: SvgPicture
                                                                .asset(
                                                              "assets/png/flag/${_searchHistoryList.elementAt(index).toLowerCase()}.svg",
                                                              fit: BoxFit.cover,
                                                              semanticsLabel:
                                                                  _searchHistoryList
                                                                      .elementAt(
                                                                          index),
                                                            ),
                                                          ),
                                                          SizedBox(width: 12),
                                                          Text(
                                                            _searchHistoryList
                                                                .elementAt(
                                                                    index),
                                                            style: GoogleFonts
                                                                .rokkitt(
                                                              fontSize: 16,
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        loc.covid.navigate,
                                                        style:
                                                            GoogleFonts.rokkitt(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                height: 1,
                                                width: width - 110,
                                                color: AppColors.black,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            margin: const EdgeInsets.only(top: 10),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: IgnorePointer(
                        ignoring: openSearch && onLoading == true ||
                            onAnimated == true,
                        child: Builder(
                          builder: (context) => GestureDetector(
                            onTap: () {
                              print(expandState.toString());
                              if (expandState == ExpandState.open) {
                                onSearchTouch("");
                                setState(() {
                                  expandState = ExpandState.close;
                                });
                                return;
                              }

                              onSearchTouch(_searchController.text);
                            },
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 1000),
                              height: 60,
                              width: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FlareActor(
                                "assets/flare/flutter-challenge.flr",
                                fit: BoxFit.cover,
                                animation: currentAnimation,
                                alignment: Alignment.center,
                                antialias: true,
                                controller: _flareControls,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TODO: REFRESH AND CHANGE LANGUAGE
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (refresh == false) {
                          setState(() {
                            refresh = true;
                            currentAnimation = SearchState.openSearch;
                            onLoading = true;

                            Future.delayed(Duration(seconds: 1), () async {
                              await FlutterChallengeCache.covidCache
                                  .initApiData();
                              setState(() {
                                currentAnimation = SearchState.loading;
                                Future.delayed(
                                  Duration(seconds: 1, milliseconds: 500),
                                  () {
                                    setState(() {
                                      refresh = false;
                                      currentAnimation =
                                          SearchState.closeSearch;
                                      preCovidData = covidData;
                                      covidData = FlutterChallengeCache
                                          .covidCache.globalCovidData;
                                      onLoading = false;
                                    });
                                  },
                                );
                              });
                            });
                          });
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AnimatedCrossFade(
                          crossFadeState: refresh
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          duration: Duration(milliseconds: 400),
                          firstChild: Container(
                            height: 60,
                            width: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 20),
                            child: Theme(
                              data: ThemeData(accentColor: AppColors.black),
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5),
                            ),
                          ),
                          secondChild: Container(
                            height: 60,
                            width: 50,
                            padding: EdgeInsets.only(bottom: 5),
                            child: Center(
                              child: Icon(
                                EvilIcons.refresh,
                                size: 40,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        if (onChangedLang == false) {
                          if (lang == "en") {
                            loc.load("locales/VI.json");
                            setState(() {
                              lang = "vi";
                              onChangedLang = true;
                              Future.delayed(Duration(milliseconds: 400), () {
                                setState(() {
                                  onChangedLang = false;
                                });
                              });
                            });
                          } else {
                            loc.load("locales/EN.json");
                            setState(() {
                              lang = "en";
                              onChangedLang = true;
                              Future.delayed(Duration(milliseconds: 400), () {
                                setState(() {
                                  onChangedLang = false;
                                });
                              });
                            });
                          }
                        }
                      },
                      child: AnimatedCrossFade(
                        duration: Duration(milliseconds: 400),
                        firstChild: Container(
                          height: 60,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SvgPicture.asset(
                              "assets/png/flag/gb.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        secondChild: Container(
                          height: 60,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SvgPicture.asset(
                              "assets/png/flag/vn.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        crossFadeState: lang == "en"
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // TODO: TAB
            Align(
              alignment: Alignment.bottomRight,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 400),
                height:
                    expandState == ExpandState.close ? 150 : height - 24 - 20,
                width: width - 100,
                curve: Curves.easeIn,
                padding: EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: SingleChildScrollView(
                        physics: currentAnimation == SearchState.openSearch
                            ? NeverScrollableScrollPhysics()
                            : BouncingScrollPhysics(),
                        controller: _scrollController,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          locText,
                                          style: GoogleFonts.rokkitt(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        width: 130,
                                        decoration: BoxDecoration(
                                          color: AppColors.yellow,
                                          // border: Border.all(
                                          //     color: AppColors.black, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                loc.covid.detail,
                                                style: GoogleFonts.rokkitt(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Icon(
                                                SimpleLineIcons.info,
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 1.5,
                                    width: width - 130,
                                    color: AppColors.black,
                                    margin: EdgeInsets.only(top: 9.75),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    height: expandState == ExpandState.close
                                        ? 0
                                        : 200,
                                    child: onAnimated
                                        ? null
                                        : Stack(
                                            children: [
                                              Center(
                                                child: Column(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Text(
                                                        loc.covid.general,
                                                        style:
                                                            GoogleFonts.rokkitt(
                                                                fontSize: 27),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    "${((covidData.totalDeaths / covidData.totalConfirmed) * 100).toStringAsFixed(3)} %",
                                                                    style: GoogleFonts.rokkitt(
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  Text(
                                                                    loc.covid
                                                                        .mortality,
                                                                    style: GoogleFonts.rokkitt(
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  Text(
                                                                    "${((covidData.totalRecovered / covidData.totalConfirmed) * 100).toStringAsFixed(3)} %",
                                                                    style: GoogleFonts.rokkitt(
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                  Text(
                                                                    loc.covid
                                                                        .recoveryRate,
                                                                    style: GoogleFonts.rokkitt(
                                                                        fontSize:
                                                                            17),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          Center(
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  "${((covidData.newConfirmed / covidData.totalConfirmed) * 100).toStringAsFixed(3)} %",
                                                                  style: GoogleFonts
                                                                      .rokkitt(
                                                                          fontSize:
                                                                              17),
                                                                ),
                                                                Text(
                                                                  loc.covid
                                                                      .increaseRate,
                                                                  style: GoogleFonts
                                                                      .rokkitt(
                                                                          fontSize:
                                                                              17),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  height: 1.5,
                                                  width: width - 130,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 400),
                                    height: expandState == ExpandState.close
                                        ? 0
                                        : 45,
                                    child: onAnimated
                                        ? null
                                        : CustomTabBar(
                                            initPage: 0,
                                            height:
                                                expandState == ExpandState.close
                                                    ? 0
                                                    : 45,
                                            width: width - 130,
                                            onPageChanged: (newPage) {
                                              _pageController.animateToPage(
                                                newPage,
                                                duration:
                                                    Duration(milliseconds: 400),
                                                curve: Curves.decelerate,
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 400),
                              height: expandState == ExpandState.close
                                  ? 0
                                  : height -
                                      24 -
                                      20 -
                                      10 -
                                      60 -
                                      11.5 -
                                      200 -
                                      57 -
                                      50 -
                                      7.5,
                              padding: const EdgeInsets.only(top: 10),
                              child: onAnimated
                                  ? null
                                  : PageView(
                                      controller: _pageController,
                                      physics: NeverScrollableScrollPhysics(),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            children: List.generate(
                                              symptom.length,
                                              (index) => ListCovidWidget(
                                                covidTile: symptom[index],
                                                height: (height -
                                                        24 -
                                                        20 -
                                                        10 -
                                                        60 -
                                                        11.5 -
                                                        200 -
                                                        57 -
                                                        50 -
                                                        7.5 -
                                                        30) /
                                                    3,
                                                margin: EdgeInsets.only(
                                                    bottom: index ==
                                                            symptom.length - 1
                                                        ? 0
                                                        : 8.5),
                                                language: loc.getPath() ==
                                                        "locales/EN.json"
                                                    ? "en"
                                                    : "vi",
                                                width: width - 150,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            children: List.generate(
                                              prevention.length,
                                              (index) => ListCovidWidget(
                                                covidTile: prevention[index],
                                                height: (height -
                                                        24 -
                                                        20 -
                                                        10 -
                                                        60 -
                                                        11.5 -
                                                        200 -
                                                        57 -
                                                        50 -
                                                        7.5 -
                                                        30) /
                                                    3,
                                                margin: EdgeInsets.only(
                                                    bottom: index ==
                                                            prevention.length -
                                                                1
                                                        ? 0
                                                        : 8.5),
                                                language: loc.getPath() ==
                                                        "locales/EN.json"
                                                    ? "en"
                                                    : "vi",
                                                width: width - 150,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: ListView(
                                            physics: BouncingScrollPhysics(),
                                            children: List.generate(
                                              stayAtHome.length,
                                              (index) => ListCovidWidget(
                                                covidTile: stayAtHome[index],
                                                height: (height -
                                                        24 -
                                                        20 -
                                                        10 -
                                                        60 -
                                                        11.5 -
                                                        200 -
                                                        57 -
                                                        50 -
                                                        7.5 -
                                                        30) /
                                                    3,
                                                margin: EdgeInsets.only(
                                                    bottom: index ==
                                                            stayAtHome.length -
                                                                1
                                                        ? 0
                                                        : 8.5),
                                                language: loc.getPath() ==
                                                        "locales/EN.json"
                                                    ? "en"
                                                    : "vi",
                                                width: width - 150,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                            SizedBox(height: 9.75),
                            SizedBox(height: 50),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 20),
                        child: InkWell(
                          onTap: () {
                            if (onAnimated == false) {
                              if (openSearch && onLoading == false) {
                                onSearchTouch("");
                                Future.delayed(
                                  Duration(seconds: 1),
                                  () {
                                    Future.delayed(
                                        Duration(milliseconds: 400),
                                        () =>
                                            setState(() => onAnimated = false));
                                    if (expandState == ExpandState.open) {
                                      setState(() =>
                                          expandState = ExpandState.close);
                                    } else {
                                      setState(
                                          () => expandState = ExpandState.open);
                                    }
                                  },
                                );
                              } else {
                                Future.delayed(Duration(milliseconds: 400),
                                    () => setState(() => onAnimated = false));
                                if (expandState == ExpandState.open) {
                                  setState(
                                      () => expandState = ExpandState.close);
                                } else {
                                  setState(
                                      () => expandState = ExpandState.open);
                                }
                              }
                            }
                            onAnimated = true;
                          },
                          child: Container(
                            height: 50,
                            width: width - 130,
                            decoration: BoxDecoration(
                                color: AppColors.yellow,
                                borderRadius: BorderRadius.circular(4)),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  AnimatedCrossFade(
                                    crossFadeState:
                                        expandState == ExpandState.close
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                    firstChild: Text(
                                      loc.covid.expand,
                                      style: GoogleFonts.rokkitt(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    secondChild: Text(
                                      loc.covid.collapse,
                                      style: GoogleFonts.rokkitt(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    duration: Duration(milliseconds: 400),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.black, width: 1.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Transform.scale(
                                      scale: 2,
                                      child: FlareActor(
                                        "assets/flare/arrow.flr",
                                        animation:
                                            expandState == ExpandState.close
                                                ? "downToUp"
                                                : "upToDown",
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (onChangedLang)
                      TweenAnimationBuilder<double>(
                        duration: Duration(milliseconds: 400),
                        tween: Tween<double>(begin: 0.2, end: 0),
                        builder: (context, value, child) => Opacity(
                          opacity: value,
                          child: Container(
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberTile({
    @required Color color,
    @required Color arrowColor,
    @required int oldNumber,
    @required int newNumber,
    @required int oldIncreaseNumber,
    @required int newIncreaseNumber,
    @required String type,
    String state,
  }) =>
      CaseTile(
        arrowColor: arrowColor,
        color: color,
        newIncreaseNumber: newIncreaseNumber,
        newNumber: newNumber,
        oldIncreaseNumber: oldIncreaseNumber,
        oldNumber: oldNumber,
        state: state,
        type: type,
        opacity: onChangedLang,
      );
}
