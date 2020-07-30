// To parse this JSON data, do
//
//     final covidTile = covidTileFromJson(jsonString);

import 'dart:convert';

import 'package:covid_map/resources/resources.dart';

CovidTile covidTileFromJson(String str) => CovidTile.fromJson(json.decode(str));

String covidTileToJson(CovidTile data) => json.encode(data.toJson());

class CovidTile {
  CovidTile({
    this.vi,
    this.en,
    this.imageUrl,
  });

  final String vi;
  final String en;
  final String imageUrl;

  CovidTile copyWith({
    String vi,
    String en,
    String imageUrl,
  }) =>
      CovidTile(
        vi: vi ?? this.vi,
        en: en ?? this.en,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  factory CovidTile.fromJson(Map<String, dynamic> json) => CovidTile(
        vi: json["vi"],
        en: json["en"],
        imageUrl: json["imageURL"],
      );

  Map<String, dynamic> toJson() => {
        "vi": vi,
        "en": en,
        "imageURL": imageUrl,
      };
}

List<CovidTile> symptom = [
  CovidTile(
    imageUrl: CoronaVirus.Headache,
    en: "Headache",
    vi: "Đau đầu",
  ),
  CovidTile(
    imageUrl: CoronaVirus.RunnyNose,
    en: "Runny nose",
    vi: "Sổ mũi",
  ),
  CovidTile(
    imageUrl: CoronaVirus.SoreThroat,
    en: "Sore throat",
    vi: "Đau họng",
  ),
  CovidTile(
    imageUrl: CoronaVirus.Fever,
    en: "Fever",
    vi: "Sốt",
  ),
  CovidTile(
    imageUrl: CoronaVirus.Vomit,
    en: "Vomit",
    vi: "Nôn mửa",
  ),
];

List<CovidTile> prevention = [
  CovidTile(
    imageUrl: CoronaVirus.CheckUp,
    en: "Medical declaration",
    vi: "Khai báo ý tế",
  ),
  CovidTile(
    imageUrl: CoronaVirus.PatientBoy,
    en: "Wear a face mask",
    vi: "Đeo khẩu trang",
  ),
  CovidTile(
    imageUrl: CoronaVirus.Distance,
    en: "Social distancing",
    vi: "giãn cách xã hội",
  ),
  CovidTile(
    imageUrl: CoronaVirus.Avoid,
    en: "Do not touch your face",
    vi: "Hạn chế chạm tay",
  ),
  CovidTile(
    imageUrl: CoronaVirus.Soap,
    en: "Washing your hands",
    vi: "Rửa tay",
  ),
  CovidTile(
    imageUrl: CoronaVirus.QuarantineDay,
    en: "Self isolation",
    vi: "Tự cách li",
  ),
];

List<CovidTile> stayAtHome = [
  CovidTile(
    imageUrl: StayAtHome.Reading,
    en: "Reading",
    vi: "Đọc sách",
  ),
  CovidTile(
    imageUrl: StayAtHome.Baking,
    en: "Learn baking",
    vi: "Học làm bánh",
  ),
  CovidTile(
    imageUrl: StayAtHome.Cleaning,
    en: "Cleaning",
    vi: "Dọn nhà",
  ),
  CovidTile(
    imageUrl: StayAtHome.Chess,
    en: "Board game",
    vi: "chơi board game",
  ),
  CovidTile(
    imageUrl: StayAtHome.Painting,
    en: "Learn to draw",
    vi: "Học vẽ",
  ),
  CovidTile(
    imageUrl: StayAtHome.Flower,
    en: "Take care of yourself",
    vi: "Chăm sóc bản thân",
  ),
  CovidTile(
    imageUrl: StayAtHome.Planning,
    en: "Planning",
    vi: "Lên kế hoạch",
  ),
  CovidTile(
    imageUrl: StayAtHome.OnlineLearning,
    en: "Online learning",
    vi: "Học online",
  ),
  CovidTile(
    imageUrl: StayAtHome.Gym,
    en: "Do exercise",
    vi: "Tập thể dục",
  ),
  CovidTile(
    imageUrl: StayAtHome.Playing,
    en: "Spend time with family",
    vi: "Chăm sóc gia đình",
  ),
];
