import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

class DietLogScreen extends StatefulWidget {
  @override
  _DietLogScreenState createState() => _DietLogScreenState();
}

class _DietLogScreenState extends State<DietLogScreen> {
  final _formKey = GlobalKey<FormState>();
  String breakfast = '';
  String lunch = '';
  String dinner = '';
  int exerciseCalories = 0;
  double proteinPercentage = 0;
  double carbPercentage = 0;
  double fatPercentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Stack(
      children: [
        // Background image
        Image.asset(
          'assets/images/main-bg.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // AppBar and content
        Column(
          children: [
            AppBar(
              title: Text('Lên kế hoạch cho hôm nay', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              backgroundColor: Colors.transparent, // Make AppBar transparent
              elevation: 0, // Remove AppBar shadow
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Bữa sáng', labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                        onSaved: (value) => breakfast = value ?? '',
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Bữa trưa', labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                        onSaved: (value) => lunch = value ?? '',
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(labelText: 'Bữa tối', labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        onSaved: (value) => dinner = value ?? '',
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Lượng calo thiêu đốt', labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        onSaved: (value) => exerciseCalories = int.tryParse(value ?? '') ?? 0,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        child: Text('Lưu'),
                        onPressed: _saveLog,
                      ),
              SizedBox(height: 20),
              Text('Tổng dinh dưỡng hấp thu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: CustomPaint(
                  painter: MacroTrianglePainter(
                    proteinPercentage: proteinPercentage,
                    carbPercentage: carbPercentage,
                    fatPercentage: fatPercentage,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final painter = MacroTrianglePainter(
                        proteinPercentage: proteinPercentage,
                        carbPercentage: carbPercentage,
                        fatPercentage: fatPercentage,
                      );
                      final size = constraints.biggest;
                      final proteinCenter = painter.getProteinCenter(size);
                      final carbCenter = painter.getCarbCenter(size);
                      final fatCenter = painter.getFatCenter(size);

                      return Stack(
                        children: [
                          Positioned(
                            left: proteinCenter.dx,
                            top: proteinCenter.dy,
                            child: Text(
                              'Đạm: ${proteinPercentage.toStringAsFixed(1)}%',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: carbCenter.dx,
                            top: carbCenter.dy,
                            child: Text(
                              'Tinh bột: ${carbPercentage.toStringAsFixed(1)}%',
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Positioned(
                            left: fatCenter.dx,
                            top: fatCenter.dy,
                            child: Text(
                              'Béo: ${fatPercentage.toStringAsFixed(1)}%',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
            )
      ])
    ]));
  }

  void _saveLog() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Here you would typically save the data to a database or state management solution
      // For this example, we'll just update the macronutrient percentages randomly
      setState(() {
        proteinPercentage = 50 + Random().nextDouble() * 10; // 50-60%
        carbPercentage = 25 + Random().nextDouble() * 10; // 25-35%
        fatPercentage = 100 - proteinPercentage - carbPercentage;
      });
      //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Log saved successfully!')));
    }
  }
}

class MacroTrianglePainter extends CustomPainter {
  final double proteinPercentage;
  final double carbPercentage;
  final double fatPercentage;

  MacroTrianglePainter({
    required this.proteinPercentage,
    required this.carbPercentage,
    required this.fatPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Calculate heights for each section
    final totalHeight = size.height;
    final proteinHeight = totalHeight * 0.40;
    final carbHeight = totalHeight * 0.37;
    final fatHeight = totalHeight * 0.3;

    // Draw fat section (largest, at the top)
    paint.color = Colors.blue.withOpacity(0.7);
    final proteinPath = Path();
    proteinPath.moveTo(0, 0);
    proteinPath.lineTo(size.width, 0);
    proteinPath.lineTo(size.width * 0.8, proteinHeight);
    proteinPath.lineTo(size.width * 0.2, proteinHeight);
    proteinPath.close();
    canvas.drawPath(proteinPath, paint);

    // Draw carb section (middle)
    paint.color = Colors.green.withOpacity(0.7);
    final carbPath = Path();
    carbPath.moveTo(size.width * 0.2, proteinHeight);
    carbPath.lineTo(size.width * 0.8, proteinHeight);
    carbPath.lineTo(size.width * 0.618, proteinHeight + carbHeight);
    carbPath.lineTo(size.width * 0.382, proteinHeight + carbHeight);
    carbPath.close();
    canvas.drawPath(carbPath, paint);

    // Draw protein section (smallest, at the bottom)
    paint.color = Colors.red.withOpacity(0.7);
    final fatPath = Path();
    fatPath.moveTo(size.width * 0.618, proteinHeight + carbHeight);
    fatPath.lineTo(size.width * 0.382, proteinHeight + carbHeight);
    fatPath.lineTo(size.width * 0.5, size.height);
    fatPath.close();
    canvas.drawPath(fatPath, paint);

    // Draw outline
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;
    final outlinePath = Path();
    outlinePath.moveTo(0, 0);
    outlinePath.lineTo(size.width, 0);
    outlinePath.lineTo(size.width * 0.5, size.height);
    outlinePath.close();
    canvas.drawPath(outlinePath, outlinePaint);

    // Draw dividing lines
    //canvas.drawLine(
    //  Offset(size.width * 0.25, fatHeight),
    //  Offset(size.width * 0.75, fatHeight),
    //  outlinePaint,
    //);
    //canvas.drawLine(
    //  Offset(size.width * 0.375, fatHeight + carbHeight),
    //  Offset(size.width * 0.625, fatHeight + carbHeight),
    //  outlinePaint,
    //);
  }

  Offset getProteinCenter(Size size) {
    return Offset(size.width * 0.42, size.height * 0.02);
  }

  Offset getCarbCenter(Size size) {
    return Offset(size.width * 0.4, size.height * 0.4);
  }

  Offset getFatCenter(Size size) {
    return Offset(size.width * 0.43, size.height * 0.755);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}