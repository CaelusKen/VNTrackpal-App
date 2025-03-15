import 'package:flutter/material.dart';
import 'package:vn_trackpal/api/dish.dart';
import 'package:vn_trackpal/data/dish_data.dart';
import 'package:vn_trackpal/screens/dishinfo.dart';

class DishSelectorScreen extends StatelessWidget {
  const DishSelectorScreen({super.key});

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
  late Future<List<DishData>> _dishesFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dishesFuture = DishApi.getDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String searchText) {
    setState(() {
      _dishesFuture = DishApi.getDishes(search: searchText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thiết đãi bản thân',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'mà không lên cân',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm công thức...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _performSearch('');
                  },
                ),
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                if (value.isEmpty) {
                  _performSearch('');
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'Các công thức phổ biến',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<DishData>>(
                future: _dishesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No dishes found'));
                  } else {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final dish = snapshot.data![index];
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
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}