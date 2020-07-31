// To parse this JSON data, do
//
//     final countryGeoData = countryGeoDataFromJson(jsonString);

import 'dart:convert';

CountryGeoData countryGeoDataFromJson(String str) =>
    CountryGeoData.fromJson(json.decode(str));

String countryGeoDataToJson(CountryGeoData data) => json.encode(data.toJson());

class CountryGeoData {
  CountryGeoData({
    this.location,
    this.countryCode,
    this.latitude,
    this.longitude,
    this.confirmed,
    this.dead,
    this.recovered,
  });

  final String location;
  final String countryCode;
  final double latitude;
  final double longitude;
  final int confirmed;
  final int dead;
  final int recovered;

  CountryGeoData copyWith({
    String location,
    String countryCode,
    double latitude,
    double longitude,
    int confirmed,
    int dead,
    int recovered,
  }) =>
      CountryGeoData(
        location: location ?? this.location,
        countryCode: countryCode ?? this.countryCode,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        confirmed: confirmed ?? this.confirmed,
        dead: dead ?? this.dead,
        recovered: recovered ?? this.recovered,
      );

  factory CountryGeoData.fromJson(Map<String, dynamic> json) => CountryGeoData(
        location: json["location"],
        countryCode: json["country_code"],
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
        confirmed: json["confirmed"],
        dead: json["dead"],
        recovered: json["recovered"],
      );

  Map<String, dynamic> toJson() => {
        "location": location,
        "country_code": countryCode,
        "latitude": latitude,
        "longitude": longitude,
        "confirmed": confirmed,
        "dead": dead,
        "recovered": recovered,
      };
}
