import 'dart:math';
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../profile/editGenres.dart';

class MatchPage extends StatefulWidget {
  final int userID;
  const MatchPage({super.key, required this.userID});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<BookDetails> books = [];
  final Random random = Random();
  bool isLoading = false;
  int offset = 0;
  int limit = 10;
  List<int> likedBookIndexes = [];
  int likeCount = 0;
  int unlikeCount = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchBooks();
    _loadLikedBooks(); // Load liked books from shared preferences
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      print('Reached the bottom of the list. Loading more books...');
      fetchBooks(); // Load more books
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    if (isLoading) {
      print("Already loading, skipping fetch");
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/books/recommendations/${widget.userID}?offset=$offset&limit=$limit&random=true'));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> booksData = responseBody['data']['books'] ?? [];

        // Check if there are new books
        if (booksData.isEmpty) {
          print('No more books to fetch');
        } else {
          List<BookDetails> newBooks =
              booksData.map((book) => BookDetails.fromJson(book)).toList();

          setState(() {
            books.addAll(newBooks);
          });
        }
      } else {
        print("Failed to fetch books: ${response.body}");
      }
    } catch (e) {
      print("Error fetching books: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // SharedPreferences
  Future<void> _saveLikedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('likedBooks', json.encode(bookStatuses));
  }

  // Load data from SharedPreferences
  Future<void> _loadLikedBooks() async {
    final prefs = await SharedPreferences.getInstance();
    String? likedBooksJson = prefs.getString('likedBooks');
    if (likedBooksJson != null) {
      List<dynamic> likedBooksList = json.decode(likedBooksJson);
      setState(() {
        bookStatuses = List<bool>.from(likedBooksList);
      });
    }
  }

  // Save the current index
  Future<void> _saveLastIndex(int currentIndex) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('lastIndex', currentIndex);
  }

  // Load the last index
  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    int lastIndex = prefs.getInt('lastIndex') ?? 0;
    setState(() {
      offset = lastIndex;
    });
  }

  List<bool> bookStatuses = [];
  void handleLike(int index, bool isLiked) {
    print("Book $index is liked: $isLiked");
    if (index >= bookStatuses.length) {
      bookStatuses.add(isLiked);
    } else {
      bookStatuses[index] = isLiked;
    }
    if (isLiked) {
      likeCount++;
    } else {
      unlikeCount++;
    }
    _saveLikedBooks();
    if ((likeCount + unlikeCount) == 10) {
      _checkGenreChange();
    }
  }

  void _checkGenreChange() {
    if (unlikeCount > 5) {
      print("More than 5 books were unliked. Loading next stack...");
      _showChangeGenreDialog("Would you like to change the genre?");
      _loadNextStack();
    } else {
      print("Fewer than 5 books were unliked. Showing genre change dialog...");
      _loadNextStack();
    }
    likeCount = 0;
    unlikeCount = 0;
  }

  void _loadNextStack() {
    setState(() {
      offset += 0;
      books.clear();
    });
    print('Loading next stack with offset: $offset, limit: $limit');
    fetchBooks();
  }

  void _showChangeGenreDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Genre'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditGenrePage(userID: widget.userID,)),
                );
              },
              child: Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('No'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/logo.png'),
          height: 50,
        ),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: Center(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : books.isEmpty
                  ? const Center(
                      child: Text(
                        "No more books to show. Please check back later or update your preferences.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController, // Attach the controller
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          userID: widget.userID,
                          books: books,
                          onLike: handleLike,
                        );
                      },
                    )),
    );
  }
}
