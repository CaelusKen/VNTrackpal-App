import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/data/data_holder.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/otp_screen.dart';
import 'package:vn_trackpal/utils/msg.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberDevice = false;
  bool _isOtpLogin = false;

  bool _isValidUsername(String username) {
    // Email regex pattern
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Phone number regex pattern (assuming Vietnamese phone numbers)
    final phoneRegex = RegExp(r'^(0|\+84)(\s|\.)?3[2-9]\d{7}$');

    return emailRegex.hasMatch(username) || phoneRegex.hasMatch(username);
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
                    _buildTextField("Tên người dùng (email, số điện thoại)", false, _usernameController),
                    SizedBox(height: 16),
                    if (!_isOtpLogin) _buildTextField("Mật khẩu", true, _passwordController),
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
                    Row(
                      children: [
                        Checkbox(
                          value: _isOtpLogin,
                          onChanged: (value) {
                            setState(() {
                              _isOtpLogin = value!;
                            });
                          },
                          fillColor: MaterialStateProperty.resolveWith((states) => Colors.yellow[700]),
                        ),
                        Text(
                          "Đăng nhập bằng OTP",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final username = _usernameController.text.trim();
                        if (username.isEmpty) {
                          Utils.showToast("Vui lòng nhập tên người dùng", context);
                        } else if (!_isValidUsername(username)) {
                          Utils.showToast("Tên người dùng không hợp lệ", context);
                        } else if (!_isOtpLogin && _passwordController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập mật khẩu", context);
                        } else {
                          if (_isOtpLogin) {
                            Provider.of<UserData>(context, listen: false).setUsername(username);
                            // Navigate to OTP screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPScreen(),
                              ),
                            );
                          } else {
                            //setState(() {isLoading = true;});
                            await AuthApi.login(
                              email: username,
                              password: _passwordController.text,
                              context: context).then((value) {
                              if (value) {
                                //setState(() {isLoading = false;});
                                  Provider.of<UserData>(context, listen: false).setName("Tuấn");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CalorieTrackerHome(),
                                    ),
                                  );
                              }
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        _isOtpLogin ? "Gửi OTP" : "Đăng nhập",
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