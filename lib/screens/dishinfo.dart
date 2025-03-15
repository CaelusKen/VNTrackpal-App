import 'package:flutter/material.dart';
import 'package:vn_trackpal/data/dish_data.dart';

class DishDetailScreen extends StatelessWidget {
  final DishData dish;

  const DishDetailScreen({Key? key, required this.dish}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Món ăn', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main-bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInImage.assetNetwork(
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish.name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text('Calories: ${dish.totalCalories}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Carbohydrates: ${dish.totalCarb}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Fat: ${dish.totalFat}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 8),
                        Text('Protein: ${dish.totalProtein}', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 16),
                        Text(
                          'Nguyên liệu:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(dish.ingredient, style: TextStyle(color: Colors.white)),
                        SizedBox(height: 16),
                        Text(
                          'Cách làm:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(dish.making, style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}