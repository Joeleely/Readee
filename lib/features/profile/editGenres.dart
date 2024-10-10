import 'package:flutter/material.dart';
import 'package:readee_app/features/match/pages/match.dart';
import 'package:readee_app/widget/bottomNav.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditGenrePage extends StatefulWidget {
  final int userID;

  const EditGenrePage({super.key, required this.userID});

  @override
  _EditGenrePageState createState() => _EditGenrePageState();
}

class _EditGenrePageState extends State<EditGenrePage> {
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
    fetchUserGenres();
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

  Future<void> fetchUserGenres() async {
    final response = await http
        .get(Uri.parse('http://localhost:3000/userGenres/${widget.userID}'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        selectedGenreIds =
            jsonData.map((genre) => genre['Genre_genre_id'] as int).toList();
      });
      print(selectedGenreIds);
    } else {
      throw Exception('Failed to load user genres');
    }
  }

  Future<void> saveUserGenres() async {
    final url = Uri.parse('http://localhost:3000/userGenre/edit');
    final headers = {"Content-Type": "application/json"};
    final body = json.encode({
      "User_user_id": widget.userID,
      "Genre_genre_id": selectedGenreIds,
    });

    final response = await http.put(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      // Success, you could display a message or navigate away
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Genres updated successfully!')));
      Navigator.pop(context);
    } else {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update genres')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Edit you interest genre',
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
                        child: Center(
                          child: Text(
                            genre,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      saveUserGenres();
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(Colors.cyan)),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: () => {Navigator.pop(context)},
                    child: const Text('Cancel'),
                  ),
                ],
              ),
              const SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }
}
