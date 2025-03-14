import 'package:flutter/material.dart';
import 'package:vn_trackpal/api/dish.dart';
import 'package:vn_trackpal/data/dish_data.dart';
import 'package:vn_trackpal/screens/dishinfo.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RecommendDishScreen extends StatelessWidget {
  const RecommendDishScreen({super.key});

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
        child: DishScreen(),
      ),
    );
  }
}

class DishScreen extends StatefulWidget {
  @override
  _DishScreenState createState() => _DishScreenState();
}

class _DishScreenState extends State<DishScreen> {
  late List<DishData> _dishes;
  late Future<void> _initFuture;
  final List<String> _targets = ['Tăng cơ', 'Giảm cân', 'Duy trì'];
  final List<String> _activityLevels = [
    'Ít vận động',
    'Vận động nhẹ',
    'Vận động tương đối',
    'Vận động nhiều',
    'Vận động tăng cường'
  ];
  late String _selectedTarget;
  late String _selectedActivityLevel;
  late String targetIndex;
  late String activityLevelIndex;
  late String _calo;
  late String _protein;
  late String _carbohydrate;
  late String _fat;
  static final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initFuture = _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    targetIndex = await _storage.read(key: 'rd_target') ?? '0';
    activityLevelIndex = await _storage.read(key: 'rd_activity_level') ?? '0';
    _selectedTarget = _targets[int.parse(targetIndex)];
    _selectedActivityLevel = _activityLevels[int.parse(activityLevelIndex)];
    _dishes = await DishApi.getRecomendDishes(activityLevel: activityLevelIndex, target: targetIndex);
    _calo = await _storage.read(key: 'calorie') ?? '0';
    _protein = await _storage.read(key: 'protein') ?? '0';
    _carbohydrate = await _storage.read(key: 'carb') ?? '0';
    _fat = await _storage.read(key: 'fat') ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Đề xuất món ăn cho hôm nay:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Chế độ đang chọn: ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: '$_selectedTarget, $_selectedActivityLevel',
                          style: TextStyle(color: Colors.yellow),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
              'Món ăn đề xuất cho bạn:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tổng calo: $_calo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tổng tinh bột: $_carbohydrate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tổng chất béo: $_fat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tổng đạm: $_protein',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
                    child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _dishes.length,
                          itemBuilder: (context, index) {
                            final dish = _dishes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DishDetailScreen(dish: dish),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/images/placeholder_dish.jpg',
                                      image: dish.imageDish.publicUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      imageErrorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/placeholder_dish.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dish.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${dish.totalCalories} calories',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                              ),
                            ],
                            ),
                          )
                        );
                      },
                    )
                  )
                ]
              )
            )
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}