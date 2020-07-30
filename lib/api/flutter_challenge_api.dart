import 'dart:convert';

import 'package:covid_map/api/api_route/covid_api_route.dart';
import 'package:covid_map/model/country_covid_data.dart';
import 'package:covid_map/model/country_geo_data.dart';
import 'package:covid_map/model/covid_data.dart';
import 'package:http/http.dart' as http;

class FlutterChallengerApi {
  static CovidApi covidapi = CovidApi();
}

class CovidApi {
  String apiHeader = "https://api.covid19api.com";

  Future<Map<String, dynamic>> getAllData() async {
    http.Response response =
        await http.get("${apiHeader + CovidApiRoute.summary}");

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);

      Map<String, dynamic> res = {};
      res["Global"] = CovidData.fromJson(data["Global"]);

      List<CountryCovidData> countryCovidDataList = data["Countries"]
          .map<CountryCovidData>(
              (countryCovidData) => CountryCovidData.fromJson(countryCovidData))
          .toList();

      res["Countries"] = countryCovidDataList;
      res["Date"] = data["Date"];

      return res;
    }

    return null;
  }

  Future<List<CountryGeoData>> getCountryGeoData() async {
    http.Response response =
        await http.get("https://www.trackcorona.live/api/countries");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<CountryGeoData> countryGeoData = data["data"]
          .map<CountryGeoData>(
              (countryGeo) => CountryGeoData.fromJson(countryGeo))
          .toList();

      return countryGeoData;
    }

    return null;
  }
}
