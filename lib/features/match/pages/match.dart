import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      // Step 1: Get user genres
      final genreResponse = await http.get(Uri.parse(
          'http://localhost:3000/userGenres?userID=${widget.userID}'));
      if (genreResponse.statusCode == 200) {
        List<dynamic> genresData = jsonDecode(genreResponse.body);

        List<int> userGenreIDs =
            genresData.map((genre) => genre['Genre_genre_id'] as int).toList();

        // Step 2: Get user logs to filter out liked books
        final logsResponse = await http
            .get(Uri.parse('http://localhost:3000/getLogs/${widget.userID}'));
        List<int> likedBookIDs = [];
        if (logsResponse.statusCode == 200) {
          List<dynamic> logsData = jsonDecode(logsResponse.body);
          likedBookIDs =
              logsData.map((log) => log['BookLikeId'] as int).toList();
        }

        // Step 3: Get books
        final bookResponse =
            await http.get(Uri.parse('http://localhost:3000/getBooks'));
        if (bookResponse.statusCode == 200) {
          List<dynamic> booksData = jsonDecode(bookResponse.body);

          List<BookDetails> matchingBooks = booksData.where((book) {
            return userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != widget.userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            return BookDetails(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genre: '',
              bookId: book['BookId'],
              isTrade: book['IsTraded'],
            );
          }).toList();

          List<BookDetails> nonMatchingBooks = booksData.where((book) {
            return !userGenreIDs.contains(book['GenreId']) &&
                book['OwnerId'] != widget.userID &&
                book['IsTraded'] == false &&
                !likedBookIDs.contains(book['BookId']);
          }).map((book) {
            return BookDetails(
              title: book['BookName'],
              author: book['Author'],
              description: book['BookDescription'],
              img: [book['BookPicture']],
              quality: '${book['Quality']}%',
              genre: '',
              bookId: book['BookId'],
              isTrade: book['IsTraded'],
            );
          }).toList();

          // Step 4: Randomly select 70% matching and 30% non-matching books
          int matchingBooksCount = (booksData.length * 0.7).toInt();
          int nonMatchingBooksCount = booksData.length - matchingBooksCount;

          List<BookDetails> selectedMatchingBooks =
              _getRandomBooks(matchingBooks, matchingBooksCount);
          List<BookDetails> selectedNonMatchingBooks =
              _getRandomBooks(nonMatchingBooks, nonMatchingBooksCount);

          // Step 5: Combine and shuffle books
          List<BookDetails> combinedBooks = [
            ...selectedMatchingBooks,
            ...selectedNonMatchingBooks
          ];

          combinedBooks.shuffle(random);

          if (mounted) {
            setState(() {
              books = combinedBooks;
              isLoading = false;
            });
          }
        } else {
          throw Exception('Failed to load books');
        }
      } else {
        throw Exception('Failed to load user genres');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  // Helper to get random books
  List<BookDetails> _getRandomBooks(List<BookDetails> booksList, int count) {
    if (booksList.length <= count) {
      return booksList;
    }
    booksList.shuffle(random);
    return booksList.sublist(0, count);
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
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
