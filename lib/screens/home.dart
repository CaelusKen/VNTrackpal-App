import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/screens/planning.dart';

class CalorieTrackerHome extends StatefulWidget {
  @override
  _CalorieTrackerHomeState createState() => _CalorieTrackerHomeState();
}

class _CalorieTrackerHomeState extends State<CalorieTrackerHome> {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String> _getName() async {
    String? name = await _storage.read(key: 'name');
    return name ?? 'Người dùng'; // Default to 'Người dùng' if name is null
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<String>(
                      future: _getName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text(
                            'XIN CHÀO ${snapshot.data?.toUpperCase()},',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Lượng calo của bạn hôm nay',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/images/image.png',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildProgressBar('Vận động (calo)', 0.25),
                    _buildProgressBar('Thức ăn hấp thu (calo)', 0.5),
                    _buildProgressBar('Mục tiêu (Calo)', 0.75),
                    const SizedBox(height: 20),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _buildInfoCard('Vận động', '00 calo', Icons.fireplace),
                        _buildInfoCard('Cân nặng', 'trong vòng 1 tuần', Icons.line_weight),
                        _buildInfoCard('Gợi ý bữa ăn tiếp theo', '', Icons.restaurant),
                        _buildInfoCard('Tìm món ăn mới?', '', Icons.search),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildTransparentFooter(context),
    );
  }

  Widget _buildProgressBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.grey,
          color: Colors.yellow,
          minHeight: 5,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Card(
      color: Colors.black.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.yellow, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
                textAlign: TextAlign.center,
              ),
          ],
        ),
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
          _buildFooterItem(Icons.home, 'Chung', null),
          _buildFooterItem(Icons.book, 'Nhật kí', null),
          _buildFooterItem(Icons.list, 'Kế hoạch', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlanningScreen()),
            );
          }),
          _buildFooterItem(Icons.more_horiz, 'Khác', null),
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
