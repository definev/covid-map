import 'package:flutter/material.dart';
import 'package:flutter_challenger/app.dart';
import 'package:flutter_challenger/cache/flutter_challenge_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterChallengeCache.init();
  runApp(MyApp());
}
