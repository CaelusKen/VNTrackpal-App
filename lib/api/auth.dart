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

const IP = 'http://192.168.1.35:5000';
const loginEndpoint = '$IP/api/v1/Auth/login';
const loginWithEmailEndpoint = '$IP/api/v1/Auth/login-with-email';
const confirmLoginWithEmailEndpoint = '$IP/api/v1/Auth/confirm-login-with-email';
const signUpEndpoint = '$IP/api/v1/Auth/register';
const persistentLoginEnpoint = '$IP/api/v1/Auth/refresh-token';
const getProfileEndpoint = '$IP/api/v1/User/get-profile';
const updateProfileEndpoint = '$IP/api/v1/User/first-update-info-user';

class AuthApi {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<String> getRefreshToken(String? cookieheader) async {
    if (cookieheader != null) {
      // Parse the cookie
      String refreshToken = _parseRefreshTokenFromCookie(cookieheader);
      if (refreshToken.isEmpty) {
        log('No Set-Cookie header found in the response');
      }
      await _storage.write(key: 'refreshToken', value: refreshToken);
      return refreshToken;
    }
    log('No Set-Cookie header found in the response');
    return '';
  }

  static Future<String> getAndStoreAccessToken(String? responseBody) async {
    if (responseBody != null) {
      String? accessToken = json.decode(responseBody)['authTokenDTO']['accessToken'];
        if (accessToken != null) {
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'accessTokenExpiredAt', value: getTokenExpireSeconds(offset: 1500).toString());
          return accessToken;
        }
    }
    return '';
  }

  static int getTokenExpireSeconds({int offset = 0}) {
   return DateTime.now().millisecondsSinceEpoch ~/ 1000 + offset;
 }

  static Future<String> requestNewAccessToken({required String refreshToken}) async {
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
        String? accessToken = json.decode(response.body)['authTokenDTO']['accessToken'];
        if (accessToken!= null) {
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'accessTokenExpiredAt', value: getTokenExpireSeconds(offset: 1500).toString());
          return response.body;
        }
      }
    } on TimeoutException catch (_) {
      //Utils.showToast('Server is not responding. Please try again later.', context);
    } on SocketException catch (_) {
      //Utils.showToast('No internet connection. Please check your network settings.', context);
    } catch (e) {
      //Utils.showToast('An unexpected error occurred. Please try again.', context);
      //log('Login error: $e');
    }
    return '';
  }

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
        getAndStoreAccessToken(response.body);
        //await getProfile(response.body);
        String cookie = await getRefreshToken(response.headers['set-cookie']);
        if (cookie.isNotEmpty) {
          if (saveCredential) {
            await saveCredentials(cookie);
          }
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

  static Future<bool> loginWithOnlyEmail(
      {required String email, required BuildContext context}) async {
    var url = Uri.parse(loginWithEmailEndpoint);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email}),
      ).timeout(const Duration(seconds: 10)); // Set a timeout of 10 seconds

      log(jsonEncode(response.body));
      if (response.statusCode == 200) {
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

  static Future<bool> confirmLoginWithEmail(
    {required String email, required String code, required BuildContext context, bool saveCredential = false}) async {
    var url = Uri.parse(confirmLoginWithEmailEndpoint);
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"email": email, "otp" : code}),
      ).timeout(const Duration(seconds: 10)); // Set a timeout of 10 seconds

      log(jsonEncode(response.body));
      if (response.statusCode == 200) {
        getAndStoreAccessToken(response.body);
        //await getProfile(response.body);
        String cookie = await getRefreshToken(response.headers['set-cookie']);
        if (cookie.isNotEmpty) {
          if (saveCredential) {
            await saveCredentials(cookie);
          }
        }
        return true;
      } else {
        if (response.statusCode == 400) {
          Utils.showToast("Mã OTP không đúng. Vui lòng thử lại.", context);
        }
        return false;
        //Utils.showToast(json.decode(response.body)['errors'][0]['message'], context);
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
    String response = await requestNewAccessToken(refreshToken: refreshToken);
    if (response.isEmpty) {
      return false;
    }
    //try {
    //  await getProfile(response);
    //} catch (e) {
    //  log('Login error: $e');
    //}
    return true;
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
        getAndStoreAccessToken(response.body);
        //await getProfile(response.body);
        String cookie = await getRefreshToken(response.headers['set-cookie']);
        if (cookie.isNotEmpty) {
          if (saveCredential) {
            await saveCredentials(cookie);
          }
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

  static Future<AccountProfile> getProfile() async {
    var url = Uri.parse(getProfileEndpoint);
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
      var data = jsonDecode(response.body)['value']['data']['user'];
      String? name = data['fullName'];
      if (name != null) {
        await _storage.write(key: 'name', value: name);
      }
      return AccountProfile.fromJson(data);
    }
    throw Exception('Failed to fetch profile');
  }

  static Future<bool> updateProfile({required String username, required String name, required String age, required String gender, required String weight, required String height, required BuildContext context}) async {
    bool cansend = await ensureValidAccessToken();
    if (!cansend) exit(-1);
    var url = Uri.parse(updateProfileEndpoint);
    String? id = await _storage.read(key: 'id')??"";
    String? accessToken = await _storage.read(key: 'accessToken');
    try {
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken'
        },
        body: jsonEncode({"id": id, "email": username, "fullname": name, "age": age, "gender": _convertGender(gender), "weight": weight, "height": height, "avatar" : "https://res.cloudinary.com/dt1pydcgj/image/upload/v1739093062/samples/two-ladies.jpg", "password": "123456"}),
      );
      log(jsonEncode(response.body.toString()));
      if (response.statusCode == 200) {
        return true;
      }
    } on TimeoutException catch (_) {
      Utils.showToast('Server is not responding. Please try again later.', context);
    } on SocketException catch (_) {
      Utils.showToast('No internet connection. Please check your network settings.', context);
    } catch (e) {
      Utils.showToast('An unexpected error occurred. Please try again.', context);
      log('Update error: $e');
    }
    return false;
  }

  static Future<bool> isProfileComplete() async {
    bool cansend = await ensureValidAccessToken();
    if (!cansend) exit(-1);
    try {
      final profile = await getProfile();
      await _storage.write(key: 'id', value: profile.id);
      await _storage.write(key: 'username', value: profile.email);
      await _storage.write(key: 'avatar', value: profile.avatar);
      return profile.gender!= null;
    } catch (e) {
      return false;
    }
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
        await _storage.write(key: 'refreshToken', value: decryptedContents);
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

 static final Map<String, String> _genderMap = {
    'Nam': 'Male',
    'Nữ': 'Female',
    'Male' : 'Nam',
    'Female' : 'Nữ'
  };

  // Method to get English gender
  static String _convertGender(String gender) {
    return _genderMap[gender] ?? gender;
  }
  
  static Future<bool> ensureValidAccessToken() async {
    String stringExpirationTime = await _storage.read(key: 'accessTokenExpiredAt')?? '0';
    int expirationTime = int.parse(stringExpirationTime) - getTokenExpireSeconds();
    if (expirationTime < 0) {
      String refreshToken = await _storage.read(key:'refreshToken')??'';
      String result = await requestNewAccessToken(refreshToken: refreshToken);
      return result.isNotEmpty;
    }
    return true;
  }
}
