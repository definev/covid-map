import 'package:flutter_challenger/api/flutter_challenge_api.dart';
import 'package:flutter_challenger/cache/cache_route/cache_route.dart';
import 'package:flutter_challenger/model/country_covid_data.dart';
import 'package:flutter_challenger/model/country_geo_data.dart';
import 'package:flutter_challenger/model/covid_data.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

initApiData() async {
  Map<String, dynamic> data = await FlutterChallengerApi.covidapi.getAllData();
  FlutterChallengeCache.covidCache
      .setCountryCodeList(data[CacheRoute.countries]);
  FlutterChallengeCache.covidCache.setCovidData(data[CacheRoute.global]);
  FlutterChallengeCache.covidCache
      .setDate(DateTime.parse(data[CacheRoute.date]));

  List<CountryGeoData> countryGeoDataList =
      await FlutterChallengerApi.covidapi.getCountryGeoData();

  if (countryGeoDataList.isNotEmpty) {
    FlutterChallengeCache.covidCache.setCountryGeoData(countryGeoDataList);
  }
}

class FlutterChallengeCache {
  static CovidCache covidCache;

  static init() async {
    await Hive.initFlutter();
    covidCache = CovidCache();
    await covidCache.init();
    await initApiData();
  }
}

class CovidCache {
  Box box;

  init() async {
    box = await Hive.openBox("covidCache");
    if (box.get("lang") == null) box.put("lang", "en");
  }

  List<CountryCovidData> get countryCovidData {
    List<Map<String, dynamic>> data = box.get(CacheRoute.countries);

    if (data != null)
      return data
          .map<CountryCovidData>((Map<String, dynamic> countryCode) =>
              CountryCovidData.fromJson(countryCode))
          .toList();
    else
      return null;
  }

  CountryCovidData getCovidDataByName(String name) {
    List<CountryCovidData> data =
        FlutterChallengeCache.covidCache.countryCovidData;
    CountryCovidData res = data.firstWhere(
      (covidData) {
        print("NAME: ${name.toLowerCase()}");
        print(
            "COUNTRY: ${covidData.country.replaceAll(" ", "").toLowerCase()}");
        print(
            "CODE: ${covidData.countryCode.replaceAll(" ", "").toLowerCase()}");
        print("");
        return covidData.country.replaceAll(" ", "").toLowerCase() ==
                name.replaceAll(" ", "replace").toLowerCase() ||
            covidData.countryCode.replaceAll(" ", "").toLowerCase() ==
                name.replaceAll(" ", "replace").toLowerCase();
      },
      orElse: () => null,
    );

    return res == null ? null : res;
  }

  String get currentLang => box.get("lang");

  void setLang(String newLang) => box.put("lang", newLang);

  void setCountryCodeList(List<CountryCovidData> countryCovidData) => box.put(
        CacheRoute.countries,
        countryCovidData.map((countryCode) => countryCode.toJson()).toList(),
      );

  CovidData get globalCovidData =>
      CovidData.fromJson(box.get(CacheRoute.global));
  void setCovidData(CovidData covidData) =>
      box.put(CacheRoute.global, covidData.toJson());

  DateTime get updatedDate => DateTime.parse(box.get(CacheRoute.date));
  void setDate(DateTime dateTime) =>
      box.put(CacheRoute.date, dateTime.toIso8601String());

  void setCountryGeoData(List<CountryGeoData> countryGeoDataList) => box.put(
      CacheRoute.countryGeoDataList,
      countryGeoDataList
          .map((countryGeoData) => countryGeoData.toJson())
          .toList());

  LatLng getLatLngFromName(String country) {
    List<CountryGeoData> listData = box
        .get(CacheRoute.countryGeoDataList)
        .map<CountryGeoData>(
            (countryGeoData) => CountryGeoData.fromJson(countryGeoData))
        .toList();

    CountryGeoData res = listData.firstWhere(
        (CountryGeoData data) =>
            country.replaceAll(" ", "replace").toLowerCase() ==
                data.location.replaceAll(" ", "replace").toLowerCase() ||
            country.replaceAll(" ", "replace").toLowerCase() ==
                data.countryCode.replaceAll(" ", "replace").toLowerCase(),
        orElse: () => null);

    return res == null ? null : LatLng(res.latitude, res.longitude);
  }
}
