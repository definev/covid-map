import 'dart:typed_data';

import 'package:covid_map/cache/flutter_challenge_cache.dart';
import 'package:covid_map/model/country_covid_data.dart';
import 'package:covid_map/model/country_geo_data.dart';
import 'package:covid_map/model/covid_marker.dart';
import 'package:covid_map/utils/image_process.dart';
import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CovidCluster {
  static final Set<CovidMarker> markers = Set<CovidMarker>();

  static List<CountryGeoData> markerLocations =
      FlutterChallengeCache.covidCache.getAllLocation;
  static Fluster<CovidMarker> fluster;

  static BitmapDescriptor bitmapDescriptor;

  static List<BitmapDescriptor> bitmapList = [];

  static int getSizeOfInfection(int numOfCase) {
    if (numOfCase > 1000000) {
      return 440;
    } else if (numOfCase > 500000) {
      return 380;
    } else if (numOfCase > 300000) {
      return 300;
    } else if (numOfCase > 100000) {
      return 200;
    } else if (numOfCase > 50000) {
      return 130;
    } else {
      return 60;
    }
  }

  static init() async {
    List<CountryCovidData> countryCovidDataList =
        FlutterChallengeCache.covidCache.countryCovidData;

    List<CountryGeoData> mergeLocationList = [];

    countryCovidDataList.forEach((element) {
      CountryGeoData ele = markerLocations.firstWhere(
          (marker) =>
              marker.countryCode.toLowerCase() ==
              element.countryCode.toLowerCase(),
          orElse: () => null);
      if (ele != null) {
        mergeLocationList.add(ele);
      }
    });

    markerLocations = mergeLocationList;

    for (var i = 0; i < markerLocations.length; i++) {
      markers.add(
        CovidMarker(
          index: i,
          id: i.toString(),
          countryGeoData: markerLocations[i],
          icon: null,
        ),
      );
    }

    for (int i = 0; i < markers.length; i++) {
      Uint8List markerIcon = await getBytesFromAsset(
          "assets/png/coronavirus/png/marker.png",
          getSizeOfInfection(markers.elementAt(i).countryGeoData.confirmed));

      BitmapDescriptor bitmapDescriptor =
          BitmapDescriptor.fromBytes(markerIcon);

      bitmapList.add(bitmapDescriptor);
    }

    int count = -1;

    fluster = Fluster<CovidMarker>(
      minZoom: 2, // The min zoom at clusters will show
      maxZoom: 4, // The max zoom at clusters will show
      radius: 100, // Cluster radius in pixels
      extent: 2048, // Tile extent. Radius is calculated with it.
      nodeSize: 64, // Size of the KD-tree leaf node.
      points:
          CovidCluster.markers.toList(), // The list of markers created before
      createCluster: (
        // Create cluster marker
        BaseCluster cluster,
        double lng,
        double lat,
      ) {
        if (count < markerLocations.length - 1) count++;

        return markers.elementAt(count).copyWith(
              isCluster: cluster.isCluster,
              clusterId: cluster.id,
              pointsSize: cluster.pointsSize,
              childMarkerId: cluster.childMarkerId,
            );
      },
    );
  }
}
