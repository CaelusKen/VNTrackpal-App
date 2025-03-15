import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/api/auth.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/log.dart';
import 'package:vn_trackpal/screens/planningv2.dart';
import 'package:vn_trackpal/screens/prelogon.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<Map<String, String>> _getUserData() async {
    
    String? name = await _storage.read(key: 'name');
    String? email = await _storage.read(key: 'username');
    String? avatar = await _storage.read(key: 'avatar');
    
    return {
      'name': name ?? 'Người dùng',
      'email': email ?? 'example@email.com',
      'avatar': avatar ?? '',
    };
  }

  void _signOut() async {
    await AuthApi.deleteCredentials();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => VNTrackpalWaitPreLogin()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main-bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Hồ sơ người dùng'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: FutureBuilder<Map<String, String>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Đã xảy ra lỗi: ${snapshot.error}'));
            } else {
              final userData = snapshot.data!;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['avatar']!.isNotEmpty
                          ? NetworkImage(userData['avatar']!)
                          : AssetImage('assets/images/two-ladies.png') as ImageProvider,
                    ),
                    SizedBox(height: 20),
                    Text(
                      userData['name']!,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      userData['email']!,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 30),
                    _buildSettingsItem(Icons.person, 'Thông tin cá nhân'),
                    _buildSettingsItem(Icons.lock, 'Bảo mật'),
                    _buildSettingsItem(Icons.notifications, 'Thông báo'),
                    _buildSettingsItem(Icons.language, 'Ngôn ngữ'),
                    SizedBox(height: 20),
                    _buildPremiumSuggestion(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signOut,
                      child: Text('Đăng xuất'),
                      style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      bottomNavigationBar: _buildTransparentFooter(context)),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Handle settings item tap
      },
    );
  }

  Widget _buildPremiumSuggestion() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Nâng cấp lên Premium',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Mở khóa tất cả tính năng và trải nghiệm không giới hạn!',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            child: Text('Tìm hiểu thêm'),
            onPressed: () {
              // Handle premium upgrade
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransparentFooter(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.black.withOpacity(0.95),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem(Icons.home, 'Chung', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CalorieTrackerHome()),
            );
          }),
          _buildFooterItem(Icons.book, 'Nhật kí', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogScreen()),
            );
          }),
          _buildFooterItem(Icons.list, 'Kế hoạch', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlanningScreen()),
            );
          }),
          _buildFooterItem(Icons.person, 'Hồ sơ', null),
        ],
      ),
    );
  }

  Widget _buildFooterItem(IconData icon, String label, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}