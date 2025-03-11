import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/signupinfo.dart';
import 'package:flutter/services.dart';

class OTPScreen extends StatefulWidget {
  final bool rememberDevice;

  const OTPScreen({Key? key, required this.rememberDevice}) : super(key: key);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            _buildOTPCard(context),
            const Spacer(),
            _buildResendButton(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Nhập OTP được gửi từ email của bạn",
            //style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildOTPTextField(),
          SizedBox(height: 20),
          _buildVerifyButton(),
        ],
      ),
    );
  }

  Widget _buildOTPTextField() {
  return TextField(
    controller: _otpController,
    keyboardType: TextInputType.number,
    maxLength: 5,
    textAlign: TextAlign.center,
    style: TextStyle(fontSize: 24),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: "Mã OTP 5 số",
      hintStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      counterText: "",
    ),
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
    ],
  );
}

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.yellow[700],
      ),
      child: ElevatedButton(
        onPressed: () async {
          String enteredOTP = _otpController.text;
          String username = await _storage.read(key: 'username') ?? "";
          bool isSuccess = await AuthApi.confirmLoginWithEmail(email: username, code: enteredOTP, context: context, saveCredential: widget.rememberDevice);
          if (isSuccess) {
            bool isProfileComplete = await AuthApi.isProfileComplete();
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => isProfileComplete ? CalorieTrackerHome() : SignUpInfoScreen()));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(
          "Xác nhận OTP",
          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[700], // Yellow background
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        onPressed: () async {
          String username = await _storage.read(key: 'username') ?? "";
          await AuthApi.loginWithOnlyEmail(email: username,context: context);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(
          "Gửi lại OTP",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold), // Changed to black
        ),
      ),
    );
  }
}