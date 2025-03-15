import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/planningv2.dart';
import 'package:vn_trackpal/screens/userprofile.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildDateSelector(),
              _buildCalorieInfo(),
              Expanded(
                child: _buildMealList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildTransparentFooter(context),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.subtract(Duration(days: 1));
            });
          },
        ),
        TextButton(
          child: Text(
            _getFormattedDate(),
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          onPressed: () => _selectDate(context),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: () {
            setState(() {
              selectedDate = selectedDate.add(Duration(days: 1));
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalorieInfo() {
  // Example values - replace these with actual data
  int target = 2000;
  int food = 1500;
  int exercise = 300;
  int remaining = target - food + exercise;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        Text(
          'Lượng calo còn lại',
          style: TextStyle(fontSize: 22, color: Colors.yellow),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCalorieInfoItem(target.toString(), 'Mục tiêu'),
            Text(' - ', style: TextStyle(fontSize: 18, color: Colors.white)),
            _buildCalorieInfoItem(food.toString(), 'Thực phẩm'),
            Text(' + ', style: TextStyle(fontSize: 18, color: Colors.white)),
            _buildCalorieInfoItem(exercise.toString(), 'Vận động'),
            Text(' = ', style: TextStyle(fontSize: 18, color: Colors.white)),
            _buildCalorieInfoItem(remaining.toString(), 'Còn lại'),
          ],
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildCalorieInfoItem(String value, String label) {
  return Column(
    children: [
      Text(
        value.padLeft(4, ' '),
        style: TextStyle(fontSize: 18, color: Colors.white, fontFamily: 'Monospace'),
      ),
      Text(
        label,
        style: TextStyle(fontSize: 12, color: Colors.white),
      ),
    ],
  );
}

  Widget _buildMealList() {
    return ListView(
      children: [
        _buildMealSection('Bữa sáng'),
        _buildMealSection('Bữa trưa'),
        _buildMealSection('Bữa tối'),
      ],
    );
  }

  Widget _buildMealSection(String mealType) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withOpacity(0.6),
      child: ExpansionTile(
        title: Text(
          mealType,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        children: [
          ListTile(
            title: Text('Thêm món ăn', style: TextStyle(color: Colors.white)),
            trailing: Icon(Icons.add, color: Colors.white),
            onTap: () => _showAddDishDialog(mealType),
          ),
        ],
      ),
    );
  }

  void _showAddDishDialog(String mealType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Thêm món ăn cho $mealType'),
          content: TextField(
            decoration: InputDecoration(hintText: "Tên món ăn"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Thêm'),
              onPressed: () {
                // TODO: Implement adding dish logic
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _getFormattedDate() {
    if (selectedDate.day == DateTime.now().day) {
      return 'Hôm nay';
    } else if (selectedDate.day == DateTime.now().day - 1) {
      return 'Hôm qua';
    } else {
      return DateFormat.yMMMd().format(selectedDate);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
          _buildFooterItem(Icons.book, 'Nhật kí', null),
          _buildFooterItem(Icons.list, 'Kế hoạch', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlanningScreen()),
            );
          }),
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
}