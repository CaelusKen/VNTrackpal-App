import 'dart:convert';

DishData dishDataFromJson(String str) => DishData.fromJson(json.decode(str));

String dishDataToJson(DishData data) => json.encode(data.toJson());

List<DishData> dishDataListFromJson(dynamic str) => 
    List<DishData>.from(str["items"].map((x) => DishData.fromJson(x)));
List<DishData> dishDataListFromJson2(dynamic str) => 
    List<DishData>.from(str.map((x) => DishData.fromJson(x)));

class DishData {
  String id;
  String name;
  String ingredient;
  String making;
  double totalCalories;
  double totalCarb;
  double totalProtein;
  double totalFat;
  ImageDish imageDish;

  DishData({
    required this.id,
    required this.name,
    required this.ingredient,
    required this.making,
    required this.totalCalories,
    required this.totalCarb,
    required this.totalProtein,
    required this.totalFat,
    required this.imageDish,
  });

  DishData copyWith({
    String? id,
    String? name,
    String? ingredient,
    String? making,
    double? totalCalories,
    double? totalCarb,
    double? totalProtein,
    double? totalFat,
    ImageDish? imageDish,
  }) =>
      DishData(
        id: id ?? this.id,
        name: name ?? this.name,
        ingredient: ingredient ?? this.ingredient,
        making: making ?? this.making,
        totalCalories: totalCalories ?? this.totalCalories,
        totalCarb: totalCarb ?? this.totalCarb,
        totalProtein: totalProtein ?? this.totalProtein,
        totalFat: totalFat ?? this.totalFat,
        imageDish: imageDish ?? this.imageDish,
      );

  factory DishData.fromJson(Map<String, dynamic> json) => DishData(
        id: json["id"],
        name: json["name"],
        ingredient: json["ingredient"],
        making: json["making"],
        totalCalories: json["totalCalories"].toDouble(),
        totalCarb: json["totalCarb"].toDouble(),
        totalProtein: json["totalProtein"].toDouble(),
        totalFat: json["totalFat"].toDouble(),
        imageDish: ImageDish.fromJson(json["imageDish"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "ingredient": ingredient,
        "making": making,
        "totalCalories": totalCalories,
        "totalCarb": totalCarb,
        "totalProtein": totalProtein,
        "totalFat": totalFat,
        "imageDish": imageDish.toJson(),
      };
}

class ImageDish {
  String publicId;
  String publicUrl;

  ImageDish({
    required this.publicId,
    required this.publicUrl,
  });

  ImageDish copyWith({
    String? publicId,
    String? publicUrl,
  }) =>
      ImageDish(
        publicId: publicId ?? this.publicId,
        publicUrl: publicUrl ?? this.publicUrl,
      );

  factory ImageDish.fromJson(Map<String, dynamic> json) => ImageDish(
        publicId: json["publicId"],
        publicUrl: json["publicUrl"],
      );

  Map<String, dynamic> toJson() => {
        "publicId": publicId,
        "publicUrl": publicUrl,
      };
}
