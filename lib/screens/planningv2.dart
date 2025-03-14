import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vn_trackpal/screens/dishselector.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/log.dart';
import 'package:vn_trackpal/screens/plansetup.dart';
import 'package:vn_trackpal/screens/userprofile.dart';

class PlanningScreen extends StatelessWidget {
  const PlanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: DietPlanScreen(),
      ),
    );
  }
}

class DietPlanScreen extends StatefulWidget {
  @override
  _DietPlanScreenState createState() => _DietPlanScreenState();
}

class _DietPlanScreenState extends State<DietPlanScreen> {
  int _selectedTarget = 0;
  int _selectedActivityLevel = 0;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  final List<String> _targets = ['Tăng cơ', 'Giảm cân', 'Duy trì'];
  final List<String> _activityLevels = [
    'Ít vận động',
    'Vận động nhẹ',
    'Vận động tương đối',
    'Vận động nhiều',
    'Vận động tăng cường'
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedSelections();
  }

  _loadSavedSelections() async {
    String? targetValue = await _storage.read(key: 'rd_target');
    String? activityValue = await _storage.read(key: 'rd_activity_level');
    
    setState(() {
      _selectedTarget = targetValue != null ? int.tryParse(targetValue) ?? -1 : -1;
      _selectedActivityLevel = activityValue != null ? int.tryParse(activityValue) ?? -1 : -1;
    });
  }

  _saveSelections() async {
    await _storage.write(key: 'rd_target', value: _selectedTarget.toString());
    await _storage.write(key: 'rd_activity_level', value: _selectedActivityLevel.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tìm chế độ ăn phù hợp', 
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lên kế hoạch xây dựng bữa ăn tỉ mỉ và chuẩn xác.\nBắt đầu kế hoạch, theo đuổi dài lâu\nđạt được kết quả mong muốn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Mục tiêu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_targets.length, (index) {
                  return _buildSelectableButton(_targets[index], index, _selectedTarget, (value) {
                    setState(() {
                      _selectedTarget = value;
                      _saveSelections();
                    });
                  });
                }),
              ),
              SizedBox(height: 20),
              Text(
                'Mức hoạt động',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_activityLevels.length, (index) {
                  return _buildSelectableButton(_activityLevels[index], index, _selectedActivityLevel, (value) {
                    setState(() {
                      _selectedActivityLevel = value;
                      _saveSelections();
                    });
                  });
                }),
              ),
              SizedBox(height: 20),
              Text(
                'Lên kế hoạch',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DietLogScreen(),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/planning.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Chuẩn bị bữa ăn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DishSelectorScreen(),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/mealprepare.jpg',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildTransparentFooter(context),
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
              MaterialPageRoute(builder: (context) => CalorieTrackerHome())
            );
          }),
          _buildFooterItem(Icons.book, 'Nhật kí', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogScreen()),
            );
          }),
          _buildFooterItem(Icons.list, 'Kế hoạch', null),
          _buildFooterItem(Icons.person, 'Hồ sơ', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfileScreen()),
            );
          }),
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

   Widget _buildSelectableButton(String text, int value, int selectedValue, Function(int) onSelected) {
    bool isSelected = selectedValue == value;
    return ElevatedButton(
      onPressed: () {
        onSelected(value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.yellow : Colors.transparent,
        foregroundColor: isSelected ? Colors.black : Colors.yellow,
        side: BorderSide(color: Colors.yellow, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}