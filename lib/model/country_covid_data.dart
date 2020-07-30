// To parse this JSON data, do
//
//     final countryCovidData = countryCovidDataFromJson(jsonString);

import 'dart:convert';

import 'package:flutter_challenger/model/covid_data.dart';

CountryCovidData countryCovidDataFromJson(String str) =>
    CountryCovidData.fromJson(json.decode(str));

String countryCovidDataToJson(CountryCovidData data) =>
    json.encode(data.toJson());

class CountryCovidData {
  CountryCovidData({
    this.country,
    this.countryCode,
    this.slug,
    this.newConfirmed,
    this.totalConfirmed,
    this.newDeaths,
    this.totalDeaths,
    this.newRecovered,
    this.totalRecovered,
    this.date,
  });

  final String country;
  final String countryCode;
  final String slug;
  final int newConfirmed;
  final int totalConfirmed;
  final int newDeaths;
  final int totalDeaths;
  final int newRecovered;
  final int totalRecovered;
  final DateTime date;

  factory CountryCovidData.fromJson(Map<String, dynamic> json) =>
      CountryCovidData(
        country: json["Country"],
        countryCode: json["CountryCode"],
        slug: json["Slug"],
        newConfirmed: json["NewConfirmed"],
        totalConfirmed: json["TotalConfirmed"],
        newDeaths: json["NewDeaths"],
        totalDeaths: json["TotalDeaths"],
        newRecovered: json["NewRecovered"],
        totalRecovered: json["TotalRecovered"],
        date: DateTime.parse(json["Date"]),
      );

  Map<String, dynamic> toJson() => {
        "Country": country,
        "CountryCode": countryCode,
        "Slug": slug,
        "NewConfirmed": newConfirmed,
        "TotalConfirmed": totalConfirmed,
        "NewDeaths": newDeaths,
        "TotalDeaths": totalDeaths,
        "NewRecovered": newRecovered,
        "TotalRecovered": totalRecovered,
        "Date": date.toIso8601String(),
      };

  CovidData getCovidData() {
    return CovidData(
      newConfirmed: this.newConfirmed,
      newDeaths: this.newDeaths,
      newRecovered: this.newRecovered,
      totalConfirmed: this.totalConfirmed,
      totalDeaths: this.totalDeaths,
      totalRecovered: this.totalRecovered,
    );
  }
}
