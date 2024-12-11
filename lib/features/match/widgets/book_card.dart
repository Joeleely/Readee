import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/typography.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;

class BookCard extends StatefulWidget {
  const BookCard(
      {super.key,
      required this.books,
      required this.userID,
      required this.onLike});
  final List<BookDetails> books;
  final int userID;
  final Function(int, bool) onLike;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  Map<int, bool> bookStatuses = {};
  List<int> likedIndices = []; // List to store the indices of liked books
  List<int> unlikedIndices = []; // List to store the indices of unliked books
  MatchEngine? _matchEngine;
  Map<BookDetails, int> currentPhotoMap =
      {}; // Track currentPhoto for each book

  @override
  void initState() {
    super.initState();

    // Initialize SwipeItems with Book details
    for (var i = 0; i < widget.books.length; i++) {
      BookDetails book = widget.books[i];
      _swipeItems.add(SwipeItem(
        content: book,
        likeAction: () async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Liked ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
          setState(() {
            likedIndices.add(i);
            bookStatuses[book.bookId] = true; // Update bookStatuses
            print("Liked books indices: $likedIndices");
          });
          await _likeBook(widget.userID, book.bookId);
        },
        nopeAction: () async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Nope ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
          setState(() {
            unlikedIndices.add(i);
            bookStatuses[book.bookId] = false; // Update bookStatuses
            print("Unliked books indices: $unlikedIndices");
          });
          await _unlikeBook(widget.userID, book.bookId);
        },
      ));
      // Initialize currentPhoto for each book to 0
      currentPhotoMap[book] = 0;
    }
    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  Future<void> _likeBook(int userId, int bookId) async {
    widget.onLike(bookId, true);
    final url = Uri.parse('http://localhost:3000/books/$bookId/like/$userId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 201) {
        print("Successfully liked the book!");
      } else {
        print("Failed to like the book: ${response.statusCode}");
      }
    } catch (e) {
      print("Error liking the book: $e");
    }
  }

  Future<void> _unlikeBook(int userId, int bookId) async {
    widget.onLike(bookId, false);
    final url = Uri.parse('http://localhost:3000/books/$bookId/unlike/$userId');
    try {
      final response = await http.post(url);
      if (response.statusCode == 201) {
        print("Successfully unliked the book!");
      } else {
        print("Failed to unlike the book: ${response.statusCode}");
      }
    } catch (e) {
      print("Error unliking the book: $e");
    }
  }

  void _reportBook(BookDetails book, int userId) async {
    final url =
        Uri.parse("http://localhost:3000/report/$userId/${book.bookId}");

    try {
      // Send a POST request
      final response = await http.post(url);

      // Check if the request was successful
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Successfully reported ${book.title}."),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Failed to report ${book.title}. Error: ${response.statusCode}"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Handle any network or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred while reporting ${book.title}: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SwipeCards(
        matchEngine: _matchEngine!,
        itemBuilder: (context, i) {
          BookDetails book = _swipeItems[i].content;
          int numberPhoto = book.img.length;

          // Get current photo for this specific book
          int currentPhoto = currentPhotoMap[book] ?? 0;

          return Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
            child: Hero(
              tag: "imageTag$i",
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        // Check if the image is a URL or base64
                        image: book.img[currentPhoto].startsWith('http')
                            ? NetworkImage(book.img[currentPhoto])
                            : MemoryImage(
                                    _convertBase64Image(book.img[currentPhoto]))
                                as ImageProvider<Object>,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black87],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            book.title,
                            style: TypographyText.h2(Colors.white),
                            maxLines: 2,
                          ),
                          SizedBox(height: 10),
                          Text(
                            book.author,
                            style: TypographyText.b4(Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 15,
                    right: 10,
                    child: GestureDetector(
                      behavior: HitTestBehavior
                          .deferToChild, // Ensures taps are passed to child widgets
                      onTap:
                          () {}, // Prevent GestureDetector from intercepting this area
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'report') {
                              // Handle report action
                              _reportBook(book, widget.userID);
                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: 'report',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber,
                                      color: Colors.red, // Red icon color
                                    ),
                                    SizedBox(
                                        width:
                                            8), // Space between icon and text
                                    Text(
                                      'Report',
                                      style: TextStyle(
                                        color: Colors.red, // Red text color
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 20,
                        height: 5,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: numberPhoto,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, int i) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                width: ((MediaQuery.of(context).size.width -
                                        (20 + ((numberPhoto + 1) * 8))) /
                                    book.img.length),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white, width: 0.5),
                                  color: currentPhoto == i
                                      ? Colors.white
                                      : Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: TypographyText.h2(Colors.white),
                                  maxLines: 2,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.6),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(
                                        book.quality,
                                        style: TypographyText.h4(Colors.white),
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                onPressed: () {
                                  _matchEngine!.currentItem?.nope();
                                  // _unlikeBook(
                                  //     widget.userID,
                                  //     MatchEngine()
                                  //         .currentItem!
                                  //         .content
                                  //         .bookId);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  padding: EdgeInsets.all(15),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.red, size: 40),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _matchEngine!.currentItem?.like();
                                  // _likeBook(
                                  //     widget.userID,
                                  //     MatchEngine()
                                  //         .currentItem!
                                  //         .content
                                  //         .bookId);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(15),
                                  backgroundColor: Colors.white,
                                ),
                                child: Icon(Icons.favorite,
                                    color: Colors.greenAccent[400], size: 40),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          onStackFinished: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Stack Finished"),
              duration: Duration(milliseconds: 500),
            ));
          },
        ),
      ),
    );
  }
}
