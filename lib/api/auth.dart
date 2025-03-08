import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vn_trackpal/data/account_profile.dart';
import 'package:vn_trackpal/data/data_holder.dart';
import 'package:vn_trackpal/utils/msg.dart';

const loginEndpoint = 'http://192.168.0.185:5000/api/v1/Auth/login';
const signUpEndpoint = 'http://192.168.0.185:5000/api/v1/Auth/register';

class AuthApi {

  static Future<bool> login(
      {required String email, required String password, required BuildContext context}) async {
    var url = Uri.parse(loginEndpoint);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 10)); // Set a timeout of 10 seconds

      log(jsonEncode(response.body));
      if (response.statusCode == 200) {
        await getProfile(response.body);
        return true;
      } else {
        Utils.showToast(json.decode(response.body)['errors'][0]['message'], context);
      }
    } on TimeoutException catch (_) {
      Utils.showToast('Server is not responding. Please try again later.', context);
    } on SocketException catch (_) {
      Utils.showToast('No internet connection. Please check your network settings.', context);
    } catch (e) {
      Utils.showToast('An unexpected error occurred. Please try again.', context);
      log('Login error: $e');
    }
    return false;
  }

  static Future<bool> register({required String email, required String password, required BuildContext context}) async {
    var url = Uri.parse(signUpEndpoint);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email, "password": password}),
      );
      log(jsonEncode(response.body));
      if (response.statusCode == 200) {
        await getProfile(response.body);

        return true;
      } else {
        Utils.showToast(json.decode(response.body)['errors']['message'], context);
      }
    } on TimeoutException catch (_) {
      Utils.showToast('Server is not responding. Please try again later.', context);
    } on SocketException catch (_) {
      Utils.showToast('No internet connection. Please check your network settings.', context);
    } catch (e) {
      Utils.showToast('An unexpected error occurred. Please try again.', context);
      log('Login error: $e');
    }
    return false;
  }

  static Future<AccountProfile> getProfile(String response) async {
      var data = jsonDecode(response)['authUserDTO'];
      //String name = data['fullName'];
      String username = data['email'];
      String name = username;
      UserData().setName(name);
      UserData().setUsername(username);
      //await _storage.write(key: 'name', value: name);
      return AccountProfile.fromJson(data);
  }
}
