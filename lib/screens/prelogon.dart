import 'package:flutter/material.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/signin.dart';
import 'package:vn_trackpal/screens/signup.dart';

class VNTrackpalWaitPreLogin extends StatefulWidget {
  @override
  _VNTrackpalWaitPreLoginState createState() => _VNTrackpalWaitPreLoginState();
}
class _VNTrackpalWaitPreLoginState extends State<VNTrackpalWaitPreLogin> {

  @override
  void initState() {
    super.initState();
    _checkCredentials();
  }

  Future<void> _checkCredentials() async {
  bool hasCredentials = await AuthApi.loadCredentials();
  if (hasCredentials) {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => CalorieTrackerHome()),
      );
    }
  }
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