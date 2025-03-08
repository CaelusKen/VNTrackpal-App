import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vn_trackpal/data/data_holder.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/signin.dart';
import 'package:vn_trackpal/screens/signup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'dart:typed_data';

class VNTrackpalWaitPreLogin extends StatefulWidget {
  @override
  _VNTrackpalWaitPreLoginState createState() => _VNTrackpalWaitPreLoginState();
}
class _VNTrackpalWaitPreLoginState extends State<VNTrackpalWaitPreLogin> {
  String? username;
  String? token;
  String? uuid;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/credentials.bin');
      
      if (await file.exists()) {
        final encryptedContents = await file.readAsBytes();
        final decryptedContents = _decryptAES(encryptedContents);
        
        final credentials = decryptedContents.split(':');
        if (credentials.length == 3) {
          setState(() {
            username = credentials[0].trim();
            token = credentials[1].trim();
            uuid = credentials[2].trim();
          });
          print('Credentials loaded: $username, $token');
          Provider.of<UserData>(context, listen: false).setName("Tuấn");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => CalorieTrackerHome()),
          );
        }
      } else {
        print('Credentials file does not exist');
      }
    } catch (e) {
      print('Error loading credentials: $e');
    }
  }

  String _decryptAES(Uint8List encryptedData) {
    // Replace 'your_des_key_here' with your actual AES key
    final key = encrypt.Key.fromUtf8('your_des_key_here');
    final iv = encrypt.IV.fromBase64('AQIDBAUGBwg=');

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt(encrypt.Encrypted(encryptedData), iv: iv);

    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/main-bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Black Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'VN Trackpal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildButton(context, 'Đăng nhập', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                }),
                const SizedBox(height: 10),
                _buildButton(context, 'Đăng ký', () {
                  //Navigator.pushReplacementNamed(context, "signUp")
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow.shade400,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}