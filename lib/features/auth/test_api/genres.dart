import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Genre {
  final int genreId;
  final String name;

  Genre({required this.genreId, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['GenreId'] ?? 0,
      name: json['Name'] ?? 'Unknown',
    );
  }
}

class GenresPage extends StatefulWidget {
  @override
  _GenresPageState createState() => _GenresPageState();
}

class _GenresPageState extends State<GenresPage> {
  List<Genre> genres = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGenres(3);
  }

  Future<void> fetchGenres(int genreId) async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3000/genres/$genreId'));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        genres = [Genre.fromJson(jsonResponse)]; // Wrap the single genre in a list
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load genres');
    }
  } catch (error) {
    print('Error fetching genres: $error'); // Log the error
    setState(() {
      isLoading = false; // Stop loading if there's an error
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Genres'),
      ),
      body: isLoading
          ? const Center(child: Text("??"))
          : ListView.builder(
              itemCount: genres.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(genres[index].name),
                  subtitle: Text('Genre ID: ${genres[index].genreId}'),
                );
              },
            ),
    );
  }
}
