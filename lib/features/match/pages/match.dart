import 'dart:math';

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/widgets/book_card.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  int offset = 0;
  int limit = 10;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    fetchBooks();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !isLoading) {
      fetchBooks(); // Load more books
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks() async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/books/recommendations/${widget.userID}?offset=$offset&limit=$limit&random=true'));

    if (response.statusCode == 200) {
      final List<dynamic> booksData = jsonDecode(response.body)['books'];
      List<BookDetails> newBooks =
          booksData.map((book) => BookDetails.fromJson(book)).toList();

      if (mounted) {
        setState(() {
          books.addAll(newBooks); // Append new books
          offset += limit; // Update offset for pagination
          isLoading = false;
        });
      }
    } else {
      throw Exception('Failed to load books');
    }
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
                          "No more book to show, wait for other to post the book"))
                  : ListView.builder(
                      controller: _scrollController, // Attach the controller
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          //book: books[index],
                          userID: widget.userID,
                          books: books,
                        );
                      },
                    )),
    );
  }
}
