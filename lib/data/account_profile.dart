// To parse this JSON data, do
//
//     final accountProfile = accountProfileFromJson(jsonString);

import 'dart:convert';

AccountProfile accountProfileFromJson(String str) => AccountProfile.fromJson(json.decode(str));

String accountProfileToJson(AccountProfile data) => json.encode(data.toJson());
 final Map<String, String> _genderMap = {
    'Nam': 'Male',
    'Nữ': 'Female',
    'Male' : 'Nam',
    'Female' : 'Nữ'
  };

  // Method to get English gender
  String _convertGender(String gender) {
    return _genderMap[gender] ?? gender;
  }

class AccountProfile {
    String? id;
    String? name;
    String? email;
    //Bool? ispre;
    int? age;
    String? gender;
    int? weight;
    int? height;
    //String? phone;
    String? avatar;
    //double? walletId;
    //double? walletPoint;
    //String? facebookLink;
    //String? linkedinLink;
    //String? twitterLink;
    //String? youtubeLink;

    AccountProfile({
        this.id,
        this.name,
        this.email,
        //this.ispre,
        this.age,
        this.gender,
        this.weight,
        this.height,
        this.avatar,
        //this.walletId,
        //this.walletPoint,
        //this.facebookLink,
        //this.linkedinLink,
        //this.twitterLink,
        //this.youtubeLink,
    });

    AccountProfile copyWith({
        int? id,
        String? name,
        String? email,
        //Bool? ispre,
        int? age,
        String? gender,
        int? weight,
        int? height,
        String? avatar,
        //double? walletId,
        //double? walletPoint,
        //String? facebookLink,
        //String? linkedinLink,
        //String? twitterLink,
        //String? youtubeLink,
    }) => 
        AccountProfile(
            //id: id ?? this.id,
            name: name ?? this.name,
            email: email ?? this.email,
            //ispre: ispre ?? this.ispre,
            age: age ?? this.age,
            gender: gender ?? this.gender,
            weight: weight ?? this.weight,
            height: height ?? this.height,
            avatar: avatar ?? this.avatar,
            //walletId: walletId ?? this.walletId,
            //walletPoint: walletPoint ?? this.walletPoint,
            //facebookLink: facebookLink ?? this.facebookLink,
            //linkedinLink: linkedinLink ?? this.linkedinLink,
            //twitterLink: twitterLink ?? this.twitterLink,
            //youtubeLink: youtubeLink ?? this.youtubeLink,
        );

    factory AccountProfile.fromJson(Map<String, dynamic> json) => AccountProfile(
        id: json["id"],
        name: json["fullName"],
        email: json["email"],
        //ispre: json["ispre"]??false,
        age: json["age"],
        gender: json["gender"] == null ? null : _convertGender(json["gender"]),
        weight: json["weight"],
        height: json["height"],
        avatar: json["avatarUrl"],
        //walletId: json["walletId"]?.toDouble(),
        //walletPoint: json["walletPoint"]?.toDouble(),
        //facebookLink: json["facebookLink"],
        //linkedinLink: json["linkedinLink"],
        //twitterLink: json["twitterLink"],
        //youtubeLink: json["youtubeLink"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "fullName": name,
        "email": email,
        //"ispre": ispre,
        "age": age,
        "gender": gender,
        "weight": weight,
        "height": height,
        "avatarUrl": avatar,
        //"walletId": walletId,
        //"walletPoint": walletPoint,
        //"facebookLink": facebookLink,
        //"linkedinLink": linkedinLink,
        //"twitterLink": twitterLink,
        //"youtubeLink": youtubeLink,
    };
}
