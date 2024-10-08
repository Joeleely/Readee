import 'package:flutter/material.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonaPage extends StatefulWidget {
  @override
  _PersonaPageState createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  final List<String> images = [
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
    "assets/atomic-habit.jpg",
  ];

  List<String> genres = [];
  // To store selected genres
  List<String> selectedGenres = [];

 @override
  void initState() {
    super.initState();
    fetchGenres();
  }

  Future<void> fetchGenres() async {
    final response = await http.get(Uri.parse('http://localhost:3000/genres'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        genres = jsonData.map((genre) => genre['Name'] as String).toList();
      });
    } else {
      throw Exception('Failed to load genres');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title text and selection count in the same row
              const Text(
                'Let us know your interested genre!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text('${selectedGenres.length} of 5',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5, // Width to height ratio
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final isSelected = selectedGenres.contains(genre);
                    final imageOfBook = images[index];
        
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedGenres.remove(genre);
                          } else if (selectedGenres.length < 5) {
                            selectedGenres.add(genre);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(
                            milliseconds: 300), // Animation duration
                        curve: Curves.easeInOut, // Animation curve
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color:
                              isSelected ? Colors.cyan[200] : Colors.grey[200],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 30.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  genre,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                const Image(
                                  image: AssetImage("assets/atomic-habit.jpg"),
                                  width: 55,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20,),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: selectedGenres.isNotEmpty
                      ? () {
                          // Do something
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28A9D1),
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }
}
