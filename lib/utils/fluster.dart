import 'package:covid_map/cache/flutter_challenge_cache.dart';
import 'package:covid_map/model/country_geo_data.dart';
import 'package:covid_map/model/covid_marker.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CovidCluster {
  static final List<CovidMarker> markers = [];

  static final List<CountryGeoData> markerLocations =
      FlutterChallengeCache.covidCache.getAllLocation;
  static Fluster<CovidMarker> fluster;

  static BitmapDescriptor bitmapDescriptor;

  static init() async {
    markerLocations.forEach((latLng) {
      markers.add(
        CovidMarker(
            id: markerLocations.indexOf(latLng).toString(),
            countryGeoData: latLng,
            icon: null),
      );
    });

    await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5, size: Size(60, 60)),
      "assets/png/coronavirus/png/marker.png",
    ).then((value) {
      bitmapDescriptor = value;
      int count = -1;

      fluster = Fluster<CovidMarker>(
        minZoom: 2, // The min zoom at clusters will show
        maxZoom: 4, // The max zoom at clusters will show
        radius: 100, // Cluster radius in pixels
        extent: 2048, // Tile extent. Radius is calculated with it.
        nodeSize: 64, // Size of the KD-tree leaf node.
        points: CovidCluster.markers, // The list of markers created before
        createCluster: (
          // Create cluster marker
          BaseCluster cluster,
          double lng,
          double lat,
        ) {
          if (count < markerLocations.length - 1) count++;

          return CovidMarker(
            id: cluster.id.toString(),
            countryGeoData: CovidCluster.markerLocations[count],
            icon: bitmapDescriptor,
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
          );
        },
      );
    });
  }
}
