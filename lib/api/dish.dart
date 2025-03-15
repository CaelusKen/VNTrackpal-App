import 'dart:convert';
import 'dart:developer';
import 'dart:io';

//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/data/dish_data.dart';

const IP = 'http://192.168.1.35:5000';
const getDishesEndpoint = '$IP/api/v1/Dish/get-dishes';
const recommendDishesEndpoint = '$IP/api/v1/Recommend/recommend-dish';
class DishApi {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  static Future<List<DishData>> getDishes({String search ='', int pageSize =20, int pageIndex=1}) async {
    String finalurl = search.isEmpty ? '$getDishesEndpoint?pageSize=$pageSize&pageIndex=$pageIndex' : '$getDishesEndpoint?searchTerm=$search&pageSize=$pageSize&pageIndex=$pageIndex';
    var url = Uri.parse(finalurl);
    //String? accessToken = await _storage.read(key: 'accessToken');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8'// Uncomment this line if you need authorization header,
        //'Authorization': 'Bearer $accessToken'
      },
    );
    log(jsonEncode(response.body.toString()));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)["value"]["data"]["dishes"];
      List<DishData> dishList = dishDataListFromJson(data);
      return dishList;
    }
    return [];
  }

  static Future<List<DishData>> getRecomendDishes({required String activityLevel, required String target}) async {
    bool cansend = await AuthApi.ensureValidAccessToken();
    if (!cansend) exit(-1);
    String finalurl = '$recommendDishesEndpoint?activityLevel=$activityLevel&target=$target';
    var url = Uri.parse(finalurl);
    String? accessToken = await _storage.read(key: 'accessToken');
    final response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken'
      },
    );
    log(jsonEncode(response.body.toString()));
    if (response.statusCode == 200) {
      info(jsonDecode(response.body)["value"]["data"]);
      var data = jsonDecode(response.body)["value"]["data"]["dishes"];
      List<DishData> dishList = dishDataListFromJson2(data);
      return dishList;
    }
    return [];
  }
  
  static Future<void> info(dynamic jsonDecode) async {
    await _storage.write(key: 'calorie', value: jsonDecode['tdee'].toString());
    await _storage.write(key: 'carb', value: jsonDecode['carb'].toString());
    await _storage.write(key: 'fat', value: jsonDecode['fat'].toString());
    await _storage.write(key: 'protein', value: jsonDecode['protein'].toString());
  }
}