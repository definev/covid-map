import 'package:flutter/material.dart';
import 'package:covid_map/app.dart';
import 'package:covid_map/cache/flutter_challenge_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterChallengeCache.init();
  runApp(MyApp());
}
