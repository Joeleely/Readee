import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/typography.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;

class BookCard extends StatefulWidget {
  const BookCard({super.key, required this.books, required this.userID});
  final List<BookDetails> books;
  final int userID;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  MatchEngine? _matchEngine;
  Map<BookDetails, int> currentPhotoMap =
      {}; // Track currentPhoto for each book

  @override
  void initState() {
    super.initState();

    // Initialize SwipeItems with Book details
    for (var book in widget.books) {
      _swipeItems.add(SwipeItem(
        content: book,
        likeAction: () async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Liked ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
          await _likeBook(widget.userID, book.bookId);
        },
        nopeAction: () async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Nope ${book.title}"),
            duration: const Duration(milliseconds: 500),
          ));
          await _unlikeBook(widget.userID, book.bookId);
        },
      ));
      // Initialize currentPhoto for each book to 0
      currentPhotoMap[book] = 0;
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  Uint8List _convertBase64Image(String base64String) {
    // Remove the prefix if it exists
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

  Future<void> _likeBook(int userId, int bookId) async {
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

  void _reportBook(BookDetails book) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Reported ${book.title}"),
        duration: const Duration(seconds: 2),
      ),
    );
    // Add logic to handle reporting the book, such as sending a request to the backend.
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
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
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
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print('Left Tapped');
                            if (book.img.length > 1 && currentPhoto > 0) {
                              setState(() {
                                currentPhotoMap[book] = currentPhoto - 1;
                                print(
                                    'numberPhoto: $numberPhoto, currentPhoto: $currentPhoto');
                              });
                            }
                          },
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            print('current photo index $currentPhoto');
                            print('Right Tapped');
                            if (book.img.length > 1) {
                              setState(() {
                                currentPhotoMap[book] =
                                    (currentPhoto + 1) % numberPhoto;
                                print(
                                    'numberPhoto: $numberPhoto, currentPhoto: ${currentPhotoMap[book]}');
                              });
                            }
                          },
                          child: Container(
                            decoration:
                                const BoxDecoration(color: Colors.transparent),
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
                              _reportBook(book);
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
                                        width: 8), // Space between icon and text
                                    Text('Report',
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
                                  Navigator.of(context)
                                      .push(_createRoute(book));
                                },
                                icon: const Icon(
                                  Icons.info_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        ),
                        Text(
                          book.author,
                          style: TypographyText.b4(Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book.description,
                          style:
                              TypographyText.b3(Colors.white.withOpacity(0.8)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _matchEngine!.currentItem?.nope();
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
        itemChanged: (SwipeItem item, int index) {
          print("Book: ${item.content.title}, index: $index");
        },
        leftSwipeAllowed: true,
        rightSwipeAllowed: true,
        upSwipeAllowed: false,
        fillSpace: true,
      ),
    );
  }
}

Route _createRoute(BookDetails book) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        BookInfoPage(book: book),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
