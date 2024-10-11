import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/features/match_list/model/matches.dart';

class MatchListPage extends StatefulWidget {
  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<Book> books = [];
  final int userID = 2;

  @override
  void initState() {
    super.initState();
    fetchMatchedBooks(); // Fetch books when the page initializes
  }

  Future<void> fetchMatchedBooks() async {
    try {
      // Step 1: Get matches for the user
      final matchesResponse =
          await http.get(Uri.parse('http://localhost:3000/getMatches/$userID'));
      List<Matches> matches = [];

      if (matchesResponse.statusCode == 200) {
        final matchesData = json.decode(matchesResponse.body);
        matches = (matchesData['matches'] as List)
            .map((matchJson) => Matches.fromJson(matchJson))
            .toList();
      } else {
        throw Exception('Failed to load matches');
      }

      // Step 2: Fetch books based on matches
      List<Book> fetchedBooks = [];

      for (var match in matches) {
        // print('Matches Response: ${matchesResponse.body}');

        final bookResponse = await http.get(
            Uri.parse('http://localhost:3000/getBook/${match.ownerBookId}'));
        if (bookResponse.statusCode == 200) {
          final bookJson = json.decode(bookResponse.body);
          fetchedBooks.add(Book(
              bookId: bookJson['BookId'] ?? '',
              title: bookJson['BookName'] ?? 'Unknown Title',
              author: bookJson['Author'] ?? 'Unknown Author',
              img: [
                bookJson['BookPicture'] ?? '',
              ],
              description:
                  bookJson['BookDescription'] ?? 'No description available',
              quality: '${bookJson['Quality'] ?? '0'}%',
              genre: bookJson['Genre'] ?? ''));

              
        } else {
          print('Failed to load book for ID: ${match.matchedBookId}');
        }
      }

      setState(() {
        books = fetchedBooks; // Store the fetched books
      });
    } catch (error) {
      print('Error fetching matched books: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Match'),
      ),
      body: books.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner when fetching data
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigate to the book info page when clicked
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookInfoPage(book: book),
                          ));
                        },
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(
                                image: NetworkImage(book.img[0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BookInfoPage(book: book),
                            ));
                          }, // Navigate to partner book
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: ListTile(
                              leading: Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    image: DecorationImage(
                                        image: NetworkImage(book.img[0]),
                                        fit: BoxFit.cover)),
                              ),
                              title: Text(book.title),
                              subtitle: Text(book.author),
                            ),
                          )),
                      const Divider()
                    ],
                  );
                },
              ),
            ),
    );
  }
}

class BookInfoPage extends StatelessWidget {
  final Book book;

  BookInfoPage({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              book.img[0],
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),
            Text(
              book.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Author: ${book.author}'),
            const SizedBox(height: 16),
            Text('Quality: ${book.quality}'),
            const SizedBox(height: 16),
            Text('Description: ${book.description}'),
          ],
        ),
      ),
    );
  }
}
