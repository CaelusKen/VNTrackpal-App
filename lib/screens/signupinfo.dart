import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/utils/msg.dart';

class SignUpInfoScreen extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<SignUpInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _selectedGender = 'Nam'; // Default gender
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

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
                    _buildTextField("Tên của bạn là?", false, _nameController),
                    SizedBox(height: 16),
                    _buildTextField("Độ tuổi của bạn là?", false, _ageController, isNumeric: true, max: 150),
                    SizedBox(height: 16),
                    _buildGenderDropdown(),
                    SizedBox(height: 16),
                    _buildTextField("Cân nặng của bạn là? (kg)", false, _weightController, isNumeric: true, max: 300),
                    SizedBox(height: 16),
                    _buildTextField("Chiều cao của bạn là? (cm)", false, _heightController, isNumeric: true, max: 350),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final name = _nameController.text.trim();
                        if (name.isEmpty) {
                          Utils.showToast("Vui lòng nhập tên", context);
                        } else if (_ageController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập tuổi", context);
                        } else if (_weightController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập cân nặng", context);
                        } else if (_heightController.text.isEmpty) {
                          Utils.showToast("Vui lòng nhập chiều cao", context);
                        } else {
                          final username = await _storage.read(key: 'username')??'';
                          bool isProfileComplete = await AuthApi.updateProfile(username: username, name: name, age: _ageController.text, gender: _selectedGender, weight: _weightController.text, height: _heightController.text, context: context);
                          if (isProfileComplete) {
                            try {
                              await AuthApi.getProfile();
                              Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => CalorieTrackerHome()),
                            );
                            } catch (e) {
                              Utils.showToast("Lỗi khi cập nhật thông tin", context);
                            }
                          }
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
                        "Hoàn tất",
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

  Widget _buildTextField(String label, bool isPassword, TextEditingController? controller, {bool isNumeric = false, int? max}) {
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
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                  _PositiveNumberFormatter(),
                  if (max != null) _MaxValueFormatter(max),
                ]
              : null,
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

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Giới tính của bạn là?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          items: <String>['Nam', 'Nữ']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          dropdownColor: Colors.grey[800],
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
          ),
        ),
      ],
    );
  }
}
class _PositiveNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (int.tryParse(newValue.text) != null && int.parse(newValue.text) > 0) {
      return newValue;
    }
    return oldValue;
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  final int maxValue;

  _MaxValueFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    final int? value = int.tryParse(newValue.text);
    if (value != null && value <= maxValue) {
      return newValue;
    }
    return oldValue;
  }
}