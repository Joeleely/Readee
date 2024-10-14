import 'package:flutter/material.dart';
import 'package:readee_app/features/match/pages/match.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonaPage extends StatefulWidget {
  final int userId;

  const PersonaPage({super.key, required this.userId});
  @override
  _PersonaPageState createState() => _PersonaPageState();
}

class _PersonaPageState extends State<PersonaPage> {
  final List<String> images = [
    "assets/sport-book.jpg",
    "assets/fiction-book.jpg",
    "assets/atomic-habit.jpg",
    "assets/history-book.jpg",
    "assets/horror-book.jpg",
    "assets/love-book.jpg",
    "assets/psychology-book.jpg",
    "assets/fantasy-book.jpg",
  ];

  List<String> genres = [];
  List<int> selectedGenreIds = [];

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

  int _getGenreId(String genre) {
    switch (genre) {
      case 'Sport':
        return 1;
      case 'Fiction':
        return 2;
      case 'Self-improve':
        return 3;
      case 'History':
        return 4;
      case 'Horror':
        return 5;
      case 'Love':
        return 6;
      case 'Psychology':
        return 7;
      case 'Fantasy':
        return 8;
      default:
        return 0;
    }
  }

  Future<void> submitSelectedGenres(int userId) async {
    print(selectedGenreIds);

    Map<String, dynamic> postData = {
      "Genre_genre_id": selectedGenreIds,
      "User_user_id": userId,
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/createUserGenres'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postData),
    );

    if (response.statusCode == 201) {
      print('Data submitted successfully');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReadeeNavigationBar(userId: widget.userId,)),
      );
    } else {
      throw Exception('Failed to submit data');
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
              const Text(
                'Let us know your interested genre!',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              Text('${selectedGenreIds.length} of 5',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    final genre = genres[index];
                    final genreId = _getGenreId(genre);
                    final isSelected = selectedGenreIds.contains(genreId);
                    final imageOfBook = images[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedGenreIds.remove(genreId);
                          } else if (selectedGenreIds.length < 5) {
                            selectedGenreIds.add(genreId);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  genre,
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                                const Spacer(),
                                Image(
                                  image: AssetImage(imageOfBook),
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
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: selectedGenreIds.isNotEmpty
                      ? () {
                          submitSelectedGenres(widget.userId);
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
