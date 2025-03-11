import 'package:flutter/material.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/signupinfo.dart';
import 'package:vn_trackpal/utils/msg.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

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
                    _buildTextField("Nhập lại mật khẩu", true, _rePasswordController),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final username = _usernameController.text.trim();
                        if (username.isEmpty) {
                          Utils.showToast("Vui lòng nhập email", context);
                        //} else if (!_isValidUsername(username)) {
                        //  Utils.showToast("Tên người dùng không hợp lệ", context);
                        } else if (_passwordController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập mật khẩu", context);
                        } else {
                          await AuthApi.register(
                              email: username,
                              password: _passwordController.text,
                              context: context).then((value) {
                              if (value) {
                                //setState(() {isLoading = false;});
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpInfoScreen(),
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
                        "Đăng kí",
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