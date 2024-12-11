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

  Uint8List _convertBase64Image(String base64String) {
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

  ImageProvider<Object> _getImageProvider(String imageString) {
    if (imageString.startsWith('http') || imageString.startsWith('https')) {
      return NetworkImage(imageString);
    } else {
      try {
        Uint8List bytes = base64Decode(imageString);
        return MemoryImage(bytes);
      } catch (e) {
        print("Error decoding Base64: $e");
        return AssetImage('assets/placeholder.png');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: SwipeCards(
          matchEngine: _matchEngine!,
          itemBuilder: (context, i) {
            BookDetails book = _swipeItems[i].content;
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
              child: Hero(
                tag: "imageTag$i",
                child: Stack(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: _getImageProvider(book.img),
                        ),
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
                          const SizedBox(height: 5),
                          Text(
                            book.description,
                            style: TypographyText.b3(
                                Colors.white.withOpacity(0.8)),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
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
