// To parse this JSON data, do
//
//     final covidData = covidDataFromJson(jsonString);

import 'dart:convert';

CovidData covidDataFromJson(String str) => CovidData.fromJson(json.decode(str));

String covidDataToJson(CovidData data) => json.encode(data.toJson());

class CovidData {
  CovidData({
    this.newConfirmed,
    this.totalConfirmed,
    this.newDeaths,
    this.totalDeaths,
    this.newRecovered,
    this.totalRecovered,
  });

  final int newConfirmed;
  final int totalConfirmed;
  final int newDeaths;
  final int totalDeaths;
  final int newRecovered;
  final int totalRecovered;

  factory CovidData.fromJson(Map<String, dynamic> json) => CovidData(
        newConfirmed: json["NewConfirmed"],
        totalConfirmed: json["TotalConfirmed"],
        newDeaths: json["NewDeaths"],
        totalDeaths: json["TotalDeaths"],
        newRecovered: json["NewRecovered"],
        totalRecovered: json["TotalRecovered"],
      );

  Map<String, dynamic> toJson() => {
        "NewConfirmed": newConfirmed,
        "TotalConfirmed": totalConfirmed,
        "NewDeaths": newDeaths,
        "TotalDeaths": totalDeaths,
        "NewRecovered": newRecovered,
        "TotalRecovered": totalRecovered,
      };
}
