import 'package:covid_map/model/country_geo_data.dart';
import 'package:covid_map/utils/fluster.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CovidMarker extends Clusterable {
  final String id;
  final CountryGeoData countryGeoData;
  final BitmapDescriptor icon;
  final Function() onMarkerTap;

  CovidMarker({
    @required this.id,
    @required this.countryGeoData,
    @required this.icon,
    this.onMarkerTap,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
          markerId: id,
          latitude: countryGeoData.latitude,
          longitude: countryGeoData.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  Marker toMarker() => Marker(
        markerId: MarkerId(id),
        position: LatLng(
          countryGeoData.latitude,
          countryGeoData.longitude,
        ),
        icon: CovidCluster.bitmapDescriptor,
        onTap: onMarkerTap,
      );

  CovidMarker copyWith({
    String id,
    CountryGeoData countryGeoData,
    BitmapDescriptor icon,
    Function() onMarkerTap,
  }) =>
      CovidMarker(
        countryGeoData: countryGeoData ?? this.countryGeoData,
        id: id ?? this.id,
        icon: icon ?? this.icon,
        onMarkerTap: onMarkerTap ?? this.onMarkerTap,
        clusterId: this.clusterId,
        isCluster: this.isCluster,
        pointsSize: this.pointsSize,
        childMarkerId: this.childMarkerId,
      );
}
