import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/profile/editGenres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';

class MatchPage extends StatefulWidget {
  final int userID;

  const MatchPage({super.key, required this.userID});

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  List<BookDetails> books = [];
  final Random random = Random();
  bool isLoading = true;
  Map<String, dynamic>? adBanner;
  List<Map<String, dynamic>> ads = [];
  Map<String, dynamic>? currentAd;
  Timer? adTimer;
  int offset = 0;
  int limit = 10;
  List<int> likedBookIndexes = [];
  int likeCount = 0;
  int unlikeCount = 0;

  @override
  void initState() {
    super.initState();
    fetchBooks();
    fetchAdBanner();
  }

  @override
  void dispose() {
    adTimer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Fetch ad banner from API
  Future<void> fetchAdBanner() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getAllAds'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> adData = jsonDecode(response.body);
        if (adData.isNotEmpty) {
          setState(() {
            ads = adData.cast<Map<String, dynamic>>();
            currentAd =
                ads[random.nextInt(ads.length)]; // Set the first random ad
          });

          // Start the timer to update the ad periodically
          adTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
            if (ads.isNotEmpty && mounted) {
              setState(() {
                currentAd = ads[random.nextInt(ads.length)];
              });
            }
          });
        }
      } else {
        throw Exception('Failed to fetch ads');
      }
    } catch (error) {
      print("Error fetching ads: $error");
    }
  }

  void launchAdUrl(String? url) async {
    if (url == null) {
      print('Error: URL is null');
      return;
    }
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch $url');
    }
  }

  // Fetch books from API
  Future<void> fetchBooks() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/books/recommendations/${widget.userID}?offset=0&limit=10&random=true'));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> booksData = responseBody['data']['books'] ?? [];
        // Check if there are new books
        if (booksData.isEmpty) {
          print('No more books to fetch');
        } else {
          List<BookDetails> newBooks = booksData.map((book) {
            return BookDetails(
                title: book['BookName'],
                author: book['Author'],
                description: book['BookDescription'],
                img: [book['BookPicture']],
                quality: '${book['Quality']}%',
                genre: '',
                bookId: book['BookId'],
                isTrade: book['IsTraded'],
                isReport: book['IsReported']);
          }).toList();

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
                  MaterialPageRoute(
                      builder: (context) => EditGenrePage(
                            userID: widget.userID,
                          )),
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

  // Helper to get random books
  // List<BookDetails> _getRandomBooks(List<BookDetails> booksList, int count) {
  //   if (booksList.length <= count) {
  //     return booksList;
  //   }
  //   booksList.shuffle(random);
  //   return booksList.sublist(0, count);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/logo.png'),
          height: 50,
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : books.isEmpty
                ? const Center(
                    child: Text(
                      "No more books to show, wait for others to post books",
                    ),
                  )
                : Column(
                    children: [
                      if (currentAd != null)
                        GestureDetector(
                          onTap: () {
                            if (currentAd!['Link'] != null) {
                              launchAdUrl(currentAd!['Link']);
                            } else {
                              print('Ad link not available');
                            }
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: 80,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                              image: currentAd!["ImageUrl"] != null
                                  ? DecorationImage(
                                      image:
                                          NetworkImage(currentAd!["ImageUrl"]),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      Expanded(
                        child: BookCard(
                          books: books,
                          userID: widget.userID,
                          onLike: handleLike,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
