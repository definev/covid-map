import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocaleBase {
  Map<String, dynamic> _data;
  String _path;
  Future<void> load(String path) async {
    _path = path;
    final strJson = await rootBundle.loadString(path);
    _data = jsonDecode(strJson);
    initAll();
  }
  
  Map<String, String> getData(String group) {
    return Map<String, String>.from(_data[group]);
  }

  String getPath() => _path;

  Localecovid _covid;
  Localecovid get covid => _covid;

  void initAll() {
    _covid = Localecovid(Map<String, String>.from(_data['covid']));
  }
}

class Localecovid {
  final Map<String, String> _data;
  Localecovid(this._data);

  String get confirmed => _data["confirmed"];
  String get recovered => _data["recovered"];
  String get death => _data["death"];
  String get searchHintText => _data["searchHintText"];
  String get nothing => _data["nothing"];
  String get navigate => _data["navigate"];
  String get detail => _data["detail"];
  String get expand => _data["expand"];
  String get collapse => _data["collapse"];
  String get symptom => _data["symptom"];
  String get whatShouldYouDo => _data["whatShouldYouDo"];
  String get prevention => _data["prevention"];
  String get general => _data["general"];
  String get mortality => _data["mortality"];
  String get recoveryRate => _data["recoveryRate"];
  String get increaseRate => _data["increaseRate"];
}
