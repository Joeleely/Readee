import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readee_app/features/match/model/book_details.dart';
import 'package:readee_app/features/match/pages/book_info.dart';
import 'package:readee_app/features/match_list/bookDetail.dart';
import 'package:readee_app/features/match_list/matchedList.dart';
import 'package:readee_app/features/match_list/model/matches.dart';

class MatchListPage extends StatefulWidget {
  @override
  State<MatchListPage> createState() => _MatchListPageState();
}

class _MatchListPageState extends State<MatchListPage> {
  List<BookDetails> ownerBooks = [];

  final int userID = 7;

  Uint8List _convertBase64Image(String base64String) {
    // Remove the prefix if it exists
    String base64Data = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(base64Data);
  }

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
      List<BookDetails> fetchedOwnerBooks = [];

      for (var match in matches) {
        // print('Matches Response: ${matchesResponse.body}');

        final ownerBookResponse = await http.get(
            Uri.parse('http://localhost:3000/getBook/${match.ownerBookId}'));
        if (ownerBookResponse.statusCode == 200) {
          final bookJson = json.decode(ownerBookResponse.body);

          var bookDetails = BookDetails(
              bookId: bookJson['BookId'] ?? '',
              title: bookJson['BookName'] ?? 'Unknown Title',
              author: bookJson['Author'] ?? 'Unknown Author',
              img: [bookJson['BookPicture'] ?? ''],
              description:
                  bookJson['BookDescription'] ?? 'No description available',
              quality: '${bookJson['Quality'] ?? '0'}%',
              genre: bookJson['Genre'] ?? '');

          bool isDuplicate = fetchedOwnerBooks.any((book) => book.bookId == bookDetails.bookId);

          if (!isDuplicate) {
            fetchedOwnerBooks.add(bookDetails);
          } else {
            print('Duplicate book found: ${bookDetails.title}, skipping...');
          }

          print('Book added: ${bookDetails.title}');
        } else {
          print('Failed to load book for ID: ${match.matchedBookId}');
        }
      }

      setState(() {
        ownerBooks = fetchedOwnerBooks; // Store the fetched books
      });
    } catch (error) {
      print('Error fetching matched books: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Match'),
        backgroundColor: const Color.fromARGB(255, 243, 252, 255),
      ),
      body: ownerBooks.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading spinner when fetching data
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                itemCount: ownerBooks.length,
                itemBuilder: (context, index) {
                  final book = ownerBooks[index];
                  return Column(
                    children: [
                      InkWell(
                        onTap: () {
                          // Navigate to the book info page when clicked
                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => BookDetailPage(
                          //       bookId: book.bookId, userId: userID),
                          // ));
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MatchedList()),
                          );
                        },
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                // Check if the image is a URL or base64
                                image: book.img[0].startsWith('http')
                                    ? NetworkImage(book.img[0])
                                    : MemoryImage(
                                            _convertBase64Image(book.img[0]))
                                        as ImageProvider<Object>,
                              ),
                            ),
                          ),
                          title: Text(book.title),
                          subtitle: Text(book.author),
                        ),
                      ),
                      const Divider()
                    ],
                  );
                },
              ),
            ),
    );
  }
}
