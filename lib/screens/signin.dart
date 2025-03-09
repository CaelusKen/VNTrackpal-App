import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/signinbyotp.dart';
import 'package:vn_trackpal/utils/msg.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _rememberDevice = false;

  void _navigateToSignInByOtpScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignInByOTPScreen(),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/main-bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: EdgeInsets.all(16),
                width: double.infinity,
                constraints: BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField("Tên người dùng (email)", false, _usernameController),
                    SizedBox(height: 16),
                    _buildTextField("Mật khẩu", true, _passwordController),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberDevice,
                          onChanged: (value) {
                            setState(() {
                              _rememberDevice = value!;
                            });
                          },
                          fillColor: MaterialStateProperty.resolveWith((states) => Colors.yellow[700]),
                        ),
                        Text(
                          "Ghi nhớ thiết bị này",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: _navigateToSignInByOtpScreen,
                      child: Text(
                        "Đăng nhập bằng OTP",
                        style: TextStyle(
                          color: Colors.yellow[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final username = _usernameController.text.trim();
                        if (username.isEmpty) {
                          Utils.showToast("Vui lòng nhập tên người dùng", context);
                        } else if (_passwordController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập mật khẩu", context);
                        } else {
                          await AuthApi.login(
                            email: username,
                            password: _passwordController.text,
                            context: context, saveCredential: _rememberDevice).then((value) {
                            if (value) {
                              _storage.write(key: 'name', value: "Tuấn");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalorieTrackerHome(),
                                ),
                              );
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
                      ),
                      child: Text(
                        "Đăng nhập",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, bool isPassword, TextEditingController? controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.yellow),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.yellow),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.yellow),
            ),
            hintText: label,
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}