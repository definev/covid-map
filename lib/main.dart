import 'package:covid_map/utils/fluster.dart';
import 'package:flutter/material.dart';
import 'package:covid_map/app.dart';
import 'package:covid_map/cache/flutter_challenge_cache.dart';
import 'package:flutter_google_maps/flutter_google_maps.dart';

void main() async {
  GoogleMap.init("AIzaSyDuvddDD1X6chXF1zIp7XY2XKaVKJpUegw");
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterChallengeCache.init();
  await CovidCluster.init();
  runApp(MyApp());
}
