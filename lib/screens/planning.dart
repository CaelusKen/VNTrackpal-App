import 'package:flutter/material.dart';
import 'package:vn_trackpal/screens/home.dart';
import 'package:vn_trackpal/screens/planningv2.dart';
import 'package:vn_trackpal/screens/userprofile.dart';

class TrackScreen extends StatelessWidget {
  const TrackScreen({super.key});

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
        child: const CalorieChart(),
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

class CalorieChart extends StatelessWidget {
  const CalorieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Lượng calo tuần này của bạn',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: StackedBarChart(),
        ),
        const SizedBox(height: 20),
        const Legend(),
      ],
    );
  }
}

class StackedBarChart extends StatelessWidget {
  final List<List<double>> data = [
    [30, 40, 325], // Monday
    [35, 35, 345], // Tuesday
    [40, 30, 261], // Wednesday
    [25, 45, 270], // Thursday
    [35, 35, 100], // Friday
    [30, 40, 250], // Saturday
    [35, 35, 125], // Sunday
  ];

  final List<String> days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  StackedBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    double maxSum = data.map((day) => day.reduce((a, b) => a + b)).reduce((a, b) => a > b ? a : b);
    return Stack(
      children: [
        // Grid lines
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
            );
          }),
        ),
        // Bars and labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            double sum = data[index].reduce((a, b) => a + b);
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${sum.toInt()}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 5),
                StackedBar(data: data[index], maxSum: maxSum),
                const SizedBox(height: 5),
                Text(
                  days[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class StackedBar extends StatelessWidget {
  final List<double> data;
  final double maxSum;

  const StackedBar({super.key, required this.data, required this.maxSum});

  @override
  Widget build(BuildContext context) {
    double sum = data.reduce((a, b) => a + b);
    double barHeight = (sum / maxSum) * 230; // Adjust 230 to fit your desired max height

    return Container(
      width: 30,
      height: barHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (data[0] / sum) * barHeight,
            color: Colors.yellow,
          ),
          Container(
            height: (data[1] / sum) * barHeight,
            color: Colors.orange,
          ),
          Container(
            height: (data[2] / sum) * barHeight,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        LegendItem(color: Colors.yellow, label: 'Tinh bột (Trung bình) ?% (?kcal)'),
        LegendItem(color: Colors.orange, label: 'Đạm (Trung bình) ?% (?kcal)'),
        LegendItem(color: Colors.white, label: 'Chất béo (Trung bình) ?% (?kcal)'),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 20, height: 20, color: color, margin: const EdgeInsets.all(5)),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}