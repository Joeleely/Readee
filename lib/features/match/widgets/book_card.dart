import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:http/http.dart' as http;
import 'package:swipe_cards/swipe_cards.dart';

class BookCard extends StatefulWidget {
  const BookCard({
    super.key,
    required this.books,
    required this.userID,
    required this.onLike,
  });

  final List<BookDetails> books;
  final int userID;
  final Function(int, bool) onLike;

  @override
  State<BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  final List<SwipeItem> _swipeItems = <SwipeItem>[];
  Map<int, bool> bookStatuses = {};
  List<int> likedIndices = [];
  List<int> unlikedIndices = [];
  MatchEngine? _matchEngine;

  @override
  void initState() {
    super.initState();

    // Initialize SwipeItems
    for (var i = 0; i < widget.books.length; i++) {
      BookDetails book = widget.books[i];
      _swipeItems.add(SwipeItem(
        content: book,
        likeAction: () => _handleLike(book, i),
        nopeAction: () => _handleUnlike(book, i),
      ));
    }

    _matchEngine = MatchEngine(swipeItems: _swipeItems);
  }

  void _handleLike(BookDetails book, int index) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Liked ${book.title}"),
      duration: const Duration(milliseconds: 500),
    ));

    setState(() {
      likedIndices.add(index);
      bookStatuses[book.bookId] = true;
    });

    await _likeBook(widget.userID, book.bookId);
    widget.onLike(book.bookId, true);
  }

  void _handleUnlike(BookDetails book, int index) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Nope ${book.title}"),
      duration: const Duration(milliseconds: 500),
    ));

    setState(() {
      unlikedIndices.add(index);
      bookStatuses[book.bookId] = false;
    });

    await _unlikeBook(widget.userID, book.bookId);
    widget.onLike(book.bookId, false);
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

  void _reportBook(BookDetails book) async {
    final url = Uri.parse(
        "http://localhost:3000/report/${widget.userID}/${book.bookId}");
    try {
      final response = await http.post(url);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Successfully reported ${book.title}."),
          duration: const Duration(seconds: 2),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Failed to report ${book.title}. Error: ${response.statusCode}"),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("An error occurred while reporting ${book.title}: $e"),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        child: SwipeCards(
          matchEngine: _matchEngine!,
          itemBuilder: (context, index) {
            BookDetails book = _swipeItems[index].content;
            return Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: book.img.isNotEmpty
                          ? DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(book.img),
                            )
                          : const DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage('assets/placeholder.png'),
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
                  Positioned(
                    top: 15,
                    right: 10,
                    child: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'report') {
                          _reportBook(book);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return [
                          const PopupMenuItem<String>(
                            value: 'report',
                            child: Text('Report'),
                          ),
                        ];
                      },
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
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
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          book.author,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          onStackFinished: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("No more books available."),
              duration: Duration(milliseconds: 500),
            ));
          },
        ),
      ),
    );
  }
}
