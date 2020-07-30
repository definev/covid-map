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
  });

  final String location;
  final String countryCode;
  final double latitude;
  final double longitude;

  factory CountryGeoData.fromJson(Map<String, dynamic> json) => CountryGeoData(
        location: json["location"],
        countryCode: json["country_code"],
        latitude: json["latitude"].toDouble(),
        longitude: json["longitude"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "location": location,
        "country_code": countryCode,
        "latitude": latitude,
        "longitude": longitude,
      };
}
