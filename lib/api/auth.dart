import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vn_trackpal/data/account_profile.dart';
import 'package:vn_trackpal/utils/msg.dart';

const loginEndpoint = 'http://192.168.0.185:5000/api/v1/Auth/login';
const signUpEndpoint = 'http://192.168.0.185:5000/api/v1/Auth/register';
const persistentLoginEnpoint = 'http://192.168.0.185:5000/api/v1/Auth/refresh-token';

class AuthApi {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<bool> login(
      {required String email, required String password, required BuildContext context, bool saveCredential = false}) async {
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
        String? setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null) {
          // Parse the cookie
          String refreshToken = _parseRefreshTokenFromCookie(setCookieHeader);
          if (saveCredential) {
            await saveCredentials(refreshToken);
          }
        } else {
          log('No Set-Cookie header found in the response');
        }
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

  static Future<bool> persistentLogin(
      {required String refreshToken}) async {
    var url = Uri.parse(persistentLoginEnpoint);
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          'Cookie' : refreshToken
        }
      ).timeout(const Duration(seconds: 10)); // Set a timeout of 10 seconds

      log(jsonEncode(response.body));
      if (response.statusCode == 200) {
        await getProfile(response.body);
        return true;
      }
    } on TimeoutException catch (_) {
      //Utils.showToast('Server is not responding. Please try again later.', context);
    } on SocketException catch (_) {
      //Utils.showToast('No internet connection. Please check your network settings.', context);
    } catch (e) {
      //Utils.showToast('An unexpected error occurred. Please try again.', context);
      //log('Login error: $e');
    }
    return false;
  }

  static Future<bool> register({required String email, required String password, required BuildContext context, bool saveCredential = false}) async {
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
        String? setCookieHeader = response.headers['set-cookie'];
        if (setCookieHeader != null) {
          // Parse the cookie
          String refreshToken = _parseRefreshTokenFromCookie(setCookieHeader);
          if (saveCredential) {
            await saveCredentials(refreshToken);
          }
        } else {
          log('No Set-Cookie header found in the response');
        }
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
      _storage.write(key: 'username', value: username);
      _storage.write(key: 'name', value: name);
      //await _storage.write(key: 'name', value: name);
      return AccountProfile.fromJson(data);
  }

  static Future<bool> loadCredentials() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/credentials.bin');
      
      if (await file.exists()) {
        final encryptedContents = await file.readAsBytes();
        final key = await _deriveKeyFromUuid();
        final iv = encrypt.IV.fromBase64('AQIDBAUGBwgIBwYFBAMCAQ==');

        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        final decryptedContents  = encrypter.decrypt(encrypt.Encrypted(encryptedContents), iv: iv);
        return await persistentLogin(refreshToken : decryptedContents);

      } else {
        log('Credentials file does not exist');
      }
    } catch (e) {
      log('Error loading credentials: $e');
    }
    return false;
  }

  static Future<void> saveCredentials(String refreshToken) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/credentials.bin');

      final key = await _deriveKeyFromUuid();
      final iv = encrypt.IV.fromBase64('AQIDBAUGBwgIBwYFBAMCAQ==');

      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(refreshToken, iv: iv);

      await file.writeAsBytes(encrypted.bytes);
    } catch (e) {
      log('Error saving credentials: $e');
    }
  }

  static Future<bool> deleteCredentials() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/credentials.bin');
      
      if (await file.exists()) {
        await file.delete();
        log('Credentials file deleted successfully');
        return true;
      } else {
        log('Credentials file does not exist');
        return false;
      }
    } catch (e) {
      log('Error deleting credentials: $e');
      return false;
    }
  }

  static Future<String> _getDeviceUuid() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String uuid = '';

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        uuid = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        uuid = iosInfo.identifierForVendor!;
      } else {
        // For other platforms
        uuid = "c00aaa8e-c603-49de-ac2a-d6655368b7cf";
      }
    } catch (e) {
      log('Error getting device UUID: $e');
      // If there's an error
      uuid = "c00aaa8e-c603-49de-ac2a-d6655368b7cf";
    }

    return uuid;
  }

  static Future<encrypt.Key> _deriveKeyFromUuid() async {
    String uuid = await _getDeviceUuid();
    List<int> uuidBytes = utf8.encode(uuid);
    Digest sha256Result = sha256.convert(uuidBytes);
    String keyString = sha256Result.toString().substring(0, 32); // Take first 32 characters (256 bits)
    return encrypt.Key.fromUtf8(keyString);
  }

  static String _parseRefreshTokenFromCookie(String setCookieHeader) {
  // Split the header into individual cookies
  List<String> cookies = setCookieHeader.split(',');
  
  // Find the refresh token cookie
  for (String cookie in cookies) {
    if (cookie.trim().startsWith('RefreshToken=')) {
      // Extract the token value
      //int startIndex = cookie.indexOf('=') + 1;
      //int endIndex = cookie.indexOf(';');
      //if (endIndex == -1) endIndex = cookie.length;
      return cookie;
    }
  }
  
  // If no refresh token found, return an empty string
  return '';
}
}
