import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readee_app/features/notification/notification.dart';
import 'package:readee_app/features/notification/notification_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int likeCount = 0;
  int unlikeCount = 0;

  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? currentAd;
  Timer? adTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    fetchBooks();
    fetchAdBanner();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      fetchBooks();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    adTimer?.cancel();
    super.dispose();
  }

  // Fetch ad banner from API
  Future<void> fetchAdBanner() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/getAllAds'));
      if (response.statusCode == 200) {
        List<dynamic> adData = jsonDecode(response.body);
        if (adData.isNotEmpty) {
          setState(() {
            currentAd = adData[random.nextInt(adData.length)];
          });

          // Update ad periodically
          adTimer = Timer.periodic(const Duration(seconds: 5), (_) {
            setState(() {
              currentAd = adData[random.nextInt(adData.length)];
            });
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
      print('Ad URL is null');
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
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/books/recommendations/${widget.userID}?offset=$offset&limit=$limit&random=true'));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> booksData = responseBody['data']['books'];

        List<BookDetails> newBooks =
            booksData.map((book) => BookDetails.fromJson(book)).toList();

        setState(() {
          books.addAll(newBooks);
          offset += limit; // Increment offset for pagination
        });
      } else {
        print('Failed to fetch books: ${response.body}');
      }
    } catch (error) {
      print('Error fetching books: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleLike(int index, bool isLiked) {
    print("Book $index is liked: $isLiked");
    if (isLiked) {
      likeCount++;
    } else {
      unlikeCount++;
    }

    if ((likeCount + unlikeCount) >= 10) {
      _checkGenreChange();
    }
  }

  void _checkGenreChange() {
    if (unlikeCount > 5) {
      _showChangeGenreDialog("You disliked many books. Would you like to change the genre?");
    } else {
      print("Continuing with current genres...");
    }
    likeCount = 0;
    unlikeCount = 0;
    _loadNextStack();
  }

  void _loadNextStack() {
    setState(() {
      offset = 0;
      books.clear();
    });
    fetchBooks();
  }

  void _showChangeGenreDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Genre'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditGenrePage(userID: widget.userID)),
                );
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('No'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationPage(
                          userId: widget.userID,
                          notificationService:
                              NotificationService('http://localhost:3000'),
                        )),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: isLoading && books.isEmpty
            ? const CircularProgressIndicator()
            : books.isEmpty
                ? const Center(
                    child: Text(
                      "No more books to show. Wait for others to post books.",
                    ),
                  )
                : Column(
                    children: [
                      if (currentAd != null)
                        GestureDetector(
                          onTap: () => launchAdUrl(currentAd?['Link']),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            height: 80,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(8),
                              image: currentAd?["ImageUrl"] != null
                                  ? DecorationImage(
                                      image: NetworkImage(currentAd!["ImageUrl"]),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: books.length,
                          itemBuilder: (context, index) {
                            return BookCard(
                              books: books,
                              userID: widget.userID,
                              onLike: (index, isLiked) => handleLike(index, isLiked),
                            );
                          },
                        ),
                      ),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
      ),
    );
  }
}
